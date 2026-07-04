import Foundation
import StoreKit

// K-14 (E5-S1) — StoreKit 2 katmanı (docs/08 §3). Entitlement TEK KAYNAK: ProStatus.
// Ürünler: lifetime.unlock (non-consumable) · pro.yearly (auto-renew) ·
// pass.weekend (non-renewing; bitiş = satın alma + 72s, uygulama hesaplar).
// Öncelik: lifetime > yearly > pass. RevenueCat yok (docs/08 kararı).

enum ProStatus: Equatable {
    case free
    case lifetime
    case yearly(expiry: Date)
    case pass(expiry: Date)

    var isPro: Bool { if case .free = self { false } else { true } }
}

@MainActor
@Observable
final class ProStore {
    static let productIDs = ["lifetime.unlock", "pro.yearly", "pass.weekend"]
    static let passDuration: TimeInterval = 72 * 3600

    private(set) var status: ProStatus = .free
    private(set) var products: [Product] = []
    private(set) var lastError: String?

    private var updatesTask: Task<Void, Never>?

    init(autoStart: Bool = true) {
        guard autoStart else { return }
        updatesTask = Task { [weak self] in
            // Uygulama dışı işlemler (aile paylaşımı, iade, yenileme) buraya düşer.
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self?.refresh()
            }
        }
        Task { await loadProducts(); await refresh() }
    }

    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: Self.productIDs)
            // Sabit sıra: lifetime (manşet) · yıllık · geçiş (docs/08 §1 tablosu).
            products = Self.productIDs.compactMap { id in loaded.first { $0.id == id } }
            lastError = nil
        } catch {
            lastError = "\(error)"
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                await transaction.finish()
            }
            await refresh() // docs/08 §4: satın alma sonrası kilitler ANINDA açılır
            lastError = nil
        } catch {
            lastError = "\(error)"
        }
    }

    // Şeffaf-fatura listesi: restore görünür ve çalışır (docs/08 §4).
    func restore() async {
        try? await AppStore.sync()
        await refresh()
    }

    // `now` test için enjekte edilir (geçiş bitişini saat oynatmadan doğrulamak için).
    func refresh(now: Date = Date()) async {
        var next: ProStatus = .free
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let t) = entitlement, t.revocationDate == nil else { continue }
            switch t.productID {
            case "lifetime.unlock":
                next = .lifetime
            case "pro.yearly":
                if case .lifetime = next { break }
                if let expiry = t.expirationDate, expiry > now {
                    next = .yearly(expiry: expiry)
                }
            case "pass.weekend":
                if next == .free {
                    let expiry = t.purchaseDate.addingTimeInterval(Self.passDuration)
                    if expiry > now { next = .pass(expiry: expiry) }
                }
            default:
                break
            }
        }
        status = next
    }
}
