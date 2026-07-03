import UIKit
import CutModels

// K-13 (E4-S4): Plan PDF'i — docs/12 §7 gereği HER ZAMAN açık tema (print gerçeği).
// Sayfa 1: başlık + özet + parça listesi (taşarsa devam sayfası); ardından levha başına
// bir diyagram sayfası. Golden test A4 + sabit tarihle bit-kararlı render'ı sabitler.
enum PlanPDF {
    // Açık palet (docs/12 print): koyu marka PDF'e taşınmaz.
    private static let ink = UIColor(red: 0.11, green: 0.098, blue: 0.09, alpha: 1)       // timber-950
    private static let inkSoft = UIColor(red: 0.34, green: 0.325, blue: 0.306, alpha: 1)  // timber-700
    private static let amber = UIColor(red: 0.961, green: 0.62, blue: 0.043, alpha: 1)    // amber-500
    private static let amberDark = UIColor(red: 0.71, green: 0.325, blue: 0.035, alpha: 1) // amber-700
    private static let sheetBg = UIColor(red: 0.961, green: 0.941, blue: 0.902, alpha: 1) // timber-100
    private static let hairline = UIColor(red: 0.906, green: 0.898, blue: 0.894, alpha: 1) // timber-200

    static let a4 = CGSize(width: 595.2, height: 841.8)
    static let letter = CGSize(width: 612, height: 792)

    // Bölge kâğıdı: ABD ölçü sistemi → Letter, gerisi A4 (docs/17 K-13 "A4/Letter").
    static var regionPageSize: CGSize {
        Locale.current.measurementSystem == .us ? letter : a4
    }

    struct Input {
        var projectName: String
        var dateText: String
        var parts: [PartInput]
        var result: OptimizeResult
        var request: OptimizeRequest
        var names: [String: String]
    }

    static func render(_ input: Input, pageSize: CGSize = PlanPDF.regionPageSize) -> Data {
        let margin: CGFloat = 40
        let contentWidth = pageSize.width - margin * 2
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        return renderer.pdfData { ctx in
            ctx.beginPage()
            var y = margin

            // Başlık + tarih
            y = draw("kerfkit — \(input.projectName)", at: y, x: margin,
                     font: .boldSystemFont(ofSize: 20), color: ink)
            y = draw(input.dateText, at: y + 2, x: margin,
                     font: .systemFont(ofSize: 10), color: inkSoft) + 10

            // Özet satırı
            let s = input.result.stats
            let bandMM = input.parts.reduce(0) { $0 + $1.bandLengthMM }
            let summary = "\(s.sheetCount) \(String(localized: "sheets"))  ·  \(s.wastePercentText) \(String(localized: "waste"))  ·  " +
                "\(s.cutCount) \(String(localized: "cuts"))  ·  \(String(localized: "banding")) \(String(format: "%.1f", Double(bandMM) / 1000)) m"
            y = draw(summary, at: y, x: margin, font: .systemFont(ofSize: 12, weight: .semibold),
                     color: ink) + 14

            // Parça tablosu
            y = drawTableHeader(at: y, x: margin, width: contentWidth)
            for part in input.parts {
                if y > pageSize.height - margin - 24 { // sayfa doldu — devam sayfası
                    ctx.beginPage()
                    y = margin
                    y = drawTableHeader(at: y, x: margin, width: contentWidth)
                }
                y = drawRow(part, at: y, x: margin, width: contentWidth)
            }

            // Levha diyagramları — her levha kendi sayfasında, açık temada.
            let stockW = input.request.stocks.first?.w ?? 1
            let stockH = input.request.stocks.first?.h ?? 1
            for sheet in 0..<s.sheetCount {
                ctx.beginPage()
                var dy = margin
                dy = draw("\(String(localized: "Sheet")) \(sheet + 1) / \(s.sheetCount) — \(input.projectName)",
                          at: dy, x: margin, font: .boldSystemFont(ofSize: 14), color: ink) + 12
                let placements = input.result.placements.filter { $0.sheetIndex == sheet }
                let avail = CGRect(x: margin, y: dy, width: contentWidth,
                                   height: pageSize.height - dy - margin)
                drawDiagram(placements, names: input.names,
                            sheetW: stockW, sheetH: stockH, in: avail)
            }
        }
    }

    // — çizim yardımcıları —

