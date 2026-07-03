import XCTest
import CutModels
@testable import CutCore

// docs/03 E1-S1 AC-1..AC-4 — E1-S1a: kerf=0, trim=0 basit hal (docs/04 §3).
// Guillotine-geçerlilik doğrulayıcısı E1-S1b'nin işi; burada çakışma/sınır kontrolü test içinde.
final class OptimizeTests: XCTestCase {
    func req(parts: [PartSpec], stockQty: Int = 1) -> OptimizeRequest {
        .init(unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
              stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: stockQty)], parts: parts)
    }

    // AC-1 (happy): 2440×1220 levha + 600×400 ×4 → tek levhaya çakışmasız yerleşir.
    func testAC1_fourPartsOneSheet_noOverlap() throws {
        let r = req(parts: [.init(id: "p1", name: "yan", materialId: "m1", w: 60_000, h: 40_000, qty: 4)])
        let res = try optimize(r)
        XCTAssertEqual(res.placements.count, 4)
        XCTAssertEqual(res.stats.sheetCount, 1)
        XCTAssertTrue(res.unplaced.isEmpty)
        XCTAssertEqual(res.engineVersion, engineVersion)
        for p in res.placements {
            XCTAssertEqual(p.sheetIndex, 0)
            XCTAssertGreaterThanOrEqual(p.x, 0)
            XCTAssertGreaterThanOrEqual(p.y, 0)
            XCTAssertLessThanOrEqual(p.x + p.w, 244_000)
            XCTAssertLessThanOrEqual(p.y + p.h, 122_000)
        }
        for (i, a) in res.placements.enumerated() {
            for b in res.placements[(i + 1)...] {
                let ayrik = a.x + a.w <= b.x || b.x + b.w <= a.x || a.y + a.h <= b.y || b.y + b.h <= a.y
                XCTAssertTrue(ayrik, "\(a.partId)@(\(a.x),\(a.y)) ile \(b.partId)@(\(b.x),\(b.y)) çakışıyor")
            }
        }
    }

    // AC-2 (edge): parça levhadan büyük → PlacementError.partExceedsStock (crash değil).
    func testAC2_oversizePart_throwsPlacementError() {
        let r = req(parts: [.init(id: "p1", name: "dev", materialId: "m1", w: 300_000, h: 130_000, qty: 1)])
        XCTAssertThrowsError(try optimize(r)) { error in
            XCTAssertEqual(error as? PlacementError, .partExceedsStock(partId: "p1"))
        }
    }

    // AC-3 (edge): 0 parça → boş plan, 0 levha, hata yok.
    func testAC3_zeroParts_emptyPlan() throws {
        let res = try optimize(req(parts: []))
        XCTAssertTrue(res.placements.isEmpty)
        XCTAssertEqual(res.stats.sheetCount, 0)
        XCTAssertEqual(res.stats.wasteBps, 0)
        XCTAssertEqual(res.stats.cutCount, 0)
        XCTAssertTrue(res.unplaced.isEmpty)
    }

    // İnceleme bulgusu (R-3): yeni levha açarken havuz seçimi malzemeye bakmalı —
    // aksi halde yanlış malzemeden boş levha tüketilip parça sahte "unplaced" döner.
    func testMultiMaterial_opensSheetFromMatchingStock() throws {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1),
                     .init(id: "s2", materialId: "m2", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "raf", materialId: "m2", w: 60_000, h: 40_000, qty: 1)])
        let res = try optimize(r)
        XCTAssertTrue(res.unplaced.isEmpty, "m2 stoğu varken parça yerleşmeli")
        XCTAssertEqual(res.placements.count, 1)
        XCTAssertEqual(res.stats.sheetCount, 1, "yalnız m2'den tek levha açılmalı; m1 tüketilmemeli")
    }

    // E1-S1c regresyonu: inceleme repro'su (w=h=2^32 birim) eskiden aritmetik taşma
    // trap'iyle süreci çökertiyordu; motor sınırları (docs/04 §2) artık tipli hataya çevirir.
    func testExtremeDimensions_typedErrorNotCrash() {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 4_294_967_296, h: 4_294_967_296, qty: 1)],
            parts: [.init(id: "p1", name: "dev", materialId: "m1", w: 4_294_967_296, h: 4_294_967_296, qty: 1)])
        XCTAssertEqual(validate(r).first?.kind, .dimensionTooLarge)
        XCTAssertThrowsError(try optimize(r)) { error in
            XCTAssertEqual(error as? EngineError, .invalidRequest)
        }
    }

    // AC-4 (hata): negatif/0 boyut → doğrulama katmanında yakalanır, optimize kontrollü fırlatır.
    func testAC4_negativeDimension_caughtByValidation() {
        let r = req(parts: [.init(id: "p1", name: "eksi", materialId: "m1", w: -100, h: 40_000, qty: 1)])
        XCTAssertEqual(validate(r).first?.kind, .nonPositiveDimension)
        XCTAssertThrowsError(try optimize(r)) { error in
            XCTAssertEqual(error as? EngineError, .invalidRequest)
        }
    }
}
