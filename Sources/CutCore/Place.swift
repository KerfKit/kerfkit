import CutModels

// docs/03 E1-S1 AC-2 — yerleştirme katmanının kontrollü hataları.
public enum PlacementError: Error, Equatable {
    case partExceedsStock(partId: String)
}

// — E1-S4b: heuristik portföy boyutları (docs/04 §3 adım 3) —
enum SortKey: CaseIterable { case alan, uzunKenar, cevre }
enum SplitRule: CaseIterable { case sasKisaEksen, minArtikAlan }
enum FirstCutAxis: CaseIterable { case yatay, dikey }

struct RunConfig {
    let sort: SortKey
    let split: SplitRule
    let firstCut: FirstCutAxis
    // Deterministik koşu sırası: sıralama × bölme × ilk-yön = 12 kombinasyon (docs/04 §2).
    static let portfolio: [RunConfig] = SortKey.allCases.flatMap { s in
        SplitRule.allCases.flatMap { sp in
            FirstCutAxis.allCases.map { f in RunConfig(sort: s, split: sp, firstCut: f) }
        }
    }
}

// Koordinat konvansiyonu: orijin levhanın sol-alt köşesi, x sağa, y yukarı
// (docs/05'te konvansiyon tanımlı değil; ilk tanım burada — görselleştirme katmanı çevirir).
//
// Kesim ağacı (docs/04 §3 4c): düğüm = levha içinde dikdörtgen bölge. Yaprak ya serbest
// alan ya yerleşmiş parça; iç düğüm = 1 guillotine kesim. cutCount = iç düğüm sayısı (§3).
// Kerf (E1-S2): kesim, uzak (hi) çocuğun boyutundan kerf düşer; parça tarafı tam ölçü.
// Levha/kullanılabilir-alan kenarında kesim olmadığından kerf düşülmez (§3 4c).
// Artık kerf'ten küçükse toz: hi çocuğu üretilmez, kesim yine sayılır.
struct CutTree {
    enum Kind {
        case free
        case part(id: String)
        case cut(lo: Int, hi: Int?) // lo = orijine yakın çocuk; hi=nil → artık toz oldu
    }
    struct Node {
        var x: Units, y: Units, w: Units, h: Units
        var kind: Kind
    }
    private(set) var nodes: [Node]
    private(set) var cutCount = 0

    init(x: Units, y: Units, w: Units, h: Units) {
        nodes = [Node(x: x, y: y, w: w, h: h, kind: .free)]
    }

    // Serbest yapraklar, oluşturulma (indeks) sırasıyla — docs/04 §3 4b'deki "ID" tie-break'i.
    var freeLeaves: [Int] {
        nodes.indices.filter { i in
            if case .free = nodes[i].kind { return true }
            return false
        }
    }

    // İlk kesim ekseni (E1-S4b): taze levha kökünde portföyün ilk-yön parametresi;
    // sonrasında bölme kuralı — SAS: kısa eksen; min-artık-alan: artığın büyük parçasını
    // en büyük tutan eksen (küçük artık parçalanması minimize). Eşitlikte ilk-yön.
    private func chooseAxis(_ n: Node, pw: Units, ph: Units, kerf: Units,
                            rule: SplitRule, preferred: FirstCutAxis, isRoot: Bool) -> FirstCutAxis {
        if isRoot { return preferred }
        switch rule {
        case .sasKisaEksen:
            if n.w < n.h { return .yatay }
            if n.w > n.h { return .dikey }
            return preferred
        case .minArtikAlan:
            let hY = max(n.h - ph - kerf, 0), wY = max(n.w - pw - kerf, 0)
            let yatayMax = max(n.w * hY, wY * ph)
            let dikeyMax = max(wY * n.h, pw * hY)
            if yatayMax != dikeyMax { return yatayMax > dikeyMax ? .yatay : .dikey }
            return preferred
        }
    }

