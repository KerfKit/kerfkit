import SwiftUI

// Kerf iOS — MVP iskeleti (E4 özü: parça girişi + optimize + plan diyagramı).
// Tam ekran seti (M-1..M-8) D-2 mockup döngüsüyle gelir (docs/15 §2, docs/13).
@main
struct KerfApp: App {
    @State private var store = ProjectStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(.dark) // koyu-öncelikli marka (docs/11 §3)
                .tint(DesignTokens.colorAmber500)
        }
        .onChange(of: scenePhase) { _, phase in
            // Arka plana geçişte bekleyen otomatik kaydı hemen tamamla (K-11).
            if phase == .background { store.flush() }
        }
    }
}
