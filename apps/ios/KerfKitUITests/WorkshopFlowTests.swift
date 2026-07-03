import XCTest

// M-5 kabulü (docs/13 §M-5): plan → Atölye Modu → adım say, KESİLDİ ilerletir, Geri al döner.
final class WorkshopFlowTests: XCTestCase {

    @MainActor
    func testWorkshopStepFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-autoOptimize"] // örnek proje + plan + Plan sekmesi (K-17)
        app.launch()

        let workshop = app.buttons["Atölye Modu"]
        XCTAssertTrue(workshop.waitForExistence(timeout: 8), "Plan sekmesinde Atölye Modu yok")
        workshop.tap()

        let done = app.buttons["✓ KESİLDİ"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        // Sayaç VoiceOver etiketiyle sorgulanır (görünen metin "KESİM 1/11").
        XCTAssertTrue(app.staticTexts["Kesim 1, toplam 11"].exists, "İlk adım 1/11 olmalı")

        done.tap()
        XCTAssertTrue(app.staticTexts["Kesim 2, toplam 11"].waitForExistence(timeout: 3),
                      "KESİLDİ sonrası 2/11'e ilerlemeli")

        app.buttons["Geri al"].tap()
        XCTAssertTrue(app.staticTexts["Kesim 1, toplam 11"].waitForExistence(timeout: 3),
                      "Geri al 1/11'e dönmeli")
    }
}
