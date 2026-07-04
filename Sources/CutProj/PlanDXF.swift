import CutModels

// E9-S4 — DXF R12 (AC1009) dışa aktarım: CNC/nesting kitlesi için levha başına
// bir çizim. Uygulama katmanı (motor değil) ama motor disiplini korunur:
// Int aritmetik + deterministik metin — Double YOK, hash'lenebilir çıktı.
// Katmanlar: SHEET (levha çerçevesi) · PARTS (parça dikdörtgenleri, kapalı
// POLYLINE) · LABELS (parça adı TEXT). Y ekseni DXF'te yukarı: y' = H − (y+h).
public enum PlanDXF {
    public struct Input {
        public var sheetW: Units
        public var sheetH: Units
        public var unit: UnitMode
        public var placements: [Placement]
        public var names: [String: String]

        public init(sheetW: Units, sheetH: Units, unit: UnitMode,
                    placements: [Placement], names: [String: String] = [:]) {
            self.sheetW = sheetW
            self.sheetH = sheetH
            self.unit = unit
            self.placements = placements
            self.names = names
        }
    }

    /// Tek levhanın DXF metni. `sheetIndex` filtreyi seçer; levhada parça yoksa
    /// yalnız çerçeve çizilir (CNC şablonu olarak yine geçerli).
    public static func generate(_ input: Input, sheetIndex: Int) -> String {
        var out = ""
        // — HEADER: sürüm + birim ($INSUNITS 4=mm, 1=inç; R12 okuyucular yok sayar) —
        out += kod(0, "SECTION") + kod(2, "HEADER")
        out += kod(9, "$ACADVER") + kod(1, "AC1009")
        out += kod(9, "$INSUNITS") + kod(70, input.unit == .metricMM ? "4" : "1")
        out += kod(0, "ENDSEC")

        // — TABLES: katmanlar (renkler AutoCAD indeks: 8 gri, 3 yeşil, 7 beyaz) —
        out += kod(0, "SECTION") + kod(2, "TABLES")
        out += kod(0, "TABLE") + kod(2, "LAYER") + kod(70, "3")
        out += katman("SHEET", renk: 8)
        out += katman("PARTS", renk: 3)
        out += katman("LABELS", renk: 7)
        out += kod(0, "ENDTAB") + kod(0, "ENDSEC")

        // — ENTITIES —
        out += kod(0, "SECTION") + kod(2, "ENTITIES")
        out += dikdortgen(x: 0, y: 0, w: input.sheetW, h: input.sheetH,
                          sheetH: input.sheetH, katman: "SHEET", unit: input.unit)
        let sayfaParcalari = input.placements.filter { $0.sheetIndex == sheetIndex }
        for p in sayfaParcalari {
            out += dikdortgen(x: p.x, y: p.y, w: p.w, h: p.h,
                              sheetH: input.sheetH, katman: "PARTS", unit: input.unit)
            let ad = input.names[p.partId] ?? p.partId
            out += etiket(ad + (p.rotated ? " (R)" : ""), p: p,
                          sheetH: input.sheetH, unit: input.unit)
        }
        out += kod(0, "ENDSEC") + kod(0, "EOF")
        return out
    }

    /// Dosya adı: tek levhada sade, çok levhada 1-tabanlı numara.
    public static func fileName(projectName: String, sheetIndex: Int, sheetCount: Int) -> String {
        let base = projectName.isEmpty ? "kerfkit" : projectName
        return sheetCount > 1 ? "\(base)-sheet\(sheetIndex + 1).dxf" : "\(base).dxf"
    }

    /// Birim metni — Int aritmetikle KESİN ondalık (Double yok):
    /// metrik 0.01mm → mm (2 hane) · imperial 1/6400″ → inç (8 hane, 15625 çarpanı).
    static func sayi(_ v: Units, unit: UnitMode) -> String {
        let negatif = v < 0
        let mutlak = negatif ? -v : v
        let tam: Units, kesirMetin: String
        switch unit {
        case .metricMM:
            tam = mutlak / 100
            kesirMetin = String(format2: mutlak % 100)
        case .imperialFrac64:
            tam = mutlak / 6400
            kesirMetin = String(format8: (mutlak % 6400) * 15625)
        }
        var sonuc = "\(tam)"
        let kirpik = kesirMetin.kirpSondakiSifirlar()
        if !kirpik.isEmpty { sonuc += "." + kirpik }
        return (negatif && sonuc != "0") ? "-" + sonuc : sonuc
    }

    // — iç yardımcılar —

    private static func kod(_ grup: Int, _ deger: String) -> String {
        "\(grup)\n\(deger)\n"
    }

    private static func katman(_ ad: String, renk: Int) -> String {
        kod(0, "LAYER") + kod(2, ad) + kod(70, "0") + kod(62, "\(renk)") + kod(6, "CONTINUOUS")
    }

    private static func dikdortgen(x: Units, y: Units, w: Units, h: Units,
                                   sheetH: Units, katman: String, unit: UnitMode) -> String {
        // DXF y-yukarı: sol-alt köşe = (x, H−(y+h))
        let y0 = sheetH - (y + h)
        var out = kod(0, "POLYLINE") + kod(8, katman) + kod(66, "1") + kod(70, "1")
        for (vx, vy) in [(x, y0), (x + w, y0), (x + w, y0 + h), (x, y0 + h)] {
            out += kod(0, "VERTEX") + kod(8, katman)
            out += kod(10, sayi(vx, unit: unit)) + kod(20, sayi(vy, unit: unit))
        }
        out += kod(0, "SEQEND")
        return out
    }

    private static func etiket(_ metin: String, p: Placement,
                               sheetH: Units, unit: UnitMode) -> String {
        // Parça merkezine; yükseklik = kısa kenarın 1/5'i, [5mm..30mm] bandında.
        let cx = p.x + p.w / 2
        let cy = sheetH - (p.y + p.h / 2)
        let kisa = min(p.w, p.h)
        let bant: ClosedRange<Units> = unit == .metricMM ? 500...3000 : 320...1920 // 5-30mm ≈ 0.05-0.3″
        let boy = min(max(kisa / 5, bant.lowerBound), bant.upperBound)
        return kod(0, "TEXT") + kod(8, "LABELS")
             + kod(10, sayi(cx, unit: unit)) + kod(20, sayi(cy, unit: unit))
             + kod(40, sayi(boy, unit: unit)) + kod(1, metin)
             + kod(72, "1") + kod(11, sayi(cx, unit: unit)) + kod(21, sayi(cy, unit: unit))
    }
}

private extension String {
    // Sabit genişlikli kesir metni (öndeki sıfırlar korunur) — Int'ten üretim.
    init(format2 v: Units) { self = Self.doldur(v, hane: 2) }
    init(format8 v: Units) { self = Self.doldur(v, hane: 8) }

    static func doldur(_ v: Units, hane: Int) -> String {
        var s = "\(v)"
        while s.count < hane { s = "0" + s }
        return s
    }

    func kirpSondakiSifirlar() -> String {
        var s = self
        while s.hasSuffix("0") { s.removeLast() }
        return s
    }
}
