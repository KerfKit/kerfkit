import SwiftUI
import CutModels
import CutProj
import CutPersist
import CutCore

struct PartInput: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var widthMM: Int
    var heightMM: Int
    var qty: Int
    var rotationAllowed: Bool
    var banding = BandingDoc()

    // Bant uzunluğu: en kenarları (üst/alt) genişlik, boy kenarları (sol/sağ) yükseklik.
    var bandLengthMM: Int {
        let single = (banding.top ? widthMM : 0) + (banding.bottom ? widthMM : 0)
            + (banding.left ? heightMM : 0) + (banding.right ? heightMM : 0)
        return single * qty
    }
}

enum DetailTab: String, CaseIterable {
    case parts = "Parçalar"
    case stock = "Stok"
    case plan = "Plan"
}

extension PlanStats {
    static func wastePercentText(bps: Int) -> String { String(format: "%%%.1f", Double(bps) / 100) }
    var wastePercentText: String { Self.wastePercentText(bps: wasteBps) }
}

// Çok-projeli durum + kalıcılık (K-11): M-1 liste kartları depo özetlerinden; aktif proje
// alanları her değişiklikte touch() ile 500ms debounce'lu kayda düşer. Son plan .cutproj'a
// gömülür (liste özeti + docs/05 Plan kaydı).
@MainActor
@Observable
final class ProjectStore {
    private enum Defaults {
        static let sheetWidthMM = 2440, sheetHeightMM = 1220, sheetQty = 5
        static let kerfMM = 3, trimMM = 0
        static let objective: Objective = .sheets
    }

    // M-1 liste
    var summaries: [ProjectRepository.Summary] = []
    var planSummaries: [String: String] = [:]
    var detailOpen = false
    var selectedTab: DetailTab = .parts

    // aktif proje
    var projectName = "Yeni Proje"
    var parts: [PartInput] = []
    var sheetWidthMM = Defaults.sheetWidthMM
    var sheetHeightMM = Defaults.sheetHeightMM
    var sheetQty = Defaults.sheetQty
    var kerfMM = Defaults.kerfMM
    var trimMM = Defaults.trimMM
    var objective: Objective = Defaults.objective

    var result: OptimizeResult?
    var lastRequest: OptimizeRequest?
    var partNames: [String: String] = [:]
    var errorMessage: String?
    var stale = false // E-4 bayat-sonuç bandı: girdiler plan sonrası değiştiyse

    private var projectId = UUID().uuidString
    private var createdAt = ProjectStore.nowISO()
    // Aktif proje listeden silindiyse touch/flush onu geri yazmasın (diriltme yasağı).
    private var activeDeleted = false
    private let repository: ProjectRepository?
    private let autosaver: Autosaver?

    var sheetW: Units { Units(sheetWidthMM) * 100 }
    var sheetH: Units { Units(sheetHeightMM) * 100 }

    // M-4 bant stat kartı: projedeki toplam bant kenarı uzunluğu (yerleşimden bağımsız).
    var bandLengthText: String {
        String(format: "%.1fm", Double(parts.reduce(0) { $0 + $1.bandLengthMM }) / 1000)
    }

