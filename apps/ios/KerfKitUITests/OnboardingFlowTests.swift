import XCTest

// M-6 kabulü (docs/07 E-6): 3 ekran → "Örnek projeyle dene" → otomatik ilk optimizasyon
// → Plan sekmesine iniş (aha-anı). Paywall onboarding'de görünmez.
final class OnboardingFlowTests: XCTestCase {

    @MainActor
    func testOnboardingToFirstPlan() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetOnboarding", "-freshStore", "-proFree"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Enter the sheet, type your parts, get the plan."]
            .waitForExistence(timeout: 5), "Onboarding 1. ekran gelmedi")

        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["Kerf, grain, edge banding — the pro details are covered."]
            .waitForExistence(timeout: 3))

        app.swipeLeft()
        let cta = app.buttons["onboarding.sampleCTA"]
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Buy once. No subscription."].exists)
        cta.tap()

        // Aha-anı: Plan sekmesinde gerçek plan (Atölye Modu butonu yalnız planla görünür).
        XCTAssertTrue(app.buttons["Workshop Mode"].waitForExistence(timeout: 8),
                      "CTA sonrası Plan sekmesine plan ile inilmedi")
    }

    @MainActor
    func testOnboardingShowsOnceAfterSkip() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetOnboarding", "-freshStore", "-proFree"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Enter the sheet, type your parts, get the plan."]
            .waitForExistence(timeout: 5))
        app.buttons["Skip intro"].tap()
        XCTAssertTrue(app.staticTexts["kerfkit"].waitForExistence(timeout: 3), "Atla listeye dönmeli")

        // İkinci açılış (arg'sız): onboarding bir daha gelmemeli.
        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertFalse(app.staticTexts["Enter the sheet, type your parts, get the plan."]
            .waitForExistence(timeout: 3), "Onboarding ikinci açılışta tekrarlanmamalı")
    }
}
