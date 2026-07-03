import Foundation
import CutModels

// E4-S2b — birim gösterim katmanı (docs/04 §2): alan değerleri metrik projede mm,
// imperial projede 1/64″ ADEDİ olarak tutulur; Units'e köprü her iki modda ×100.
// Karışık birim tek projede yasak — dönüşüm yalnız Stok'taki birim değişiminde.
enum UnitFormat {

    // 1952 → "30 1/2", 64 → "1", 8 → "1/8" (gcd ile indirgenir; ″ işareti çağırana ait).
    static func fraction(frac64 value: Int) -> String {
        let whole = value / 64
        var num = value % 64
        if num == 0 { return String(whole) }
        var den = 64
        let g = gcd(num, den)
        num /= g; den /= g
        return whole == 0 ? "\(num)/\(den)" : "\(whole) \(num)/\(den)"
    }

    // Boyut etiketi: metrik "720", imperial "30 1/2″".
    static func dimension(_ value: Int, unit: UnitMode) -> String {
        switch unit {
        case .metricMM: String(value)
        case .imperialFrac64: fraction(frac64: value) + "\u{2033}"
        }
    }

    // "720 × 580" / "30 1/2″ × 15 1/4″" — satır ve talimat etiketleri için.
    static func size(_ w: Int, _ h: Int, unit: UnitMode) -> String {
        "\(dimension(w, unit: unit)) × \(dimension(h, unit: unit))"
    }

    // Birim değişiminde alan dönüşümü — en yakın hedef birime yuvarlanır (deterministik).
    // 1″ = 25.4mm → mm→64th: round(mm·640/254) · 64th→mm: round(v·254/640).
    static func convert(_ value: Int, from: UnitMode, to: UnitMode) -> Int {
        guard from != to else { return value }
        switch to {
        case .imperialFrac64: return (value * 640 + 127) / 254
        case .metricMM: return (value * 254 + 320) / 640
        }
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }
}
