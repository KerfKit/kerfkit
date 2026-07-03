import XCTest
import CutProj
@testable import CutPersist

// docs/03 E3-S2 AC: öldür-aç bütünlüğü · 100 projede liste <100ms · 500ms debounce.
final class ProjectRepositoryTests: XCTestCase {
    func makeDoc(_ n: Int) -> ProjectDoc {
        ProjectDoc(id: "proj-\(n)", name: "Proje \(n)",
                   createdAt: "2026-07-03T10:00:00Z",
                   modifiedAt: "2026-07-03T10:\(String(format: "%02d", n % 60)):00Z",
                   parts: [PartDoc(id: "p1", name: "Yan", materialId: "m1",
                                   w: 60_000, h: 40_000, qty: 4)])
    }

    func testKillRelaunch_lastStateIntact() throws {
        let path = NSTemporaryDirectory() + "kerf-test-\(UUID().uuidString).sqlite"
        defer { try? FileManager.default.removeItem(atPath: path) }
        do {
            let repo = try ProjectRepository(path: path)
            try repo.save(makeDoc(1))
            var doc2 = makeDoc(2)
            doc2.name = "Güncellenmiş"
            try repo.save(doc2)
        } // "öldürme": repo kapsam dışı
        let reopened = try ProjectRepository(path: path)
        XCTAssertEqual(try reopened.count(), 2)
        let loaded = try reopened.load(id: "proj-2")
        XCTAssertEqual(loaded?.name, "Güncellenmiş")
        XCTAssertEqual(loaded?.parts.first?.w, 60_000)
    }

    func testUpsert_updatesExisting() throws {
        let repo = try ProjectRepository()
        try repo.save(makeDoc(1))
        var updated = makeDoc(1)
        updated.name = "Yeni Ad"
        updated.modifiedAt = "2026-07-03T11:00:00Z"
        try repo.save(updated)
        XCTAssertEqual(try repo.count(), 1)
        XCTAssertEqual(try repo.load(id: "proj-1")?.name, "Yeni Ad")
        XCTAssertEqual(try repo.list().first?.modifiedAt, "2026-07-03T11:00:00Z")
    }

    func testList100Projects_under100ms() throws {
        let repo = try ProjectRepository()
        for n in 0..<100 { try repo.save(makeDoc(n)) }
        let start = Date()
        let summaries = try repo.list()
        let elapsed = Date().timeIntervalSince(start)
        XCTAssertEqual(summaries.count, 100)
        XCTAssertLessThan(elapsed, 0.1, "liste 100 projede <100ms açılmalı (docs/03 E3-S2)")
    }

    func testAutosave_debounceCollapsesBursts() async throws {
        let repo = try ProjectRepository()
        let saver = Autosaver(repository: repo, delayMilliseconds: 50)
        var doc = makeDoc(1)
        doc.name = "v1"; await saver.scheduleSave(doc)
        doc.name = "v2"; await saver.scheduleSave(doc)
        doc.name = "v3"; await saver.scheduleSave(doc)
        try await Task.sleep(nanoseconds: 200_000_000) // debounce penceresini geç
        let count = await saver.saveCount
        XCTAssertEqual(count, 1, "patlama tek yazmaya inmeli")
        XCTAssertEqual(try repo.load(id: "proj-1")?.name, "v3", "son durum kazanır")
    }

    func testFlush_persistsImmediately() async throws {
        let repo = try ProjectRepository()
        let saver = Autosaver(repository: repo, delayMilliseconds: 10_000)
        var doc = makeDoc(7)
        doc.name = "acil"
        await saver.scheduleSave(doc)
        await saver.flush(doc)
        XCTAssertEqual(try repo.load(id: "proj-7")?.name, "acil")
    }
}
