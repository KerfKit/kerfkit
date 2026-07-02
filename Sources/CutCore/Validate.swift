import CutModels

// docs/04 §3 adım 1 — UI ön-doğrulama. E1-S1 AC-2/AC-4 buradan test edilir.
public func validate(_ req: OptimizeRequest) -> [ValidationIssue] {
    var issues: [ValidationIssue] = []
    if req.kerf < 0 || req.trim < 0 {
        issues.append(.init(kind: .negativeKerfOrTrim, subjectId: "request", message: "kerf/trim >= 0 olmali"))
    }
    let materialIds = Set(req.stocks.map(\.materialId))
    for s in req.stocks {
        if s.w <= 0 || s.h <= 0 { issues.append(.init(kind: .nonPositiveDimension, subjectId: s.id, message: "stok boyutu > 0 olmali")) }
        if s.qty < 1 { issues.append(.init(kind: .nonPositiveQuantity, subjectId: s.id, message: "stok adedi >= 1 olmali")) }
    }
    for p in req.parts {
        if p.w <= 0 || p.h <= 0 { issues.append(.init(kind: .nonPositiveDimension, subjectId: p.id, message: "parca boyutu > 0 olmali")); continue }
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
