import XCTest
import CutModels
@testable import CutCore

final class ValidateTests: XCTestCase {
    func req(parts: [PartSpec]) -> OptimizeRequest {
        .init(unitMode: .metricMM, kerf: 300, trim: 1000, objective: .sheets, seed: 1,
              stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 5)], parts: parts)
    }
    func testHappyPath_noIssues() {
        let r = req(parts: [.init(id: "p1", name: "yan", materialId: "m1", w: 60_000, h: 40_000, qty: 4)])
        XCTAssertTrue(validate(r).isEmpty)
    }
    func testOversizePart_reported() {
        let r = req(parts: [.init(id: "p1", name: "dev", materialId: "m1", w: 250_000, h: 40_000, qty: 1, rotation: .fixed)])
        XCTAssertEqual(validate(r).first?.kind, .partExceedsStock)
    }
    func testRotationRescuesOversize() {
        let r = req(parts: [.init(id: "p1", name: "uzun", materialId: "m1", w: 10_000, h: 230_000, qty: 1, rotation: .allowed)])
        XCTAssertTrue(validate(r).isEmpty)
    }
    func testZeroDimension_reported() {
        let r = req(parts: [.init(id: "p1", name: "sifir", materialId: "m1", w: 0, h: 40_000, qty: 1)])
        XCTAssertEqual(validate(r).first?.kind, .nonPositiveDimension)
    }
    func testUnknownMaterial_reported() {
        let r = req(parts: [.init(id: "p1", name: "yabanci", materialId: "mX", w: 10_000, h: 10_000, qty: 1)])
        XCTAssertEqual(validate(r).first?.kind, .unknownMaterial)
    }

    // E1-S1c — docs/04 §2 motor sınırları: boyut ≤ 10^8 birim, toplam stok alanı ≤ 5×10^14 birim².
    func testPartDimensionTooLarge_reported() {
        let r = req(parts: [.init(id: "p1", name: "dev", materialId: "m1", w: 100_000_001, h: 40_000, qty: 1)])
        XCTAssertEqual(validate(r).first?.kind, .dimensionTooLarge)
    }
    func testStockDimensionTooLarge_reported() {
        let r = OptimizeRequest(unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
                                stocks: [.init(id: "s1", materialId: "m1", w: 100_000_001, h: 122_000, qty: 1)],
                                parts: [])
        XCTAssertEqual(validate(r).first?.kind, .dimensionTooLarge)
    }
    func testTotalStockAreaTooLarge_singleStock_reported() {
        // 10^8 × 10^8 = 10^16 birim² > 5×10^14 (boyutlar tek tek sınır içinde)
        let r = OptimizeRequest(unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
                                stocks: [.init(id: "s1", materialId: "m1", w: 100_000_000, h: 100_000_000, qty: 1)],
                                parts: [])
        XCTAssertEqual(validate(r).first?.kind, .totalStockAreaTooLarge)
    }
    func testTotalStockAreaTooLarge_viaQty_reported() {
        // 244000×122000 = 2,977×10^10 birim²; qty 20000 → 5,95×10^14 > 5×10^14
        let r = OptimizeRequest(unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
                                stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 20_000)],
                                parts: [])
        XCTAssertEqual(validate(r).first?.kind, .totalStockAreaTooLarge)
    }
    // E1-S2 incelemesi: kerf/trim üst sınırsızdı — 2·trim aritmetiği validate İÇİNDE taşabiliyordu.
    func testTrimTooLarge_reportedNotCrash() {
        let r = OptimizeRequest(unitMode: .metricMM, kerf: 0, trim: 5_000_000_000_000_000_000,
                                objective: .sheets, seed: 1,
                                stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
                                parts: [.init(id: "p1", name: "a", materialId: "m1", w: 10_000, h: 10_000, qty: 1)])
        XCTAssertEqual(validate(r).first?.kind, .dimensionTooLarge)
    }
    func testKerfTooLarge_reported() {
        let r = OptimizeRequest(unitMode: .metricMM, kerf: 100_000_001, trim: 0,
                                objective: .sheets, seed: 1,
                                stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
                                parts: [])
        XCTAssertEqual(validate(r).first?.kind, .dimensionTooLarge)
    }

    func testLimits_exactBoundary_ok() {
        // Tam sınırda geçerli: boyut 10^8 ve toplam alan tam 5×10^14 birim²
        let r = OptimizeRequest(unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
                                stocks: [.init(id: "s1", materialId: "m1", w: 100_000_000, h: 5_000_000, qty: 1)],
                                parts: [.init(id: "p1", name: "raf", materialId: "m1", w: 60_000, h: 40_000, qty: 1)])
        XCTAssertTrue(validate(r).isEmpty)
    }
}
