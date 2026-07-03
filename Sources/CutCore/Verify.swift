import CutModels

// partId serileştirmede ayırıcılarla çakışamaz: '\', '|', ';' ters bölü ile kaçışlanır —
// serileştirme enjektif kalır, ayırıcısız id'lerin hash'i değişmez (docs/04 §5).
private func escaped(_ id: String) -> String {
    var out = ""
    for ch in id {
        if ch == "\\" || ch == "|" || ch == ";" { out.append("\\") }
        out.append(ch)
    }
    return out
}

// docs/04 §5 — placementsHash: FNV-1a 64-bit, kanonik serileştirme
// `partId|sheetIndex|x|y|w|h|r;` (motor çıkış sırası), 16 haneli küçük-harf hex.
// FNV çarpması bilinçli sarmal (&*): UInt64 modular aritmetiği her platformda bit-eşit.
public func placementsHash(_ placements: [Placement]) -> String {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for p in placements {
        let line = "\(escaped(p.partId))|\(p.sheetIndex)|\(p.x)|\(p.y)|\(p.w)|\(p.h)|\(p.rotated ? 1 : 0);"
        for byte in line.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
    }
    let hex = String(hash, radix: 16)
    return String(repeating: "0", count: 16 - hex.count) + hex
}

private struct PlacedRect {
    let partId: String
    let x: Units, y: Units, w: Units, h: Units
}

// Guillotine-geçerlilik = kesim ağacının yeniden inşası (docs/04 §5 madde 3): bir tam kesim
// çizgisi hiçbir parçanın İÇİNDEN geçmeden kümeyi iki boş-olmayan gruba ayırabiliyorsa ve
// her grup da özyinelemeli kesilebiliyorsa geçerli. Bir yanı boş kesimler (kenar firesi)
// doğrulama için gereksizdir: parçalar hangi alt bölgedeyse aynı kesim dizisi tam bölgede
// de geçerli kalır — bu yüzden aday çizgiler yalnız parça kenarlarından gelir. n ≤ 1 geçerli.
// Ön koşul: tüm dikdörtgenler pozitif boyutlu (verifyInvariants dejenereleri önden eler);
// pozitif boyutta iki grup ayrıktır ve kesin küçülür — sonlanma garantili.
//
// Arama bütçesi: guillotine-kesilebilir kümenin her alt kümesi de kesilebilir olduğundan
// geçerli yerleşimde geri-izleme hiç olmaz ve çağrı sayısı ≤ 2n−1'dir. Bütçe bunun çok
// üstünde tutulur; aşım ancak geri-izlemeyle (yani geçersiz yerleşimle) mümkündür — erken
// false SAĞLAMDIR ve çok sayıda bağımsız geçersiz kümede üstel patlamayı keser.
private func isGuillotineCuttable(_ rects: [PlacedRect]) -> Bool {
    var budget = max(1024, 8 * rects.count)
    return isGuillotineCuttable(rects, budget: &budget)
}

private func isGuillotineCuttable(_ rects: [PlacedRect], budget: inout Int) -> Bool {
    budget -= 1
    if budget < 0 { return false } // yalnız geri-izleme tüketebilir ⇒ geçersiz yerleşim
    if rects.count <= 1 { return true }
    var xLines: Set<Units> = []
    var yLines: Set<Units> = []
    for r in rects {
        xLines.insert(r.x); xLines.insert(r.x + r.w)
        yLines.insert(r.y); yLines.insert(r.y + r.h)
    }
    for line in xLines.sorted() {
        guard !rects.contains(where: { $0.x < line && line < $0.x + $0.w }) else { continue }
        let left = rects.filter { $0.x + $0.w <= line }
        let right = rects.filter { $0.x >= line }
        guard !left.isEmpty, !right.isEmpty else { continue }
        if isGuillotineCuttable(left, budget: &budget) && isGuillotineCuttable(right, budget: &budget) { return true }
    }
    for line in yLines.sorted() {
        guard !rects.contains(where: { $0.y < line && line < $0.y + $0.h }) else { continue }
        let below = rects.filter { $0.y + $0.h <= line }
        let above = rects.filter { $0.y >= line }
        guard !below.isEmpty, !above.isEmpty else { continue }
        if isGuillotineCuttable(below, budget: &budget) && isGuillotineCuttable(above, budget: &budget) { return true }
    }
    return false
}

// docs/04 §5/§7 — değişmez doğrulayıcı: dejenere boyut, katalog tutarlılığı, sınır,
// çakışma, guillotine-geçerlilik. kerf mesafe kontrolü (§5 madde 4) E1-S2'de eklenir.
public func verifyInvariants(_ res: OptimizeResult, req: OptimizeRequest) -> [InvariantViolation] {
    var violations: [InvariantViolation] = []
    var partMaterial: [String: String] = [:]
    for p in req.parts where partMaterial[p.id] == nil { partMaterial[p.id] = p.materialId }

    let bySheet = Dictionary(grouping: res.placements, by: \.sheetIndex)
    for (sheet, ps) in bySheet.sorted(by: { $0.key < $1.key }) {
        // Geometrik kontrollere yalnız pozitif boyutlu yerleşimler girer; dejenereler
        // ihlal olarak raporlanır (aksi halde guillotine aramasında küme küçülmez).
        var geometric: [Placement] = []
        for p in ps {
            guard p.w > 0 && p.h > 0 else {
                violations.append(.init(kind: .nonPositiveSize, sheetIndex: sheet,
                                        subjectIds: [p.partId], message: "yerlesim boyutu pozitif degil"))
                continue
            }
            geometric.append(p)
            // Sınır: her yerleşimin KENDİ malzemesinin azami stok boyutuna karşı.
            // sheetIndex→stok eşlemesi şemada taşınmadığından (docs/05) bu muhafazakâr
            // bir üst sınırdır — tek-tip stokta birebir. Kesin eşleme şema eki ister (önce sor).
            guard let material = partMaterial[p.partId] else {
                violations.append(.init(kind: .unknownPart, sheetIndex: sheet,
                                        subjectIds: [p.partId], message: "partId istek kataloğunda yok"))
                continue
            }
            let candidates = req.stocks.filter { $0.materialId == material }
            let maxW = candidates.map(\.w).max() ?? 0
            let maxH = candidates.map(\.h).max() ?? 0
            if p.x < 0 || p.y < 0 || p.x + p.w > maxW || p.y + p.h > maxH {
                violations.append(.init(kind: .outOfBounds, sheetIndex: sheet,
                                        subjectIds: [p.partId], message: "parca levha siniri disina tasiyor"))
            }
        }
        for (i, a) in geometric.enumerated() {
            for b in geometric[(i + 1)...]
            where a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h {
                violations.append(.init(kind: .overlap, sheetIndex: sheet,
                                        subjectIds: [a.partId, b.partId], message: "parcalar cakisiyor"))
            }
        }
        let rects = geometric.map { PlacedRect(partId: $0.partId, x: $0.x, y: $0.y, w: $0.w, h: $0.h) }
        if !isGuillotineCuttable(rects) {
            violations.append(.init(kind: .notGuillotine, sheetIndex: sheet,
                                    subjectIds: geometric.map(\.partId),
                                    message: "yerlesimden kesim agaci yeniden insa edilemiyor"))
        }
    }
    return violations
}
