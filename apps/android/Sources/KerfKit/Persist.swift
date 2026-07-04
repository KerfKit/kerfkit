import Foundation
import SkipSQL
import SkipSQLPlus

// E9-S2b — SkipSQL kalıcılığı (Package.swift K-10/K-11 planı: "Android karşılığı
// SkipSQL ile"). İskelet ölçeği küçük (≤ birkaç proje × ≤20 parça): her mutasyonda
// tam-yazım tek işlemde — iOS CutPersist'in artımlı şemasına E9-S3'te yaklaşılır.
// DB açılamazsa uygulama BELLEK-İÇİ sürer (çökme yok; log düşer).
final class ProjectDB {
    private let ctx: SQLContext

    init() throws {
        let dir = try FileManager.default.url(for: .applicationSupportDirectory,
                                              in: .userDomainMask, appropriateFor: nil, create: true)
        let path = dir.appendingPathComponent("kerfkit.sqlite").path
        ctx = try SQLContext(path: path, flags: [.readWrite, .create], configuration: .plus)
        try ctx.exec(sql: """
            CREATE TABLE IF NOT EXISTS projects (
              id TEXT PRIMARY KEY, name TEXT NOT NULL, sira INTEGER NOT NULL)
            """)
        try ctx.exec(sql: """
            CREATE TABLE IF NOT EXISTS parts (
              id TEXT PRIMARY KEY, project_id TEXT NOT NULL, name TEXT NOT NULL,
              w INTEGER NOT NULL, h INTEGER NOT NULL, qty INTEGER NOT NULL,
              sira INTEGER NOT NULL)
            """)
    }

    func load() throws -> [AndroidProject] {
        var projects: [AndroidProject] = []
        for row in try ctx.selectAll(sql: "SELECT id, name FROM projects ORDER BY sira") {
            guard let idText = row[0].textValue, let id = UUID(uuidString: idText),
                  let name = row[1].textValue else { continue }
            var project = AndroidProject(id: id, name: name)
            let partRows = try ctx.selectAll(
                sql: "SELECT id, name, w, h, qty FROM parts WHERE project_id = ? ORDER BY sira",
                parameters: [.text(idText)])
            for p in partRows {
                guard let pidText = p[0].textValue, let pid = UUID(uuidString: pidText),
                      let pname = p[1].textValue,
                      let w = p[2].integerValue, let h = p[3].integerValue,
                      let qty = p[4].integerValue else { continue }
                project.parts.append(PartRow(id: pid, name: pname,
                                             widthMM: Int(w), heightMM: Int(h), qty: Int(qty)))
            }
            projects.append(project)
        }
        return projects
    }

    func save(_ projects: [AndroidProject]) throws {
        try ctx.exec(sql: "BEGIN")
        do {
            try ctx.exec(sql: "DELETE FROM parts")
            try ctx.exec(sql: "DELETE FROM projects")
            for (i, project) in projects.enumerated() {
                try ctx.exec(sql: "INSERT INTO projects (id, name, sira) VALUES (?, ?, ?)",
                             parameters: [.text(project.id.uuidString), .text(project.name),
                                          .integer(Int64(i))])
                for (j, part) in project.parts.enumerated() {
                    try ctx.exec(sql: """
                        INSERT INTO parts (id, project_id, name, w, h, qty, sira)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                        """,
                        parameters: [.text(part.id.uuidString), .text(project.id.uuidString),
                                     .text(part.name), .integer(Int64(part.widthMM)),
                                     .integer(Int64(part.heightMM)), .integer(Int64(part.qty)),
                                     .integer(Int64(j))])
                }
            }
            try ctx.exec(sql: "COMMIT")
        } catch {
            try? ctx.exec(sql: "ROLLBACK")
            throw error
        }
    }
}
