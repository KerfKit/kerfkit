import XCTest
import CutModels
@testable import CutCore

// docs/04 §5 — E1-S1b: değişmez doğrulayıcı + placementsHash.
final class VerifyTests: XCTestCase {
    // Fikstür kataloğu: doğrulayıcı partId→malzeme çözümü yaptığından, kullanılan
    // her id istekte tanımlı olmalı (boyutlar doğrulayıcı için önemsiz).
    func req(stockW: Units = 244_000, stockH: Units = 122_000,
             partIds: [String] = ["p1", "p2", "a", "b", "c", "d"]) -> OptimizeRequest {
        .init(unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
              stocks: [.init(id: "s1", materialId: "m1", w: stockW, h: stockH, qty: 5)],
              parts: partIds.map { .init(id: $0, name: $0, materialId: "m1", w: 10_000, h: 10_000, qty: 1) })
    }
    func result(_ placements: [Placement]) -> OptimizeResult {
        .init(placements: placements, stats: .init(sheetCount: 1, wasteBps: 0, cutCount: 0),
              unplaced: [], engineVersion: engineVersion)
    }
    func pl(_ id: String, _ x: Units, _ y: Units, _ w: Units, _ h: Units, sheet: Int = 0) -> Placement {
        .init(partId: id, sheetIndex: sheet, x: x, y: y, w: w, h: h, rotated: false)
    }

    // — placementsHash (docs/04 §5 kanonik format) —

    func testHash_emptyList_isFNVOffsetBasis() {
        // Hiç bayt karıştırılmadan FNV-1a ofset tabanı: 0xcbf29ce484222325
        XCTAssertEqual(placementsHash([]), "cbf29ce484222325")
    }
    func testHash_deterministic() {
        let ps = [pl("p1", 0, 0, 60_000, 40_000), pl("p2", 60_000, 0, 60_000, 40_000)]
        XCTAssertEqual(placementsHash(ps), placementsHash(ps))
        XCTAssertEqual(placementsHash(ps).count, 16)
    }
    func testHash_orderSensitive() {
        let a = pl("p1", 0, 0, 60_000, 40_000), b = pl("p2", 60_000, 0, 60_000, 40_000)
        XCTAssertNotEqual(placementsHash([a, b]), placementsHash([b, a]))
    }
    func testHash_fieldSensitive() {
        let a = pl("p1", 0, 0, 60_000, 40_000)
        var rotated = a
        rotated.rotated = true
        XCTAssertNotEqual(placementsHash([a]), placementsHash([rotated]))
        var moved = a
        moved.x = 1
        XCTAssertNotEqual(placementsHash([a]), placementsHash([moved]))
    }

    // — verifyInvariants —

    func testInvariants_engineOutput_clean() throws {
        let r = OptimizeRequest(unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
                                stocks: [.init(id: "s1", materialId: "m1", w: 244_000, h: 122_000, qty: 1)],
                                parts: [.init(id: "p1", name: "panel", materialId: "m1", w: 60_000, h: 40_000, qty: 4)])
        let res = try optimize(r)
        XCTAssertTrue(verifyInvariants(res, req: r).isEmpty)
    }
    func testInvariants_overlap_reported() {
        let res = result([pl("p1", 0, 0, 60_000, 40_000), pl("p2", 30_000, 20_000, 60_000, 40_000)])
        let v = verifyInvariants(res, req: req())
        XCTAssertTrue(v.contains { $0.kind == .overlap && Set($0.subjectIds) == ["p1", "p2"] })
    }
    func testInvariants_touchingEdges_noOverlap() {
        // Kenar paylaşımı (kerf=0) çakışma DEĞİLDİR
        let res = result([pl("p1", 0, 0, 60_000, 40_000), pl("p2", 60_000, 0, 60_000, 40_000)])
        XCTAssertFalse(verifyInvariants(res, req: req()).contains { $0.kind == .overlap })
    }
    func testInvariants_outOfBounds_reported() {
        let res = result([pl("p1", 200_000, 100_000, 60_000, 40_000)]) // 260k×140k > 244k×122k
        let v = verifyInvariants(res, req: req())
        XCTAssertTrue(v.contains { $0.kind == .outOfBounds && $0.subjectIds == ["p1"] })
    }
    func testInvariants_guillotineLayout_valid() {
        // İki tam şerit: y=40_000'de tek yatay kesim yeter
        let res = result([pl("p1", 0, 0, 244_000, 40_000), pl("p2", 0, 40_000, 244_000, 82_000)])
        XCTAssertTrue(verifyInvariants(res, req: req()).isEmpty)
    }
    func testInvariants_pinwheel_notGuillotine() {
        // Klasik fırıldak: çakışmasız, sınır içi, ama hiçbir tam kesim parçasız geçemez
        let res = result([
            pl("a", 0, 0, 60_000, 40_000),
            pl("b", 60_000, 0, 40_000, 60_000),
            pl("c", 40_000, 60_000, 60_000, 40_000),
            pl("d", 0, 40_000, 40_000, 60_000),
        ])
        let v = verifyInvariants(res, req: req(stockW: 100_000, stockH: 100_000))
        XCTAssertTrue(v.contains { $0.kind == .notGuillotine })
        XCTAssertFalse(v.contains { $0.kind == .overlap })
        XCTAssertFalse(v.contains { $0.kind == .outOfBounds })
    }
    func testInvariants_emptySideFirstCut_valid() {
        // İlk kesimin bir yanı boş kalabilir (kenar firesi): alt şeritte iki parça, üst boş
        let res = result([pl("p1", 0, 0, 100_000, 30_000), pl("p2", 100_000, 0, 80_000, 30_000)])
        XCTAssertTrue(verifyInvariants(res, req: req()).isEmpty)
    }

