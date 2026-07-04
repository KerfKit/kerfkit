import XCTest

// K-15 kabulleri: katman kapıları (docs/08 §1) + şeffaf-fatura maddeleri (docs/08 §4)
// UI testiyle kanıtlanır. Ücretsiz durum varsayılan (StoreKit alımı yok).
final class PaywallGateUITests: XCTestCase {

    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-skipOnboarding", "-resetDefaults", "-freshStore", "-proFree"]
        app.launch()
        return app
    }

    @MainActor
    func testThirdProjectGateOpensPaywall() throws {
        let app = launch()
        // 2 proje serbest
        for _ in 0..<2 {
            app.buttons["nav.newProject"].tap()
            XCTAssertTrue(app.textFields["Part name"].waitForExistence(timeout: 5))
            app.navigationBars.buttons.firstMatch.tap() // geri
            _ = app.staticTexts["kerfkit"].waitForExistence(timeout: 3)
        }
        // 3. deneme → kapı diyaloğu (hesaplama sınırsız mesajı) → paywall
        app.buttons["nav.newProject"].tap()
        XCTAssertTrue(app.staticTexts["Free plan holds 2 saved projects"]
            .waitForExistence(timeout: 5), "3. projede kapı diyaloğu çıkmalı")
        app.buttons["See Pro options"].tap()

        // docs/08 §4 şeffaflık maddeleri paywall'da:
        XCTAssertTrue(app.staticTexts["Unlimited projects + PDF + Workshop Mode"]
            .waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["72 hours of everything. DOES NOT auto-renew — it just ends."]
            .exists, "Geçişte 'yenilenmez' tam punto (madde 2)")
        XCTAssertTrue(app.staticTexts["Everything included. Renews yearly — cancel anytime in Settings."]
            .exists, "Yıllıkta yenileme koşulu görünür (madde 1-2)")
        XCTAssertTrue(app.buttons["paywall.restore"].exists, "Restore görünür (madde 3)")
        XCTAssertTrue(app.links["Refund policy"].exists || app.buttons["Refund policy"].exists,
                      "İade politikası 1 dokunuş (madde 4)")
        XCTAssertTrue(app.buttons["paywall.lifetime.unlock"].waitForExistence(timeout: 5),
                      "Ürün kutuları fiyatla yüklenmeli")
        app.buttons["paywall.close"].tap()
        XCTAssertTrue(app.staticTexts["kerfkit"].waitForExistence(timeout: 3),
                      "Kapat → listeye dönüş (kapı nazik, zorlamasız)")
    }

    @MainActor
    func testPart21GateAndImportHold() throws {
        let app = launch()
        app.buttons["nav.newProject"].tap()
        XCTAssertTrue(app.textFields["Part name"].waitForExistence(timeout: 5))

        // 22 satırlık TSV yapıştır: 20 girer, 2'si Pro'ya kalır
        var tsv = ""
        for i in 1...22 { tsv += "P\(i)\t\(200 + i)\t\(100 + i)\t1\n" }
        UIPasteboard.general.string = tsv
        app.buttons["Paste"].firstMatch.tap()
        let summary = app.staticTexts["parts.importSummary"]
        XCTAssertTrue(summary.waitForExistence(timeout: 5))
        XCTAssertTrue(summary.label.contains("20"), "20 parça girmeli: \(summary.label)")
        XCTAssertTrue(summary.label.contains("2"), "2 parça Pro'ya kalmalı: \(summary.label)")

        // 21. parça elle → kapı (typeText insanüstü hızlı; her ⏎ sonrası odak beklenir)
        app.textFields["Part name"].tap()
        app.typeText("Extra\n"); waitFocus(app.textFields["W"])
        app.typeText("300\n"); waitFocus(app.textFields["H"])
        app.typeText("200\n"); waitFocus(app.textFields["Qty"])
        app.typeText("1\n")
        XCTAssertTrue(app.staticTexts["Free plan holds 20 parts per project"]
            .waitForExistence(timeout: 5), "21. parçada kapı çıkmalı")
        app.buttons["Not now"].tap()
    }

    @MainActor
    private func waitFocus(_ element: XCUIElement) {
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            if (element.value(forKey: "hasKeyboardFocus") as? Bool) == true { return }
            usleep(30_000)
        }
        XCTFail("Odak beklenen alana taşınmadı: \(element)")
    }

    @MainActor
    func testExportLockedTilesOpenPaywall() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-autoOptimize", "-resetDefaults", "-freshStore", "-proFree"] // örnek proje + plan
        app.launch()
        let locked = app.buttons["plan.locked.PDF"]
        XCTAssertTrue(locked.waitForExistence(timeout: 8),
                      "Ücretsizde dışa aktarım kilitli görünmeli")
        locked.tap()
        XCTAssertTrue(app.staticTexts["Unlimited projects + PDF + Workshop Mode"]
            .waitForExistence(timeout: 5), "Kilitli kutucuk paywall açmalı")
    }
}
