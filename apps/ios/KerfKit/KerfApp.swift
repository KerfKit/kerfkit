import SwiftUI

// KerfKit iOS — ekran seti M-1..M-6 (docs/13). Onboarding ilk açılışta bir kez (E4-S6);
// -skipOnboarding/-autoOptimize test kancaları atlar, -resetOnboarding yeniden gösterir.
@main
struct KerfApp: App {
    @State private var store = ProjectStore()
    @State private var onboardingShown: Bool
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboardingSeen") private var onboardingSeen = false

    init() {
        let args = CommandLine.arguments
        if args.contains("-resetOnboarding") {
            UserDefaults.standard.set(false, forKey: "onboardingSeen")
        }
        if args.contains("-resetDefaults") { // M-8 varsayılanlarını test için sıfırla
            for key in ["defaultKerfMM", "defaultTrimMM", "defaultObjective", "defaultUnitMode"] {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        let seen = UserDefaults.standard.bool(forKey: "onboardingSeen")
        let skip = args.contains("-skipOnboarding") || args.contains("-autoOptimize")
        _onboardingShown = State(initialValue: !seen && !skip)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(.dark) // koyu-öncelikli marka (docs/11 §3)
                .tint(DesignTokens.colorAmber500)
                .fullScreenCover(isPresented: $onboardingShown) {
                    OnboardingView { startSample in
                        onboardingSeen = true
                        onboardingShown = false
                        if startSample {
                            // Aha-anı garantisi: örnek proje + ilk optimizasyon + Plan sekmesi.
                            store.createProject(sample: true)
                            store.optimizePlan()
                            store.selectedTab = .plan
                        }
                    }
                    .environment(store)
                    .preferredColorScheme(.dark)
                }
        }
        .onChange(of: scenePhase) { _, phase in
            // Arka plana geçişte bekleyen otomatik kaydı hemen tamamla (K-11).
            if phase == .background { store.flush() }
        }
    }
}
