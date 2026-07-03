import SwiftUI
import CutModels
import CutCore

// M-6 Onboarding (E4-S6, D-4 ÖNERİ A: görsel-üst) — docs/07 E-6 metinleri, docs/13 §M-6.
// Görseller GERÇEK diyagram render'ı: örnek proje motorla bir kez optimize edilir.
// Paywall burada GÖSTERİLMEZ; CTA örnek projeyle ilk optimizasyonu yaşatır (aha-anı).
struct OnboardingView: View {
    let onFinish: (_ startSample: Bool) -> Void
    @State private var page: Int

    private let sample = OnboardingView.makeSamplePlan()

    init(initialPage: Int = 0, onFinish: @escaping (_ startSample: Bool) -> Void) {
        self.onFinish = onFinish
        _page = State(initialValue: initialPage)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Atla") { onFinish(false) }
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.colorTimber500)
                    .frame(minWidth: 44, minHeight: 44)
                    .accessibilityLabel("Onboarding'i atla")
            }

            TabView(selection: $page) {
                pageView(visual: planVisual,
                         sentence: "Levhayı gir, parçaları yaz, planı al.",
                         detail: "Kesim planı saniyeler içinde — deterministik, her seferinde aynı.")
                    .tag(0)
                pageView(visual: proVisual,
                         sentence: "Kerf, damar, kenar bandı — pro detaylar hazır.",
                         detail: "Testere payı hesapta, damar kilidi tek dokunuş, bant metresi kartında.")
                    .tag(1)
                pageView(visual: statsVisual,
                         sentence: "Tek seferlik satın al. Abonelik yok.",
                         detail: "Önce dene: örnek projeyle ilk planını hemen gör.")
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            dots

            Button {
                onFinish(true)
            } label: {
                Text("Örnek projeyle dene")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.colorAmber500)
            .foregroundStyle(DesignTokens.colorTimber950)
            .opacity(page == 2 ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: page)
            .disabled(page != 2)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
        .background(DesignTokens.colorTimber950)
    }

    private func pageView(visual: some View, sentence: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            visual
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .background(DesignTokens.colorTimber900, in: RoundedRectangle(cornerRadius: 16))
                .padding(.top, 24)
            Text(sentence)
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(DesignTokens.colorTimber50)
                .padding(.top, 32)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(DesignTokens.colorTimber300)
                .padding(.top, 10)
            Spacer()
        }
    }

    // İlerleme noktaları amber (docs/13) — aktif nokta hap biçiminde uzar.
    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == page ? DesignTokens.colorAmber500 : DesignTokens.colorTimber700)
                    .frame(width: i == page ? 24 : 8, height: 8)
            }
        }
        .padding(.vertical, 16)
        .accessibilityLabel("Sayfa \(page + 1), toplam 3")
    }

    // — gerçek render görselleri —

    private var planVisual: some View {
        SheetDiagram(placements: sample.result.placements, names: sample.names,
                     sheetW: 244_000, sheetH: 122_000)
            .padding(16)
    }

    private var proVisual: some View {
        VStack(spacing: 12) {
            SheetDiagram(placements: sample.result.placements, names: sample.names,
                         sheetW: 244_000, sheetH: 122_000,
                         highlight: sample.result.placements.first { $0.rotated })
                .padding(.horizontal, 16)
            HStack(spacing: 8) {
                chip("kerf 3 mm")
                chip("damar 🔒")
                chip("bant 7.5 m")
            }
            .padding(.bottom, 14)
        }
        .padding(.top, 16)
    }

    private var statsVisual: some View {
        HStack(spacing: 8) {
            StatCard(title: "levha", value: "\(sample.result.stats.sheetCount)")
            StatCard(title: "fire", value: sample.result.stats.wastePercentText)
            StatCard(title: "kesim", value: "\(sample.result.stats.cutCount)")
        }
        .padding(16)
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(DesignTokens.colorTimber200)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(DesignTokens.colorTimber800, in: Capsule())
    }

    // Örnek proje motordan bir kez geçirilir — onboarding görseli gerçek çıktıdır.
    static func makeSamplePlan() -> (result: OptimizeResult, names: [String: String]) {
        let parts: [(String, Units, Units, Int, RotationRule)] = [
            ("Yan", 72_000, 58_000, 2, .fixed),
            ("Raf", 76_400, 56_000, 2, .allowed),
            ("Kapak", 39_600, 71_600, 1, .fixed),
            ("Çekmece", 39_600, 18_000, 6, .allowed),
        ]
        var names: [String: String] = [:]
        let specs = parts.enumerated().map { i, p in
            names["ob\(i)"] = p.0
            return PartSpec(id: "ob\(i)", name: p.0, materialId: "panel",
                            w: p.1, h: p.2, qty: p.3, rotation: p.4)
        }
        let req = OptimizeRequest(unitMode: .metricMM, kerf: 300, trim: 0, objective: .sheets,
                                  seed: 1,
                                  stocks: [StockSpec(id: "levha", materialId: "panel",
                                                     w: 244_000, h: 122_000, qty: 5)],
                                  parts: specs)
        let result = (try? optimize(req))
            ?? OptimizeResult(placements: [], stats: .init(sheetCount: 0, wasteBps: 0, cutCount: 0),
                              unplaced: [], engineVersion: "-")
        return (result, names)
    }
}
