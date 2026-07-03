import CutModels

// docs/04 §2 motor sınırları (E1-S1c) — bu ikili, motordaki tüm alan çarpımlarını ve
// wasteBps'in ×10^4 adımını Int64 içinde tutar (tavan 9,22×10^14 birim²).
let maxDimension: Units = 100_000_000               // 10^8 birim
let maxTotalStockArea: Units = 500_000_000_000_000  // 5×10^14 birim²

// docs/04 §3 adım 1 — UI ön-doğrulama. E1-S1 AC-2/AC-4 buradan test edilir.
public func validate(_ req: OptimizeRequest) -> [ValidationIssue] {
    var issues: [ValidationIssue] = []
    if req.kerf < 0 || req.trim < 0 {
        issues.append(.init(kind: .negativeKerfOrTrim, subjectId: "request", message: "kerf/trim >= 0 olmali"))
    }
    let materialIds = Set(req.stocks.map(\.materialId))
    var areaBudget = maxTotalStockArea
    var areaExceeded = false
    for s in req.stocks {
        var dimsValid = true
        if s.w <= 0 || s.h <= 0 {
            issues.append(.init(kind: .nonPositiveDimension, subjectId: s.id, message: "stok boyutu > 0 olmali")); dimsValid = false
        } else if s.w > maxDimension || s.h > maxDimension {
            issues.append(.init(kind: .dimensionTooLarge, subjectId: s.id, message: "stok boyutu <= 10^8 birim olmali (04 §2)")); dimsValid = false
        }
        if s.qty < 1 { issues.append(.init(kind: .nonPositiveQuantity, subjectId: s.id, message: "stok adedi >= 1 olmali")) }
        guard dimsValid, s.qty >= 1, !areaExceeded else { continue }
        // area·qty > kalan bütçe testi bölmeyle: area > budget/qty ⇔ area·qty > budget (tam),
        // çarpma yalnız güvenli dalda yapılır — taşma imkânsız.
        let area = s.w * s.h // ≤ 10^16, güvenli
        if area > areaBudget / Units(s.qty) {
            areaExceeded = true
        } else {
            areaBudget -= area * Units(s.qty)
        }
    }
    if areaExceeded {
        issues.append(.init(kind: .totalStockAreaTooLarge, subjectId: "request", message: "toplam stok alani <= 5*10^14 birim^2 olmali (04 §2)"))
    }
    for p in req.parts {
        if p.w <= 0 || p.h <= 0 { issues.append(.init(kind: .nonPositiveDimension, subjectId: p.id, message: "parca boyutu > 0 olmali")); continue }
        if p.w > maxDimension || p.h > maxDimension { issues.append(.init(kind: .dimensionTooLarge, subjectId: p.id, message: "parca boyutu <= 10^8 birim olmali (04 §2)")); continue }
        if p.qty < 1 { issues.append(.init(kind: .nonPositiveQuantity, subjectId: p.id, message: "parca adedi >= 1 olmali")) }
        if !materialIds.contains(p.materialId) {
            issues.append(.init(kind: .unknownMaterial, subjectId: p.id, message: "parcanin malzemesi stoklarda yok"))
            continue
        }
        let fits = req.stocks.contains { s in
            guard s.materialId == p.materialId else { return false }
            let uw = s.w - 2 * req.trim, uh = s.h - 2 * req.trim
            let direct = p.w <= uw && p.h <= uh
            let rotated = p.rotation == .allowed && p.h <= uw && p.w <= uh
            return direct || rotated
        }
        if !fits { issues.append(.init(kind: .partExceedsStock, subjectId: p.id, message: "parca hicbir stoga sigmiyor (trim dahil)")) }
    }
    return issues
}
