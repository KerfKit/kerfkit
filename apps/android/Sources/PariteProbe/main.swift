import CutCore
import CutModels

// E9-S2b — Android parite feneri MAC karşılığı: ViewModel.pariteBeacon ile AYNI
// sabit istek (örnek dolap; kerf 300 / trim 0 / sheets / seed 1). Çıktı formatı
// birebir; tools/android-parite.sh iki satırı karşılaştırır.
let rows: [(String, Int64, Int64, Int)] = [
    ("Side", 720, 400, 2), ("Shelf", 764, 380, 3), ("Top", 800, 400, 1), ("Back", 764, 700, 1),
]
let req = OptimizeRequest(
    unitMode: .metricMM, kerf: 300, trim: 0, objective: .sheets, seed: 1,
    stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 99)],
    parts: rows.enumerated().map { i, r in
        .init(id: "p\(i)", name: r.0, materialId: "m1", w: r.1 * 100, h: r.2 * 100, qty: r.3)
    })
let res = try optimize(req)
print("KERFKIT-PARITE sheets=\(res.stats.sheetCount) wasteBps=\(res.stats.wasteBps) "
    + "cuts=\(res.stats.cutCount) hash=\(placementsHash(res.placements))")
