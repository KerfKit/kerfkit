import SwiftUI
import CutModels

// Proje Detayı — docs/07 §1: 3 sekme (Parçalar | Stok | Plan), TabView yok.
struct ProjectDetailView: View {
    @Environment(ProjectStore.self) private var store

    var body: some View {
        @Bindable var store = store
        VStack(spacing: 0) {
            Picker("Sekme", selection: $store.selectedTab) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)

            switch store.selectedTab {
            case .parts: PartsTabView()
            case .stock: StockTabView()
            case .plan: PlanTabView()
            }
        }
        .navigationTitle(store.projectName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TextField("Proje adı", text: $store.projectName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .onSubmit { store.touch(markStale: false) }
            }
        }
        .background(DesignTokens.colorTimber950)
    }
}

// M-2 varyant A (D-2 ÖNERİ): tablo-yoğun liste + üstte sabit hızlı-ekleme satırı.
// Hedef akış: ad ⏎ en ⏎ boy ⏎ adet ⏎ → satır eklenir, imleç yeni ada döner (<60sn/10 parça).
struct PartsTabView: View {
    @Environment(ProjectStore.self) private var store

    @State private var name = ""
    @State private var widthMM: Int?
    @State private var heightMM: Int?
    @State private var qty: Int?
    @FocusState private var focus: Field?

    enum Field { case name, width, height, qty }

    var body: some View {
        @Bindable var store = store
        VStack(spacing: 0) {
            quickAddBar
            Text("Return → satır eklenir, imleç yeni ada geçer")
                .font(.caption2)
                .foregroundStyle(DesignTokens.colorTimber500)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 6)

            List {
                ForEach($store.parts) { $part in
                    PartRow(part: $part)
                }
                .onDelete { offsets in
                    store.parts.remove(atOffsets: offsets)
                    store.touch()
                }
                .listRowBackground(DesignTokens.colorTimber950)
            }
            .listStyle(.plain)
        }
    }

    private var quickAddBar: some View {
        HStack(spacing: 6) {
            TextField("Parça adı", text: $name)
                .focused($focus, equals: .name)
                .onSubmit { focus = .width }
            TextField("En", value: $widthMM, format: .number)
                .frame(width: 56)
                .focused($focus, equals: .width)
                .onSubmit { focus = .height }
            TextField("Boy", value: $heightMM, format: .number)
                .frame(width: 56)
                .focused($focus, equals: .height)
                .onSubmit { focus = .qty }
            TextField("Adet", value: $qty, format: .number)
                .frame(width: 44)
                .focused($focus, equals: .qty)
                .onSubmit(addPart)
            Button(action: addPart) {
                Image(systemName: "return")
                    .font(.headline)
                    .frame(width: 44, height: 40)
                    .background(DesignTokens.colorAmber500, in: RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(DesignTokens.colorTimber950)
            }
            .accessibilityLabel("Parçayı ekle")
        }
        .textFieldStyle(.roundedBorder)
        .keyboardType(.default)
        .padding(12)
        .background(DesignTokens.colorTimber900)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DesignTokens.colorAmber500).frame(height: 2)
        }
    }

    private func addPart() {
        guard let w = widthMM, let h = heightMM, w > 0, h > 0 else {
            focus = widthMM == nil ? .width : .height
            return
        }
        let partName = name.isEmpty ? "Parça \(store.parts.count + 1)" : name
        store.parts.append(.init(name: partName, widthMM: w, heightMM: h,
                                 qty: max(qty ?? 1, 1), rotationAllowed: true))
        store.touch()
        name = ""; widthMM = nil; heightMM = nil; qty = nil
        focus = .name
    }
}

// Tablo satırı: ad | en × boy | ×adet | damar kilidi (docs/04 §damar — kilit = rotasyon yasak).
private struct PartRow: View {
    @Environment(ProjectStore.self) private var store
    @Binding var part: PartInput

