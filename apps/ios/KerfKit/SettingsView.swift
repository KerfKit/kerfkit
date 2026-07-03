import SwiftUI
import CutModels
import CutCore

// M-8 Ayarlar (E4-S7, D-5 ÖNERİ A: klasik gruplu form) — docs/13 §M-8.
// Sahte kontrol yok: inç kesir pad'iyle, tema açık-palet türetilince seçilebilir olur.
struct SettingsView: View {
    @Environment(ProjectStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @AppStorage("defaultKerfMM") private var defaultKerfMM = 3
    @AppStorage("defaultTrimMM") private var defaultTrimMM = 0
    @AppStorage("defaultObjective") private var defaultObjective = Objective.sheets.rawValue

    @State private var exportURLs: [URL] = []

    var body: some View {
        Form {
            Section {
                LabeledContent("Birim", value: "mm")
            } header: {
                Text("Birimler")
            } footer: {
                Text("Kesirli inç, kesir pad'iyle birlikte gelecek.")
            }

            Section {
                clampedRow("Testere payı — kerf (mm)", value: $defaultKerfMM, floor: 0)
                clampedRow("Kenar tıraşı — trim (mm)", value: $defaultTrimMM, floor: 0)
                Picker("Hedef", selection: $defaultObjective) {
                    Text("Az levha").tag(Objective.sheets.rawValue)
                    Text("Az fire").tag(Objective.waste.rawValue)
                    Text("Az kesim").tag(Objective.cuts.rawValue)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Varsayılanlar")
            } footer: {
                Text("Yeni projelere uygulanır; mevcut projeler etkilenmez.")
            }

            Section {
                LabeledContent("Tema", value: "Koyu")
            } header: {
                Text("Görünüm")
            } footer: {
                Text("Açık tema türetildiğinde seçilebilir olacak; PDF her zaman açık temada.")
            }

            Section {
                ShareLink(items: exportURLs) {
                    Label("Tümünü dışa aktar (.cutproj)", systemImage: "square.and.arrow.up")
                }
                .disabled(exportURLs.isEmpty)
            } header: {
                Text("Verilerim")
            } footer: {
                Text("Verin senindir — hesap yok, bulut yok; istediğin an dışarı al.")
            }

            Section {
                Label("kerfkit hiçbir veri toplamaz", systemImage: "checkmark.seal")
                    .foregroundStyle(DesignTokens.colorTimber200)
            } header: {
                Text("Gizlilik")
            } footer: {
                Text("Analitik yok, hesap yok, internet gerekmez.")
            }

            Section("Destek") {
                if let mail = URL(string: "mailto:hello@kerfkit.app") {
                    Link(destination: mail) {
                        LabeledContent {
                            Text("<24s yanıt")
                        } label: {
                            Text("hello@kerfkit.app")
                                .foregroundStyle(DesignTokens.colorAmber500)
                        }
                    }
                }
            }

            Section("Hakkında") {
                LabeledContent("Sürüm", value: "\(appVersion) · motor \(engineVersion)")
            }
        }
        .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Bitti") { dismiss() }
            }
        }
        .scrollContentBackground(.hidden)
        .background(DesignTokens.colorTimber950)
        .task { exportURLs = store.exportAllProjects() }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    // HStack bilinçli (LabeledContent değil): birleşik erişilebilirlik öğesi alanın
    // klavye odağını UI testinden gizliyor.
    private func clampedRow(_ label: String, value: Binding<Int>, floor: Int) -> some View {
        let clamped = Binding(get: { value.wrappedValue },
                              set: { value.wrappedValue = max(floor, $0) })
        return HStack {
            Text(label)
            Spacer()
            TextField("", value: clamped, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .accessibilityIdentifier(label)
        }
    }
}