    // pw×ph parçayı serbest yaprağın sol-alt köşesine koyar; artığı guillotine kesimlerle böler.
    mutating func place(partId: String, at leaf: Int, pw: Units, ph: Units, kerf: Units,
                        rule: SplitRule, firstCut: FirstCutAxis) {
        var idx = leaf
        let n = nodes[idx]
        // iki eksende de artık varsa ilk kesim parçayı içeren şeridi ayırır
        if pw < n.w && ph < n.h {
            let axis = chooseAxis(n, pw: pw, ph: ph, kerf: kerf,
                                  rule: rule, preferred: firstCut, isRoot: idx == 0)
            idx = axis == .yatay ? split(idx, horizontalAtHeight: ph, kerf: kerf)
                                 : split(idx, verticalAtWidth: pw, kerf: kerf)
        }
        // tek eksende artık kaldıysa ikinci (ya da tek) kesim
        let strip = nodes[idx]
        if pw < strip.w {
            idx = split(idx, verticalAtWidth: pw, kerf: kerf)
        } else if ph < strip.h {
            idx = split(idx, horizontalAtHeight: ph, kerf: kerf)
        }
        nodes[idx].kind = .part(id: partId)
    }

    // Yaprağı y+h'de yatay kesimle böler; orijin tarafındaki (alt) şeridin indeksini döner.
    private mutating func split(_ leaf: Int, horizontalAtHeight h: Units, kerf: Units) -> Int {
        let n = nodes[leaf]
        let lo = nodes.count
        nodes.append(Node(x: n.x, y: n.y, w: n.w, h: h, kind: .free))
        var hi: Int?
        let hiH = n.h - h - kerf
        if hiH > 0 {
            hi = nodes.count
            nodes.append(Node(x: n.x, y: n.y + h + kerf, w: n.w, h: hiH, kind: .free))
        }
        nodes[leaf].kind = .cut(lo: lo, hi: hi)
        cutCount += 1
        return lo
    }

    // Yaprağı x+w'de dikey kesimle böler; orijin tarafındaki (sol) şeridin indeksini döner.
    private mutating func split(_ leaf: Int, verticalAtWidth w: Units, kerf: Units) -> Int {
        let n = nodes[leaf]
        let lo = nodes.count
        nodes.append(Node(x: n.x, y: n.y, w: w, h: n.h, kind: .free))
        var hi: Int?
        let hiW = n.w - w - kerf
        if hiW > 0 {
            hi = nodes.count
            nodes.append(Node(x: n.x + w + kerf, y: n.y, w: hiW, h: n.h, kind: .free))
        }
        nodes[leaf].kind = .cut(lo: lo, hi: hi)
        cutCount += 1
        return lo
    }
}

// Aday konum skoru — docs/04 §3 4b: Best Area Fit → Best Short Side Fit → ID (levha, yaprak),
// tam eşitlikte döndürülmemiş varyant önce (deterministik).
private struct Orientation {
    let w: Units
    let h: Units
    let rotated: Bool
}

private struct Fit {
    var sheet: Int
    var leaf: Int
    var rotated: Bool
    var leftover: Units
    var shortSide: Units
}

private func isBetter(_ a: Fit, than b: Fit) -> Bool {
    if a.leftover != b.leftover { return a.leftover < b.leftover }
    if a.shortSide != b.shortSide { return a.shortSide < b.shortSide }
    if a.sheet != b.sheet { return a.sheet < b.sheet }
    if a.leaf != b.leaf { return a.leaf < b.leaf }
    return !a.rotated && b.rotated
}

private struct OpenSheet {
    let materialId: String
    var tree: CutTree
}

private func bestFit(_ part: PartSpec, in sheets: [OpenSheet]) -> Fit? {
    var best: Fit?
    for si in 0..<sheets.count {
        let sheet = sheets[si]
        if sheet.materialId != part.materialId { continue }
        for li in sheet.tree.freeLeaves {
            let n = sheet.tree.nodes[li]
            var orientations: [Orientation] = [Orientation(w: part.w, h: part.h, rotated: false)]
            if part.rotation == .allowed && part.w != part.h {
                orientations.append(Orientation(w: part.h, h: part.w, rotated: true))
            }
            for o in orientations {
                if o.w > n.w || o.h > n.h { continue }
                let cand = Fit(sheet: si, leaf: li, rotated: o.rotated,
                               leftover: n.w * n.h - o.w * o.h,
                               shortSide: min(n.w - o.w, n.h - o.h))
                if let current = best, !isBetter(cand, than: current) { continue }
                best = cand
            }
        }
    }
    return best
}

