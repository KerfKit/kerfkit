import XCTest
import CutModels
@testable import CutProj

// docs/03 E3-S1 AC: örnek dosya round-trip; bilinmeyen alanlar korunur (forward-compat).
final class ProjectDocTests: XCTestCase {
    // docs/05 §2 örneği + her seviyeye bilinmeyen alanlar eklenmiş hali
    let sample = """
    {
      "schemaVersion": 1,
      "id": "uuid-1",
      "name": "Mutfak Dolabı",
      "createdAt": "2026-07-02T10:00:00Z",
      "modifiedAt": "2026-07-03T09:30:00Z",
      "unitMode": "metric_mm",
      "defaults": { "kerf": 300, "trim": 1000, "objective": "sheets" },
      "futureTopLevel": { "nested": [1, 2.5, "x", null, true] },
      "materials": [
        { "id": "m1", "name": "18mm Birch Ply", "kind": "sheet",
          "thicknessLabel": "18mm", "costPerUnit": null, "grainAxis": "x",
          "futureMaterialField": "korunmali" }
      ],
      "stocks": [
        { "id": "s1", "materialId": "m1", "w": 244000, "h": 122000,
          "qty": 5, "isOffcut": false, "label": "4x8 sheet", "futureStockField": 42 }
      ],
      "parts": [
        { "id": "p1", "name": "Yan panel", "materialId": "m1",
          "w": 60000, "h": 40000, "qty": 4,
          "rotation": "allowed",
          "banding": { "top": true, "bottom": false, "left": true, "right": true },
          "notes": "", "futurePartField": [true, false] }
      ],
      "plans": []
    }
    """

    func testRoundTrip_preservesUnknownFields() throws {
        let doc = try ProjectIO.decode(Data(sample.utf8))
        XCTAssertEqual(doc.name, "Mutfak Dolabı")
        XCTAssertEqual(doc.parts.first?.banding?.top, true)
        // Bilinmeyen alanlar yakalandı mı?
        XCTAssertEqual(doc.extra["futureTopLevel"],
                       .object(["nested": .array([.integer(1), .number(2.5), .string("x"), .null, .bool(true)])]))
        XCTAssertEqual(doc.materials.first?.extra["futureMaterialField"], .string("korunmali"))
        XCTAssertEqual(doc.stocks.first?.extra["futureStockField"], .integer(42))
        XCTAssertEqual(doc.parts.first?.extra["futurePartField"], .array([.bool(true), .bool(false)]))
        // Kanonik round-trip: encode → decode → değer-eşit; ikinci tur encode byte-eşit
        let encoded1 = try ProjectIO.encode(doc)
        let doc2 = try ProjectIO.decode(encoded1)
        XCTAssertEqual(doc, doc2)
        let encoded2 = try ProjectIO.encode(doc2)
        XCTAssertEqual(encoded1, encoded2, "kanonik biçim kararlı olmalı (bit-eşit)")
    }

    func testNewerSchema_rejectedTyped() {
        let newer = sample.replacingOccurrences(of: "\"schemaVersion\": 1", with: "\"schemaVersion\": 99")
        XCTAssertThrowsError(try ProjectIO.decode(Data(newer.utf8))) { error in
            XCTAssertEqual(error as? ProjectIO.IOError,
                           .newerSchema(found: 99, supported: cutprojSchemaVersion))
        }
    }

    func testPlanEmbedsEngineTypes() throws {
        var doc = try ProjectIO.decode(Data(sample.utf8))
        let req = OptimizeRequest(unitMode: .metricMM, kerf: 300, trim: 0, objective: .sheets, seed: 1,
                                  stocks: doc.stocks.map(\.asSpec), parts: doc.parts.map(\.asSpec))
        let res = OptimizeResult(placements: [], stats: .init(sheetCount: 0, wasteBps: 0, cutCount: 0),
                                 unplaced: [], engineVersion: "0.2.0-dev")
        doc.plans.append(PlanDoc(id: "pl1", createdAt: "2026-07-03T10:00:00Z",
                                 engineVersion: "0.2.0-dev", request: req, result: res))
        let redecoded = try ProjectIO.decode(try ProjectIO.encode(doc))
        XCTAssertEqual(redecoded.plans.first?.request.parts.count, 1)
        XCTAssertEqual(redecoded, doc)
    }
}
