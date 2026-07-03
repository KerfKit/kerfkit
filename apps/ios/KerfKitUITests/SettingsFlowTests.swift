import XCTest

// M-8 kabulü (docs/13 §M-8): varsayılan kerf değişir → YENİ proje bu değerle açılır.
final class SettingsFlowTests: XCTestCase {

    @MainActor
    func testDefaultKerfAppliesToNewProject() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding", "-resetDefaults"]
        app.launch()

        app.buttons["Ayarlar"].tap()
        let kerfField = app.textFields["Testere payı — kerf (mm)"].firstMatch
        XCTAssertTrue(kerfField.waitForExistence(timeout: 5), "Ayarlar kerf alanı yok")
        XCTAssertEqual(kerfField.value as? String, "3", "Sıfırlanmış varsayılan 3 olmalı")
        // "4" eklenince değer 3'ten farklılaşır (imleç konumuna göre 34/43) —
        // önemli olan: ayarlarda NE kaldıysa yeni projeye O taşınır.
        kerfField.tap()
        kerfField.typeText("4")
        app.buttons["Bitti"].tap() // alan commit'i Bitti/odak kaybıyla gerçekleşir
        _ = app.buttons["Ayarlar"].waitForExistence(timeout: 3)
        app.buttons["Ayarlar"].tap() // yeniden açıp commit edilmiş değeri oku
        XCTAssertTrue(kerfField.waitForExistence(timeout: 5))
        let setValue = kerfField.value as? String
        app.buttons["Bitti"].tap()

        app.buttons["Yeni proje"].tap()
        app.buttons["Stok"].tap()
        let stokKerf = app.textFields["Testere payı — kerf (mm)"].firstMatch
        XCTAssertTrue(stokKerf.waitForExistence(timeout: 5))
        XCTAssertNotEqual(stokKerf.value as? String, "3", "Varsayılan değişmiş olmalı")
        XCTAssertEqual(stokKerf.value as? String, setValue,
                       "Yeni proje, ayarlanan varsayılan kerf ile açılmalı")
    }
}
