import CutModels

public enum EngineError: Error, Equatable { case notImplemented(String), invalidRequest }

public let engineVersion = "0.1.0-dev"

// E1 epiği burada büyüyecek (docs/04 §3). G-0 aşamasında bilinçli olarak boş:
// test-önce kültürü gereği ilk gerçek implementasyon E1-S1a oturumunda gelir.
public func optimize(_ req: OptimizeRequest) throws -> OptimizeResult {
    guard validate(req).isEmpty else { throw EngineError.invalidRequest }
    throw EngineError.notImplemented("E1-S1a: serbest-dikdortgen agaci + yerlestirme")
}
