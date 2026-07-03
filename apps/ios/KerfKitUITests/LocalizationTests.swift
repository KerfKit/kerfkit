import XCTest

// L-1 kabulü: taban EN, TR String Catalog'dan gelir — TR locale ile açılan uygulamada
// gerçek Türkçe metinler görünmeli (docs/18 §2; üslup: günlük dil, §5.0).
final class LocalizationTests: XCTestCase {

    @MainActor
    func testTurkishLocaleShowsTurkishUI() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding", "-AppleLanguages", "(tr)",
                               "-AppleLocale", "tr_TR"]
        app.launch()

        app.buttons["nav.newProject"].tap()
        XCTAssertTrue(app.buttons["Parçalar"].waitForExistence(timeout: 5),
                      "TR'de sekme 'Parçalar' olmalı")
        XCTAssertTrue(app.textFields["Parça adı"].exists, "TR'de alan 'Parça adı' olmalı")
        app.buttons["Stok"].tap()
        XCTAssertTrue(app.staticTexts["Testere payı (mm)"].waitForExistence(timeout: 3),
                      "TR'de kerf satırı 'Testere payı (mm)' olmalı")
    }
}
