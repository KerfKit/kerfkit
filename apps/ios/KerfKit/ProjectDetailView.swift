import SwiftUI
import CutModels
import CutProj

// Proje Detayı — docs/07 §1: 3 sekme (Parçalar | Stok | Plan), TabView yok.
struct ProjectDetailView: View {
    @Environment(ProjectStore.self) private var store

    var body: some View {
        @Bindable var store = store
        VStack(spacing: 0) {
            Picker("Tab", selection: $store.selectedTab) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Text(tab.title).tag(tab)
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
                TextField(String(localized: "Project name"), text: $store.projectName)
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
    @Environment(ProStore.self) private var pro
    @State private var partGateOpen = false
    @State private var paywallOpen = false

    @State private var name = ""
    @State private var widthMM: Int?
    @State private var heightMM: Int?
    @State private var w64 = 0 // imperial hızlı-giriş (1/64″)
    @State private var h64 = 0
    @State private var wPadOpen = false
    @State private var hPadOpen = false
    @State private var qty: Int?
    @FocusState private var focus: Field?

    enum Field { case name, width, height, qty }

    var body: some View {
        @Bindable var store = store
        VStack(spacing: 0) {
            quickAddBar
            HStack(spacing: 8) {
                Text("Return adds the part and jumps back to Name")
                    .font(.caption2)
                    .foregroundStyle(DesignTokens.colorTimber500)
                Spacer()
                // K-12: pano içe aktarma — PasteButton izin uyarısı çıkarmaz (M-2 bandının
                // gizlilik-dostu hali; sistem kendi dilinde "Yapıştır" yazar).
                PasteButton(payloadType: String.self) { [isPro = pro.status.isPro] items in
                    Task { @MainActor in
                        if let text = items.first {
                            store.importParts(fromCSV: text,
                                              limit: isPro ? nil : max(0, 20 - store.parts.count))
                        }
                    }
                }
                .labelStyle(.titleOnly)
                .controlSize(.small)
                .tint(DesignTokens.colorTimber700)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            // Kapı uyarısı gerçek bir görünüme asılmalı — EmptyView modifier'ları sunulmaz.
            .alert(Text("Free plan holds 20 parts per project"), isPresented: $partGateOpen) {
                Button(String(localized: "See Pro options")) { paywallOpen = true }
                Button(String(localized: "Not now"), role: .cancel) {}
            } message: {
                Text("Part 21 needs Pro — or split the project into two.")
            }
            .sheet(isPresented: $paywallOpen) { PaywallView().preferredColorScheme(.dark) }

            if let summary = store.importSummary {
                Text(summary)
                    .font(.caption)
                    .foregroundStyle(DesignTokens.colorAmber400)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .accessibilityIdentifier("parts.importSummary")
            }

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
            TextField(String(localized: "Part name"), text: $name)
                .autocorrectionDisabled()
                .focused($focus, equals: .name)
                .onSubmit { focus = .width }
            if store.unitMode == .imperialFrac64 {
                // Kesir pad'i (E4-S2b): 60pt tuşlu sayfa; klavye yerine dokunuşla.
                padButton(value: w64, placeholder: String(localized: "W"), id: "parts.wpad") { wPadOpen = true }
                    .sheet(isPresented: $wPadOpen) {
                        FractionPad(title: String(localized: "W"), frac64: $w64)
                            .presentationDetents([.medium]).preferredColorScheme(.dark)
                    }
                padButton(value: h64, placeholder: String(localized: "H"), id: "parts.hpad") { hPadOpen = true }
                    .sheet(isPresented: $hPadOpen) {
                        FractionPad(title: String(localized: "H"), frac64: $h64)
                            .presentationDetents([.medium]).preferredColorScheme(.dark)
                    }
            } else {
                TextField(String(localized: "W"), value: $widthMM, format: .number)
                    .frame(width: 56)
                    .focused($focus, equals: .width)
                    .onSubmit { focus = .height }
                TextField(String(localized: "H"), value: $heightMM, format: .number)
                    .frame(width: 56)
                    .focused($focus, equals: .height)
                    .onSubmit { focus = .qty }
            }
            TextField(String(localized: "Qty"), value: $qty, format: .number)
                .frame(width: 44)
                .focused($focus, equals: .qty)
                .onSubmit(addPart)
            Button(action: addPart) {
                Image(systemName: "return")
                    .font(.headline)
                    .frame(width: 44, height: 44) // HIG asgari dokunma hedefi
                    .background(DesignTokens.colorAmber500, in: RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(DesignTokens.colorTimber950)
            }
            .accessibilityLabel(String(localized: "Add part"))
            .accessibilityIdentifier("parts.add")
        }
        .textFieldStyle(.roundedBorder)
        .controlSize(.large) // alan yüksekliği ≥44pt (HIG)
        .keyboardType(.default)
        .padding(12)
        .background(DesignTokens.colorTimber900)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DesignTokens.colorAmber500).frame(height: 2)
        }
    }

    private func addPart() {
        // K-15 kapısı (docs/08 §1): ücretsizde proje başına 20 parça.
        if !pro.status.isPro && store.parts.count >= 20 {
            partGateOpen = true
            return
        }
        let w: Int, h: Int
        if store.unitMode == .imperialFrac64 {
            w = w64; h = h64
            guard w > 0, h > 0 else { wPadOpen = w == 0; hPadOpen = w != 0 && h == 0; return }
        } else {
            guard let mw = widthMM, let mh = heightMM, mw > 0, mh > 0 else {
                focus = widthMM == nil ? .width : .height
                return
            }
            w = mw; h = mh
        }
        let partName = name.isEmpty ? String(localized: "Part \(store.parts.count + 1)") : name
        store.parts.append(.init(name: partName, width: w, height: h,
                                 qty: max(qty ?? 1, 1), rotationAllowed: true))
        store.touch()
        name = ""; widthMM = nil; heightMM = nil; w64 = 0; h64 = 0; qty = nil
        focus = .name
    }

    private func padButton(value: Int, placeholder: String, id: String,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(value == 0 ? placeholder : UnitFormat.fraction(frac64: value))
                .font(.subheadline.monospacedDigit())
                .lineLimit(1).minimumScaleFactor(0.6)
                .frame(width: 64, height: 44)
                .background(DesignTokens.colorTimber800, in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(value == 0 ? DesignTokens.colorTimber500 : DesignTokens.colorTimber50)
        }
        .accessibilityIdentifier(id)
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
            Text(UnitFormat.size(part.width, part.height, unit: store.unitMode))
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
                    .frame(width: 44, height: 44) // HIG asgari dokunma hedefi
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(part.rotationAllowed ? String(localized: "Rotation allowed") : String(localized: "Grain locked"))

            bandingMenu
        }
    }

    // Bant rozeti (docs/13 M-2: 4 nokta) — Menu ile kenar seçimi, sistem bileşeni.
    private var bandingMenu: some View {
        Menu {
            Toggle("Top edge", isOn: bandBinding(\.top))
            Toggle("Bottom edge", isOn: bandBinding(\.bottom))
            Toggle("Left edge", isOn: bandBinding(\.left))
            Toggle("Right edge", isOn: bandBinding(\.right))
            Divider()
            Button("All four edges") { setBanding(BandingDoc(top: true, bottom: true, left: true, right: true)) }
            Button("No banding") { setBanding(BandingDoc()) }
        } label: {
            BandingDots(banding: part.banding)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(String(localized: "Edge banding"))
    }

    private func bandBinding(_ path: WritableKeyPath<BandingDoc, Bool>) -> Binding<Bool> {
        Binding(get: { part.banding[keyPath: path] },
                set: { part.banding[keyPath: path] = $0; store.touch() })
    }

    private func setBanding(_ value: BandingDoc) {
        part.banding = value
        store.touch()
    }
}

// 4 nokta: üst/alt/sol/sağ kenar bantlıysa amber dolu.
struct BandingDots: View {
    let banding: BandingDoc

    var body: some View {
        VStack(spacing: 3) {
            dot(banding.top)
            HStack(spacing: 9) { dot(banding.left); dot(banding.right) }
            dot(banding.bottom)
        }
    }

    private func dot(_ on: Bool) -> some View {
        Circle()
            .fill(on ? DesignTokens.colorAmber500 : DesignTokens.colorTimber700)
            .frame(width: 5, height: 5)
    }
}

// M-3 Stok — levha ölçüleri + kesim varsayılanları (kerf/trim, docs/04 §2).
struct StockTabView: View {
    @Environment(ProjectStore.self) private var store

    var body: some View {
        @Bindable var store = store
        Form {
            Section("Sheet") {
                Picker("Unit", selection: Binding(get: { store.unitMode },
                                                  set: { store.setUnitMode($0) })) {
                    Text("mm").tag(UnitMode.metricMM)
                    Text("inches").tag(UnitMode.imperialFrac64)
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("stock.unit")
                .listRowBackground(DesignTokens.colorTimber900)
                if store.unitMode == .imperialFrac64 {
                    FractionField(label: String(localized: "Width"), id: "stock.width",
                                  frac64: $store.sheetWidth)
                        .listRowBackground(DesignTokens.colorTimber900)
                    FractionField(label: String(localized: "Height"), id: "stock.height",
                                  frac64: $store.sheetHeight)
                        .listRowBackground(DesignTokens.colorTimber900)
                } else {
                    numberRow(String(localized: "Width (mm)"), id: "stock.width", value: $store.sheetWidth, floor: 1)
                    numberRow(String(localized: "Height (mm)"), id: "stock.height", value: $store.sheetHeight, floor: 1)
                }
                numberRow(String(localized: "Quantity"), id: "stock.qty", value: $store.sheetQty, floor: 1)
            }
            Section("Cutting defaults") {
                if store.unitMode == .imperialFrac64 {
                    FractionField(label: String(localized: "Blade kerf"), id: "stock.kerf",
                                  frac64: $store.kerf)
                        .listRowBackground(DesignTokens.colorTimber900)
                    FractionField(label: String(localized: "Edge trim"), id: "stock.trim",
                                  frac64: $store.trim)
                        .listRowBackground(DesignTokens.colorTimber900)
                } else {
                    numberRow(String(localized: "Blade kerf (mm)"), id: "stock.kerf", value: $store.kerf, floor: 0)
                    numberRow(String(localized: "Edge trim (mm)"), id: "stock.trim", value: $store.trim, floor: 0)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .onChange(of: [store.sheetWidth, store.sheetHeight, store.sheetQty,
                       store.kerf, store.trim]) { store.touch() }
    }

    // floor: 0/eksi girilirse diyagramda sıfıra bölme ve motora geçersiz stok gitmesin.
    private func numberRow(_ label: String, id: String, value: Binding<Int>, floor: Int) -> some View {
        let clamped = Binding(get: { value.wrappedValue },
                              set: { value.wrappedValue = max(floor, $0) })
        return LabeledContent(label) {
            TextField("", value: clamped, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .accessibilityIdentifier(id)
        }
        .listRowBackground(DesignTokens.colorTimber900)
    }
}

// M-4 varyant A (D-2 ÖNERİ): stat kartları üstte, hedef seçici, bayat bandı, diyagram.
struct PlanTabView: View {
    @Environment(ProjectStore.self) private var store
    @Environment(ProStore.self) private var pro
    @State private var exportPaywallOpen = false

    var body: some View {
        @Bindable var store = store
        ScrollView {
            VStack(spacing: 12) {
                if let result = store.result {
                    HStack(spacing: 8) {
                        StatCard(title: String(localized: "sheets"), value: "\(result.stats.sheetCount)")
                        StatCard(title: String(localized: "waste"), value: result.stats.wastePercentText)
                        StatCard(title: String(localized: "cuts"), value: "\(result.stats.cutCount)")
                        StatCard(title: String(localized: "banding"), value: store.bandLengthText)
                    }

                    objectivePicker

                    if store.stale {
                        staleBanner
                    }

                    if !result.unplaced.isEmpty {
                        warningCard(String(localized: "\(result.unplaced.count) parts didn\u{2019}t fit"),
                                    detail: String(localized: "Add more stock or check the part sizes."))
                    }

                    diagramPager(result)

                    // M-4 alt eylem: Atölye Modu (docs/13) — kesime tezgâh başında rehberlik.
                    Button {
                        store.workshopOpen = true
                    } label: {
                        Label(String(localized: "Workshop Mode"), systemImage: "hammer.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(DesignTokens.colorTimber950)
                    .disabled(store.stale)

                    shareRow(result)
                } else {
                    emptyPlan
                }

                if let message = store.errorMessage {
                    warningCard(String(localized: "Couldn\u{2019}t calculate the plan"), detail: message)
                }
            }
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $store.workshopOpen) {
            WorkshopView().environment(store)
        }
    }

    // Hedef değişince mevcut plan anında yeniden hesaplanır (motor deterministik + hızlı).
    private var objectivePicker: some View {
        @Bindable var store = store
        return Picker("Objective", selection: $store.objective) {
            Text("Fewer sheets").tag(Objective.sheets)
            Text("Less waste").tag(Objective.waste)
            Text("Fewer cuts").tag(Objective.cuts)
        }
        .pickerStyle(.segmented)
        .onChange(of: store.objective) {
            // Parça kalmadıysa yeniden hesaplama son geçerli planı silmesin.
            if store.result != nil && !store.parts.isEmpty { store.optimizePlan() }
        }
    }

    // K-13 paylaşım satırı — K-15: dışa aktarım Pro kilidi (docs/08 §1).
    private func shareRow(_ result: OptimizeResult) -> some View {
        Group {
        if !pro.status.isPro {
            HStack(spacing: 8) {
                lockedTile("PDF")
                lockedTile("CSV")
                lockedTile("DXF")
                lockedTile(".cutproj")
            }
            .sheet(isPresented: $exportPaywallOpen) { PaywallView().preferredColorScheme(.dark) }
        } else {
        HStack(spacing: 8) {
            if let request = store.lastRequest {
                ShareLink(item: PlanPDFExport(input: PlanPDF.Input(
                    projectName: store.projectName,
                    unit: store.unitMode,
                    dateText: Date().formatted(date: .long, time: .omitted),
                    parts: store.parts, result: result, request: request,
                    names: store.partNames)),
                          preview: SharePreview("\(store.projectName).pdf")) {
                    shareTile("PDF", icon: "doc.richtext")
                }
            }
            ShareLink(item: CSVExport(name: store.projectName, rows: store.csvRows, unit: store.unitMode),
                      preview: SharePreview("\(store.projectName).csv")) {
                shareTile("CSV", icon: "tablecells")
            }
            if let request = store.lastRequest, let stock = request.stocks.first {
                // E9-S4: levha başına DXF (CNC işi levha bazlı; çoklu levhada dosya listesi)
                ShareLink(items: (0..<result.stats.sheetCount).map { i in
                    DXFExport(id: i,
                              fileName: PlanDXF.fileName(projectName: store.projectName,
                                                         sheetIndex: i,
                                                         sheetCount: result.stats.sheetCount),
                              input: PlanDXF.Input(sheetW: stock.w, sheetH: stock.h,
                                                   unit: store.unitMode,
                                                   placements: result.placements,
                                                   names: store.partNames))
                }, preview: { SharePreview($0.fileName) }) {
                    shareTile("DXF", icon: "scissors")
                }
            }
            ShareLink(item: CutprojExport(doc: store.exportableDoc()),
                      preview: SharePreview("\(store.projectName).cutproj")) {
                shareTile(".cutproj", icon: "square.and.arrow.up")
            }
        }
        }
        }
    }

    private func lockedTile(_ title: String) -> some View {
        Button {
            exportPaywallOpen = true
        } label: {
            Label { Text(verbatim: title) } icon: { Image(systemName: "lock.fill") }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(DesignTokens.colorTimber900, in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(DesignTokens.colorTimber300)
        }
        .accessibilityLabel(String(localized: "\(title) — unlock with Pro"))
        .accessibilityIdentifier("plan.locked.\(title)")
    }

    private func shareTile(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(DesignTokens.colorTimber900, in: RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(DesignTokens.colorTimber50)
    }

    private var staleBanner: some View {
        HStack {
            Text("Inputs changed — plan is stale")
                .font(.footnote.weight(.bold))
            Spacer()
            Button("Recalculate") { store.optimizePlan() }
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
                Text("swipe for sheets")
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
                 ? String(localized: "Add parts on the Parts tab first.")
                 : String(localized: "\(store.parts.count) parts ready — calculate the plan."))
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(DesignTokens.colorTimber300)
            Button {
                store.optimizePlan()
            } label: {
                Text("Calculate plan")
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
