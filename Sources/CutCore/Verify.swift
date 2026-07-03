import CutModels

// docs/04 §5 — placementsHash: FNV-1a 64-bit, kanonik serileştirme
// `partId|sheetIndex|x|y|w|h|r;` (motor çıkış sırası), 16 haneli küçük-harf hex.
// FNV çarpması bilinçli sarmal (&*): UInt64 modular aritmetiği her platformda bit-eşit.
public func placementsHash(_ placements: [Placement]) -> String {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for p in placements {
        let line = "\(p.partId)|\(p.sheetIndex)|\(p.x)|\(p.y)|\(p.w)|\(p.h)|\(p.rotated ? 1 : 0);"
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
private func isGuillotineCuttable(_ rects: [PlacedRect]) -> Bool {
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
        if isGuillotineCuttable(left) && isGuillotineCuttable(right) { return true }
    }
    for line in yLines.sorted() {
        guard !rects.contains(where: { $0.y < line && line < $0.y + $0.h }) else { continue }
        let below = rects.filter { $0.y + $0.h <= line }
        let above = rects.filter { $0.y >= line }
        guard !below.isEmpty, !above.isEmpty else { continue }
        if isGuillotineCuttable(below) && isGuillotineCuttable(above) { return true }
    }
    return false
}

// docs/04 §5/§7 — değişmez doğrulayıcı: çakışma, sınır, guillotine-geçerlilik.
// kerf mesafe kontrolü (§5 madde 4) E1-S2'de eklenir.
public func verifyInvariants(_ res: OptimizeResult, req: OptimizeRequest) -> [InvariantViolation] {
    var violations: [InvariantViolation] = []
    var partMaterial: [String: String] = [:]
    for p in req.parts where partMaterial[p.id] == nil { partMaterial[p.id] = p.materialId }

    let bySheet = Dictionary(grouping: res.placements, by: \.sheetIndex)
    for (sheet, ps) in bySheet.sorted(by: { $0.key < $1.key }) {
        // Levha boyutu: sonuç şeması sheetIndex→stok eşlemesi taşımadığından (docs/05),
        // aynı-malzeme stokların azami w/h'si kullanılır — tek-tip stokta birebir,
        // karışık boylarda muhafazakâr üst sınır. Kesin eşleme şema eki ister (önce sor).
        let material = ps.first.flatMap { partMaterial[$0.partId] }
        let candidates = req.stocks.filter { material == nil || $0.materialId == material }
        let maxW = candidates.map(\.w).max() ?? 0
        let maxH = candidates.map(\.h).max() ?? 0

        for p in ps where p.x < 0 || p.y < 0 || p.x + p.w > maxW || p.y + p.h > maxH {
            violations.append(.init(kind: .outOfBounds, sheetIndex: sheet, subjectIds: [p.partId],
                                    message: "parca levha siniri disina tasiyor"))
        }
        for (i, a) in ps.enumerated() {
            for b in ps[(i + 1)...]
            where a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h {
                violations.append(.init(kind: .overlap, sheetIndex: sheet,
                                        subjectIds: [a.partId, b.partId], message: "parcalar cakisiyor"))
            }
        }
        let rects = ps.map { PlacedRect(partId: $0.partId, x: $0.x, y: $0.y, w: $0.w, h: $0.h) }
        if !isGuillotineCuttable(rects) {
            violations.append(.init(kind: .notGuillotine, sheetIndex: sheet,
                                    subjectIds: ps.map(\.partId),
                                    message: "yerlesimden kesim agaci yeniden insa edilemiyor"))
        }
    }
    return violations
}