    init() {
        do {
            let dir = try FileManager.default.url(for: .applicationSupportDirectory,
                                                  in: .userDomainMask, appropriateFor: nil, create: true)
            // İsim geçişi (G-0.3b): kerf.sqlite'tan kalan veriyi bir kez taşı (wal/shm dahil).
            let fm = FileManager.default
            if !fm.fileExists(atPath: dir.appendingPathComponent("kerfkit.sqlite").path) {
                for suffix in ["", "-wal", "-shm"] {
                    let old = dir.appendingPathComponent("kerf.sqlite\(suffix)")
                    let new = dir.appendingPathComponent("kerfkit.sqlite\(suffix)")
                    if fm.fileExists(atPath: old.path) { try? fm.moveItem(at: old, to: new) }
                }
            }
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

    // Özetler v2 sütunlarından — doküman açılmaz (K-11 AC: 100 projede liste <100ms).
    func loadSummaries() {
        summaries = (try? repository?.list()) ?? []
        var infos: [String: String] = [:]
        for s in summaries {
            if let sheets = s.planSheetCount, let bps = s.planWasteBps {
                infos[s.id] = "\(sheets) levha · \(PlanStats.wastePercentText(bps: bps)) fire · \(s.partCount) parça"
            } else {
                infos[s.id] = "\(s.partCount) parça · henüz plan yok"
            }
        }
        planSummaries = infos
    }

    // Detaydan dönüşte: bekleyen debounce'u bitir, listeyi ancak yazım tamamlanınca tazele
    // (yoksa 500ms'lik kayıtla yarışıp bayat özet gösterir).
    func flushThenReload() {
        guard let autosaver, !activeDeleted else { loadSummaries(); return }
        let doc = currentDoc()
        Task {
            await autosaver.flush(doc)
            loadSummaries()
        }
    }

    func createProject(sample: Bool) {
        projectId = UUID().uuidString
        createdAt = ProjectStore.nowISO()
        activeDeleted = false
        result = nil; lastRequest = nil; errorMessage = nil; stale = false
        sheetWidthMM = Defaults.sheetWidthMM; sheetHeightMM = Defaults.sheetHeightMM
        sheetQty = Defaults.sheetQty; kerfMM = Defaults.kerfMM; trimMM = Defaults.trimMM
        objective = Defaults.objective
        if sample {
            projectName = "Mutfak Dolabı"
            parts = [
                .init(name: "Yan", widthMM: 720, heightMM: 580, qty: 2, rotationAllowed: false,
                      banding: BandingDoc(top: true, left: true, right: true)),
                .init(name: "Raf", widthMM: 764, heightMM: 560, qty: 2, rotationAllowed: true,
                      banding: BandingDoc(top: true)),
                .init(name: "Kapak", widthMM: 396, heightMM: 716, qty: 1, rotationAllowed: false,
                      banding: BandingDoc(top: true, bottom: true, left: true, right: true)),
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
        activeDeleted = false
        selectedTab = .parts
        detailOpen = true
    }

    func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let id = summaries[index].id
            try? repository?.delete(id: id)
            if id == projectId { activeDeleted = true }
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
        // Parça id'si UUID — dizin-tabanlı id silmede kayar, gömülü plan referansları kırılırdı.
        doc.parts = parts.enumerated().map { i, p in
            PartDoc(id: p.id.uuidString, name: p.name.isEmpty ? "Parça \(i + 1)" : p.name,
                    materialId: "panel", w: Units(p.widthMM) * 100, h: Units(p.heightMM) * 100,
                    qty: p.qty, rotation: p.rotationAllowed ? .allowed : .fixed,
                    banding: p.banding == BandingDoc() ? nil : p.banding)
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
            PartInput(id: UUID(uuidString: $0.id) ?? UUID(),
                      name: $0.name, widthMM: Int($0.w / 100), heightMM: Int($0.h / 100),
                      qty: $0.qty, rotationAllowed: $0.rotation == .allowed,
                      banding: $0.banding ?? BandingDoc())
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
        guard let autosaver, !activeDeleted else { return }
        let doc = currentDoc()
        Task { await autosaver.scheduleSave(doc) }
    }

    // Arka plana geçişte bekleyen kaydı hemen tamamla (veri asla kaybolmaz — docs/02 §4).
    func flush() {
        guard let autosaver, !activeDeleted else { return }
        let doc = currentDoc()
        Task { await autosaver.flush(doc) }
    }

    func optimizePlan() {
        var names: [String: String] = [:]
        let specs = parts.compactMap { p -> PartSpec? in
            guard p.widthMM > 0, p.heightMM > 0, p.qty > 0 else { return nil }
            let pid = p.id.uuidString
            names[pid] = p.name.isEmpty ? "Parça" : p.name
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
            // Son geçerli plan korunur (bayat kalır) — nil'lemek diske de plansız yazardı.
            if case .partExceedsStock(let pid) = error {
                errorMessage = "\(names[pid] ?? pid) levhaya sığmıyor — boyutları ya da damar kilidini kontrol et."
            }
        } catch {
            errorMessage = "Girdi doğrulamadan geçmedi — boyut ve adetleri kontrol et."
        }
        touch(markStale: false)
    }
}
