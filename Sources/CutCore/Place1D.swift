import CutModels

// docs/04 §4 — 1D motor (E2-S1): FFD + küçük-n branch-and-bound.
// Kerf/uç kuralı: parça sonunda malzeme kalıyorsa 1 kesim + kerf; stok ucuna tam gelen
// parçada kesim yok. Determinizm: kararlı sıralama, RNG yok, B&B sınırı düğüm bütçesi.

// UI ön-doğrulama — 2D validate ile aynı tür sözlüğü (docs/04 §3 adım 1 + §2 motor sınırları).
public func validate1D(_ req: Optimize1DRequest) -> [ValidationIssue] {
    var issues: [ValidationIssue] = []
    if req.kerf < 0 {
        issues.append(.init(kind: .negativeKerfOrTrim, subjectId: "request", message: "kerf >= 0 olmali"))
    }
    if req.kerf > maxDimension {
        issues.append(.init(kind: .dimensionTooLarge, subjectId: "request", message: "kerf <= 10^8 birim olmali (04 §2)"))
    }
    var materialIds: Set<String> = []
    var lengthBudget = maxTotalStockArea // 1D'de Σ boy·adet sınırı (aynı tavan, fazlasıyla genis)
    var budgetExceeded = false
    for s in req.stocks {
        var lengthValid = true
        if s.length <= 0 {
            issues.append(.init(kind: .nonPositiveDimension, subjectId: s.id, message: "stok boyu > 0 olmali")); lengthValid = false
        } else if s.length > maxDimension {
            issues.append(.init(kind: .dimensionTooLarge, subjectId: s.id, message: "stok boyu <= 10^8 birim olmali (04 §2)")); lengthValid = false
        }
        if s.qty < 1 { issues.append(.init(kind: .nonPositiveQuantity, subjectId: s.id, message: "stok adedi >= 1 olmali")) }
        materialIds.insert(s.materialId)
        if lengthValid && s.qty >= 1 && !budgetExceeded {
            if s.length > lengthBudget / Units(s.qty) {
                budgetExceeded = true
            } else {
                lengthBudget -= s.length * Units(s.qty)
            }
        }
    }
    if budgetExceeded {
        issues.append(.init(kind: .totalStockAreaTooLarge, subjectId: "request", message: "toplam stok boyu siniri asildi (04 §2)"))
    }
    for p in req.parts {
        if p.length <= 0 { issues.append(.init(kind: .nonPositiveDimension, subjectId: p.id, message: "parca boyu > 0 olmali")); continue }
        if p.length > maxDimension { issues.append(.init(kind: .dimensionTooLarge, subjectId: p.id, message: "parca boyu <= 10^8 birim olmali (04 §2)")); continue }
        if p.qty < 1 { issues.append(.init(kind: .nonPositiveQuantity, subjectId: p.id, message: "parca adedi >= 1 olmali")) }
        if !materialIds.contains(p.materialId) {
            issues.append(.init(kind: .unknownMaterial, subjectId: p.id, message: "parcanin malzemesi stoklarda yok"))
            continue
        }
        var fits = false
        for s in req.stocks {
            if s.materialId == p.materialId && p.length <= s.length { fits = true; break }
        }
        if !fits { issues.append(.init(kind: .partExceedsStock, subjectId: p.id, message: "parca hicbir stok boyuna sigmiyor")) }
    }
    return issues
}

struct Run1D {
    var placements: [Placement1D]
    var unplaced: [String]
    var stockCount: Int
    var totalStockLength: Units
    var usedLength: Units
    var cutCount: Int
}

private struct Instance1D {
    let part: Part1D
    let ordinal: Int
}

private struct OpenBar {
    let materialId: String
    let length: Units
    var usedEnd: Units
}

private struct BarPool {
    let stock: Stock1D
    var remaining: Int
}

