import XCTest
@testable import CutProj

// K-12 (E3-S3) AC'leri: ayraç otomatik algı · hatalı satır satır-numaralı raporla atlanır ·
// export→import kayıpsız. 3 gerçekçi fixture (docs/03).
final class CSVPartListTests: XCTestCase {

    private func fixture(_ name: String) throws -> String {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "fixtures/\(name)", withExtension: nil))
        return try String(contentsOf: url, encoding: .utf8)
    }

    func testCommaWithHeader_quotedNameAndBanding() throws {
        let text = try fixture("comma_with_header.csv")
        XCTAssertEqual(CSVPartList.detectDelimiter(text), ",")
        let (rows, issues) = CSVPartList.parse(text)
        XCTAssertTrue(issues.isEmpty, "\(issues)")
        XCTAssertEqual(rows.count, 4)
        XCTAssertEqual(rows[0].name, "Side, left", "Tırnaklı ad ayraç dahil kayıpsız")
        XCTAssertFalse(rows[0].rotationAllowed)
        XCTAssertEqual(rows[0].banding, BandingDoc(top: true, left: true, right: true))
        XCTAssertEqual(rows[3].qty, 6)
        XCTAssertTrue(rows[3].rotationAllowed, "Boş rotation → allowed")
    }

    func testSemicolonEU_decimalRowReportedAndSkipped() throws {
        let text = try fixture("semicolon_eu.csv")
        XCTAssertEqual(CSVPartList.detectDelimiter(text), ";")
        let (rows, issues) = CSVPartList.parse(text)
        XCTAssertEqual(rows.count, 3, "Ondalıklı satır atlanır, kalanlar yaşar")
        XCTAssertEqual(issues, [CSVPartList.LineIssue(
            line: 3, reason: .invalidNumber(field: "width", value: "396,5"))],
            "Hata, dosyadaki gerçek satır numarasıyla raporlanır")
    }

    func testTabPaste_missingColumnsAndBadQty() throws {
        let text = try fixture("tab_paste.tsv")
        XCTAssertEqual(CSVPartList.detectDelimiter(text), "\t")
        let (rows, issues) = CSVPartList.parse(text)
        XCTAssertEqual(rows.count, 3) // Side, Shelf (qty default 1), Door
        XCTAssertEqual(rows[1].qty, 1, "Eksik qty → 1")
        XCTAssertEqual(issues.count, 2)
        XCTAssertEqual(issues[0].line, 3)
        // Satır sonundaki ayraç trim'lenir — "Bad row<TAB>" tek dolu hücredir.
        XCTAssertEqual(issues[0].reason, .tooFewColumns(found: 1))
        XCTAssertEqual(issues[1].line, 5)
        XCTAssertEqual(issues[1].reason, .invalidNumber(field: "qty", value: "six"))
    }

    func testRoundTrip_lossless() throws {
        let original: [CSVPartList.Row] = [
            .init(name: "Side, \"left\"", width: 720, height: 580, qty: 2,
                  rotationAllowed: false, banding: BandingDoc(top: true, left: true, right: true)),
            .init(name: "Şerit; dar", width: 120, height: 60, qty: 12),
            .init(name: "Plain", width: 300, height: 200, qty: 1,
                  rotationAllowed: true, banding: BandingDoc(top: true, bottom: true, left: true, right: true)),
        ]
        let exported = CSVPartList.export(original)
        let (parsed, issues) = CSVPartList.parse(exported)
        XCTAssertTrue(issues.isEmpty, "\(issues)")
        XCTAssertEqual(parsed, original, "export → import kayıpsız (AC)")
    }
}
