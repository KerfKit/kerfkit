import Foundation
import GRDB
import CutProj

// docs/03 E3-S2 (K-11) — yerel kalıcılık: belge-depo modeli (satır = .cutproj JSON).
// Gerekçe: dosya = dışa aktarım formatı = DB içeriği (docs/05 "tek şema, üç kullanım");
// liste sorguları için ad/tarih sütunları ayrıca tutulur.
public final class ProjectRepository: Sendable {
    private let dbQueue: DatabaseQueue

    public init(path: String) throws {
        dbQueue = try DatabaseQueue(path: path)
        try Self.migrator.migrate(dbQueue)
    }

    public init(inMemory: Void = ()) throws {
        dbQueue = try DatabaseQueue()
        try Self.migrator.migrate(dbQueue)
    }

    static var migrator: DatabaseMigrator {
        var m = DatabaseMigrator()
        m.registerMigration("v1") { db in
            try db.create(table: "project") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("modifiedAt", .text).notNull()
                t.column("doc", .blob).notNull()
            }
        }
        // Liste özet sütunları — M-1 kartları doküman açmadan dolsun (100 projede <100ms AC).
        m.registerMigration("v2-ozet-sutunlari") { db in
            try db.alter(table: "project") { t in
                t.add(column: "partCount", .integer).notNull().defaults(to: 0)
                t.add(column: "planSheetCount", .integer)
                t.add(column: "planWasteBps", .integer)
            }
            // Tek seferlik geri doldurma: mevcut satırlar bir kez çözülür.
            let rows = try Row.fetchAll(db, sql: "SELECT id, doc FROM project")
            for row in rows {
                let data: Data = row["doc"]
                guard let doc = try? ProjectIO.decode(data) else { continue }
                let plan = doc.plans.last
                try db.execute(
                    sql: "UPDATE project SET partCount = ?, planSheetCount = ?, planWasteBps = ? WHERE id = ?",
                    arguments: [doc.parts.count, plan?.result.stats.sheetCount,
                                plan?.result.stats.wasteBps, row["id"] as String])
            }
        }
        return m
    }

    public struct Summary: Equatable, Sendable {
        public let id: String
        public let name: String
        public let modifiedAt: String
        public let partCount: Int
        public let planSheetCount: Int?
        public let planWasteBps: Int?
    }

    public func save(_ doc: ProjectDoc) throws {
        let data = try ProjectIO.encode(doc)
        let plan = doc.plans.last
        try dbQueue.write { db in
            try db.execute(
                sql: """
                INSERT INTO project (id, name, modifiedAt, doc, partCount, planSheetCount, planWasteBps)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                  name = excluded.name, modifiedAt = excluded.modifiedAt, doc = excluded.doc,
                  partCount = excluded.partCount, planSheetCount = excluded.planSheetCount,
                  planWasteBps = excluded.planWasteBps
                """,
                arguments: [doc.id, doc.name, doc.modifiedAt, data,
                            doc.parts.count, plan?.result.stats.sheetCount, plan?.result.stats.wasteBps])
        }
    }

    public func load(id: String) throws -> ProjectDoc? {
        try dbQueue.read { db in
            guard let row = try Row.fetchOne(db, sql: "SELECT doc FROM project WHERE id = ?",
                                             arguments: [id]) else { return nil }
            let data: Data = row["doc"]
            return try ProjectIO.decode(data)
        }
    }

    public func list() throws -> [Summary] {
        try dbQueue.read { db in
            try Row.fetchAll(db, sql: """
                SELECT id, name, modifiedAt, partCount, planSheetCount, planWasteBps
                FROM project ORDER BY modifiedAt DESC
                """)
                .map { Summary(id: $0["id"], name: $0["name"], modifiedAt: $0["modifiedAt"],
                               partCount: $0["partCount"], planSheetCount: $0["planSheetCount"],
                               planWasteBps: $0["planWasteBps"]) }
        }
    }

    public func delete(id: String) throws {
        try dbQueue.write { db in
            try db.execute(sql: "DELETE FROM project WHERE id = ?", arguments: [id])
        }
    }

    public func count() throws -> Int {
        try dbQueue.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM project") ?? 0
        }
    }
}

// Otomatik kayıt — her değişiklikte 500ms debounce (docs/03 E3-S2 AC).
// Patlama tek yazmaya iner; flush() bekleyen kaydı hemen tamamlar (arka plana geçişte çağır).
public actor Autosaver {
    private let repository: ProjectRepository
    private let delayNanos: UInt64
    private var pending: Task<Void, Never>?
    public private(set) var saveCount = 0
    public private(set) var lastError: String?

    public init(repository: ProjectRepository, delayMilliseconds: Int = 500) {
        self.repository = repository
        self.delayNanos = UInt64(delayMilliseconds) * 1_000_000
    }

    public func scheduleSave(_ doc: ProjectDoc) {
        pending?.cancel()
        pending = Task {
            do {
                try await Task.sleep(nanoseconds: delayNanos)
            } catch {
                return // iptal edildi — yenisi planlandı
            }
            self.performSave(doc)
        }
    }

    public func flush(_ doc: ProjectDoc? = nil) async {
        pending?.cancel()
        pending = nil
        if let doc { performSave(doc) }
    }

    private func performSave(_ doc: ProjectDoc) {
        do {
            try repository.save(doc)
            saveCount += 1
            lastError = nil
        } catch {
            lastError = "\(error)"
        }
    }
}
