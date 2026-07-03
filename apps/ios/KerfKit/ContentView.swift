import SwiftUI
import CutModels

// M-1 Projeler Listesi (docs/07 E-1) — kartlar + boş durumda "Örnek projeyi dene".
struct ContentView: View {
    @Environment(ProjectStore.self) private var store
    @State private var autoOptimizeRan = false
    @State private var settingsOpen = false

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            Group {
                if store.summaries.isEmpty {
                    emptyState
                } else {
                    projectList
                }
            }
            .navigationTitle("kerfkit")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        settingsOpen = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Ayarlar")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.createProject(sample: false)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Yeni proje")
                }
            }
            .sheet(isPresented: $settingsOpen) {
                NavigationStack { SettingsView() }
                    .environment(store)
                    .preferredColorScheme(.dark)
            }
            .navigationDestination(isPresented: $store.detailOpen) {
                ProjectDetailView()
            }
            .onChange(of: store.detailOpen) {
                // Detaydan dönüş: bekleyen otomatik kaydı bitirip özetleri tazele.
                if !store.detailOpen { store.flushThenReload() }
            }
            .onAppear {
                // UI smoke testi kancası (K-17): -autoOptimize örnek projeyle planı açar.
                // Tek sefer — onAppear her pop-back'te tetiklenir, kanca tekrarlamamalı.
                if !autoOptimizeRan, CommandLine.arguments.contains("-autoOptimize") {
                    autoOptimizeRan = true
                    store.createProject(sample: true)
                    store.optimizePlan()
                    store.selectedTab = .plan
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.split.3x1")
                .font(.system(size: 44))
                .foregroundStyle(DesignTokens.colorTimber500)
            Text("İlk projeni oluştur")
                .font(.title3.bold())
                .foregroundStyle(DesignTokens.colorTimber50)
            Text("Ya da tek dokunuşla dolu bir projeyle başla —\nkesim planını hemen gör.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(DesignTokens.colorTimber300)
            Button {
                store.createProject(sample: true)
                store.optimizePlan()
                store.selectedTab = .plan
            } label: {
                Text("Örnek projeyi dene")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(DesignTokens.colorTimber950)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var projectList: some View {
        List {
            ForEach(store.summaries, id: \.id) { summary in
                Button {
                    store.open(id: summary.id)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(summary.name)
                            .font(.headline)
                            .foregroundStyle(DesignTokens.colorTimber50)
                        Text(store.planSummaries[summary.id] ?? "Henüz plan yok")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.colorTimber300)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete { store.deleteProjects(at: $0) }
        }
    }
}
