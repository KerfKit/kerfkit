import CutModels

public enum EngineError: Error, Equatable { case notImplemented(String), invalidRequest }

// 0.2.0: E1-S4b heuristik portföyü — davranış ailesi değişti, golden'lar bilinçli güncellendi.
public let engineVersion = "0.2.0-dev"

// docs/04 §3 — doğrulama → malzeme havuzlu 12-koşuluk portföy → hedefe göre seçim.
public func optimize(_ req: OptimizeRequest) throws -> OptimizeResult {
    let issues = validate(req)
    if !issues.isEmpty {
        // E1-S1 AC-2: salt "hiçbir stoğa sığmıyor" durumu tipli yerleştirme hatasıdır;
        // başka her doğrulama sorunu (tek başına ya da karışık) genel doğrulama hatası.
        if let first = issues.first, issues.allSatisfy({ $0.kind == .partExceedsStock }) {
            throw PlacementError.partExceedsStock(partId: first.subjectId)
        }
        throw EngineError.invalidRequest
    }
    return runPortfolio(req)
}