    // — R-3 inceleme bulguları (E1-S1b) —

    func testInvariants_zeroSizePlacement_reportedNotCrash() {
        // Sıfır-boyutlu yerleşim: SIGSEGV değil, tipli ihlal raporu
        let res = result([pl("p1", 5_000, 0, 0, 10_000), pl("p2", 20_000, 0, 10_000, 10_000)])
        let v = verifyInvariants(res, req: req())
        XCTAssertTrue(v.contains { $0.kind == .nonPositiveSize && $0.subjectIds == ["p1"] })
    }
    func testInvariants_unknownPartId_reported() {
        // Katalog dışı partId sessizce temiz geçmemeli
        let res = result([pl("ghost", 0, 0, 10_000, 10_000)])
        let v = verifyInvariants(res, req: req())
        XCTAssertTrue(v.contains { $0.kind == .unknownPart && $0.subjectIds == ["ghost"] })
    }
    func testInvariants_boundsUsePlacementOwnMaterial() {
        // Sınır kontrolü her yerleşimin KENDİ malzemesiyle ölçülmeli; levhadaki ilk
        // (katalog dışı) yerleşim malzeme çözümünü gevşetememeli
        let r = OptimizeRequest(
            unitMode: .metricMM, kerf: 0, trim: 0, objective: .sheets, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: 100_000, h: 100_000, qty: 1),
                     .init(id: "s2", materialId: "m2", w: 900_000, h: 900_000, qty: 1)],
            parts: [.init(id: "p1", name: "kucuk", materialId: "m1", w: 10_000, h: 10_000, qty: 1)])
        let res = result([pl("ghost", 0, 0, 5_000, 5_000), pl("p1", 500_000, 500_000, 10_000, 10_000)])
        let v = verifyInvariants(res, req: r)
        XCTAssertTrue(v.contains { $0.kind == .outOfBounds && $0.subjectIds == ["p1"] },
                      "p1 kendi malzemesinin (m1, 100k) çok dışında — m2 stoğuyla aklanmamalı")
    }
    func testHash_separatorInPartId_noCollision() {
        // Enjektiflik: partId içindeki ayırıcılar kaçışlanmalı (inceleme çakışma kanıtı)
        let crafted = [Placement(partId: "x|0|0|0|1|1|0;y", sheetIndex: 0, x: 0, y: 0, w: 1, h: 1, rotated: false)]
        let pair = [Placement(partId: "x", sheetIndex: 0, x: 0, y: 0, w: 1, h: 1, rotated: false),
                    Placement(partId: "y", sheetIndex: 0, x: 0, y: 0, w: 1, h: 1, rotated: false)]
        XCTAssertNotEqual(placementsHash(crafted), placementsHash(pair))
    }
    func testInvariants_multiPinwheel_notGuillotine_terminates() {
        // Birden çok bağımsız guillotine-dışı küme: arama bütçesi erken ve SAĞLAM false verir
        // (geçerli yerleşim ≤ 2n−1 çağrıda kanıtlandığından bütçe aşımı ⇒ geçersiz)
        var ps: [Placement] = []
        for k in 0..<3 {
            let ox = Units(k) * 110_000
            ps.append(pl("a", ox, 0, 60_000, 40_000))
            ps.append(pl("b", ox + 60_000, 0, 40_000, 60_000))
            ps.append(pl("c", ox + 40_000, 60_000, 60_000, 40_000))
            ps.append(pl("d", ox, 40_000, 40_000, 60_000))
        }
        let v = verifyInvariants(result(ps), req: req(stockW: 400_000, stockH: 100_000))
        XCTAssertTrue(v.contains { $0.kind == .notGuillotine })
    }
}
