import XCTest
import CutModels
@testable import CutCore

// docs/03 E2-S1 AC'leri — 1D motor (K-8).
final class Optimize1DTests: XCTestCase {
    func req(stocks: [Stock1D], parts: [Part1D], kerf: Units = 300) -> Optimize1DRequest {
        Optimize1DRequest(unitMode: .metricMM, kerf: kerf, objective: .sheets, seed: 1,
                          stocks: stocks, parts: parts)
    }

    // AC-1: 2400mm ×3 stok + [800×5, 600×3], kerf 3mm — FFD planı elle türetilmiş yerleşimle birebir.
    func testE2S1_AC1_ffdWithKerf_exactLayout() throws {
        let r = req(stocks: [.init(id: "s1", materialId: "m1", length: 240_000, qty: 3)],
                    parts: [.init(id: "p800", name: "boy", materialId: "m1", length: 80_000, qty: 5),
                            .init(id: "p600", name: "kisa", materialId: "m1", length: 60_000, qty: 3)])
        let res = try optimize1D(r)
        XCTAssertTrue(res.unplaced.isEmpty)
        XCTAssertEqual(res.stats.sheetCount, 3)
        XCTAssertEqual(res.stats.cutCount, 8)
        // stok 0-1: 800@0, 800@80300, 600@160600 · stok 2: 800@0, 600@80300
        let expected: [Placement1D] = [
            .init(partId: "p800", stockIndex: 0, offset: 0, length: 80_000),
            .init(partId: "p800", stockIndex: 0, offset: 80_300, length: 80_000),
            .init(partId: "p800", stockIndex: 1, offset: 0, length: 80_000),
            .init(partId: "p800", stockIndex: 1, offset: 80_300, length: 80_000),
            .init(partId: "p800", stockIndex: 2, offset: 0, length: 80_000),
            .init(partId: "p600", stockIndex: 0, offset: 160_600, length: 60_000),
            .init(partId: "p600", stockIndex: 1, offset: 160_600, length: 60_000),
            .init(partId: "p600", stockIndex: 2, offset: 80_300, length: 60_000),
        ]
        XCTAssertEqual(res.placements, expected)
        // atık raporu: 720000 − 580000 = 140000 → 1944 bps
        XCTAssertEqual(res.stats.wasteBps, 1944)
        XCTAssertTrue(verifyInvariants1D(res, req: r).isEmpty)
    }

    // AC-2: FFD'nin 4 stok harcadığı klasik örnekte B&B 3'e iner; sonuç asla FFD'den kötü olamaz.
    func testE2S1_AC2_branchAndBound_beatsFFD() throws {
        let r = req(stocks: [.init(id: "s1", materialId: "m1", length: 100_000, qty: 10)],
                    parts: [.init(id: "a", name: "a", materialId: "m1", length: 50_000, qty: 2),
                            .init(id: "b", name: "b", materialId: "m1", length: 40_000, qty: 2),
                            .init(id: "c", name: "c", materialId: "m1", length: 30_000, qty: 4)],
                    kerf: 0)
        let ffd = ffd1D(r)
        XCTAssertEqual(ffd.stockCount, 4, "FFD bu dizilimde 4 stok harcar (klasik alt-optimal)")
        let res = try optimize1D(r)
        XCTAssertEqual(res.stats.sheetCount, 3, "B&B tam çözümü bulur: (50,50)(40,30,30)(40,30,30)")
        XCTAssertEqual(res.stats.wasteBps, 0)
        XCTAssertTrue(res.unplaced.isEmpty)
        XCTAssertTrue(verifyInvariants1D(res, req: r).isEmpty)
        XCTAssertLessThanOrEqual(res.stats.sheetCount, ffd.stockCount, "AC-2: B&B ≥ FFD kalitesi")
    }

    // AC-3: parça en uzun stoktan büyük → tipli hata (sessiz atlama yok).
    func testE2S1_AC3_partExceedsLongestStock_typedError() {
        let r = req(stocks: [.init(id: "s1", materialId: "m1", length: 240_000, qty: 3)],
                    parts: [.init(id: "dev", name: "dev", materialId: "m1", length: 250_000, qty: 1)])
        XCTAssertThrowsError(try optimize1D(r)) { error in
            XCTAssertEqual(error as? PlacementError, .partExceedsStock(partId: "dev"))
        }
    }

    // Uç kuralı: stok ucuna tam gelen parçada kesim yok — 120×2 kerf'siz tek stokta 1 kesim, 0 fire.
    func testE2S1_flushEnd_noCutNoKerf() throws {
        let r = req(stocks: [.init(id: "s1", materialId: "m1", length: 240_000, qty: 2)],
                    parts: [.init(id: "yarim", name: "y", materialId: "m1", length: 120_000, qty: 2)],
                    kerf: 0)
        let res = try optimize1D(r)
        XCTAssertEqual(res.stats.sheetCount, 1)
        XCTAssertEqual(res.stats.cutCount, 1, "ilk parçadan sonra 1 kesim; ikincisi uca tam oturur")
        XCTAssertEqual(res.stats.wasteBps, 0)
    }

    // Stok tükenmesi: sığmayanlar unplaced'a düşer (sessiz değil).
    func testE2S1_stockExhausted_unplaced() throws {
        let r = req(stocks: [.init(id: "s1", materialId: "m1", length: 240_000, qty: 1)],
                    parts: [.init(id: "p800", name: "boy", materialId: "m1", length: 80_000, qty: 4)])
        let res = try optimize1D(r)
        XCTAssertEqual(res.placements.count, 2, "kerf 3mm ile tek stoğa yalnız 2×800 sığar")
        XCTAssertEqual(res.unplaced, ["p800", "p800"])
    }

    func testE2S1_deterministic() throws {
        let r = req(stocks: [.init(id: "s1", materialId: "m1", length: 240_000, qty: 5)],
                    parts: [.init(id: "a", name: "a", materialId: "m1", length: 70_000, qty: 4),
                            .init(id: "b", name: "b", materialId: "m1", length: 45_000, qty: 5)])
        let h1 = placements1DHash(try optimize1D(r).placements)
        let h2 = placements1DHash(try optimize1D(r).placements)
        XCTAssertEqual(h1, h2)
    }
}
