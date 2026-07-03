import Foundation
import CutModels

// K-12 (E3-S3) — parça listesi CSV/TSV alışverişi (docs/03 AC):
//   · ayraç otomatik algılanır (virgül / noktalı virgül / tab)
//   · hatalı satır ATLANIR ve satır numarasıyla raporlanır (asla sessiz düşmez)
//   · export → import kayıpsızdır (ad içinde ayraç/tırnak dahil)
// Kolonlar: name, width_mm, height_mm, qty[, rotation][, banding]
//   rotation: "allowed" | "fixed" (boş → allowed)
//   banding:  TBLR alt kümesi, ör. "TLR" (boş → yok)
public enum CSVPartList {

    public struct Row: Equatable, Sendable {
        public var name: String
        public var width: Int
        public var height: Int
        public var qty: Int
        public var rotationAllowed: Bool
        public var banding: BandingDoc

        public init(name: String, width: Int, height: Int, qty: Int,
                    rotationAllowed: Bool = true, banding: BandingDoc = BandingDoc()) {
            self.name = name; self.width = width; self.height = height
            self.qty = qty; self.rotationAllowed = rotationAllowed; self.banding = banding
        }
    }

    public enum IssueReason: Equatable, Sendable {
        case tooFewColumns(found: Int)
        case invalidNumber(field: String, value: String)
        case nonPositive(field: String)
    }

    public struct LineIssue: Equatable, Sendable {
        public let line: Int // 1 tabanlı, başlık dahil — kullanıcı dosyada bulabilsin
        public let reason: IssueReason
    }

    // — ayraç algısı: ilk dolu satırlarda en sık görünen ayraç kazanır —
    public static func detectDelimiter(_ text: String) -> Character {
        var counts: [Character: Int] = [",": 0, ";": 0, "\t": 0]
        for line in text.split(separator: "\n", omittingEmptySubsequences: true).prefix(5) {
            var inQuotes = false
            for ch in line {
                if ch == "\"" { inQuotes.toggle() }
                else if !inQuotes, counts[ch] != nil { counts[ch, default: 0] += 1 }
            }
        }
        return counts.max { l, r in (l.value, tieRank(l.key)) < (r.value, tieRank(r.key)) }?.key ?? ","
    }

    // Eşitlikte öncelik: tab > noktalı virgül > virgül (yapıştırılan TSV en net sinyaldir).
    private static func tieRank(_ c: Character) -> Int { c == "\t" ? 2 : c == ";" ? 1 : 0 }

    public static func parse(_ text: String) -> (rows: [Row], issues: [LineIssue]) {
        let delimiter = detectDelimiter(text)
        var rows: [Row] = []
        var issues: [LineIssue] = []

        let lines = text.components(separatedBy: .newlines)
        for (index, rawLine) in lines.enumerated() {
            let lineNo = index + 1
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }

            let fields = splitFields(line, delimiter: delimiter)
            // Başlık satırı: sayı kolonunda sayı yoksa ve ilk satırlardaysa sessizce atla.
            if rows.isEmpty, issues.isEmpty, fields.count >= 3, Int(cleanNumber(fields[1])) == nil,
               fields[1].rangeOfCharacter(from: .decimalDigits) == nil {
                continue
            }
            guard fields.count >= 3 else {
                issues.append(LineIssue(line: lineNo, reason: .tooFewColumns(found: fields.count)))
                continue
            }

            guard let w = Int(cleanNumber(fields[1])) else {
                issues.append(LineIssue(line: lineNo, reason: .invalidNumber(field: "width", value: fields[1]))); continue
            }
            guard let h = Int(cleanNumber(fields[2])) else {
                issues.append(LineIssue(line: lineNo, reason: .invalidNumber(field: "height", value: fields[2]))); continue
            }
            var qty = 1
            if fields.count >= 4, !fields[3].isEmpty {
                guard let q = Int(cleanNumber(fields[3])) else {
                    issues.append(LineIssue(line: lineNo, reason: .invalidNumber(field: "qty", value: fields[3]))); continue
                }
                qty = q
            }
            guard w > 0, h > 0 else { issues.append(LineIssue(line: lineNo, reason: .nonPositive(field: w <= 0 ? "width" : "height"))); continue }
            guard qty > 0 else { issues.append(LineIssue(line: lineNo, reason: .nonPositive(field: "qty"))); continue }

            let rotation = fields.count >= 5 ? fields[4].lowercased() : ""
            let bandingCode = fields.count >= 6 ? fields[5].uppercased() : ""
            rows.append(Row(name: fields[0], width: w, height: h, qty: qty,
                            rotationAllowed: rotation != "fixed",
                            banding: BandingDoc(top: bandingCode.contains("T"),
                                                bottom: bandingCode.contains("B"),
                                                left: bandingCode.contains("L"),
                                                right: bandingCode.contains("R"))))
        }
        return (rows, issues)
    }

    // Başlık proje birimini söyler: metrik width_mm, imperial width_64th (sayı uzayı
    // projeninkidir; import başlığı zaten toleransla atlar — dönüşüm yapılmaz).
    public static func export(_ rows: [Row], unit: UnitMode = .metricMM) -> String {
        let cols = unit == .metricMM ? "width_mm,height_mm" : "width_64th,height_64th"
        var out = "name,\(cols),qty,rotation,banding\n"
        for r in rows {
            let banding = (r.banding.top ? "T" : "") + (r.banding.bottom ? "B" : "")
                + (r.banding.left ? "L" : "") + (r.banding.right ? "R" : "")
            out += [quote(r.name), String(r.width), String(r.height), String(r.qty),
                    r.rotationAllowed ? "allowed" : "fixed", banding].joined(separator: ",") + "\n"
        }
        return out
    }

    // — alan bölme: çift tırnak destekli (ad içinde ayraç/tırnak kayıpsız kalsın) —
    private static func splitFields(_ line: String, delimiter: Character) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var i = line.startIndex
        while i < line.endIndex {
            let ch = line[i]
            if ch == "\"" {
                let next = line.index(after: i)
                if inQuotes, next < line.endIndex, line[next] == "\"" {
                    current.append("\""); i = next // kaçışlı tırnak: ""
                } else {
                    inQuotes.toggle()
                }
            } else if ch == delimiter && !inQuotes {
                fields.append(current.trimmingCharacters(in: .whitespaces)); current = ""
            } else {
                current.append(ch)
            }
            i = line.index(after: i)
        }
        fields.append(current.trimmingCharacters(in: .whitespaces))
        return fields
    }

    private static func quote(_ name: String) -> String {
        name.contains(where: { $0 == "," || $0 == ";" || $0 == "\t" || $0 == "\"" })
            ? "\"" + name.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            : name
    }

    // Yalnız boşluk temizlenir ("1 220" → "1220"). Ondalıklı biçimler ("600,5"/"600.5")
    // bilinçli olarak GEÇMEZ — mm tam sayıdır; satır numaralı hata olarak raporlanır.
    private static func cleanNumber(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "")
    }
}
