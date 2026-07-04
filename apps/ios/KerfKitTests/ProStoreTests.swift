import XCTest
import StoreKit
import StoreKitTest
@testable import KerfKit

// K-14 AC'leri (docs/17): satın al→kilit açılır · sil-kur→restore çalışır ·
// iade→kilit kapanır · 72s geçişi biter. SKTestSession yereldir — mağaza hesabı gerekmez.
@MainActor
final class ProStoreTests: XCTestCase {

    private var session: SKTestSession!

    override func setUp() async throws {
        session = try SKTestSession(configurationFileNamed: "Products")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
    }

    private func makeStore() -> ProStore { ProStore(autoStart: false) }

    // SKTestSession işlemleri currentEntitlements'a asenkron düşer — yoklamalı bekle.
    private func waitFor(_ store: ProStore, _ expected: ProStatus,
                         timeout: TimeInterval = 3,
                         _ message: String = "", file: StaticString = #filePath,
                         line: UInt = #line) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            await store.refresh()
            if store.status == expected { return }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertEqual(store.status, expected, message, file: file, line: line)
    }

    func testPurchaseLifetime_unlocksImmediately() async throws {
        let store = makeStore()
        await store.refresh()
        XCTAssertEqual(store.status, .free)

        try await session.buyProduct(identifier: "lifetime.unlock")
        await waitFor(store, .lifetime, "docs/08 §4: satın alma sonrası ANINDA açılır")
    }

    func testFreshInstall_restoreFindsExistingPurchase() async throws {
        try await session.buyProduct(identifier: "lifetime.unlock")
        // "Sil-kur": yeni store örneği = taze kurulum; işlemler Apple hesabında durur.
        let freshStore = makeStore()
        await freshStore.refresh()
        XCTAssertEqual(freshStore.status, .lifetime, "Restore mevcut alımı bulmalı")
    }

    func testRefund_locksAgain() async throws {
        try await session.buyProduct(identifier: "lifetime.unlock")
        let store = makeStore()
        await store.refresh()
        XCTAssertEqual(store.status, .lifetime)

        let transactions = session.allTransactions()
        let id = try XCTUnwrap(transactions.first?.identifier)
        try session.refundTransaction(identifier: UInt(id))
        await waitFor(store, .free, "docs/08: iade → kilit kapanır")
    }

    func testWeekendPass_expiresAfter72Hours() async throws {
        try await session.buyProduct(identifier: "pass.weekend")
        let store = makeStore()
        await store.refresh()
        guard case .pass(let expiry) = store.status else {
            return XCTFail("Geçiş alımı .pass vermeli, geldi: \(store.status)")
        }
        XCTAssertEqual(expiry.timeIntervalSinceNow, ProStore.passDuration, accuracy: 120,
                       "Bitiş = satın alma + 72 saat")

        // Saat oynatmadan: 73 saat sonrası enjekte edilir (refresh(now:)).
        await store.refresh(now: Date().addingTimeInterval(73 * 3600))
        XCTAssertEqual(store.status, .free, "72 saat dolunca geçiş biter — OTOMATİK YENİLENMEZ")
    }

    func testYearly_activeUntilExpiry() async throws {
        try await session.buyProduct(identifier: "pro.yearly")
        let store = makeStore()
        await store.refresh()
        guard case .yearly(let expiry) = store.status else {
            return XCTFail("Yıllık alım .yearly vermeli, geldi: \(store.status)")
        }
        XCTAssertGreaterThan(expiry, Date(), "Yenileme tarihi ileride olmalı (paywall'da gösterilir)")
    }

    func testPriority_lifetimeBeatsPass() async throws {
        try await session.buyProduct(identifier: "pass.weekend")
        try await session.buyProduct(identifier: "lifetime.unlock")
        let store = makeStore()
        await store.refresh()
        XCTAssertEqual(store.status, .lifetime, "Öncelik: lifetime > yearly > pass")
    }
}
