import SwiftUI
import StoreKit

// K-15 (E5-S2) — paywall, D-6 varyant A (Ahmet seçimi, 4 Tem): üç kutu dikey,
// Lifetime manşet. docs/08 §4 şeffaf-fatura maddeleri EKRANDA: fiyat/süre/yenileme
// tam punto · geçiş "OTOMATİK YENİLENMEZ" · Restore görünür · iade+destek 1 dokunuş ·
// sahte kıtlık yok. Fiyatlar Product.displayPrice'tan — hardcode YOK.
struct PaywallView: View {
    @Environment(ProStore.self) private var pro
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID = "lifetime.unlock"
    @State private var purchasing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                            .foregroundStyle(DesignTokens.colorTimber500)
                    }
                    .accessibilityLabel(String(localized: "Close"))
                    .accessibilityIdentifier("paywall.close")
                }

                Text("Unlimited projects + PDF + Workshop Mode")
                    .font(.title2.bold())
                    .foregroundStyle(DesignTokens.colorTimber50)

                VStack(alignment: .leading, spacing: 6) {
                    benefit("Unlimited saved projects and parts")
                    benefit("PDF · CSV · .cutproj export")
                    benefit("Workshop Mode at the saw")
                    benefit("Calculations stay free and unlimited")
                }
                .padding(.vertical, 14)

                if pro.products.isEmpty {
                    ProgressView().frame(maxWidth: .infinity).padding()
                } else {
                    ForEach(pro.products, id: \.id) { product in
                        productBox(product)
                    }
                }

                Button {
                    purchasing = true
                    Task {
                        if let product = pro.products.first(where: { $0.id == selectedID }) {
                            await pro.purchase(product)
                        }
                        purchasing = false
                        if pro.status.isPro { dismiss() } // docs/08 §4: kilitler ANINDA açılır
                    }
                } label: {
                    Text(ctaTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignTokens.colorAmber500)
                .foregroundStyle(DesignTokens.colorTimber950)
                .disabled(purchasing || pro.products.isEmpty)
                .accessibilityIdentifier("paywall.buy")
                .padding(.top, 8)

                HStack(spacing: 6) {
                    Spacer()
                    Button("Restore Purchases") { Task { await pro.restore(); if pro.status.isPro { dismiss() } } }
                        .accessibilityIdentifier("paywall.restore")
                    Text(verbatim: "·")
                    if let refund = URL(string: "https://support.apple.com/118223") {
                        Link("Refund policy", destination: refund)
                    }
                    Text(verbatim: "·")
                    if let mail = URL(string: "mailto:hello@kerfkit.app") {
                        Link(destination: mail) { Text(verbatim: "hello@kerfkit.app") }
                    }
                    Spacer()
                }
                .font(.footnote)
                .tint(DesignTokens.colorTimber300)
                .padding(.top, 12)

                Text("Prices are charged through the App Store. Yearly renews unless cancelled before the period ends; the Weekend Pass is one-time and never renews.")
                    .font(.caption2)
                    .foregroundStyle(DesignTokens.colorTimber500)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(DesignTokens.colorTimber950)
        .task { if pro.products.isEmpty { await pro.loadProducts() } }
    }

    private var ctaTitle: String {
        guard let product = pro.products.first(where: { $0.id == selectedID }) else {
            return String(localized: "Get Lifetime")
        }
        switch product.id {
        case "pro.yearly": return String(localized: "Get Yearly — \(product.displayPrice)/yr")
        case "pass.weekend": return String(localized: "Get Weekend Pass — \(product.displayPrice)")
        default: return String(localized: "Get Lifetime — \(product.displayPrice)")
        }
    }

    private func benefit(_ key: LocalizedStringKey) -> some View {
        Label { Text(key) } icon: {
            Image(systemName: "checkmark")
                .foregroundStyle(DesignTokens.colorAmber500)
        }
        .font(.subheadline)
        .foregroundStyle(DesignTokens.colorTimber200)
    }

    private func productBox(_ product: Product) -> some View {
        let selected = product.id == selectedID
        let headline = product.id == "lifetime.unlock"
        return Button {
            selectedID = product.id
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundStyle(DesignTokens.colorTimber50)
                    Spacer()
                    Text(product.id == "pro.yearly"
                         ? String(localized: "\(product.displayPrice)/yr")
                         : product.displayPrice)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(DesignTokens.colorAmber400)
                }
                Text(detailKey(for: product.id))
                    .font(.caption)
                    .foregroundStyle(DesignTokens.colorTimber500)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selected ? DesignTokens.colorTimber900 : .clear,
                        in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selected ? DesignTokens.colorAmber500 : DesignTokens.colorTimber700,
                            lineWidth: selected ? 2 : 1)
            }
            .overlay(alignment: .topTrailing) {
                if headline {
                    Text("MOST POPULAR")
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(DesignTokens.colorAmber500, in: Capsule())
                        .foregroundStyle(DesignTokens.colorTimber950)
                        .offset(x: -12, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.bottom, 10)
        .accessibilityIdentifier("paywall.\(product.id)")
    }

    private func detailKey(for id: String) -> LocalizedStringKey {
        switch id {
        case "pro.yearly":
            "Everything included. Renews yearly — cancel anytime in Settings."
        case "pass.weekend":
            "72 hours of everything. DOES NOT auto-renew — it just ends."
        default:
            "One payment. No subscription, no renewals — like a tool: buy once, use forever."
        }
    }
}
