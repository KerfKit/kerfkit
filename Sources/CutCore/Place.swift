import CutModels

// docs/03 E1-S1 AC-2 — yerleştirme katmanının kontrollü hataları.
public enum PlacementError: Error, Equatable {
    case partExceedsStock(partId: String)
}

// Koordinat konvansiyonu: orijin levhanın sol-alt köşesi, x sağa, y yukarı
// (docs/05'te konvansiyon tanımlı değil; ilk tanım burada — görselleştirme katmanı çevirir).
//
// Kesim ağacı (docs/04 §3 4c): düğüm = levha içinde dikdörtgen bölge. Yaprak ya serbest
// alan ya yerleşmiş parça; iç düğüm = 1 guillotine kesim. cutCount = iç düğüm sayısı (§3).
struct CutTree {
    enum Kind {
        case free
        case part(id: String)
        case cut(lo: Int, hi: Int) // lo = orijine yakın çocuk; BFS kesim sırası E1-S1b'de
    }
    struct Node {
        var x: Units, y: Units, w: Units, h: Units
        var kind: Kind
    }
    private(set) var nodes: [Node]
    private(set) var cutCount = 0

    init(w: Units, h: Units) {
        nodes = [Node(x: 0, y: 0, w: w, h: h, kind: .free)]
    }

    // Serbest yapraklar, oluşturulma (indeks) sırasıyla — docs/04 §3 4b'deki "ID" tie-break'i.
    var freeLeaves: [Int] {
        nodes.indices.filter { i in
            if case .free = nodes[i].kind { return true }
            return false
        }
    }

    // pw×ph parçayı serbest yaprağın sol-alt köşesine koyar; artığı guillotine kesimlerle böler.
    // İlk kesim ekseni (E1-S1a sabit kuralı): SAS — serbest dikdörtgenin kısa ekseni bölünür:
    // w <= h ise yatay kesim, aksi halde dikey. Bölme portföyü E1-S4'te gelir (docs/04 §3 adım 3).
    mutating func place(partId: String, at leaf: Int, pw: Units, ph: Units) {
        var idx = leaf
        let n = nodes[idx]
        // iki eksende de artık varsa ilk kesim parçayı içeren şeridi ayırır
        if pw < n.w && ph < n.h {
            idx = n.w <= n.h ? split(idx, horizontalAtHeight: ph) : split(idx, verticalAtWidth: pw)
        }
        // tek eksende artık kaldıysa ikinci (ya da tek) kesim
        let strip = nodes[idx]
        if pw < strip.w {
            idx = split(idx, verticalAtWidth: pw)
        } else if ph < strip.h {
            idx = split(idx, horizontalAtHeight: ph)
        }
        nodes[idx].kind = .part(id: partId)
    }

    // Yaprağı y+h'de yatay kesimle böler; orijin tarafındaki (alt) şeridin indeksini döner.
    private mutating func split(_ leaf: Int, horizontalAtHeight h: Units) -> Int {
        let n = nodes[leaf]
        let lo = nodes.count
        nodes.append(Node(x: n.x, y: n.y, w: n.w, h: h, kind: .free))
        nodes.append(Node(x: n.x, y: n.y + h, w: n.w, h: n.h - h, kind: .free))
        nodes[leaf].kind = .cut(lo: lo, hi: lo + 1)
        cutCount += 1
        return lo
    }

    // Yaprağı x+w'de dikey kesimle böler; orijin tarafındaki (sol) şeridin indeksini döner.
    private mutating func split(_ leaf: Int, verticalAtWidth w: Units) -> Int {
        let n = nodes[leaf]
        let lo = nodes.count
        nodes.append(Node(x: n.x, y: n.y, w: w, h: n.h, kind: .free))
        nodes.append(Node(x: n.x + w, y: n.y, w: n.w - w, h: n.h, kind: .free))
        nodes[leaf].kind = .cut(lo: lo, hi: lo + 1)
        cutCount += 1
        return lo
    }
}

// Aday konum skoru — docs/04 §3 4b: Best Area Fit → Best Short Side Fit → ID (levha, yaprak),
// tam eşitlikte döndürülmemiş varyant önce (deterministik).
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

private typealias OpenSheet = (materialId: String, tree: CutTree)