// Kullanılabilir alan = stok − 2·trim (docs/04 §3 4a); kerf tek parçanın sığmasını etkilemez.
private func canHold(_ stock: StockSpec, _ part: PartSpec, trim: Units) -> Bool {
    let uw = stock.w - 2 * trim, uh = stock.h - 2 * trim
    let direct = part.w <= uw && part.h <= uh
    let rotated = part.rotation == .allowed && part.h <= uw && part.w <= uh
    return direct || rotated
}

private struct Instance {
    let part: PartSpec
    let ordinal: Int
}

private struct StockPool {
    let stock: StockSpec
    var remaining: Int
}

// Tek koşunun ham sonucu — havuz birleştirme ve hedef seçimi için ara yapı.
struct PoolRun {
    var placements: [Placement]
    var unplaced: [String]
    var sheetCount: Int
    var sheetArea: Units
    var usedArea: Units
    var cutCount: Int
    var wasteBps: Int { sheetArea > 0 ? Int((sheetArea - usedArea) * 10_000 / sheetArea) : 0 }
}

// docs/04 §3 adım 4 — tek heuristik koşu (portföyün bir kombinasyonu).
func placeAll(_ req: OptimizeRequest, config: RunConfig) -> PoolRun {
    // Parça örnekleri; kararlı sıralama: config.sort anahtarı → alan/uzun-kenar ikincili →
    // id↑ → örnek sırası (total order, sort kararlılığına dayanmaz; docs/04 §2).
    var instances: [Instance] = []
    for p in req.parts {
        for _ in 0..<p.qty { instances.append(Instance(part: p, ordinal: instances.count)) }
    }
    func primaryKey(_ p: PartSpec) -> Units {
        switch config.sort {
        case .alan: return p.w * p.h
        case .uzunKenar: return max(p.w, p.h)
        case .cevre: return p.w + p.h
        }
    }
    func secondaryKey(_ p: PartSpec) -> Units {
        switch config.sort {
        case .alan: return max(p.w, p.h)
        case .uzunKenar, .cevre: return p.w * p.h
        }
    }
    instances.sort { a, b in
        let k1a = primaryKey(a.part), k1b = primaryKey(b.part)
        if k1a != k1b { return k1a > k1b }
        let k2a = secondaryKey(a.part), k2b = secondaryKey(b.part)
        if k2a != k2b { return k2a > k2b }
        if a.part.id != b.part.id { return a.part.id < b.part.id }
        return a.ordinal < b.ordinal
    }

    var pools = req.stocks.map { StockPool(stock: $0, remaining: $0.qty) }
    var sheets: [OpenSheet] = []
    var sheetAreas: [Units] = [] // tam levha alanı — fire trim+kerf dahil raporlanır
    var placements: [Placement] = []
    var unplaced: [String] = []

    func commit(_ part: PartSpec, _ fit: Fit) {
        let n = sheets[fit.sheet].tree.nodes[fit.leaf]
        let pw = fit.rotated ? part.h : part.w
        let ph = fit.rotated ? part.w : part.h
        sheets[fit.sheet].tree.place(partId: part.id, at: fit.leaf, pw: pw, ph: ph,
                                     kerf: req.kerf, rule: config.split, firstCut: config.firstCut)
        placements.append(.init(partId: part.id, sheetIndex: fit.sheet,
                                x: n.x, y: n.y, w: pw, h: ph, rotated: fit.rotated))
    }

    for inst in instances {
        let part = inst.part
        if let fit = bestFit(part, in: sheets) {
            commit(part, fit)
            continue
        }
        // Açık levhalara sığmadı → istek sırasındaki ilk uygun stoktan yeni levha (docs/04 §3 4d).
        // "Uygun" = malzeme eşleşmesi + boyut (trim dahil); havuz tükendiyse unplaced.
        guard let pi = pools.firstIndex(where: {
            $0.remaining > 0 && $0.stock.materialId == part.materialId && canHold($0.stock, part, trim: req.trim)
        }) else {
            unplaced.append(part.id)
            continue
        }
        pools[pi].remaining -= 1
        let s = pools[pi].stock
        sheets.append(OpenSheet(materialId: s.materialId,
                                tree: CutTree(x: req.trim, y: req.trim,
                                              w: s.w - 2 * req.trim, h: s.h - 2 * req.trim)))
        sheetAreas.append(s.w * s.h)
        guard let fit = bestFit(part, in: sheets) else {
            unplaced.append(part.id) // canHold nedeniyle erişilmez; kuvvet-unwrap yerine kontrollü yol
            continue
        }
        commit(part, fit)
    }

    return PoolRun(placements: placements,
                   unplaced: unplaced,
                   sheetCount: sheets.count,
                   sheetArea: sheetAreas.reduce(Units(0), +),
                   usedArea: placements.reduce(Units(0)) { $0 + $1.w * $1.h },
                   cutCount: sheets.reduce(0) { $0 + $1.tree.cutCount })
}

