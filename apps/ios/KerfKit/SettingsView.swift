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
                LabeledContent("Unit", value: "mm")
            } header: {
                Text("Units")
            } footer: {
                Text("Fractional inches arrive together with the fraction pad.")
            }

            Section {
                clampedRow(String(localized: "Blade kerf (mm)"), id: "settings.kerf",
                           value: $defaultKerfMM, floor: 0)
                clampedRow(String(localized: "Edge trim (mm)"), id: "settings.trim",
                           value: $defaultTrimMM, floor: 0)
                Picker("Objective", selection: $defaultObjective) {
                    Text("Fewer sheets").tag(Objective.sheets.rawValue)
                    Text("Less waste").tag(Objective.waste.rawValue)
                    Text("Fewer cuts").tag(Objective.cuts.rawValue)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Defaults")
            } footer: {
                Text("Applies to new projects; existing ones keep their settings.")
            }

            Section {
                LabeledContent("Theme", value: String(localized: "Dark"))
            } header: {
                Text("Appearance")
            } footer: {
                Text("A light theme will be selectable once it\u{2019}s ready; PDFs always print light.")
            }

            Section {
                ShareLink(items: exportURLs) {
                    Label("Export everything (.cutproj)", systemImage: "square.and.arrow.up")
                }
                .disabled(exportURLs.isEmpty)
            } header: {
                Text("My data")
            } footer: {
                Text("Your data is yours — no account, no cloud; take it with you anytime.")
            }

            Section {
                Label("kerfkit collects no data", systemImage: "checkmark.seal")
                    .foregroundStyle(DesignTokens.colorTimber200)
            } header: {
                Text("Privacy")
            } footer: {
                Text("No analytics, no accounts, works fully offline.")
            }

            Section("Support") {
                if let mail = URL(string: "mailto:hello@kerfkit.app") {
                    Link(destination: mail) {
                        LabeledContent {
                            Text("replies in under 24h")
                        } label: {
                            Text(verbatim: "hello@kerfkit.app")
                                .foregroundStyle(DesignTokens.colorAmber500)
                        }
                    }
                }
            }

            Section("About") {
                LabeledContent("Version", value: "\(appVersion) · \(String(localized: "engine")) \(engineVersion)")
            }
        }
        .navigationTitle(Text("Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
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
    private func clampedRow(_ label: String, id: String, value: Binding<Int>, floor: Int) -> some View {
        let clamped = Binding(get: { value.wrappedValue },
                              set: { value.wrappedValue = max(floor, $0) })
        return HStack {
            Text(label)
            Spacer()
            TextField("", value: clamped, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .accessibilityIdentifier(id)
        }
    }
}
