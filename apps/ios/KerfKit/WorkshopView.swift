import SwiftUI
import CutModels

// M-5 Atölye Modu (D-3 ÖNERİ A: talimat-merkez) — docs/13 §M-5, docs/12 §7.
// Ekran uyanık kalır; Tezgâh Modu = ultra-kontrast açık tema + dev tipografi (parlama gerçeği).
// Eldiven kuralı: birincil ≥56pt, hedef arası ≥8pt.
struct WorkshopView: View {
    @Environment(ProjectStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private var bench: Bool { store.benchMode }
    private var bg: Color { bench ? DesignTokens.colorTimber50 : DesignTokens.colorTimber950 }
    private var fg: Color { bench ? DesignTokens.colorTimber950 : DesignTokens.colorTimber50 }
    private var fg2: Color { bench ? DesignTokens.colorTimber700 : DesignTokens.colorTimber300 }
    private var cardBg: Color { bench ? .white : DesignTokens.colorTimber900 }

    var body: some View {
        @Bindable var store = store
        VStack(spacing: 0) {
            topBar
            if let index = store.currentStepIndex {
                stepContent(index)
            } else {
                doneContent
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bg)
        .statusBarHidden()
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label(String(localized: "Plan"), systemImage: "chevron.left")
                    .font(.body.weight(.bold))
                    .lineLimit(1).minimumScaleFactor(0.6) // K-18: XXL'de harf kırılması
                    .frame(minWidth: 56, minHeight: 56, alignment: .leading)
            }
            .foregroundStyle(fg)
            Spacer()
            Text(store.projectName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(fg2)
                .lineLimit(1)
            Spacer()
            Toggle(isOn: Binding(get: { store.benchMode }, set: { store.benchMode = $0 })) {
                Label(String(localized: "Bench"), systemImage: "sun.max.fill")
                    .font(.footnote.weight(.bold))
                    .lineLimit(1).minimumScaleFactor(0.6) // K-18: XXL'de harf kırılması
            }
            .toggleStyle(.button)
            .buttonStyle(.bordered)
            .tint(bench ? DesignTokens.colorAmber600 : DesignTokens.colorTimber300) // K-18: metinli buton 4.5:1
            .frame(minHeight: 56)
            .accessibilityLabel(String(localized: "Bench Mode"))
        }
    }

    private func stepContent(_ index: Int) -> some View {
        let step = store.workshopSteps[index]
        let name = store.partNames[step.partId] ?? step.partId
        let total = store.workshopSteps.count
        return VStack(spacing: 0) {
            HStack {
                Text("CUT \(index + 1)/\(total)")
                    .font(.footnote.weight(.bold))
                    .kerning(2)
                    .foregroundStyle(fg2)
                    .accessibilityLabel(String(localized: "Cut \(index + 1) of \(total)"))
                Spacer()
                ProgressRing(progress: Double(index) / Double(total), bench: bench)
                    .frame(width: 44, height: 44)
            }
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 10) {
                Text(name)
                    .font(.system(size: bench ? 46 : 40, weight: .heavy))
                    .foregroundStyle(fg)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(verbatim: UnitFormat.size(Int(step.w / 100), Int(step.h / 100), unit: store.unitMode)
                     + (store.unitMode == .metricMM ? " mm" : "") + (step.rotated ? "  ⤾" : ""))
                    .font(.system(size: bench ? 34 : 28, weight: .bold).monospacedDigit())
                    .foregroundStyle(fg)
                Text("Sheet \(step.sheetIndex + 1)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(fg2)

                SheetDiagram(
                    placements: store.workshopSteps.filter { $0.sheetIndex == step.sheetIndex },
                    names: store.partNames,
                    sheetW: store.lastRequest?.stocks.first?.w ?? store.sheetW,
                    sheetH: store.lastRequest?.stocks.first?.h ?? store.sheetH,
                    highlight: step, muted: bench)
                    .frame(maxHeight: 150)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(cardBg, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                if bench {
                    RoundedRectangle(cornerRadius: 16).stroke(DesignTokens.colorTimber950, lineWidth: 3)
                }
            }
            .padding(.top, 12)

            Spacer()

            Button {
                store.markCut(index)
            } label: {
                Text(verbatim: "✓ " + String(localized: "DONE"))
                    .font(.system(size: bench ? 26 : 22, weight: .heavy))
                    .frame(maxWidth: .infinity, minHeight: bench ? 72 : 64)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.colorAmber500)
            .foregroundStyle(DesignTokens.colorTimber950)

            Button {
                store.undoLastCut()
            } label: {
                Text("Undo")
                    .font(.body.weight(bench ? .bold : .regular))
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.bordered)
            .tint(fg2)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .disabled(store.completedCutIds.isEmpty)
        }
    }

    private var doneContent: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(DesignTokens.colorGreen500)
            Text("All cuts done")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(fg)
            Text("\(store.workshopSteps.count) parts cut — nice work!")
                .font(.title3)
                .foregroundStyle(fg2)
            Spacer()
            Button {
                store.undoLastCut()
            } label: {
                Text("Undo")
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.bordered)
            .tint(fg2)
            Button {
                dismiss()
            } label: {
                Text("Back to plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.colorAmber500)
            .foregroundStyle(DesignTokens.colorTimber950)
            .padding(.bottom, 16)
        }
    }
}

// İlerleme halkası — köşede, tamamlanan kesim oranı.
struct ProgressRing: View {
    let progress: Double
    let bench: Bool

    var body: some View {
        ZStack {
            Circle().stroke(bench ? DesignTokens.colorTimber200 : DesignTokens.colorTimber800,
                            lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(bench ? DesignTokens.colorAmber600 : DesignTokens.colorAmber500,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .accessibilityLabel(String(localized: "\(Int(progress * 100)) percent done"))
    }
}
