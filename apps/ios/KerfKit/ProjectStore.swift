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

// UI durumu + kalıcılık (K-11): her değişiklik touch() ile 500ms debounce'lu otomatik
// kayda düşer; arka plana geçişte flush. Açılışta son proje yüklenir, yoksa örnek proje.
@Observable
final class ProjectStore {
    var parts: [PartInput] = []
    var sheetWidthMM = 2440
    var sheetHeightMM = 1220
    var sheetQty = 5
    var kerfMM = 3
    var trimMM = 0
    var objective: Objective = .sheets
    var projectName = "Mutfak Dolabı"

    var result: OptimizeResult?
    var partNames: [String: String] = [:]
    var errorMessage: String?

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
            let repo = try ProjectRepository(path: dir.appendingPathComponent("kerf.sqlite").path)
            repository = repo
            autosaver = Autosaver(repository: repo)
        } catch {
            repository = nil
            autosaver = nil
        }
        if let last = try? repository?.list().first,
           let doc = try? repository?.load(id: last.id) {
            apply(doc)
        } else {
            seedSampleProject()
        }
    }

    private func seedSampleProject() {
        // Örnek proje: onboarding aktivasyon garantisi özü (docs/03 E4-S6)
        parts = [
            .init(name: "Yan", widthMM: 720, heightMM: 580, qty: 2, rotationAllowed: false),
            .init(name: "Raf", widthMM: 764, heightMM: 560, qty: 2, rotationAllowed: true),
            .init(name: "Kapak", widthMM: 396, heightMM: 716, qty: 1, rotationAllowed: false),
            .init(name: "Çekmece", widthMM: 396, heightMM: 180, qty: 6, rotationAllowed: true),
        ]
        touch()
    }

    // — kalıcılık köprüsü —

    static func nowISO() -> String {
        ISO8601DateFormatter().string(from: Date())
    }

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
    }

    // Her kullanıcı değişikliğinden sonra çağrılır — 500ms debounce'lu otomatik kayıt.
    func touch() {
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
            partNames = names
            errorMessage = nil
        } catch let error as PlacementError {
            result = nil
            if case .partExceedsStock(let pid) = error {
                errorMessage = "\(names[pid] ?? pid) levhaya sığmıyor — boyutları ya da damar kilidini kontrol et."
            }
        } catch {
            result = nil
            errorMessage = "Girdi doğrulamadan geçmedi — boyut ve adetleri kontrol et."
        }
        touch()
    }
}