// Hedefe göre leksikografik karşılaştırma (docs/04 §3 adım 5); yerleşmeyen sayısı her
// hedefte baskındır (daha çok parça yerleştiren koşu her zaman üstün). İlk konfig kazanır.
private func betterRun(_ a: PoolRun, than b: PoolRun, objective: Objective) -> Bool {
    if a.unplaced.count != b.unplaced.count { return a.unplaced.count < b.unplaced.count }
    let ka: [Int], kb: [Int]
    switch objective {
    case .sheets: ka = [a.sheetCount, a.wasteBps, a.cutCount]; kb = [b.sheetCount, b.wasteBps, b.cutCount]
    case .waste:  ka = [a.wasteBps, a.sheetCount, a.cutCount]; kb = [b.wasteBps, b.sheetCount, b.cutCount]
    case .cuts:   ka = [a.cutCount, a.sheetCount, a.wasteBps]; kb = [b.cutCount, b.sheetCount, b.wasteBps]
    }
    for i in 0..<ka.count {
        if ka[i] != kb[i] { return ka[i] < kb[i] }
    }
    return false
}

// docs/04 §3 adım 2+3+5 — malzeme havuzları ayrık; havuz başına 12 koşuluk portföy;
// hedefe göre seçim; havuz sonuçları stok sırasına göre birleştirilir (levha indeksi ofsetli).
func runPortfolio(_ req: OptimizeRequest) -> OptimizeResult {
    var materialOrder: [String] = []
    for s in req.stocks where !materialOrder.contains(s.materialId) { materialOrder.append(s.materialId) }

    var placements: [Placement] = []
    var unplaced: [String] = []
    var sheetOffset = 0
    var totalSheetArea: Units = 0
    var totalUsed: Units = 0
    var totalCuts = 0

    for mat in materialOrder {
        let poolParts = req.parts.filter { $0.materialId == mat }
        guard !poolParts.isEmpty else { continue }
        let pool = OptimizeRequest(unitMode: req.unitMode, kerf: req.kerf, trim: req.trim,
                                   objective: req.objective, seed: req.seed,
                                   stocks: req.stocks.filter { $0.materialId == mat },
                                   parts: poolParts)
        var best: PoolRun?
        for config in RunConfig.portfolio {
            let run = placeAll(pool, config: config)
            if let b = best, !betterRun(run, than: b, objective: req.objective) { continue }
            best = run
        }
        guard let sel = best else { continue }
        placements.append(contentsOf: sel.placements.map { p in
            var q = p
            q.sheetIndex += sheetOffset
            return q
        })
        unplaced.append(contentsOf: sel.unplaced)
        sheetOffset += sel.sheetCount
        totalSheetArea += sel.sheetArea
        totalUsed += sel.usedArea
        totalCuts += sel.cutCount
    }

    let wasteBps = totalSheetArea > 0 ? Int((totalSheetArea - totalUsed) * 10_000 / totalSheetArea) : 0
    return OptimizeResult(
        placements: placements,
        stats: .init(sheetCount: sheetOffset, wasteBps: wasteBps, cutCount: totalCuts),
        unplaced: unplaced,
        engineVersion: engineVersion)
}
