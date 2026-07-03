import SwiftUI
import CutModels
import CutProj
import CutPersist
import CutCore

struct PartInput: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var widthMM: Int
    var heightMM: Int
    var qty: Int
    var rotationAllowed: Bool
}

enum DetailTab: String, CaseIterable {
    case parts = "Parçalar"
    case stock = "Stok"
    case plan = "Plan"
}

// Çok-projeli durum + kalıcılık (K-11): M-1 liste kartları depo özetlerinden; aktif proje
// alanları her değişiklikte touch() ile 500ms debounce'lu kayda düşer. Son plan .cutproj'a
// gömülür (liste özeti + docs/05 Plan kaydı).
@Observable
final class ProjectStore {
    // M-1 liste
    var summaries: [ProjectRepository.Summary] = []
    var planSummaries: [String: String] = [:]
    var detailOpen = false
    var selectedTab: DetailTab = .parts

    // aktif proje
    var projectName = "Yeni Proje"
    var parts: [PartInput] = []
    var sheetWidthMM = 2440
    var sheetHeightMM = 1220
    var sheetQty = 5
    var kerfMM = 3
    var trimMM = 0
    var objective: Objective = .sheets

    var result: OptimizeResult?
    var lastRequest: OptimizeRequest?
    var partNames: [String: String] = [:]
    var errorMessage: String?
    var stale = false // E-4 bayat-sonuç bandı: girdiler plan sonrası değiştiyse

    private var projectId = UUID().uuidString
    private var createdAt = ProjectStore.nowISO()
    private let repository: ProjectRepository?
    private let autosaver: Autosaver?

    var sheetW: Units { Units(sheetWidthMM) * 100 }
    var sheetH: Units { Units(sheetHeightMM) * 100 }

    init() {
        do {
            let dir = try FileManager.default.url(for: .applicationSupportDirectory,
                                                  in: .userDomainMask, appropriateFor: nil, create: true)
            let repo = try ProjectRepository(path: dir.appendingPathComponent("kerfkit.sqlite").path)
            repository = repo
            autosaver = Autosaver(repository: repo)
        } catch {
            repository = nil
            autosaver = nil
        }
        loadSummaries()
    }

    static func nowISO() -> String {
        ISO8601DateFormatter().string(from: Date())
    }

    // — M-1 liste işlemleri —

    func loadSummaries() {
        summaries = (try? repository?.list()) ?? []
        var infos: [String: String] = [:]
        for s in summaries {
            if let doc = try? repository?.load(id: s.id), let plan = doc.plans.last {
                let waste = Double(plan.result.stats.wasteBps) / 100
                infos[s.id] = "\(plan.result.stats.sheetCount) levha · %\(String(format: "%.1f", waste)) fire · \(doc.parts.count) parça"
            } else if let doc = try? repository?.load(id: s.id) {
                infos[s.id] = "\(doc.parts.count) parça · henüz plan yok"
            }
        }
        planSummaries = infos
    }

    func createProject(sample: Bool) {
        projectId = UUID().uuidString
        createdAt = ProjectStore.nowISO()
        result = nil; lastRequest = nil; errorMessage = nil; stale = false
        sheetWidthMM = 2440; sheetHeightMM = 1220; sheetQty = 5; kerfMM = 3; trimMM = 0
        objective = .sheets
        if sample {
            projectName = "Mutfak Dolabı"
            parts = [
                .init(name: "Yan", widthMM: 720, heightMM: 580, qty: 2, rotationAllowed: false),
                .init(name: "Raf", widthMM: 764, heightMM: 560, qty: 2, rotationAllowed: true),
                .init(name: "Kapak", widthMM: 396, heightMM: 716, qty: 1, rotationAllowed: false),
                .init(name: "Çekmece", widthMM: 396, heightMM: 180, qty: 6, rotationAllowed: true),
            ]
        } else {
            projectName = "Yeni Proje"
            parts = []
        }
        selectedTab = .parts
        detailOpen = true
        touch(markStale: false)
    }

    func open(id: String) {
        guard let doc = try? repository?.load(id: id) else { return }
        apply(doc)
        selectedTab = .parts
        detailOpen = true
    }

