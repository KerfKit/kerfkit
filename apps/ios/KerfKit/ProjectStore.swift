import SwiftUI
import CutModels
import CutProj
import CutPersist
import CutCore

struct PartInput: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var width: Int
    var height: Int
    var qty: Int
    var rotationAllowed: Bool
    var banding = BandingDoc()

    // Bant uzunluğu: en kenarları (üst/alt) genişlik, boy kenarları (sol/sağ) yükseklik.
    var bandLength: Int {
        let single = (banding.top ? width : 0) + (banding.bottom ? width : 0)
            + (banding.left ? height : 0) + (banding.right ? height : 0)
        return single * qty
    }
}

enum DetailTab: CaseIterable {
    case parts, stock, plan

    var title: String {
        switch self {
        case .parts: String(localized: "Parts")
        case .stock: String(localized: "Stock")
        case .plan: String(localized: "Plan")
        }
    }
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
        // Metrik: mm · Imperial: 1/64″ adedi (docs/04 §2). 4×8ft = 96″×48″; kerf 1/8″.
        static let sheetQty = 5
        static let objective: Objective = .sheets
        static func sheetWidth(_ u: UnitMode) -> Int { u == .metricMM ? 2440 : 96 * 64 }
        static func sheetHeight(_ u: UnitMode) -> Int { u == .metricMM ? 1220 : 48 * 64 }
        static func kerf(_ u: UnitMode) -> Int { u == .metricMM ? 3 : 8 }
        static func trim(_ u: UnitMode) -> Int { 0 }
    }

    // M-1 liste
    var summaries: [ProjectRepository.Summary] = []
    var planSummaries: [String: String] = [:]
    var detailOpen = false
    var selectedTab: DetailTab = .parts

    // aktif proje
    var unitMode: UnitMode = .metricMM // proje birimi — karışık birim yasak (docs/04 §2)
    var projectName = String(localized: "New Project")
    var parts: [PartInput] = []
    var sheetWidth = 2440
    var sheetHeight = 1220
    var sheetQty = Defaults.sheetQty
    var kerf = 3
    var trim = 0
    var objective: Objective = Defaults.objective

    var result: OptimizeResult?
    var lastRequest: OptimizeRequest?
    var partNames: [String: String] = [:]
    var errorMessage: String?
    var stale = false // E-4 bayat-sonuç bandı: girdiler plan sonrası değiştiyse
    var importSummary: String? // K-12 içe aktarma özeti (bant metni)

    // M-5 Atölye Modu: adım = plan yerleşimi (deterministik sıra), id = "c<indeks>".
    var workshopOpen = false
    var benchMode = false // Tezgâh Modu (docs/12 §7) — oturumluk, M-8'de kalıcı ayara taşınır
    var completedCutIds: Set<String> = []

    private var projectId = UUID().uuidString
    private var createdAt = ProjectStore.nowISO()
    // Aktif proje listeden silindiyse touch/flush onu geri yazmasın (diriltme yasağı).
    private var activeDeleted = false
    // inMemory testlerde M-8 kullanıcı varsayılanları okunmaz — snapshot determinizmi.
    private var usesUserDefaults = true
    private let repository: ProjectRepository?
    private let autosaver: Autosaver?

    var sheetW: Units { Units(sheetWidth) * 100 }
    var sheetH: Units { Units(sheetHeight) * 100 }

    // M-4 bant stat kartı: metrikte metre, imperial'da feet (yerleşimden bağımsız).
    var bandLengthText: String {
        let total = Double(parts.reduce(0) { $0 + $1.bandLength })
        return unitMode == .metricMM
            ? String(format: "%.1fm", total / 1000)
            : String(format: "%.1fft", total / 64 / 12)
    }

    // — M-5 atölye adımları —

    var workshopSteps: [Placement] { result?.placements ?? [] }
    var currentStepIndex: Int? {
        workshopSteps.indices.first { !completedCutIds.contains("c\($0)") }
    }

    func markCut(_ index: Int) {
        completedCutIds.insert("c\(index)")
        touch(markStale: false)
    }

    func undoLastCut() {
        // Geri al: tamamlanan en büyük indeksli adım geri açılır.
        if let last = completedCutIds.compactMap({ Int($0.dropFirst()) }).max() {
            completedCutIds.remove("c\(last)")
            touch(markStale: false)
        }
    }

    // inMemory: snapshot/birim testleri kalıcı mağazayı kirletmesin.
    init(inMemory: Bool = false) {
        if inMemory {
            repository = try? ProjectRepository()
            autosaver = repository.map { Autosaver(repository: $0) }
            usesUserDefaults = false
            loadSummaries()
            return
        }
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
                let sheetsText = String(localized: "\(sheets) sheets")
                let partsText = String(localized: "\(s.partCount) parts")
                let wasteText = String(localized: "\(PlanStats.wastePercentText(bps: bps)) waste")
                infos[s.id] = "\(sheetsText) · \(wasteText) · \(partsText)"
            } else {
                let partsText = String(localized: "\(s.partCount) parts")
                infos[s.id] = "\(partsText) · \(String(localized: "no plan yet"))"
            }
        }
        planSummaries = infos
    }

    // K-13 paylaşımı: aktif projenin dokümanı (tembel .cutproj/PDF üretimi için).
    func exportableDoc() -> ProjectDoc { currentDoc() }

    // — K-12 CSV köprüsü —

    var csvRows: [CSVPartList.Row] {
        parts.map { .init(name: $0.name, width: $0.width, height: $0.height,
                          qty: $0.qty, rotationAllowed: $0.rotationAllowed, banding: $0.banding) }
    }

    // Panodan CSV/TSV: hatalı satırlar atlanır, özet bantta gösterilir (docs/03 E3-S3).
    func importParts(fromCSV text: String) {
        let (rows, issues) = CSVPartList.parse(text)
        parts.append(contentsOf: rows.map {
            PartInput(name: $0.name, width: $0.width, height: $0.height,
                      qty: $0.qty, rotationAllowed: $0.rotationAllowed, banding: $0.banding)
        })
        let imported = String(localized: "\(rows.count) parts imported")
        importSummary = issues.isEmpty
            ? imported
            : imported + " · " + String(localized: "\(issues.count) rows skipped")
        if !rows.isEmpty { touch() }
    }

    // M-8 Verilerim: her proje .cutproj olarak geçici dizine yazılır (ShareLink için).
    func exportAllProjects() -> [URL] {
        var urls: [URL] = []
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("kerfkit-disari", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        for s in summaries {
            guard let doc = try? repository?.load(id: s.id),
                  let data = try? ProjectIO.encode(doc) else { continue }
            let safeName = s.name.replacingOccurrences(of: "/", with: "-")
            let url = dir.appendingPathComponent("\(safeName)-\(s.id.prefix(6)).cutproj")
            if (try? data.write(to: url)) != nil { urls.append(url) }
        }
        return urls
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
        completedCutIds = []; workshopOpen = false
        // Birim: kullanıcı seçimi > bölge otomatiği (ABD → inç; docs/18 §2). Test store metrik.
        let ud = UserDefaults.standard
        if usesUserDefaults {
            let pref = ud.string(forKey: "defaultUnitMode") ?? "auto"
            unitMode = pref == UnitMode.imperialFrac64.rawValue ? .imperialFrac64
                : pref == UnitMode.metricMM.rawValue ? .metricMM
                : (Locale.current.measurementSystem == .us ? .imperialFrac64 : .metricMM)
        } else {
            unitMode = .metricMM
        }
        sheetWidth = Defaults.sheetWidth(unitMode); sheetHeight = Defaults.sheetHeight(unitMode)
        sheetQty = Defaults.sheetQty
        // M-8 kullanıcı varsayılanları (mm-tabanlı) yalnız metrik projelere uygulanır;
        // imperial varsayılanları sabit (1/8″ kerf) — Ayarlar dipnotunda söylenir.
        if usesUserDefaults, unitMode == .metricMM {
            kerf = ud.object(forKey: "defaultKerfMM") as? Int ?? Defaults.kerf(.metricMM)
            trim = ud.object(forKey: "defaultTrimMM") as? Int ?? Defaults.trim(.metricMM)
        } else {
            kerf = Defaults.kerf(unitMode); trim = Defaults.trim(unitMode)
        }
        objective = usesUserDefaults
            ? (Objective(rawValue: ud.string(forKey: "defaultObjective") ?? "") ?? Defaults.objective)
            : Defaults.objective
        if sample {
            unitMode = .metricMM // örnek veri mm ile tanımlı
            sheetWidth = Defaults.sheetWidth(.metricMM); sheetHeight = Defaults.sheetHeight(.metricMM)
            kerf = Defaults.kerf(.metricMM); trim = Defaults.trim(.metricMM)
            projectName = String(localized: "Kitchen Cabinet")
            parts = [
                .init(name: String(localized: "Side"), width: 720, height: 580, qty: 2, rotationAllowed: false,
                      banding: BandingDoc(top: true, left: true, right: true)),
                .init(name: String(localized: "Shelf"), width: 764, height: 560, qty: 2, rotationAllowed: true,
                      banding: BandingDoc(top: true)),
                .init(name: String(localized: "Door"), width: 396, height: 716, qty: 1, rotationAllowed: false,
                      banding: BandingDoc(top: true, bottom: true, left: true, right: true)),
                .init(name: String(localized: "Drawer"), width: 396, height: 180, qty: 6, rotationAllowed: true),
            ]
        } else {
            projectName = String(localized: "New Project")
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

    // Stok'taki birim değişimi: tüm alanlar en yakın hedef birime çevrilir (deterministik).
    func setUnitMode(_ new: UnitMode) {
        guard new != unitMode else { return }
        let old = unitMode
        unitMode = new
        sheetWidth = UnitFormat.convert(sheetWidth, from: old, to: new)
        sheetHeight = UnitFormat.convert(sheetHeight, from: old, to: new)
        kerf = UnitFormat.convert(kerf, from: old, to: new)
        trim = UnitFormat.convert(trim, from: old, to: new)
        for i in parts.indices {
            parts[i].width = UnitFormat.convert(parts[i].width, from: old, to: new)
            parts[i].height = UnitFormat.convert(parts[i].height, from: old, to: new)
        }
        touch()
    }

    // — kalıcılık köprüsü —

    private func currentDoc() -> ProjectDoc {
        var doc = ProjectDoc(id: projectId, name: projectName,
                             createdAt: createdAt, modifiedAt: ProjectStore.nowISO(),
                             unitMode: unitMode,
                             defaults: DefaultsDoc(kerf: Units(kerf) * 100,
                                                   trim: Units(trim) * 100,
                                                   objective: objective))
        doc.materials = [MaterialDoc(id: "panel", name: "Panel", kind: "sheet")]
        doc.stocks = [StockDoc(id: "levha", materialId: "panel",
                               w: sheetW, h: sheetH, qty: sheetQty)]
        // Parça id'si UUID — dizin-tabanlı id silmede kayar, gömülü plan referansları kırılırdı.
        doc.parts = parts.enumerated().map { i, p in
            PartDoc(id: p.id.uuidString, name: p.name.isEmpty ? String(localized: "Part \(i + 1)") : p.name,
                    materialId: "panel", w: Units(p.width) * 100, h: Units(p.height) * 100,
                    qty: p.qty, rotation: p.rotationAllowed ? .allowed : .fixed,
                    banding: p.banding == BandingDoc() ? nil : p.banding)
        }
        if let result, let lastRequest {
            doc.plans = [PlanDoc(id: "plan-son", createdAt: ProjectStore.nowISO(),
                                 engineVersion: result.engineVersion,
                                 request: lastRequest, result: result, stale: stale,
                                 workshopProgress: completedCutIds.isEmpty ? nil
                                     : WorkshopProgressDoc(completedCutIds: completedCutIds.sorted()))]
        }
        return doc
    }

    private func apply(_ doc: ProjectDoc) {
        projectId = doc.id
        createdAt = doc.createdAt
        unitMode = doc.unitMode
        projectName = doc.name
        kerf = Int(doc.defaults.kerf / 100)
        trim = Int(doc.defaults.trim / 100)
        objective = doc.defaults.objective
        if let stock = doc.stocks.first {
            sheetWidth = Int(stock.w / 100)
            sheetHeight = Int(stock.h / 100)
            sheetQty = stock.qty
        }
        parts = doc.parts.map {
            PartInput(id: UUID(uuidString: $0.id) ?? UUID(),
                      name: $0.name, width: Int($0.w / 100), height: Int($0.h / 100),
                      qty: $0.qty, rotationAllowed: $0.rotation == .allowed,
                      banding: $0.banding ?? BandingDoc())
        }
        if let plan = doc.plans.last {
            result = plan.result
            lastRequest = plan.request
            stale = plan.stale
            completedCutIds = Set(plan.workshopProgress?.completedCutIds ?? [])
            var names: [String: String] = [:]
            for p in plan.request.parts { names[p.id] = p.name }
            partNames = names
        } else {
            result = nil; lastRequest = nil; stale = false
            completedCutIds = []
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
            guard p.width > 0, p.height > 0, p.qty > 0 else { return nil }
            let pid = p.id.uuidString
            names[pid] = p.name.isEmpty ? String(localized: "Part") : p.name
            return PartSpec(id: pid, name: names[pid] ?? "", materialId: "panel",
                            w: Units(p.width) * 100, h: Units(p.height) * 100,
                            qty: p.qty, rotation: p.rotationAllowed ? .allowed : .fixed)
        }
        let req = OptimizeRequest(
            unitMode: unitMode,
            kerf: Units(kerf) * 100,
            trim: Units(trim) * 100,
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
            completedCutIds = [] // plan değişti — atölye ilerlemesi eski plana aitti
        } catch let error as PlacementError {
            // Son geçerli plan korunur (bayat kalır) — nil'lemek diske de plansız yazardı.
            if case .partExceedsStock(let pid) = error {
                errorMessage = String(localized: "\(names[pid] ?? pid) doesn\u{2019}t fit the sheet — check its size or the grain lock.")
            }
        } catch {
            errorMessage = String(localized: "Couldn\u{2019}t validate the input — check sizes and quantities.")
        }
        touch(markStale: false)
    }
}
