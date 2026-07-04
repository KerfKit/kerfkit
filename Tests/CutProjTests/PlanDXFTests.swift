import XCTest
@testable import CutProj
import CutModels

// E9-S4 kabulleri: DXF R12 yapısal doğruluk + y-ekseni çevirisi + Int-tabanlı
// kesin sayı metni (Double'sız) + levha filtresi + dosya adı kuralı.
final class PlanDXFTests: XCTestCase {

    private func ornekInput(unit: UnitMode = .metricMM) -> PlanDXF.Input {
        PlanDXF.Input(
            sheetW: 244_000, sheetH: 122_000, unit: unit,
            placements: [
                Placement(partId: "p1", sheetIndex: 0, x: 0, y: 0, w: 60_000, h: 40_000, rotated: false),
                Placement(partId: "p2", sheetIndex: 0, x: 60_300, y: 0, w: 60_000, h: 40_000, rotated: true),
                Placement(partId: "p3", sheetIndex: 1, x: 0, y: 0, w: 50_000, h: 30_000, rotated: false),
            ],
            names: ["p1": "Raf", "p2": "Yan", "p3": "Kapak"])
    }

    func testR12IskeletVeKatmanlar() {
        let dxf = PlanDXF.generate(ornekInput(), sheetIndex: 0)
        XCTAssertTrue(dxf.hasPrefix("0\nSECTION\n2\nHEADER\n"))
        XCTAssertTrue(dxf.contains("9\n$ACADVER\n1\nAC1009\n"))
        XCTAssertTrue(dxf.contains("9\n$INSUNITS\n70\n4\n"), "metrik → mm (4)")
        for katman in ["SHEET", "PARTS", "LABELS"] {
            XCTAssertTrue(dxf.contains("0\nLAYER\n2\n\(katman)\n"), "\(katman) katmanı tanımlı olmalı")
        }
        XCTAssertTrue(dxf.hasSuffix("0\nENDSEC\n0\nEOF\n"))
    }

    func testLevhaFiltresiVeKapaliPolyline() {
        let dxf = PlanDXF.generate(ornekInput(), sheetIndex: 0)
        // levha 0: çerçeve + 2 parça = 3 POLYLINE; her biri kapalı (70/1) + SEQEND
        XCTAssertEqual(dxf.components(separatedBy: "0\nPOLYLINE\n").count - 1, 3)
        XCTAssertEqual(dxf.components(separatedBy: "0\nSEQEND\n").count - 1, 3)
        XCTAssertEqual(dxf.components(separatedBy: "70\n1\n").count - 1, 3, "tüm polyline'lar kapalı")
        XCTAssertEqual(dxf.components(separatedBy: "0\nVERTEX\n").count - 1, 12, "3 dikdörtgen × 4 köşe")
        XCTAssertFalse(dxf.contains("Kapak"), "levha 1 parçası levha 0 dosyasına sızmamalı")

        let dxf1 = PlanDXF.generate(ornekInput(), sheetIndex: 1)
        XCTAssertTrue(dxf1.contains("1\nKapak\n"))
        XCTAssertEqual(dxf1.components(separatedBy: "0\nPOLYLINE\n").count - 1, 2, "çerçeve + 1 parça")
    }

    func testYEkseniCevirisiVeEtiket() {
        let dxf = PlanDXF.generate(ornekInput(), sheetIndex: 0)
        // p1 (x0 y0 w600 h400, üst-sol) → DXF sol-alt köşe (0, 1220−400=820)
        XCTAssertTrue(dxf.contains("0\nVERTEX\n8\nPARTS\n10\n0\n20\n820\n"),
                      "y-yukarı çeviri: üstteki parça DXF'te tepede biter")
        // rotasyon işareti etikete " (R)" olarak düşer (ASCII — DXF TEXT güvenli)
        XCTAssertTrue(dxf.contains("1\nYan (R)\n"))
        XCTAssertTrue(dxf.contains("1\nRaf\n"))
    }

    func testSayiMetni_metrikVeImperial_IntKesin() {
        // metrik: 0.01mm birim → mm
        XCTAssertEqual(PlanDXF.sayi(61_250, unit: .metricMM), "612.5")
        XCTAssertEqual(PlanDXF.sayi(61_205, unit: .metricMM), "612.05")
        XCTAssertEqual(PlanDXF.sayi(61_200, unit: .metricMM), "612")
        XCTAssertEqual(PlanDXF.sayi(0, unit: .metricMM), "0")
        // imperial: 1/6400″ birim → inç (tam kesin: 1/6400 = 0.00015625)
        XCTAssertEqual(PlanDXF.sayi(6_400, unit: .imperialFrac64), "1")
        XCTAssertEqual(PlanDXF.sayi(3_200, unit: .imperialFrac64), "0.5")
        XCTAssertEqual(PlanDXF.sayi(100, unit: .imperialFrac64), "0.015625")
        XCTAssertEqual(PlanDXF.sayi(1, unit: .imperialFrac64), "0.00015625")
    }

    func testImperialBirimBasligi() {
        let dxf = PlanDXF.generate(ornekInput(unit: .imperialFrac64), sheetIndex: 0)
        XCTAssertTrue(dxf.contains("9\n$INSUNITS\n70\n1\n"), "imperial → inç (1)")
    }

    func testDosyaAdi() {
        XCTAssertEqual(PlanDXF.fileName(projectName: "Dolap", sheetIndex: 0, sheetCount: 1),
                       "Dolap.dxf")
        XCTAssertEqual(PlanDXF.fileName(projectName: "Dolap", sheetIndex: 1, sheetCount: 3),
                       "Dolap-sheet2.dxf")
        XCTAssertEqual(PlanDXF.fileName(projectName: "", sheetIndex: 0, sheetCount: 1),
                       "kerfkit.dxf")
    }

    func testDeterminizm_ayniGirdiAyniMetin() {
        let a = PlanDXF.generate(ornekInput(), sheetIndex: 0)
        let b = PlanDXF.generate(ornekInput(), sheetIndex: 0)
        XCTAssertEqual(a, b)
    }
}
