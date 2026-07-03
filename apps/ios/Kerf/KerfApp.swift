import SwiftUI

// Kerf iOS — MVP iskeleti (E4 özü: parça girişi + optimize + plan diyagramı).
// Tam ekran seti (M-1..M-8) D-2 mockup döngüsüyle gelir (docs/15 §2, docs/13).
@main
struct KerfApp: App {
    @State private var store = ProjectStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(.dark) // koyu-öncelikli marka (docs/11 §3)
                .tint(DesignTokens.colorAmber500)
        }
    }
}