// FFD — azalan boy sırala (kararlı: boy↓ → id↑ → örnek sırası), ilk sığan açık stoğa koy;
// sığmazsa istek sırasındaki ilk uygun stoktan yenisini aç; havuz bitti ise unplaced.
func ffd1D(_ req: Optimize1DRequest) -> Run1D {
    var instances: [Instance1D] = []
    for p in req.parts {
        for _ in 0..<p.qty { instances.append(Instance1D(part: p, ordinal: instances.count)) }
    }
    instances.sort { a, b in
        if a.part.length != b.part.length { return a.part.length > b.part.length }
        if a.part.id != b.part.id { return a.part.id < b.part.id }
        return a.ordinal < b.ordinal
    }

    var pools = req.stocks.map { BarPool(stock: $0, remaining: $0.qty) }
    var bars: [OpenBar] = []
    var placements: [Placement1D] = []
    var unplaced: [String] = []
    var totalStockLength: Units = 0
    var usedLength: Units = 0
    var cutCount = 0

    func commit(_ part: Part1D, barIndex: Int) {
        let offset = bars[barIndex].usedEnd
        placements.append(Placement1D(partId: part.id, stockIndex: barIndex,
                                      offset: offset, length: part.length))
        usedLength += part.length
        let end = offset + part.length
        if end == bars[barIndex].length {
            bars[barIndex].usedEnd = end // stok ucuna tam geldi — kesim yok (docs/04 §4)
        } else {
            bars[barIndex].usedEnd = end + req.kerf
            cutCount += 1
        }
    }

    for inst in instances {
        let part = inst.part
        var placedBar = -1
        for i in 0..<bars.count {
            if bars[i].materialId != part.materialId { continue }
            if bars[i].usedEnd + part.length <= bars[i].length { placedBar = i; break }
        }
        if placedBar >= 0 {
            commit(part, barIndex: placedBar)
            continue
        }
        var poolIndex = -1
        for i in 0..<pools.count {
            if pools[i].remaining > 0 && pools[i].stock.materialId == part.materialId
                && part.length <= pools[i].stock.length { poolIndex = i; break }
        }
        if poolIndex < 0 {
            unplaced.append(part.id)
            continue
        }
        pools[poolIndex].remaining -= 1
        let s = pools[poolIndex].stock
        bars.append(OpenBar(materialId: s.materialId, length: s.length, usedEnd: 0))
        totalStockLength += s.length
        commit(part, barIndex: bars.count - 1)
    }

    return Run1D(placements: placements, unplaced: unplaced, stockCount: bars.count,
                 totalStockLength: totalStockLength, usedLength: usedLength, cutCount: cutCount)
}

// Branch-and-bound — koşul: tek-tip stok boyu, benzersiz parça boyu ≤15, FFD'de unplaced yok,
// örnek sayısı ≤ 60. Sınır deterministik düğüm bütçesi (docs/04 §4); B&B yalnız FFD'den
// kesin az stokla çıkarsa benimsenir.
private let bnbNodeBudget = 300_000
private let bnbMaxInstances = 60
private let bnbMaxUniqueLengths = 15

private struct BnBState {
    var assignment: [Int]      // örnek → kutu indeksi
    var best: [Int]
    var bestCount: Int
    var nodes: Int
}

