import SwiftUI
import CutModels

struct ContentView: View {
    @Environment(ProjectStore.self) private var store
    @State private var showPlan = false

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            Form {
                Section("Levha") {
                    LabeledContent("Boyut (mm)") {
                        HStack(spacing: 4) {
                            NumberField(value: $store.sheetWidthMM)
                            Text("×").foregroundStyle(DesignTokens.colorTimber500)
                            NumberField(value: $store.sheetHeightMM)
                        }
                    }
                    Stepper("Adet: \(store.sheetQty)", value: $store.sheetQty, in: 1...200)
                    LabeledContent("Kerf (mm)") { NumberField(value: $store.kerfMM) }
                    LabeledContent("Kenar payı (mm)") { NumberField(value: $store.trimMM) }
                    Picker("Hedef", selection: $store.objective) {
                        Text("Az levha").tag(Objective.sheets)
                        Text("Az fire").tag(Objective.waste)
                        Text("Az kesim").tag(Objective.cuts)
                    }
                }
                Section("Parçalar") {
                    ForEach($store.parts) { $part in
                        PartRow(part: $part)
                    }
                    .onDelete { store.parts.remove(atOffsets: $0) }
                    Button {
                        store.parts.append(.init(name: "", widthMM: 400, heightMM: 300, qty: 1, rotationAllowed: true))
                    } label: {
                        Label("Parça ekle", systemImage: "plus")
                    }
                }
                if let msg = store.errorMessage {
                    Section {
                        Label(msg, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(DesignTokens.colorAmber400)
                    }
                }
                Section {
                    Button {
                        store.optimizePlan()
                        showPlan = store.result != nil
                    } label: {
                        Text("Optimize et")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 44) // dokunma hedefi ≥44pt (docs/12)
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(DesignTokens.colorTimber950)
                }
            }
            .navigationTitle("kerf")
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                // UI smoke testi kancası (K-17 temeli): -autoOptimize ile plan doğrudan açılır
                if CommandLine.arguments.contains("-autoOptimize") {
                    store.optimizePlan()
                    showPlan = store.result != nil
                }
            }
            .sheet(isPresented: $showPlan) {
                if let result = store.result {
                    PlanView(result: result, store: store)
                }
            }
        }
    }
}

struct PartRow: View {
    @Binding var part: PartInput

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Parça adı", text: $part.name)
                    .font(.headline)
                Spacer()
                Button {
                    part.rotationAllowed.toggle()
                } label: {
                    Image(systemName: part.rotationAllowed ? "rotate.right" : "lock")
                        .foregroundStyle(part.rotationAllowed ? DesignTokens.colorAmber500 : DesignTokens.colorTimber500)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(part.rotationAllowed ? "Rotasyon serbest" : "Damar kilidi: rotasyon kapalı")
            }
            HStack(spacing: 4) {
                NumberField(value: $part.widthMM)
                Text("×").foregroundStyle(DesignTokens.colorTimber500)
                NumberField(value: $part.heightMM)
                Text("mm").foregroundStyle(DesignTokens.colorTimber500)
                Spacer()
                Stepper("×\(part.qty)", value: $part.qty, in: 1...500)
                    .fixedSize()
            }
        }
        .padding(.vertical, 2)
    }
}

struct NumberField: View {
    @Binding var value: Int

    var body: some View {
        TextField("0", value: $value, format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 64)
            .textFieldStyle(.roundedBorder)
    }
}
