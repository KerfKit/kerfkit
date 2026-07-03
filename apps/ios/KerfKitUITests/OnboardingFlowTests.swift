import XCTest

// M-6 kabulü (docs/07 E-6): 3 ekran → "Örnek projeyle dene" → otomatik ilk optimizasyon
// → Plan sekmesine iniş (aha-anı). Paywall onboarding'de görünmez.
final class OnboardingFlowTests: XCTestCase {

    @MainActor
    func testOnboardingToFirstPlan() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetOnboarding"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Levhayı gir, parçaları yaz, planı al."]
            .waitForExistence(timeout: 5), "Onboarding 1. ekran gelmedi")

        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["Kerf, damar, kenar bandı — pro detaylar hazır."]
            .waitForExistence(timeout: 3))

        app.swipeLeft()
        let cta = app.buttons["Örnek projeyle dene"]
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Tek seferlik satın al. Abonelik yok."].exists)
        cta.tap()

        // Aha-anı: Plan sekmesinde gerçek plan (Atölye Modu butonu yalnız planla görünür).
        XCTAssertTrue(app.buttons["Atölye Modu"].waitForExistence(timeout: 8),
                      "CTA sonrası Plan sekmesine plan ile inilmedi")
    }

    @MainActor
    func testOnboardingShowsOnceAfterSkip() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetOnboarding"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Levhayı gir, parçaları yaz, planı al."]
            .waitForExistence(timeout: 5))
        app.buttons["Onboarding'i atla"].tap()
        XCTAssertTrue(app.staticTexts["kerfkit"].waitForExistence(timeout: 3), "Atla listeye dönmeli")

        // İkinci açılış (arg'sız): onboarding bir daha gelmemeli.
        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertFalse(app.staticTexts["Levhayı gir, parçaları yaz, planı al."]
            .waitForExistence(timeout: 3), "Onboarding ikinci açılışta tekrarlanmamalı")
    }
}
