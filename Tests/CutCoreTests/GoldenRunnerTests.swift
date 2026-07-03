import XCTest
import Foundation
import CutModels
@testable import CutCore

struct GoldenVector: Codable {
    var name: String
    var pending: Bool
    var request: OptimizeRequest
    var expected: Expected?
    struct Expected: Codable { var sheetCount: Int; var wasteBps: Int; var cutCount: Int; var placementsHash: String }
}

final class GoldenRunnerTests: XCTestCase {
    // Vektörler VectorData.swift'ten (gömülü) okunur: Android asset dosya sistemi dizin
    // listelemeyi desteklemez, Wasm'da Bundle yok (K-30). Tek kaynak vectors/*.json —
    // testEmbeddedVectorsMatchDisk (macOS) gömülü kopyanın bayat kalmasını engeller;
    // güncelleme: node tools/gen-vectors-swift.mjs

    #if !SKIP
    func testEmbeddedVectorsMatchDisk() throws {
        guard let dir = Bundle.module.resourceURL?.appendingPathComponent("vectors") else {
            XCTFail("vectors klasoru bulunamadi"); return
        }
        let onDisk = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
        XCTAssertEqual(onDisk.map(\.lastPathComponent).sorted(), VectorData.all.keys.sorted(),
                       "gömülü vektör seti dizinle eşleşmiyor — node tools/gen-vectors-swift.mjs koş")
        for url in onDisk {
            let disk = try String(contentsOf: url, encoding: .utf8)
            XCTAssertEqual(VectorData.all[url.lastPathComponent], disk,
                           "\(url.lastPathComponent) gömülü kopyadan sapmış — node tools/gen-vectors-swift.mjs koş")
        }
    }
    #endif

    func testAllVectors() throws {
        let names = VectorData.all.keys.sorted()
        XCTAssertFalse(names.isEmpty, "gömülü vektör seti boş olmamalı")
        for name in names {
            guard let json = VectorData.all[name],
                  let data = json.data(using: .utf8) else {
                XCTFail("\(name): gömülü veri okunamadı")
                continue
            }
            let vector = try JSONDecoder().decode(GoldenVector.self, from: data)
            XCTAssertTrue(validate(vector.request).isEmpty, "\(vector.name): istek gecerli olmali")
            if vector.pending {
                continue // motor implementasyonu gelince expected doldurulur, pending false yapilir
            }
            let result = try optimize(vector.request)
            guard let exp = vector.expected else {
                XCTFail("\(vector.name): pending=false ise expected zorunlu")
                continue
            }
            XCTAssertEqual(result.stats.sheetCount, exp.sheetCount, vector.name)
            XCTAssertEqual(result.stats.wasteBps, exp.wasteBps, vector.name)
            XCTAssertEqual(result.stats.cutCount, exp.cutCount, vector.name)
            XCTAssertEqual(placementsHash(result.placements), exp.placementsHash, vector.name)
            // docs/04 §5 — değişmez doğrulayıcı her vektörde ayrıca koşar
            let violations = verifyInvariants(result, req: vector.request)
            XCTAssertTrue(violations.isEmpty, "\(vector.name): \(violations)")
        }
    }
}
