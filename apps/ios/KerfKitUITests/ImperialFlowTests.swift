import XCTest

// E4-S2b kabulü: birim inç'e çevrilir → 4×8ft varsayılan stok → kesir pad'iyle
// 30 1/2″ × 15 1/4″ parça girilir → satırda kesirli gösterim → plan hesaplanır.
final class ImperialFlowTests: XCTestCase {

    @MainActor
    func testImperialProjectWithFractionPad() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding", "-resetDefaults"]
        app.launch()

        // Varsayılan birimi İnç yap
        app.buttons["nav.settings"].tap()
        app.buttons["settings.unit"].tap()
        app.buttons["Inches"].tap()
        app.buttons["Done"].tap()

        // Yeni proje: stok 96″ × 48″ ile açılmalı
        app.buttons["nav.newProject"].tap()
        app.buttons["Stock"].tap()
        let widthField = app.buttons["stock.width"]
        XCTAssertTrue(widthField.waitForExistence(timeout: 5))
        XCTAssertTrue((widthField.value as? String)?.contains("96") == true,
                      "Imperial varsayılan levha 96″ olmalı: \(String(describing: widthField.value))")

        // Parça: W = 30 1/2″ (pad: 3,0 + hızlı 1/2), H = 15 1/4″
        app.buttons["Parts"].tap()
        app.buttons["parts.wpad"].tap()
        app.buttons["3"].tap(); app.buttons["0"].tap(); app.buttons["1/2"].firstMatch.tap()
        app.buttons["pad.done"].tap()
        app.buttons["parts.hpad"].tap()
        app.buttons["1"].tap(); app.buttons["5"].tap(); app.buttons["1/4"].firstMatch.tap()
        app.buttons["pad.done"].tap()
        app.buttons["parts.add"].tap()

        XCTAssertTrue(app.staticTexts["30 1/2\u{2033} × 15 1/4\u{2033}"]
            .waitForExistence(timeout: 5), "Satırda kesirli boyut görünmeli")

        // Plan hesaplanabilmeli (motor imperial birim uzayında koşar)
        app.buttons["Plan"].tap()
        app.buttons["Calculate plan"].tap()
        XCTAssertTrue(app.buttons["Workshop Mode"].waitForExistence(timeout: 8),
                      "Imperial projede plan hesaplanmalı")
    }
}
