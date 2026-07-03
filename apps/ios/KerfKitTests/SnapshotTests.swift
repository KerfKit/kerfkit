import XCTest
import SwiftUI
import SnapshotTesting
@testable import KerfKit

// docs/17 K-UI şablonu: snapshot testleri (koyu tema × DynamicType M/XXL).
// Uygulama koyu-öncelikli (docs/11 §3) — light varyantı zorlanmaz, koyu sabitlenir.
// Referanslar __Snapshots__/ altında; kasıtlı UI değişikliğinde `record` ile yenile.
@MainActor
final class SnapshotTests: XCTestCase {

    private func host(_ view: some View, sizeCategory: UIContentSizeCategory,
                      configure: (ProjectStore) -> Void = { _ in }) -> UIViewController {
        let store = ProjectStore(inMemory: true)
        store.createProject(sample: true)
        store.optimizePlan()
        configure(store)
        let vc = UIHostingController(rootView: NavigationStack { view }
            .environment(store)
            .tint(DesignTokens.colorAmber500))
        vc.overrideUserInterfaceStyle = .dark
        vc.traitOverrides.preferredContentSizeCategory = sizeCategory
        return vc
    }

    func testPartsTab_darkMedium() {
        assertSnapshot(of: host(PartsTabView(), sizeCategory: .medium),
                       as: .image(on: .iPhone13), named: "parcalar-M")
    }

    func testPartsTab_darkXXL() {
        assertSnapshot(of: host(PartsTabView(), sizeCategory: .extraExtraLarge),
                       as: .image(on: .iPhone13), named: "parcalar-XXL")
    }

    func testPlanTab_darkMedium() {
        assertSnapshot(of: host(PlanTabView(), sizeCategory: .medium),
                       as: .image(on: .iPhone13), named: "plan-M")
    }

    func testPlanTab_darkXXL() {
        assertSnapshot(of: host(PlanTabView(), sizeCategory: .extraExtraLarge),
                       as: .image(on: .iPhone13), named: "plan-XXL")
    }

    func testStockTab_darkMedium() {
        assertSnapshot(of: host(StockTabView(), sizeCategory: .medium),
                       as: .image(on: .iPhone13), named: "stok-M")
    }

    func testWorkshop_dark() {
        assertSnapshot(of: host(WorkshopView(), sizeCategory: .medium),
                       as: .image(on: .iPhone13), named: "atolye-koyu")
    }

    func testWorkshop_bench() {
        assertSnapshot(of: host(WorkshopView(), sizeCategory: .medium,
                                configure: { $0.benchMode = true }),
                       as: .image(on: .iPhone13), named: "atolye-tezgah")
    }
}
