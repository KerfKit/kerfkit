import SwiftUI

// KerfKit iOS — ekran seti M-1..M-6 (docs/13). Onboarding ilk açılışta bir kez (E4-S6);
// -skipOnboarding/-autoOptimize test kancaları atlar, -resetOnboarding yeniden gösterir.
@main
struct KerfApp: App {
    @State private var store: ProjectStore
    @State private var proStore: ProStore
    @State private var foundingStore = FoundingStore()
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
        if args.contains("-freshStore") { // K-15 kapı testleri: temiz mağaza
            if let dir = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                      in: .userDomainMask, appropriateFor: nil, create: true) {
                for suffix in ["", "-wal", "-shm"] {
                    try? FileManager.default.removeItem(at: dir.appendingPathComponent("kerfkit.sqlite\(suffix)"))
                }
            }
        }
        _store = State(initialValue: ProjectStore())
        // K-15 testleri: yerel StoreKit ortamında eski test alımları kalabiliyor;
        // -proFree dinleyiciyi kapatır, durum .free sabitlenir (kapılar determinist).
        _proStore = State(initialValue: ProStore(autoStart: !args.contains("-proFree")))
        let seen = UserDefaults.standard.bool(forKey: "onboardingSeen")
        let skip = args.contains("-skipOnboarding") || args.contains("-autoOptimize")
        _onboardingShown = State(initialValue: !seen && !skip)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(proStore)
                .environment(foundingStore)
                .preferredColorScheme(.dark) // koyu-öncelikli marka (docs/11 §3)
                .tint(DesignTokens.colorAmber500)
                .task { await foundingStore.refresh() } // K-16: açılışta bayrağı tazele
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
