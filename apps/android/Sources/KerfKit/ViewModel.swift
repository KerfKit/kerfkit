import Foundation
import Observation
import SkipFuse
import CutCore
import CutModels

// K-31 (E9-S1) — Android iskeleti: bellek-içi proje deposu + GERÇEK motor çağrısı.
// Kalıcılık (SkipSQL) ve birim paritesi E9-S2'de; burada amaç uçtan uca akışın
// Android'de native Swift motoruyla çalıştığının kanıtı. Birimler docs/04 §2:
// metrik modda 1 birim = 0.01mm (UI tam mm girer, ×100 saklanır).
struct PartRow: Identifiable, Hashable {
    let id: UUID
    var name: String
    var widthMM: Int
    var heightMM: Int
    var qty: Int

    init(id: UUID = UUID(), name: String, widthMM: Int, heightMM: Int, qty: Int) {
        self.id = id
        self.name = name
        self.widthMM = widthMM
        self.heightMM = heightMM
        self.qty = qty
    }
}

struct AndroidProject: Identifiable, Hashable {
    let id: UUID
    var name: String
    var parts: [PartRow]

    init(id: UUID = UUID(), name: String, parts: [PartRow] = []) {
        self.id = id
        self.name = name
        self.parts = parts
    }
}

@Observable public class ProjectVM {
    var projects: [AndroidProject] = []
    var plan: OptimizeResult?
    var planError: String?
    var pendingPlanJump: UUID?     // M-6 CTA → detay Plan sekmesine iniş
    var partNames: [String: String] = [:]

    // Varsayılan levha 2440×1220 + kerf 3mm (docs/04 örnek standardı; Units = Int64).
    let sheetW: Units = 244_000
    let sheetH: Units = 122_000
    let kerf: Units = 300

    init() {
        projects = [Self.sampleProject()]
    }

    static func sampleProject() -> AndroidProject {
        AndroidProject(name: "Sample cabinet", parts: [
            PartRow(name: "Side", widthMM: 720, heightMM: 400, qty: 2),
            PartRow(name: "Shelf", widthMM: 764, heightMM: 380, qty: 3),
            PartRow(name: "Top", widthMM: 800, heightMM: 400, qty: 1),
            PartRow(name: "Back", widthMM: 764, heightMM: 700, qty: 1),
        ])
    }

    func addProject(named name: String) -> AndroidProject {
        let project = AndroidProject(name: name)
        projects.append(project)
        return project
    }

    func deleteProject(_ id: UUID) {
        projects.removeAll { $0.id == id }
    }

    func addPart(to projectID: UUID, _ part: PartRow) {
        guard let i = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[i].parts.append(part)
    }

    func removePart(from projectID: UUID, partID: UUID) {
        guard let i = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[i].parts.removeAll { $0.id == partID }
    }

    func parts(of projectID: UUID) -> [PartRow] {
        projects.first { $0.id == projectID }?.parts ?? []
    }

    // M-8 varsayılanları (iOS ile aynı anahtarlar) — yeni optimizasyonlara işler.
    static func defaultsRequest(rows: [PartRow], sheetW: Units, sheetH: Units) -> OptimizeRequest {
        let d = UserDefaults.standard
        let kerfMM = d.object(forKey: "defaultKerfMM") == nil ? 3 : d.integer(forKey: "defaultKerfMM")
        let trimMM = d.integer(forKey: "defaultTrimMM")
        let objective: Objective = switch d.string(forKey: "defaultObjective") {
        case "waste": .waste
        case "cuts": .cuts
        default: .sheets
        }
        return OptimizeRequest(
            unitMode: .metricMM, kerf: Units(kerfMM) * 100, trim: Units(trimMM) * 100,
            objective: objective, seed: 1,
            stocks: [.init(id: "s1", materialId: "m1", w: sheetW, h: sheetH, qty: 99)],
            parts: rows.map {
                .init(id: $0.id.uuidString, name: $0.name, materialId: "m1",
                      w: Units($0.widthMM) * 100, h: Units($0.heightMM) * 100, qty: $0.qty)
            })
    }

    // Motor çağrısı — iOS ile AYNI istek şekli (deterministik seed; docs/04).
    func optimize(projectID: UUID) {
        let rows = parts(of: projectID)
        guard !rows.isEmpty else {
            plan = nil
            planError = nil
            return
        }
        let req = Self.defaultsRequest(rows: rows, sheetW: sheetW, sheetH: sheetH)
        do {
            plan = try CutCore.optimize(req)
            partNames = Dictionary(uniqueKeysWithValues: rows.map { ($0.id.uuidString, $0.name) })
            planError = nil
        } catch {
            plan = nil
            planError = "\(error)"
        }
    }

    // M-6 görseli: örnek projenin GERÇEK motor çıktısı (UI durumunu bozmaz).
    func sampleResult() -> OptimizeResult? {
        let rows = Self.sampleProject().parts
        let req = Self.defaultsRequest(rows: rows, sheetW: sheetW, sheetH: sheetH)
        return try? CutCore.optimize(req)
    }
}
