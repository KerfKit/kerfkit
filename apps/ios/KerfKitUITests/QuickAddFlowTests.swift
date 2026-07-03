import XCTest

// M-2 kabul kapısı (docs/17 K-UI şablonu — zorunlu): 10 parça yalnız klavyeyle <60sn.
// Akış M-2A hızlı-ekleme satırı: ad ⏎ en ⏎ boy ⏎ adet ⏎ → satır eklenir, imleç ada döner.
// Not: typeText insanüstü hızda bastığından her Return sonrası odağın taşınması beklenir
// (yalnız klavye — dokunma yok); insan yazımında bu bekleme doğal olarak oluşur.
final class QuickAddFlowTests: XCTestCase {

    @MainActor
    func testOnPartsWithKeyboardUnder60Seconds() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding"]
        app.launch()

        // Yeni boş proje — detay Parçalar sekmesinde açılır.
        app.buttons["Yeni proje"].tap()
        let name = app.textFields["Parça adı"]
        let width = app.textFields["En"]
        let height = app.textFields["Boy"]
        let qty = app.textFields["Adet"]
        XCTAssertTrue(name.waitForExistence(timeout: 5), "Hızlı-ekleme satırı görünmedi")

        let start = Date()
        name.tap()
        for i in 1...10 {
            app.typeText("Parca\(i)\n"); waitFocus(width)
            app.typeText("\(300 + i)\n"); waitFocus(height)
            app.typeText("\(200 + i)\n"); waitFocus(qty)
            app.typeText("2\n"); waitFocus(name)
        }
        let elapsed = Date().timeIntervalSince(start)

        // Liste tembel — son satır ekran dışında kalabilir; önce kaydır.
        app.swipeUp()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Parca10"].waitForExistence(timeout: 5),
                      "10. parça listede görünmedi")
        XCTAssertTrue(app.staticTexts["310 × 210"].exists, "10. parçanın ölçüsü yanlış")
        XCTAssertLessThan(elapsed, 60, "10 parça klavye akışı 60 saniyeyi aştı: \(elapsed)sn")
    }

    // docs/17 K-UI şablonu: 44pt dokunma hedefi assert'i (HIG asgarisi — mağaza reddi riski).
    @MainActor
    func testTouchTargetsAtLeast44pt() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding"]
        app.launch()
        app.buttons["Yeni proje"].tap()
        let name = app.textFields["Parça adı"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        app.typeText("Test\n"); waitFocus(app.textFields["En"])
        app.typeText("300\n"); waitFocus(app.textFields["Boy"])
        app.typeText("200\n"); waitFocus(app.textFields["Adet"])
        app.typeText("1\n")

        for label in ["Parçayı ekle", "Döndürme serbest", "Bant kenarları"] {
            let el = app.buttons[label].firstMatch
            XCTAssertTrue(el.waitForExistence(timeout: 3), "\(label) bulunamadı")
            XCTAssertGreaterThanOrEqual(el.frame.width, 44, "\(label) genişliği <44pt")
            XCTAssertGreaterThanOrEqual(el.frame.height, 44, "\(label) yüksekliği <44pt")
        }
    }

    @MainActor
    private func waitFocus(_ element: XCUIElement) {
        // XCTNSPredicateExpectation ~1sn aralıkla yoklar (40 bekleme ≈ +40sn harness
        // maliyeti) — süre ölçümünü bozmamak için sıkı döngüyle bekle.
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            if (element.value(forKey: "hasKeyboardFocus") as? Bool) == true { return }
            usleep(30_000)
        }
        XCTFail("Odak beklenen alana taşınmadı: \(element)")
    }
}
