import SwiftUI
import CoreTransferable
import UniformTypeIdentifiers
import CutProj

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

extension String {
    var safeFileName: String {
        replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-")
    }
}