    func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let id = summaries[index].id
            try? repository?.delete(id: id)
        }
        loadSummaries()
    }

    // — kalıcılık köprüsü —

    private func currentDoc() -> ProjectDoc {
        var doc = ProjectDoc(id: projectId, name: projectName,
                             createdAt: createdAt, modifiedAt: ProjectStore.nowISO(),
                             defaults: DefaultsDoc(kerf: Units(kerfMM) * 100,
                                                   trim: Units(trimMM) * 100,
                                                   objective: objective))
        doc.materials = [MaterialDoc(id: "panel", name: "Panel", kind: "sheet")]
        doc.stocks = [StockDoc(id: "levha", materialId: "panel",
                               w: sheetW, h: sheetH, qty: sheetQty)]
        doc.parts = parts.enumerated().map { i, p in
            PartDoc(id: "p\(i)", name: p.name.isEmpty ? "Parça \(i + 1)" : p.name,
                    materialId: "panel", w: Units(p.widthMM) * 100, h: Units(p.heightMM) * 100,
                    qty: p.qty, rotation: p.rotationAllowed ? .allowed : .fixed)
        }
        if let result, let lastRequest {
            doc.plans = [PlanDoc(id: "plan-son", createdAt: ProjectStore.nowISO(),
                                 engineVersion: result.engineVersion,
                                 request: lastRequest, result: result, stale: stale)]
        }
        return doc
    }

    private func apply(_ doc: ProjectDoc) {
        projectId = doc.id
        createdAt = doc.createdAt
        projectName = doc.name
        kerfMM = Int(doc.defaults.kerf / 100)
        trimMM = Int(doc.defaults.trim / 100)
        objective = doc.defaults.objective
        if let stock = doc.stocks.first {
            sheetWidthMM = Int(stock.w / 100)
            sheetHeightMM = Int(stock.h / 100)
            sheetQty = stock.qty
        }
        parts = doc.parts.map {
            PartInput(name: $0.name, widthMM: Int($0.w / 100), heightMM: Int($0.h / 100),
                      qty: $0.qty, rotationAllowed: $0.rotation == .allowed)
        }
        if let plan = doc.plans.last {
            result = plan.result
            lastRequest = plan.request
            stale = plan.stale
            var names: [String: String] = [:]
            for p in plan.request.parts { names[p.id] = p.name }
            partNames = names
        } else {
            result = nil; lastRequest = nil; stale = false
        }
        errorMessage = nil
    }

    // Her kullanıcı değişikliğinden sonra: bayat işareti + 500ms debounce'lu kayıt.
    func touch(markStale: Bool = true) {
        if markStale && result != nil { stale = true }
        guard let autosaver else { return }
        let doc = currentDoc()
        Task { await autosaver.scheduleSave(doc) }
    }

    // Arka plana geçişte bekleyen kaydı hemen tamamla (veri asla kaybolmaz — docs/02 §4).
    func flush() {
        guard let autosaver else { return }
        let doc = currentDoc()
        Task { await autosaver.flush(doc) }
    }

    func optimizePlan() {
        var names: [String: String] = [:]
        let specs = parts.enumerated().compactMap { i, p -> PartSpec? in
            guard p.widthMM > 0, p.heightMM > 0, p.qty > 0 else { return nil }
            let pid = "p\(i)"
            names[pid] = p.name.isEmpty ? "Parça \(i + 1)" : p.name
            return PartSpec(id: pid, name: names[pid] ?? "", materialId: "panel",
                            w: Units(p.widthMM) * 100, h: Units(p.heightMM) * 100,
                            qty: p.qty, rotation: p.rotationAllowed ? .allowed : .fixed)
        }
        let req = OptimizeRequest(
            unitMode: .metricMM,
            kerf: Units(kerfMM) * 100,
            trim: Units(trimMM) * 100,
            objective: objective,
            seed: 1,
            stocks: [StockSpec(id: "levha", materialId: "panel", w: sheetW, h: sheetH, qty: sheetQty)],
            parts: specs)
        do {
            result = try optimize(req)
            lastRequest = req
            partNames = names
            errorMessage = nil
            stale = false
        } catch let error as PlacementError {
            result = nil
            if case .partExceedsStock(let pid) = error {
                errorMessage = "\(names[pid] ?? pid) levhaya sığmıyor — boyutları ya da damar kilidini kontrol et."
            }
        } catch {
            result = nil
            errorMessage = "Girdi doğrulamadan geçmedi — boyut ve adetleri kontrol et."
        }
        touch(markStale: false)
    }
}
