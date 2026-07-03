import CutModels

// partId serileştirmede ayırıcılarla çakışamaz: '\', '|', ';' ters bölü ile kaçışlanır —
// serileştirme enjektif kalır, ayırıcısız id'lerin hash'i değişmez (docs/04 §5).
func escaped(_ id: String) -> String {
    var out = ""
    for ch in id {
        let s = String(ch)
        if s == "\\" || s == "|" || s == ";" { out += "\\" }
        out += s
    }
    return out
}

// UTF-8 baytları (K-30): spec (docs/04 §5) UTF-8 ister — hash'ler platformlar arası sabit.
// Swift tarafı stdlib .utf8; Kotlin tarafı (#if SKIP) dilin kendi UTF-8 kodlayıcısı —
// ikisi de aynı bayt dizisini üretir, golden hash'ler bunun kanıtıdır.
private func utf8Bytes(_ s: String) -> [UInt8] {
    #if SKIP
    var bytes: [UInt8] = []
    let arr = s.toByteArray(Charsets.UTF_8)
    for b in arr {
        bytes.append(b.toUByte())
    }
    return bytes
    #else
    return Array(s.utf8)
    #endif
}

// docs/04 §5 — placementsHash: FNV-1a 64-bit, kanonik serileştirme
// `partId|sheetIndex|x|y|w|h|r;` (motor çıkış sırası), 16 haneli küçük-harf hex.
// FNV çarpması bilinçli sarmal (&*): UInt64 modular aritmetiği her platformda bit-eşit.
// FNV-1a 64 çekirdeği — 2D ve 1D kanonik satırları aynı sabitlerle özetler (docs/04 §5).
func canonicalFNVHex(_ lines: [String]) -> String {
    // Sabitler iki 32-bit yarıdan kurulur; bileşik atama yok — Kotlin/Skip uyumu (K-30).
    var hash: UInt64 = (UInt64(0xcbf2_9ce4) << 32) | UInt64(0x8422_2325)
    let prime: UInt64 = UInt64(0x0000_0100) << 32 | UInt64(0x0000_01b3)
    for line in lines {
        let bytes = utf8Bytes(line)
        for byte in bytes {
            hash = hash ^ UInt64(byte)
            hash = hash &* prime
        }
    }
    // 16 hane küçük-harf hex, elle: String(_:radix:) Skip'te ULong için yok.
    let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
    var hex = ""
    var value = hash
    for _ in 0..<16 {
        let nibble = Int(value & UInt64(15))
        hex = digits[nibble] + hex
        value = value >> 4
    }
    return hex
}

public func placementsHash(_ placements: [Placement]) -> String {
    var lines: [String] = []
    for p in placements {
        lines.append("\(escaped(p.partId))|\(p.sheetIndex)|\(p.x)|\(p.y)|\(p.w)|\(p.h)|\(p.rotated ? 1 : 0);")
    }
    return canonicalFNVHex(lines)
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
// çakışma, kerf mesafeleri (§5 madde 4, E1-S2), trim'li sınır, guillotine-geçerlilik.
public func verifyInvariants(_ res: OptimizeResult, req: OptimizeRequest) -> [InvariantViolation] {
    var violations: [InvariantViolation] = []
    var partMaterial: [String: String] = [:]
    for p in req.parts where partMaterial[p.id] == nil { partMaterial[p.id] = p.materialId }

    var bySheet: [Int: [Placement]] = [:]
    for p in res.placements {
        var arr = bySheet[p.sheetIndex] ?? []
        arr.append(p)
        bySheet[p.sheetIndex] = arr
    }
    for sheet in bySheet.keys.sorted() {
        let ps = bySheet[sheet] ?? []
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
            // Kullanılabilir alan = stok − 2·trim (docs/04 §3 4a); trim payına taşma ihlaldir.
            if p.x < req.trim || p.y < req.trim
                || p.x + p.w > maxW - req.trim || p.y + p.h > maxH - req.trim {
                violations.append(.init(kind: .outOfBounds, sheetIndex: sheet,
                                        subjectIds: [p.partId], message: "parca kullanilabilir alan disina tasiyor (trim dahil)"))
            }
        }
        for i in 0..<geometric.count {
            let a = geometric[i]
            for j in (i + 1)..<geometric.count {
                let b = geometric[j]
                let xOverlap = a.x < b.x + b.w && b.x < a.x + a.w
                let yOverlap = a.y < b.y + b.h && b.y < a.y + a.h
                if xOverlap && yOverlap {
                    violations.append(.init(kind: .overlap, sheetIndex: sheet,
                                            subjectIds: [a.partId, b.partId], message: "parcalar cakisiyor"))
                    continue
                }
                // Kerf mesafesi (docs/04 §5 madde 4): bir eksende izdüşümleri örtüşen iki
                // parça, guillotine ağacında o eksene dik bir kesimle ayrılmak zorundadır —
                // aradaki boşluk kerf'ten küçük olamaz. Çapraz çiftlerde doğrudan kısıt yok.
                guard req.kerf > 0 else { continue }
                let gap: Units
                if yOverlap {
                    gap = max(b.x - (a.x + a.w), a.x - (b.x + b.w))
                } else if xOverlap {
                    gap = max(b.y - (a.y + a.h), a.y - (b.y + b.h))
                } else {
                    continue
                }
                if gap < req.kerf {
                    violations.append(.init(kind: .kerfViolation, sheetIndex: sheet,
                                            subjectIds: [a.partId, b.partId],
                                            message: "komsu parcalar arasindaki bosluk kerf'ten kucuk"))
                }
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