func branchAndBound1D(_ req: Optimize1DRequest, ffd: Run1D) -> Run1D? {
    guard ffd.unplaced.isEmpty else { return nil }
    guard let firstStock = req.stocks.first else { return nil }
    for s in req.stocks {
        if s.length != firstStock.length || s.materialId != firstStock.materialId { return nil }
    }
    var uniqueLengths: Set<Units> = []
    var instances: [Instance1D] = []
    for p in req.parts {
        uniqueLengths.insert(p.length)
        for _ in 0..<p.qty { instances.append(Instance1D(part: p, ordinal: instances.count)) }
    }
    if uniqueLengths.count > bnbMaxUniqueLengths || instances.count > bnbMaxInstances { return nil }
    instances.sort { a, b in
        if a.part.length != b.part.length { return a.part.length > b.part.length }
        if a.part.id != b.part.id { return a.part.id < b.part.id }
        return a.ordinal < b.ordinal
    }
    let barLength = firstStock.length
    let kerf = req.kerf

    var state = BnBState(assignment: Array(repeating: -1, count: instances.count),
                         best: [], bestCount: ffd.stockCount, nodes: 0)
    var barUsed: [Units] = [] // kutu başına usedEnd (kerf kuralı dahil)

    func place(_ idx: Int) {
        if state.nodes >= bnbNodeBudget { return }
        state.nodes += 1
        if barUsed.count >= state.bestCount { return } // budama: mevcut en iyiden kötü/eşit
        if idx == instances.count {
            state.bestCount = barUsed.count
            state.best = state.assignment
            return
        }
        let len = instances[idx].part.length
        var triedRemainders: Set<Units> = []
        for b in 0..<barUsed.count {
            let used = barUsed[b]
            if used + len > barLength { continue }
            if triedRemainders.contains(used) { continue } // simetri kırma: eşit-durum kutular
            triedRemainders.insert(used)
            let saved = used
            let end = used + len
            barUsed[b] = end == barLength ? end : end + kerf
            state.assignment[idx] = b
            place(idx + 1)
            barUsed[b] = saved
            state.assignment[idx] = -1
            if state.nodes >= bnbNodeBudget { return }
        }
        // yeni kutu (tek dal — kutular ayırt edilemez); +1 bile mevcut en iyiye ulaşıyorsa dal ölü
        if barUsed.count + 1 < state.bestCount {
            let end = len == barLength ? len : len + kerf
            barUsed.append(end)
            state.assignment[idx] = barUsed.count - 1
            place(idx + 1)
            barUsed.removeLast()
            state.assignment[idx] = -1
        }
    }
    place(0)

    guard state.bestCount < ffd.stockCount, state.best.count == instances.count else { return nil }
    guard state.bestCount <= req.stocks.reduce(0, { $0 + $1.qty }) else { return nil }

    // Yeniden inşa: kutu başına örnekler (azalan sıra korunur) → ofsetler kerf kuralıyla
    var placements: [Placement1D] = []
    var usedEnds = Array(repeating: Units(0), count: state.bestCount)
    var usedLength: Units = 0
    var cutCount = 0
    for idx in 0..<instances.count {
        let bar = state.best[idx]
        let part = instances[idx].part
        let offset = usedEnds[bar]
        placements.append(Placement1D(partId: part.id, stockIndex: bar,
                                      offset: offset, length: part.length))
        usedLength += part.length
        let end = offset + part.length
        if end == barLength {
            usedEnds[bar] = end
        } else {
            usedEnds[bar] = end + kerf
            cutCount += 1
        }
    }
    return Run1D(placements: placements, unplaced: [], stockCount: state.bestCount,
                 totalStockLength: barLength * Units(state.bestCount),
                 usedLength: usedLength, cutCount: cutCount)
}

// docs/04 §4 — doğrulama → malzeme havuzları → FFD (+ uygunsa B&B) → birleştirme.
public func optimize1D(_ req: Optimize1DRequest) throws -> Optimize1DResult {
    let issues = validate1D(req)
    if !issues.isEmpty {
        if let first = issues.first, issues.allSatisfy({ $0.kind == .partExceedsStock }) {
            throw PlacementError.partExceedsStock(partId: first.subjectId)
        }
        throw EngineError.invalidRequest
    }

    var materialOrder: [String] = []
    for s in req.stocks where !materialOrder.contains(s.materialId) { materialOrder.append(s.materialId) }

    var placements: [Placement1D] = []
    var unplaced: [String] = []
    var stockOffset = 0
    var totalStock: Units = 0
    var totalUsed: Units = 0
    var totalCuts = 0

    for mat in materialOrder {
        let poolParts = req.parts.filter { $0.materialId == mat }
        if poolParts.isEmpty { continue }
        let pool = Optimize1DRequest(unitMode: req.unitMode, kerf: req.kerf,
                                     objective: req.objective, seed: req.seed,
                                     stocks: req.stocks.filter { $0.materialId == mat },
                                     parts: poolParts)
        let ffd = ffd1D(pool)
        let selected: Run1D
        if let better = branchAndBound1D(pool, ffd: ffd) {
            selected = better
        } else {
            selected = ffd
        }
        for p in selected.placements {
            placements.append(Placement1D(partId: p.partId, stockIndex: p.stockIndex + stockOffset,
                                          offset: p.offset, length: p.length))
        }
        unplaced.append(contentsOf: selected.unplaced)
        stockOffset += selected.stockCount
        totalStock += selected.totalStockLength
        totalUsed += selected.usedLength
        totalCuts += selected.cutCount
    }

    let wasteBps = totalStock > 0 ? Int((totalStock - totalUsed) * 10_000 / totalStock) : 0
    return Optimize1DResult(
        placements: placements,
        stats: PlanStats(sheetCount: stockOffset, wasteBps: wasteBps, cutCount: totalCuts),
        unplaced: unplaced,
        engineVersion: engineVersion)
}

