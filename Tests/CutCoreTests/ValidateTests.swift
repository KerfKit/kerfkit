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
}
