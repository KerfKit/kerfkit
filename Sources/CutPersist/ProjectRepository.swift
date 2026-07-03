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
        return m
    }

    public struct Summary: Equatable, Sendable {
        public let id: String
        public let name: String
        public let modifiedAt: String
    }

    public func save(_ doc: ProjectDoc) throws {
        let data = try ProjectIO.encode(doc)
        try dbQueue.write { db in
            try db.execute(
                sql: """
                INSERT INTO project (id, name, modifiedAt, doc) VALUES (?, ?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                  name = excluded.name, modifiedAt = excluded.modifiedAt, doc = excluded.doc
                """,
                arguments: [doc.id, doc.name, doc.modifiedAt, data])
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
            try Row.fetchAll(db, sql: "SELECT id, name, modifiedAt FROM project ORDER BY modifiedAt DESC")
                .map { Summary(id: $0["id"], name: $0["name"], modifiedAt: $0["modifiedAt"]) }
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