// docs/04 §5 — 1D kanonik hash: `partId|stockIndex|offset|length;` (aynı FNV çekirdeği).
public func placements1DHash(_ placements: [Placement1D]) -> String {
    var lines: [String] = []
    for p in placements {
        lines.append("\(escaped(p.partId))|\(p.stockIndex)|\(p.offset)|\(p.length);")
    }
    return canonicalFNVHex(lines)
}

// 1D değişmez doğrulayıcı: pozitif boy, sınır içi (aynı-malzeme azami stok boyu —
// stockIndex→stok eşlemesi şemada taşınmadığından muhafazakâr), komşular arası ≥ kerf.
public func verifyInvariants1D(_ res: Optimize1DResult, req: Optimize1DRequest) -> [InvariantViolation] {
    var violations: [InvariantViolation] = []
    var partMaterial: [String: String] = [:]
    for p in req.parts where partMaterial[p.id] == nil { partMaterial[p.id] = p.materialId }

    var byStock: [Int: [Placement1D]] = [:]
    for p in res.placements {
        var arr = byStock[p.stockIndex] ?? []
        arr.append(p)
        byStock[p.stockIndex] = arr
    }
    for stockIndex in byStock.keys.sorted() {
        let ps = (byStock[stockIndex] ?? []).sorted { a, b in
            if a.offset != b.offset { return a.offset < b.offset }
            return a.partId < b.partId
        }
        var previousEnd: Units = -1
        var previousId = ""
        for p in ps {
            if p.length <= 0 {
                violations.append(.init(kind: .nonPositiveSize, sheetIndex: stockIndex,
                                        subjectIds: [p.partId], message: "yerlesim boyu pozitif degil"))
                continue
            }
            guard let material = partMaterial[p.partId] else {
                violations.append(.init(kind: .unknownPart, sheetIndex: stockIndex,
                                        subjectIds: [p.partId], message: "partId istek kataloğunda yok"))
                continue
            }
            var maxLen: Units = 0
            for s in req.stocks where s.materialId == material {
                if s.length > maxLen { maxLen = s.length }
            }
            if p.offset < 0 || p.offset + p.length > maxLen {
                violations.append(.init(kind: .outOfBounds, sheetIndex: stockIndex,
                                        subjectIds: [p.partId], message: "parca stok boyu disina tasiyor"))
            }
            if previousEnd >= 0 {
                let gap = p.offset - previousEnd
                if gap < 0 {
                    violations.append(.init(kind: .overlap, sheetIndex: stockIndex,
                                            subjectIds: [previousId, p.partId], message: "parcalar cakisiyor"))
                } else if gap < req.kerf {
                    violations.append(.init(kind: .kerfViolation, sheetIndex: stockIndex,
                                            subjectIds: [previousId, p.partId],
                                            message: "komsu parcalar arasindaki bosluk kerf'ten kucuk"))
                }
            }
            previousEnd = p.offset + p.length
            previousId = p.partId
        }
    }
    return violations
}
