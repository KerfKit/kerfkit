import XCTest
import SwiftUI
import StoreKitTest
import SnapshotTesting
@testable import KerfKit

// K-15: paywall görsel sabitlemesi — ürünler yerel SKTestSession'dan yüklenir
// (fiyatlar Products.storekit'ten; mağaza hesabı gerekmez).
@MainActor
final class PaywallSnapshotTests: XCTestCase {

    func testPaywall_darkMedium() async throws {
        let vc = try await host(founding: .closed)
        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "paywall-M")
    }

    // K-16: founding penceresi açık — rozet + gerçek sayaç + "gelecekteki fiyat" satırı.
    func testPaywall_foundingActive() async throws {
        var config = FoundingConfig(active: true)
        config.claimed = 120
        config.seats = 300
        config.futurePrice = "$99.99"
        let vc = try await host(founding: config)
        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "paywall-founding-M")
    }

    private func host(founding config: FoundingConfig) async throws -> UIViewController {
        let session = try SKTestSession(configurationFileNamed: "Products")
        session.resetToDefaultState()
        session.clearTransactions()

        let pro = ProStore(autoStart: false)
        await pro.loadProducts()
        XCTAssertEqual(pro.products.count, 3, "Üç ürün yüklenmeli (lifetime/yıllık/geçiş)")

        let suite = UserDefaults(suiteName: "paywall-snapshot")!
        suite.removePersistentDomain(forName: "paywall-snapshot")
        let founding = FoundingStore(defaults: suite)
        if config != .closed {
            founding.apply(try JSONEncoder().encode(config))
        }

        let vc = UIHostingController(rootView: PaywallView()
            .environment(pro)
            .environment(founding)
            .tint(DesignTokens.colorAmber500))
        vc.overrideUserInterfaceStyle = .dark
        return vc
    }
}
