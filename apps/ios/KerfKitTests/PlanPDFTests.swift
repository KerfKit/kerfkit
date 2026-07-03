import XCTest
import UIKit
import SnapshotTesting
@testable import KerfKit

// K-13 golden'ı (docs/17): örnek projenin PDF'i sabitlenir — sayfa sayısı + sayfa
// görüntüleri. Tarih ve kâğıt (A4) sabit: render bit-kararlı.
@MainActor
final class PlanPDFTests: XCTestCase {

    private func makeInput() throws -> PlanPDF.Input {
        let store = ProjectStore(inMemory: true)
        store.createProject(sample: true)
        store.optimizePlan()
        let result = try XCTUnwrap(store.result, "Örnek plan hesaplanamadı")
        let request = try XCTUnwrap(store.lastRequest)
        return PlanPDF.Input(projectName: "Mutfak Dolabı",
                             dateText: "3 Temmuz 2026",
                             parts: store.parts, result: result, request: request,
                             names: store.partNames)
    }

    func testPageCount_oneSummaryPlusPerSheet() throws {
        let input = try makeInput()
        let data = PlanPDF.render(input, pageSize: PlanPDF.a4)
        let doc = try XCTUnwrap(pdfDocument(from: data))
        XCTAssertEqual(doc.numberOfPages, 1 + input.result.stats.sheetCount)
    }

    func testGolden_summaryAndDiagramPages() throws {
        let data = PlanPDF.render(try makeInput(), pageSize: PlanPDF.a4)
        assertSnapshot(of: try pageImage(data, page: 1), as: .image, named: "pdf-ozet")
        assertSnapshot(of: try pageImage(data, page: 2), as: .image, named: "pdf-levha1")
    }

    // — PDF sayfasını rasterize et —

    private func pdfDocument(from data: Data) -> CGPDFDocument? {
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        return CGPDFDocument(provider)
    }

    private func pageImage(_ data: Data, page number: Int) throws -> UIImage {
        let doc = try XCTUnwrap(pdfDocument(from: data))
        let page = try XCTUnwrap(doc.page(at: number), "Sayfa \(number) yok")
        let box = page.getBoxRect(.mediaBox)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1 // golden karşılaştırması cihaz ölçeğinden bağımsız
        return UIGraphicsImageRenderer(size: box.size, format: format).image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: box.size))
            ctx.cgContext.translateBy(x: 0, y: box.size.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            ctx.cgContext.drawPDFPage(page)
        }
    }
}