    var body: some View {
        HStack(spacing: 8) {
            Text(part.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignTokens.colorTimber50)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(part.widthMM) × \(part.heightMM)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(DesignTokens.colorTimber200)
            Text("×\(part.qty)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(DesignTokens.colorTimber300)
                .frame(width: 36, alignment: .trailing)
            Button {
                part.rotationAllowed.toggle()
                store.touch()
            } label: {
                Image(systemName: part.rotationAllowed ? "arrow.triangle.2.circlepath" : "lock.fill")
                    .foregroundStyle(part.rotationAllowed
                                     ? DesignTokens.colorTimber300 : DesignTokens.colorAmber500)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(part.rotationAllowed ? "Döndürme serbest" : "Damar kilitli")
        }
        .padding(.vertical, 2)
    }
}

// M-3 Stok — levha ölçüleri + kesim varsayılanları (kerf/trim, docs/04 §2).
struct StockTabView: View {
    @Environment(ProjectStore.self) private var store

    var body: some View {
        @Bindable var store = store
        Form {
            Section("Levha") {
                numberRow("En (mm)", value: $store.sheetWidthMM)
                numberRow("Boy (mm)", value: $store.sheetHeightMM)
                numberRow("Adet", value: $store.sheetQty)
            }
            Section("Kesim varsayılanları") {
                numberRow("Testere payı — kerf (mm)", value: $store.kerfMM)
                numberRow("Kenar tıraşı — trim (mm)", value: $store.trimMM)
            }
        }
        .scrollContentBackground(.hidden)
        .onChange(of: store.sheetWidthMM) { store.touch() }
        .onChange(of: store.sheetHeightMM) { store.touch() }
        .onChange(of: store.sheetQty) { store.touch() }
        .onChange(of: store.kerfMM) { store.touch() }
        .onChange(of: store.trimMM) { store.touch() }
    }

    private func numberRow(_ label: String, value: Binding<Int>) -> some View {
        LabeledContent(label) {
            TextField("", value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
        }
        .listRowBackground(DesignTokens.colorTimber900)
    }
}

// M-4 varyant A (D-2 ÖNERİ): stat kartları üstte, hedef seçici, bayat bandı, diyagram.
struct PlanTabView: View {
    @Environment(ProjectStore.self) private var store

    var body: some View {
        @Bindable var store = store
        ScrollView {
            VStack(spacing: 12) {
                if let result = store.result {
                    HStack(spacing: 8) {
                        StatCard(title: "levha", value: "\(result.stats.sheetCount)")
                        StatCard(title: "fire",
                                 value: String(format: "%%%.1f", Double(result.stats.wasteBps) / 100))
                        StatCard(title: "kesim", value: "\(result.stats.cutCount)")
                    }

                    objectivePicker

                    if store.stale {
                        staleBanner
                    }

                    if !result.unplaced.isEmpty {
                        warningCard("\(result.unplaced.count) parça yerleşmedi",
                                    detail: "Stok adedini artır ya da parça ölçülerini kontrol et.")
                    }

                    diagramPager(result)
                } else {
                    emptyPlan
                }

                if let message = store.errorMessage {
                    warningCard("Plan hesaplanamadı", detail: message)
                }
            }
            .padding(.horizontal)
        }
    }

    // Hedef değişince mevcut plan anında yeniden hesaplanır (motor deterministik + hızlı).
    private var objectivePicker: some View {
        @Bindable var store = store
        return Picker("Hedef", selection: $store.objective) {
            Text("Az levha").tag(Objective.sheets)
            Text("Az fire").tag(Objective.waste)
            Text("Az kesim").tag(Objective.cuts)
        }
        .pickerStyle(.segmented)
        .onChange(of: store.objective) {
            if store.result != nil { store.optimizePlan() }
        }
    }

    private var staleBanner: some View {
        HStack {
            Text("Girdiler değişti — plan bayat")
                .font(.footnote.weight(.bold))
            Spacer()
            Button("Yeniden hesapla") { store.optimizePlan() }
                .font(.footnote.weight(.bold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .foregroundStyle(DesignTokens.colorTimber950)
        .background(DesignTokens.colorOak500, in: RoundedRectangle(cornerRadius: 10))
    }

    private func warningCard(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote.weight(.bold))
                .foregroundStyle(DesignTokens.colorRed500)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(DesignTokens.colorTimber200)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(DesignTokens.colorTimber900, in: RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2).fill(DesignTokens.colorRed500).frame(width: 4)
        }
    }

    private func diagramPager(_ result: OptimizeResult) -> some View {
        // Diyagram, plan hangi girdiyle hesaplandıysa o levha ölçüsüyle çizilir —
        // stok sonradan değişse bile (bayat durumda) ölçek bozulmaz.
        let sheetW = store.lastRequest?.stocks.first?.w ?? store.sheetW
        let sheetH = store.lastRequest?.stocks.first?.h ?? store.sheetH
        return VStack(spacing: 6) {
            TabView {
                ForEach(0..<result.stats.sheetCount, id: \.self) { sheet in
                    SheetDiagram(
                        placements: result.placements.filter { $0.sheetIndex == sheet },
                        names: store.partNames,
                        sheetW: sheetW, sheetH: sheetH)
                        .padding(.bottom, result.stats.sheetCount > 1 ? 28 : 0)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: result.stats.sheetCount > 1 ? .always : .never))
            .frame(height: 240)
            if result.stats.sheetCount > 1 {
                Text("levha kaydır")
                    .font(.caption2)
                    .foregroundStyle(DesignTokens.colorTimber500)
            }
        }
    }

    private var emptyPlan: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.3x3.topleft.filled")
                .font(.system(size: 40))
                .foregroundStyle(DesignTokens.colorTimber500)
            Text(store.parts.isEmpty
                 ? "Önce Parçalar sekmesinden parça ekle."
                 : "\(store.parts.count) parça hazır — planı hesapla.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(DesignTokens.colorTimber300)
            Button {
                store.optimizePlan()
            } label: {
                Text("Planı hesapla")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(DesignTokens.colorTimber950)
            .disabled(store.parts.isEmpty)
        }
        .padding(.top, 48)
    }
}
