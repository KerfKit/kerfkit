import SwiftUI

// M-8 Android paritesi (E9-S2) — iOS anahtarlarıyla aynı varsayılanlar
// (defaultKerfMM/defaultTrimMM/defaultObjective); yeni projelere işler,
// mevcut plan ayarları korunur. Dürüst gizlilik metni (toggle yok — veri yok).
struct SettingsView: View {
    @AppStorage("defaultKerfMM") var defaultKerfMM = 3
    @AppStorage("defaultTrimMM") var defaultTrimMM = 0
    @AppStorage("defaultObjective") var defaultObjective = "sheets"

    var body: some View {
        Form {
            Section {
                Picker("Blade kerf (mm)", selection: $defaultKerfMM) {
                    ForEach([0, 2, 3, 4, 5], id: \.self) { v in
                        Text(verbatim: "\(v) mm").tag(v)
                    }
                }
                Picker("Edge trim (mm)", selection: $defaultTrimMM) {
                    ForEach([0, 5, 10, 15], id: \.self) { v in
                        Text(verbatim: "\(v) mm").tag(v)
                    }
                }
                Picker("Objective", selection: $defaultObjective) {
                    Text("Fewer sheets").tag("sheets")
                    Text("Less waste").tag("waste")
                    Text("Fewer cuts").tag("cuts")
                }
            } header: {
                Text("Defaults")
            } footer: {
                Text("Applies to new projects; existing ones keep their settings.")
            }

            Section {
                Text("kerfkit collects no data")
            } header: {
                Text("Privacy")
            } footer: {
                Text("No analytics, no accounts, works fully offline.")
            }

            Section {
                LabeledContent("Version") { Text(verbatim: "0.0.1") }
            }
        }
        .navigationTitle(Text("Settings"))
    }
}
