import SwiftUI
import CutModels
import CutCore

struct PartInput: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var widthMM: Int
    var heightMM: Int
    var qty: Int
    var rotationAllowed: Bool
}

// UI durumu — kalıcılık E3-S2'de (GRDB, onay bekliyor); MVP bellek-içi.
@Observable
final class ProjectStore {
    // Örnek proje: Mutfak Dolabı (onboarding aktivasyon garantisi özü, docs/03 E4-S6).
    var parts: [PartInput] = [
        .init(name: "Yan", widthMM: 720, heightMM: 580, qty: 2, rotationAllowed: false),
        .init(name: "Raf", widthMM: 764, heightMM: 560, qty: 2, rotationAllowed: true),
        .init(name: "Kapak", widthMM: 396, heightMM: 716, qty: 1, rotationAllowed: false),
        .init(name: "Çekmece", widthMM: 396, heightMM: 180, qty: 6, rotationAllowed: true),
    ]
    var sheetWidthMM = 2440
    var sheetHeightMM = 1220
    var sheetQty = 5
    var kerfMM = 3
    var trimMM = 0
    var objective: Objective = .sheets

    var result: OptimizeResult?
    var partNames: [String: String] = [:]
    var errorMessage: String?

    var sheetW: Units { Units(sheetWidthMM) * 100 }
    var sheetH: Units { Units(sheetHeightMM) * 100 }

    func optimizePlan() {
        var names: [String: String] = [:]
        let specs = parts.enumerated().compactMap { i, p -> PartSpec? in
            guard p.widthMM > 0, p.heightMM > 0, p.qty > 0 else { return nil }
            let pid = "p\(i)"
            names[pid] = p.name.isEmpty ? "Parça \(i + 1)" : p.name
            return PartSpec(id: pid, name: names[pid] ?? "", materialId: "panel",
                            w: Units(p.widthMM) * 100, h: Units(p.heightMM) * 100,
                            qty: p.qty, rotation: p.rotationAllowed ? .allowed : .fixed)
        }
        let req = OptimizeRequest(
            unitMode: .metricMM,
            kerf: Units(kerfMM) * 100,
            trim: Units(trimMM) * 100,
            objective: objective,
            seed: 1,
            stocks: [StockSpec(id: "levha", materialId: "panel", w: sheetW, h: sheetH, qty: sheetQty)],
            parts: specs)
        do {
            result = try optimize(req)
            partNames = names
            errorMessage = nil
        } catch let error as PlacementError {
            result = nil
            if case .partExceedsStock(let pid) = error {
                errorMessage = "\(names[pid] ?? pid) levhaya sığmıyor — boyutları ya da damar kilidini kontrol et."
            }
        } catch {
            result = nil
            errorMessage = "Girdi doğrulamadan geçmedi — boyut ve adetleri kontrol et."
        }
    }
}
