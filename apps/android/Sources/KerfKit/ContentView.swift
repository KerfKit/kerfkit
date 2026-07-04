import SwiftUI
import CutModels

// K-31 (E9-S1) — M-1 proje listesi → M-2 parça girişi → M-4 plan (docs/13).
// iOS birebir kopya DEĞİL: Skip Fuse'un köprülediği bileşen alt kümesiyle sade
// parite; Compose'da kırılan bileşenler docs/13 Android-notlarına işlenir.
struct ContentView: View {
    @State var vm = ProjectVM()
    @State var path: [UUID] = []
    @AppStorage("onboardingSeen") var onboardingSeen = false

    var body: some View {
        Group {
            if onboardingSeen {
                NavigationStack(path: $path) {
                    ProjectListView()
                }
            } else {
                // M-6: ilk açılışta bir kez; CTA → örnek proje + ilk optimizasyon + Plan inişi.
                OnboardingView { startSample in
                    onboardingSeen = true
                    if startSample, let sample = vm.projects.first {
                        vm.optimize(projectID: sample.id)
                        vm.pendingPlanJump = sample.id
                        path.append(sample.id)
                    }
                }
            }
        }
        .environment(vm)
    }
}

// M-1 — proje listesi
struct ProjectListView: View {
    @Environment(ProjectVM.self) var vm

    var body: some View {
        List {
            ForEach(vm.projects) { project in
                NavigationLink(value: project.id) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(project.name).font(.headline)
                        Text("\(project.parts.count) parts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                for offset in offsets {
                    vm.deleteProject(vm.projects[offset].id)
                }
            }
        }
        .navigationTitle(Text(verbatim: "kerfkit"))
        .navigationDestination(for: UUID.self) { id in
            ProjectDetailView(projectID: id)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    _ = vm.addProject(named: "New Project")
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(Text("New Project"))
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel(Text("Settings"))
            }
        }
    }
}

// M-2 parça girişi + M-4 plan — tek detay ekranında iki sekme (iskelet paritesi)
struct ProjectDetailView: View {
    @Environment(ProjectVM.self) var vm
    let projectID: UUID

    @State var tab = 0
    @State var name = ""
    @State var widthText = ""
    @State var heightText = ""
    @State var qtyText = ""

    var project: AndroidProject? {
        vm.projects.first { $0.id == projectID }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker(selection: $tab) {
                Text("Parts").tag(0)
                Text("Plan").tag(1)
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if tab == 0 {
                partsTab
            } else {
                planTab
            }
        }
        .navigationTitle(Text(project?.name ?? ""))
        .onAppear {
            if vm.pendingPlanJump == projectID {
                tab = 1
                vm.pendingPlanJump = nil
            }
        }
    }

    // — M-2: hızlı ekleme satırı + parça listesi —
    var partsTab: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                TextField("Part name", text: $name)
                    .textFieldStyle(.roundedBorder)
                TextField("W", text: $widthText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 64)
                TextField("H", text: $heightText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 64)
                TextField("Qty", text: $qtyText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 48)
                Button {
                    addPart()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel(Text("Add part"))
            }
            .padding()

            List {
                ForEach(vm.parts(of: projectID)) { part in
                    HStack {
                        Text(part.name)
                        Spacer()
                        Text(verbatim: "\(part.widthMM)×\(part.heightMM)  ×\(part.qty)")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                }
                .onDelete { offsets in
                    let rows = vm.parts(of: projectID)
                    for offset in offsets {
                        vm.removePart(from: projectID, partID: rows[offset].id)
                    }
                }
            }
        }
    }

    func addPart() {
        guard let w = Int(widthText), let h = Int(heightText), w > 0, h > 0 else { return }
        let qty = Int(qtyText) ?? 1
        let partName = name.isEmpty
            ? "Part \(vm.parts(of: projectID).count + 1)"
            : name
        vm.addPart(to: projectID, PartRow(name: partName, widthMM: w, heightMM: h, qty: max(1, qty)))
        name = ""
        widthText = ""
        heightText = ""
        qtyText = ""
    }

    // — M-4: plan istatistikleri + levha diyagramı —
    var planTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    vm.optimize(projectID: projectID)
                } label: {
                    Text("Optimize")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)

                if let error = vm.planError {
                    Text(verbatim: error).foregroundStyle(.red).font(.caption)
                }

                if let plan = vm.plan {
                    HStack(spacing: 16) {
                        statCell("Sheets", "\(plan.stats.sheetCount)")
                        statCell("Waste", wasteText(plan.stats.wasteBps))
                        statCell("Cuts", "\(plan.stats.cutCount)")
                    }
                    if !plan.unplaced.isEmpty {
                        Text("\(plan.unplaced.count) parts did not fit")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    NavigationLink {
                        WorkshopView(plan: plan, names: vm.partNames)
                    } label: {
                        Text("Workshop Mode")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.bordered)

                    ForEach(0..<plan.stats.sheetCount, id: \.self) { sheet in
                        SheetDiagram(placements: plan.placements.filter { $0.sheetIndex == sheet },
                                     sheetW: vm.sheetW, sheetH: vm.sheetH)
                    }
                } else if vm.planError == nil {
                    Text("Add parts, then optimize.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }

    func statCell(_ title: LocalizedStringKey, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: value).font(.title3.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func wasteText(_ bps: Int) -> String {
        // wasteBps 1/100 % (Int — platform paritesi); yerel ondalık E9-S2'de.
        "\(bps / 100).\(String(format: "%02d", bps % 100))%"
    }
}

// M-4 diyagramı: GeometryReader + dikdörtgenler (Canvas köprüsü E9-S2'de denenir).
struct SheetDiagram: View {
    let placements: [Placement]
    let sheetW: Units
    let sheetH: Units

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / CGFloat(sheetW)
            // Taşma düzeltmesi (E9-S2b): dış aspectRatio köprüde birebir ölçeklemiyordu;
            // iç kutuya AÇIK frame verilir, parçalar bu kutuya kırpılır.
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .border(Color.gray.opacity(0.5), width: 1)
                ForEach(0..<placements.count, id: \.self) { i in
                    let p = placements[i]
                    Rectangle()
                        .fill(Color.orange.opacity(0.55))
                        .border(Color.orange, width: 1)
                        .frame(width: CGFloat(p.w) * scale, height: CGFloat(p.h) * scale)
                        .offset(x: CGFloat(p.x) * scale, y: CGFloat(p.y) * scale)
                }
            }
            .frame(width: geo.size.width, height: CGFloat(sheetH) * scale, alignment: .topLeading)
            .clipped()
        }
        .aspectRatio(CGFloat(sheetW) / CGFloat(sheetH), contentMode: .fit)
    }
}
