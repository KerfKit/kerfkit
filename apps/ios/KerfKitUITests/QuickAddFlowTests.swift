import XCTest

// M-2 kabul kapısı (docs/17 K-UI şablonu — zorunlu): 10 parça yalnız klavyeyle <60sn.
// Akış M-2A hızlı-ekleme satırı: ad ⏎ en ⏎ boy ⏎ adet ⏎ → satır eklenir, imleç ada döner.
// Not: typeText insanüstü hızda bastığından her Return sonrası odağın taşınması beklenir
// (yalnız klavye — dokunma yok); insan yazımında bu bekleme doğal olarak oluşur.
final class QuickAddFlowTests: XCTestCase {

    @MainActor
    func testOnPartsWithKeyboardUnder60Seconds() throws {
        let app = XCUIApplication()
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

    @MainActor
    private func waitFocus(_ element: XCUIElement) {
        // XCTNSPredicateExpectation ~1sn aralıkla yoklar (40 bekleme ≈ +40sn harness
        // maliyeti) — süre ölçümünü bozmamak için sıkı döngüyle bekle.
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            if (element.value(forKey: "hasKeyboardFocus") as? Bool) == true { return }
            usleep(30_000)
        }
        XCTFail("Odak beklenen alana taşınmadı: \(element)")
    }
}
