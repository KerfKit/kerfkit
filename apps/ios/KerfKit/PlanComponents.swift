import SwiftUI
import CutModels

// Plan sekmesinin (PlanTabView, M-4) çizim bileşenleri: StatCard + SheetDiagram.
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold().monospacedDigit())
                .foregroundStyle(DesignTokens.colorAmber500)
            Text(title)
                .font(.caption)
                .foregroundStyle(DesignTokens.colorTimber300)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(DesignTokens.colorTimber900, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Diyagram dili docs/12 §5 özü: koyu levha zemini + amber parçalar + etiketler.
// Motor orijini sol-alt; Canvas sol-üst — y ekseni çevrilir.
struct SheetDiagram: View {
    let placements: [Placement]
    let names: [String: String]
    let sheetW: Units
    let sheetH: Units
    // M-5: vurgulu yerleşim — dolu verilirse yalnız o amber, kalanlar soluk çizilir.
    var highlight: Placement? = nil
    var muted = false // Tezgâh Modu: soluk zemin açık tema tonlarıyla

    var body: some View {
        // Sıfır/eksi levha ölçüsü aspectRatio ve ölçekte NaN üretir — çizme.
        if sheetW <= 0 || sheetH <= 0 {
            Color.clear
        } else {
            diagram
        }
    }

    private var diagram: some View {
        Canvas { ctx, size in
            let scale = min(size.width / CGFloat(sheetW), size.height / CGFloat(sheetH))
            let w = CGFloat(sheetW) * scale, h = CGFloat(sheetH) * scale
            let ox = (size.width - w) / 2, oy = (size.height - h) / 2

            ctx.fill(Path(CGRect(x: ox, y: oy, width: w, height: h)),
                     with: .color(muted ? DesignTokens.colorTimber100 : DesignTokens.colorTimber800))

            for p in placements {
                let rect = CGRect(
                    x: ox + CGFloat(p.x) * scale,
                    y: oy + h - CGFloat(p.y + p.h) * scale,
                    width: CGFloat(p.w) * scale,
                    height: CGFloat(p.h) * scale)
                let isActive = highlight == nil || p == highlight
                let fill = isActive ? DesignTokens.colorAmber500
                    : (muted ? DesignTokens.colorTimber300 : DesignTokens.colorTimber700)
                ctx.fill(Path(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2),
                         with: .color(fill))
                if highlight != nil && p == highlight {
                    ctx.stroke(Path(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2),
                               with: .color(DesignTokens.colorAmber700), lineWidth: 3)
                }
                let name = names[p.partId] ?? p.partId
                let label = Text("\(name)\(p.rotated ? " ⤾" : "")")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DesignTokens.colorTimber950)
                if isActive && rect.width > 40 && rect.height > 16 {
                    ctx.draw(label, at: CGPoint(x: rect.midX, y: rect.midY))
                }
            }
        }
        .aspectRatio(CGFloat(sheetW) / CGFloat(sheetH), contentMode: .fit)
        .accessibilityLabel("Kesim diyagramı: \(placements.count) parça yerleşimi")
    }
}
