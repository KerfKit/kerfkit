import XCTest
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
    func testAllVectors() throws {
        let urls = Bundle.module.urls(forResourcesWithExtension: "json", subdirectory: "vectors") ?? []
        XCTAssertFalse(urls.isEmpty, "vectors klasoru bos olmamali")
        for url in urls.sorted(by: { $0.absoluteString < $1.absoluteString }) {
            let data = try Data(contentsOf: url)
            let vector = try JSONDecoder().decode(GoldenVector.self, from: data)
            XCTAssertTrue(validate(vector.request).isEmpty, "\(vector.name): istek gecerli olmali")
            if vector.pending {
                continue // motor implementasyonu (E1) gelince expected doldurulur, pending false yapilir
            }
            let result = try optimize(vector.request)
            guard let exp = vector.expected else {
                XCTFail("\(vector.name): pending=false ise expected zorunlu")
                continue
            }
            XCTAssertEqual(result.stats.sheetCount, exp.sheetCount, vector.name)
            XCTAssertEqual(result.stats.wasteBps, exp.wasteBps, vector.name)
        }
    }
}
