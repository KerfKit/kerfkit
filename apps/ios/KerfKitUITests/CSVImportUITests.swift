import XCTest

// K-12 UI kabulü: panodaki TSV, Yapıştır ile içe akar; hatalı satır özeti bantta.
final class CSVImportUITests: XCTestCase {

    @MainActor
    func testPasteTSVImportsPartsAndReportsSkipped() throws {
        UIPasteboard.general.string = "Side\t720\t580\t2\nShelf\t764\t560\t2\nBadRow\t\nDoor\t396\t716\t1\n"

        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding", "-resetDefaults", "-freshStore", "-proFree"]
        app.launch()
        app.buttons["nav.newProject"].tap()

        let paste = app.buttons["Paste"].firstMatch
        XCTAssertTrue(paste.waitForExistence(timeout: 5), "PasteButton görünmeli")
        paste.tap()

        let summary = app.staticTexts["parts.importSummary"]
        XCTAssertTrue(summary.waitForExistence(timeout: 5), "İçe aktarma özeti çıkmalı")
        let text = summary.label
        XCTAssertTrue(text.contains("3"), "3 parça içe aktarılmalı: \(text)")
        XCTAssertTrue(text.contains("1"), "1 satır atlandı raporlanmalı: \(text)")
        XCTAssertTrue(app.staticTexts["Door"].waitForExistence(timeout: 3),
                      "İçe aktarılan parça listede görünmeli")
    }
}