private func bestFit(_ part: PartSpec, in sheets: [OpenSheet]) -> Fit? {
    var best: Fit?
    for (si, sheet) in sheets.enumerated() where sheet.materialId == part.materialId {
        for li in sheet.tree.freeLeaves {
            let n = sheet.tree.nodes[li]
            var orientations: [(w: Units, h: Units, rotated: Bool)] = [(part.w, part.h, false)]
            if part.rotation == .allowed && part.w != part.h {
                orientations.append((part.h, part.w, true))
            }
            for o in orientations where o.w <= n.w && o.h <= n.h {
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

// E1-S1a kapsamı trim=0 olduğundan stok boyutu doğrudan kullanılabilir alandır.
private func canHold(_ stock: StockSpec, _ part: PartSpec) -> Bool {
    let direct = part.w <= stock.w && part.h <= stock.h
    let rotated = part.rotation == .allowed && part.h <= stock.w && part.w <= stock.h
    return direct || rotated
}

// docs/04 §3 adım 4 — tek heuristik koşu. Portföy (adım 3) ve hedef seçimi (adım 5) E1-S4'te.
func placeAll(_ req: OptimizeRequest) throws -> OptimizeResult {
    guard req.kerf == 0 && req.trim == 0 else {
        throw EngineError.notImplemented("E1-S2: kerf + trim")
    }
    // Parça örnekleri; kararlı sıralama: alan↓ → uzun kenar↓ → id↑ (docs/04 §2),
    // son anahtar örnek sırası — total order olduğundan sort kararlılığına dayanmaz.
    var instances: [(part: PartSpec, ordinal: Int)] = []
    for p in req.parts {
        for _ in 0..<p.qty { instances.append((p, instances.count)) }
    }
    instances.sort { a, b in
        let areaA = a.part.w * a.part.h, areaB = b.part.w * b.part.h
        if areaA != areaB { return areaA > areaB }
        let longA = max(a.part.w, a.part.h), longB = max(b.part.w, b.part.h)
        if longA != longB { return longA > longB }
        if a.part.id != b.part.id { return a.part.id < b.part.id }
        return a.ordinal < b.ordinal
    }

    var pools = req.stocks.map { (stock: $0, remaining: $0.qty) }
    var sheets: [OpenSheet] = []
    var placements: [Placement] = []
    var unplaced: [String] = []

    func commit(_ part: PartSpec, _ fit: Fit) {
        let n = sheets[fit.sheet].tree.nodes[fit.leaf]
        let pw = fit.rotated ? part.h : part.w
        let ph = fit.rotated ? part.w : part.h
        sheets[fit.sheet].tree.place(partId: part.id, at: fit.leaf, pw: pw, ph: ph)
        placements.append(.init(partId: part.id, sheetIndex: fit.sheet,
                                x: n.x, y: n.y, w: pw, h: ph, rotated: fit.rotated))
    }

    for (part, _) in instances {
        if let fit = bestFit(part, in: sheets) {
            commit(part, fit)
            continue
        }
        // Açık levhalara sığmadı → istek sırasındaki ilk uygun stoktan yeni levha (docs/04 §3 4d).
        // validate() geçtiği için normalde stok bulunur; havuz tükendiyse unplaced.
        guard let pi = pools.firstIndex(where: { $0.remaining > 0 && canHold($0.stock, part) }) else {
            unplaced.append(part.id)
            continue
        }
        pools[pi].remaining -= 1
        sheets.append((pools[pi].stock.materialId, CutTree(w: pools[pi].stock.w, h: pools[pi].stock.h)))
        guard let fit = bestFit(part, in: sheets) else {
            unplaced.append(part.id) // canHold nedeniyle erişilmez; kuvvet-unwrap yerine kontrollü yol
            continue
        }
        commit(part, fit)
    }

    let sheetArea = sheets.reduce(Units(0)) { $0 + $1.tree.nodes[0].w * $1.tree.nodes[0].h }
    let usedArea = placements.reduce(Units(0)) { $0 + $1.w * $1.h }
    let wasteBps = sheetArea > 0 ? Int((sheetArea - usedArea) * 10_000 / sheetArea) : 0
    let cutCount = sheets.reduce(0) { $0 + $1.tree.cutCount }
    return OptimizeResult(
        placements: placements,
        stats: .init(sheetCount: sheets.count, wasteBps: wasteBps, cutCount: cutCount),
        unplaced: unplaced,
        engineVersion: engineVersion)
}
