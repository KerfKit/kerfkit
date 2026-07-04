import SwiftUI
import CoreTransferable
import UniformTypeIdentifiers
import CutProj
import CutModels

// Paylaşım öğeleri TEMBEL: render/encode yalnız kullanıcı paylaşınca koşar —
// body her değerlendirmede PDF üretmek israf olurdu (K-13).
struct PlanPDFExport: Transferable {
    let input: PlanPDF.Input

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .pdf) { export in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(export.input.projectName.safeFileName).pdf")
            try PlanPDF.render(export.input).write(to: url)
            return SentTransferredFile(url)
        }
    }
}

struct CutprojExport: Transferable {
    let doc: ProjectDoc

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: UTType(filenameExtension: "cutproj") ?? .json) { export in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(export.doc.name.safeFileName).cutproj")
            try ProjectIO.encode(export.doc).write(to: url)
            return SentTransferredFile(url)
        }
    }
}

// K-12: parça listesi CSV'si — Numbers/Excel/diğer uygulamalarla alışveriş.
struct CSVExport: Transferable {
    let name: String
    let rows: [CSVPartList.Row]
    let unit: UnitMode

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { export in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(export.name.safeFileName).csv")
            try Data(CSVPartList.export(export.rows, unit: export.unit).utf8).write(to: url)
            return SentTransferredFile(url)
        }
    }
}

extension String {
    var safeFileName: String {
        replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-")
    }
}

// E9-S4: levha başına DXF R12 — CNC/nesting akışları (PlanDXF, CutProj katmanı).
struct DXFExport: Transferable, Identifiable {
    let id: Int            // sheetIndex
    let fileName: String
    let input: PlanDXF.Input

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: UTType(filenameExtension: "dxf") ?? .data) { export in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(export.fileName.safeFileName) // ad .dxf içerir
            try Data(PlanDXF.generate(export.input, sheetIndex: export.id).utf8).write(to: url)
            return SentTransferredFile(url)
        }
    }
}
