import CutModels

public enum EngineError: Error, Equatable { case notImplemented(String), invalidRequest }

public let engineVersion = "0.1.0-dev"

// docs/04 §3 — E1-S1a: tek heuristik koşu (Best Area Fit), kerf=0/trim=0 basit hal.
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
    return try placeAll(req)
}
