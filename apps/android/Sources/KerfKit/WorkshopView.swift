import SwiftUI
import CutModels

// M-5 Android paritesi (E9-S2) — talimat-merkez akış: sıradaki kesim dev
// tipografiyle, DONE/Undo eldiven boyutunda (docs/13 §M-5). Tezgâh Modu =
// ultra-kontrast açık tema. Ekran-uyanık kalma Compose'a köprülenmiyor —
// E9-S3 notu (docs/13 Android notları).
struct WorkshopView: View {
    @Environment(ProjectVM.self) var vm
    @Environment(\.dismiss) var dismiss

    let plan: OptimizeResult
    let names: [String: String]

    @State var done = 0
    @State var bench = false

    var steps: [Placement] { plan.placements }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Plan").font(.body.bold()).frame(minHeight: 56)
                }
                Spacer()
                Button {
                    bench.toggle()
                } label: {
                    Text("Bench")
                        .font(.footnote.bold())
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(bench ? .orange : .gray)
            }

            if done < steps.count {
                stepContent
            } else {
                doneContent
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bench ? Color.white : Color.black.opacity(0.9))
        .foregroundStyle(bench ? Color.black : Color.white)
    }

    var stepContent: some View {
        let step = steps[done]
        let name = names[step.partId] ?? step.partId
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(verbatim: "CUT \(done + 1)/\(steps.count)")
                    .font(.footnote.bold())
                Spacer()
                Text(verbatim: "\(done * 100 / max(1, steps.count))%")
                    .font(.footnote.bold())
                    .foregroundStyle(.orange)
            }
            .padding(.top, 8)

            Text(verbatim: name)
                .font(.system(size: bench ? 46 : 40, weight: .heavy))
                .lineLimit(1)
            Text(verbatim: "\(step.w / 100)×\(step.h / 100) mm" + (step.rotated ? "  ⤾" : ""))
                .font(.system(size: bench ? 34 : 28, weight: .bold))
            Text("Sheet \(step.sheetIndex + 1)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                done += 1
            } label: {
                Text("DONE")
                    .font(.system(size: bench ? 26 : 22, weight: .heavy))
                    .frame(maxWidth: .infinity, minHeight: bench ? 72 : 64)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)

            Button {
                if done > 0 { done -= 1 }
            } label: {
                Text("Undo").frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.bordered)
            .disabled(done == 0)
            .padding(.bottom, 16)
        }
    }

    var doneContent: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("All cuts done")
                .font(.system(size: 34, weight: .heavy))
            Text("\(steps.count) parts cut — nice work!")
                .font(.title3)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                if done > 0 { done -= 1 }
            } label: {
                Text("Undo").frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.bordered)
            Button {
                dismiss()
            } label: {
                Text("Back to plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.bottom, 16)
        }
    }
}
