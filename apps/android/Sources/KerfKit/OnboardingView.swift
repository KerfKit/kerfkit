import SwiftUI
import CutModels

// M-6 Android paritesi (E9-S2) — iOS OnboardingView'ın sade köprü hali:
// 3 sayfa, gerçek motor görseli (örnek plan), CTA → örnek proje + Plan inişi.
// TabView(.page) köprü riski yüzünden yok; sayfa geçişi düğmeyle (docs/13 Android notları).
struct OnboardingView: View {
    @Environment(ProjectVM.self) var vm
    let onFinish: (Bool) -> Void

    @State var page = 0
    @State var sample: OptimizeResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button {
                    onFinish(false)
                } label: {
                    Text("Skip").frame(minHeight: 44)
                }
            }

            Group {
                if page == 0 {
                    pageView(sentence: "Enter the sheet, type your parts, get the plan.",
                             detail: "Your cut plan in seconds — same result every time.")
                } else if page == 1 {
                    pageView(sentence: "Kerf, grain, edge banding — the pro details are covered.",
                             detail: "Kerf in the math, grain locked in one tap, banding meters on the card.")
                } else {
                    pageView(sentence: "Buy once. No subscription.",
                             detail: "Try it first: see your first plan with the sample project.")
                }
            }

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? Color.orange : Color.gray.opacity(0.4))
                        .frame(width: i == page ? 24 : 8, height: 8)
                }
            }
            .padding(.vertical, 16)

            if page < 2 {
                Button {
                    page += 1
                } label: {
                    Text("Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 16)
            } else {
                Button {
                    onFinish(true)
                } label: {
                    Text("Try the sample project")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 16)
            }
        }
        .padding(.horizontal, 24)
        .task {
            // Gerçek motor görseli — sahte veri yok (docs/11 §5).
            if sample == nil { sample = vm.sampleResult() }
        }
    }

    func pageView(sentence: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if let sample {
                    SheetDiagram(placements: sample.placements.filter { $0.sheetIndex == 0 },
                                 sheetW: vm.sheetW, sheetH: vm.sheetH)
                        .padding(16)
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            .padding(.top, 24)

            Text(sentence)
                .font(.system(size: 28, weight: .heavy))
                .padding(.top, 32)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 10)
            Spacer()
        }
    }
}
