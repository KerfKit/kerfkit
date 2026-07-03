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

    // — E1-S2 (K-3): kerf + trim — docs/03 E1-S2, docs/04 §3 4a/4c —

    // AC-1: kerf=3mm iken iki komşu parça arasında TAM 3mm boşluk; levha kenarında kerf düşülmez.
    func testE1S2_AC1_kerfGapBetweenNeighbors_noneAtSheetEdge() throws {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 300, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "panel", materialId: "m1", w: 100_000, h: 122_000, qty: 2, rotation: .fixed)])
        let res = try optimize(r)
        XCTAssertEqual(res.placements.count, 2)
        let sorted = res.placements.sorted { $0.x < $1.x }
        XCTAssertEqual(sorted[0].x, 0, "levha kenarında kerf düşülmez — ilk parça kenara yaslı")
        XCTAssertEqual(sorted[1].x - (sorted[0].x + sorted[0].w), 300, "komşular arasında tam kerf boşluğu")
        XCTAssertTrue(verifyInvariants(res, req: r).isEmpty)
    }

    // AC-2: trim=10mm iken kullanılabilir alan (W−2·trim)×(H−2·trim).
    func testE1S2_AC2_trimInsetsUsableArea() throws {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 1_000, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "panel", materialId: "m1", w: 60_000, h: 40_000, qty: 1, rotation: .fixed)])
        let res = try optimize(r)
        XCTAssertEqual(res.placements.first?.x, 1_000, "yerleşim trim payının içinden başlar")
        XCTAssertEqual(res.placements.first?.y, 1_000)
        XCTAssertTrue(verifyInvariants(res, req: r).isEmpty)
    }
    func testE1S2_AC2_partExactlyUsableArea_fits() throws {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 1_000, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "tam", materialId: "m1", w: 242_000, h: 120_000, qty: 1, rotation: .fixed)])
        let res = try optimize(r)
        XCTAssertEqual(res.placements.count, 1)
        XCTAssertEqual(res.stats.cutCount, 0, "kullanılabilir alanı tam dolduran parça kesim istemez")
    }
    func testE1S2_AC2_partExceedingUsableArea_typedError() {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 1_000, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "tasan", materialId: "m1", w: 243_000, h: 120_000, qty: 1, rotation: .fixed)])
        XCTAssertThrowsError(try optimize(r)) { error in
            XCTAssertEqual(error as? PlacementError, .partExceedsStock(partId: "p1"))
        }
    }

    // Kerf artığı kerf'ten küçükse serbest yaprak üretilmez (toz) — kesim yine sayılır.
    func testE1S2_dustRemainder_noOverflowNoGhostLeaf() throws {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 300, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "yarim", materialId: "m1", w: 121_700, h: 122_000, qty: 2, rotation: .fixed)])
        let res = try optimize(r)
        XCTAssertEqual(res.placements.count, 2)
        XCTAssertTrue(res.unplaced.isEmpty)
        XCTAssertTrue(verifyInvariants(res, req: r).isEmpty)
    }

    // — E1-S3 (K-4): damar kilidi — docs/03 E1-S3 —
    // Davranış E1-S1a'daki bestFit/validate'te zaten kuruluydu; bu testler AC'leri sabitler.

    // AC-1: rotation=fixed parça 90° denenmez — rotasyon kazançlı olsa bile.
    func testE1S3_AC1_fixedNeverRotated_allowedMayRotate() throws {
        let fixedReq = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "damarli", materialId: "m1", w: 40_000, h: 60_000, qty: 4, rotation: .fixed)])
        let fixedRes = try optimize(fixedReq)
        XCTAssertEqual(fixedRes.placements.count, 4)
        XCTAssertTrue(fixedRes.placements.allSatisfy { !$0.rotated }, "fixed parça asla döndürülmez")
        // Aynı geometri rotation=allowed iken motor 90° adayını kullanabilmeli (001 vektörü bunu kanıtlıyor);
        // burada asgari güvence: allowed koşusu da 4 parçayı yerleştirir.
        var allowedReq = fixedReq
        allowedReq.parts[0].rotation = .allowed
        XCTAssertEqual(try optimize(allowedReq).placements.count, 4)
    }

    // AC-2: yalnız döndürülünce sığan parça — allowed rotasyonla yerleşir,
    // fixed ise SESSİZCE atlanmaz: tipli partExceedsStock ile raporlanır.
    func testE1S3_AC2_onlyRotatedFits_fixedReported_allowedPlaced() throws {
        let base = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "uzun", materialId: "m1", w: 120_000, h: 230_000, qty: 1, rotation: .allowed)])
        let res = try optimize(base)
        XCTAssertEqual(res.placements.count, 1)
        XCTAssertEqual(res.placements.first?.rotated, true, "yalnız 90° sığar")
        var fixedReq = base
        fixedReq.parts[0].rotation = .fixed
        XCTAssertThrowsError(try optimize(fixedReq)) { error in
            XCTAssertEqual(error as? PlacementError, .partExceedsStock(partId: "p1"))
        }
    }

    // — E1-S4a (K-5): çoklu levha + çoklu malzeme — docs/03 E1-S4 —

    // AC-1: malzeme havuzları ayrık — 18mm huş parçası 12mm MDF stoğuna asla yerleşmez,
    // MDF levhası hiç açılmaz; karışık istekte her levha tek malzemenin parçalarını taşır.
    func testE1S4a_AC1_materialPoolsSeparate() throws {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "mdf", materialId: "mdf12", w: 280_000, h: 207_000, qty: 5),
                     .init(id: "birch", materialId: "birch18", w: 244_000, h: 122_000, qty: 5)],
            parts: [.init(id: "b1", name: "govde", materialId: "birch18", w: 60_000, h: 40_000, qty: 2),
                    .init(id: "m1", name: "arkalik", materialId: "mdf12", w: 80_000, h: 50_000, qty: 2)])
        let res = try optimize(r)
        XCTAssertEqual(res.placements.count, 4)
        XCTAssertTrue(res.unplaced.isEmpty)
        XCTAssertEqual(res.stats.sheetCount, 2, "malzeme başına bir levha")
        let birchSheets = Set(res.placements.filter { $0.partId == "b1" }.map(\.sheetIndex))
        let mdfSheets = Set(res.placements.filter { $0.partId == "m1" }.map(\.sheetIndex))
        XCTAssertEqual(birchSheets.count, 1)
        XCTAssertEqual(mdfSheets.count, 1)
        XCTAssertTrue(birchSheets.isDisjoint(with: mdfSheets), "havuzlar ayrık")
        XCTAssertTrue(verifyInvariants(res, req: r).isEmpty)
    }

    // AC-3: stok tükenirse yerleşmeyenler unplaced'ta döner (sessiz atlama yok).
    func testE1S4a_AC3_stockExhausted_unplacedReported() throws {
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
            parts: [.init(id: "p1", name: "yarim", materialId: "m1", w: 244_000, h: 61_000, qty: 3, rotation: .fixed)])
        let res = try optimize(r)
        XCTAssertEqual(res.placements.count, 2, "tek levhaya iki yarım sığar")
        XCTAssertEqual(res.unplaced, ["p1"], "üçüncü örnek nedenli listede — sessiz düşmez")
        XCTAssertEqual(res.stats.sheetCount, 1)
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
