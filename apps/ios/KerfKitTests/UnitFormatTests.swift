import XCTest
import CutModels
@testable import KerfKit

// E4-S2b: kesir biçimi + mm↔1/64″ dönüşümü (docs/04 §2 birim uzayı).
final class UnitFormatTests: XCTestCase {

    func testFractionFormatting() {
        XCTAssertEqual(UnitFormat.fraction(frac64: 64), "1")
        XCTAssertEqual(UnitFormat.fraction(frac64: 96), "1 1/2")
        XCTAssertEqual(UnitFormat.fraction(frac64: 8), "1/8")
        XCTAssertEqual(UnitFormat.fraction(frac64: 32), "1/2", "32/64 indirgenir")
        XCTAssertEqual(UnitFormat.fraction(frac64: 63), "63/64", "AC üst sınırı")
        XCTAssertEqual(UnitFormat.fraction(frac64: 1), "1/64", "AC alt sınırı")
        XCTAssertEqual(UnitFormat.fraction(frac64: 1952), "30 1/2")
        XCTAssertEqual(UnitFormat.fraction(frac64: 0), "0")
    }

    func testDimensionLabels() {
        XCTAssertEqual(UnitFormat.dimension(720, unit: .metricMM), "720")
        XCTAssertEqual(UnitFormat.dimension(1952, unit: .imperialFrac64), "30 1/2\u{2033}")
        XCTAssertEqual(UnitFormat.size(720, 580, unit: .metricMM), "720 × 580")
    }

    func testConversion_knownAnchors() {
        // 1″ = 25.4mm: 25 mm → 63/64 (25·640/254 = 62.99…→63); 2440mm → 96.06…″
        XCTAssertEqual(UnitFormat.convert(25, from: .metricMM, to: .imperialFrac64), 63)
        XCTAssertEqual(UnitFormat.convert(2440, from: .metricMM, to: .imperialFrac64), 6148)
        XCTAssertEqual(UnitFormat.convert(64, from: .imperialFrac64, to: .metricMM), 25,
                       "1″ → 25.4 → 25mm'e yuvarlanır")
        XCTAssertEqual(UnitFormat.convert(6144, from: .imperialFrac64, to: .metricMM), 2438,
                       "96″ levha → 2438mm (gerçek 4×8ft ölçüsü)")
    }

    func testConversion_roundTripDriftBounded() {
        // Tur kaybı en fazla 1 birim: dönüşüm yuvarlama tanımı gereği.
        for mm in [1, 3, 18, 120, 396, 580, 764, 1220, 2440] {
            let back = UnitFormat.convert(UnitFormat.convert(mm, from: .metricMM, to: .imperialFrac64),
                                          from: .imperialFrac64, to: .metricMM)
            XCTAssertLessThanOrEqual(abs(back - mm), 1, "mm=\(mm) turu \(back)")
        }
    }
}
