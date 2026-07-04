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
        let session = try SKTestSession(configurationFileNamed: "Products")
        session.resetToDefaultState()
        session.clearTransactions()

        let pro = ProStore(autoStart: false)
        await pro.loadProducts()
        XCTAssertEqual(pro.products.count, 3, "Üç ürün yüklenmeli (lifetime/yıllık/geçiş)")

        let vc = UIHostingController(rootView: PaywallView()
            .environment(pro)
            .tint(DesignTokens.colorAmber500))
        vc.overrideUserInterfaceStyle = .dark
        assertSnapshot(of: vc, as: .image(on: .iPhone13), named: "paywall-M")
    }
}