    @discardableResult
    private static func draw(_ text: String, at y: CGFloat, x: CGFloat,
                             font: UIFont, color: UIColor) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let size = (text as NSString).size(withAttributes: attrs)
        (text as NSString).draw(at: CGPoint(x: x, y: y), withAttributes: attrs)
        return y + size.height
    }

    private static func drawTableHeader(at y: CGFloat, x: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 9, weight: .bold)
        let cols = columns(x: x, width: width)
        let headers = [(String(localized: "PART"), cols.name), (String(localized: "W × H (mm)"), cols.size),
                       (String(localized: "QTY"), cols.qty), (String(localized: "BANDING"), cols.band)]
        for (title, colX) in headers {
            (title as NSString).draw(at: CGPoint(x: colX, y: y),
                                     withAttributes: [.font: font, .foregroundColor: inkSoft])
        }
        let lineY = y + 14
        strokeLine(from: CGPoint(x: x, y: lineY), to: CGPoint(x: x + width, y: lineY), color: ink)
        return lineY + 4
    }

    private static func drawRow(_ part: PartInput, at y: CGFloat, x: CGFloat,
                                width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 11)
        let cols = columns(x: x, width: width)
        let edges = [part.banding.top, part.banding.bottom, part.banding.left, part.banding.right]
            .filter { $0 }.count
        let cells = [(part.name, cols.name),
                     ("\(part.widthMM) × \(part.heightMM)", cols.size),
                     ("×\(part.qty)", cols.qty),
                     (edges == 0 ? "—" : String(localized: "\(edges) edges"), cols.band)]
        for (text, colX) in cells {
            (text as NSString).draw(at: CGPoint(x: colX, y: y),
                                    withAttributes: [.font: font, .foregroundColor: ink])
        }
        let lineY = y + 17
        strokeLine(from: CGPoint(x: x, y: lineY), to: CGPoint(x: x + width, y: lineY),
                   color: hairline)
        return lineY + 3
    }

    private static func columns(x: CGFloat, width: CGFloat)
        -> (name: CGFloat, size: CGFloat, qty: CGFloat, band: CGFloat) {
        (x, x + width * 0.42, x + width * 0.68, x + width * 0.82)
    }

    private static func strokeLine(from: CGPoint, to: CGPoint, color: UIColor) {
        guard let cg = UIGraphicsGetCurrentContext() else { return }
        cg.setStrokeColor(color.cgColor)
        cg.setLineWidth(0.5)
        cg.move(to: from); cg.addLine(to: to); cg.strokePath()
    }

    // Motor orijini sol-alt; PDF koordinatı sol-üst — y çevrilir (SheetDiagram ile aynı kural).
    private static func drawDiagram(_ placements: [Placement], names: [String: String],
                                    sheetW: Units, sheetH: Units, in rect: CGRect) {
        guard sheetW > 0, sheetH > 0, let cg = UIGraphicsGetCurrentContext() else { return }
        let scale = min(rect.width / CGFloat(sheetW), rect.height / CGFloat(sheetH))
        let w = CGFloat(sheetW) * scale, h = CGFloat(sheetH) * scale
        let ox = rect.minX + (rect.width - w) / 2
        let oy = rect.minY

        cg.setFillColor(sheetBg.cgColor)
        cg.fill(CGRect(x: ox, y: oy, width: w, height: h))
        cg.setStrokeColor(inkSoft.cgColor)
        cg.setLineWidth(0.8)
        cg.stroke(CGRect(x: ox, y: oy, width: w, height: h))

        let labelFont = UIFont.systemFont(ofSize: 9, weight: .semibold)
        for p in placements {
            let r = CGRect(x: ox + CGFloat(p.x) * scale,
                           y: oy + h - CGFloat(p.y + p.h) * scale,
                           width: CGFloat(p.w) * scale,
                           height: CGFloat(p.h) * scale).insetBy(dx: 0.6, dy: 0.6)
            cg.setFillColor(amber.cgColor)
            cg.fill(r)
            cg.setStrokeColor(amberDark.cgColor)
            cg.setLineWidth(0.6)
            cg.stroke(r)

            let name = "\(names[p.partId] ?? p.partId)\(p.rotated ? " ⤾" : "")"
            let size = (name as NSString).size(withAttributes: [.font: labelFont])
            if r.width > size.width + 4 && r.height > size.height + 2 {
                (name as NSString).draw(
                    at: CGPoint(x: r.midX - size.width / 2, y: r.midY - size.height / 2),
                    withAttributes: [.font: labelFont, .foregroundColor: ink])
            }
        }
    }
}
