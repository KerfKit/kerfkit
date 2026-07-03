import XCTest

// M-8 kabulü (docs/13 §M-8): varsayılan kerf değişir → YENİ proje bu değerle açılır.
final class SettingsFlowTests: XCTestCase {

    @MainActor
    func testDefaultKerfAppliesToNewProject() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding", "-resetDefaults"]
        app.launch()

        app.buttons["nav.settings"].tap()
        let kerfField = app.textFields["settings.kerf"].firstMatch
        XCTAssertTrue(kerfField.waitForExistence(timeout: 5), "Ayarlar kerf alanı yok")
        XCTAssertEqual(kerfField.value as? String, "3", "Sıfırlanmış varsayılan 3 olmalı")
        // "4" eklenince değer 3'ten farklılaşır (imleç konumuna göre 34/43) —
        // önemli olan: ayarlarda NE kaldıysa yeni projeye O taşınır.
        kerfField.tap()
        kerfField.typeText("4")
        app.buttons["Done"].tap() // alan commit'i Done/odak kaybıyla gerçekleşir
        _ = app.buttons["nav.settings"].waitForExistence(timeout: 3)
        app.buttons["nav.settings"].tap() // yeniden açıp commit edilmiş değeri oku
        XCTAssertTrue(kerfField.waitForExistence(timeout: 5))
        let setValue = kerfField.value as? String
        app.buttons["Done"].tap()

        app.buttons["nav.newProject"].tap()
        app.buttons["Stock"].tap()
        let stokKerf = app.textFields["stock.kerf"].firstMatch
        XCTAssertTrue(stokKerf.waitForExistence(timeout: 5))
        XCTAssertNotEqual(stokKerf.value as? String, "3", "Varsayılan değişmiş olmalı")
        XCTAssertEqual(stokKerf.value as? String, setValue,
                       "Yeni proje, ayarlanan varsayılan kerf ile açılmalı")
    }
}
