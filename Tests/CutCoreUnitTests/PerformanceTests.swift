import XCTest
import CutModels
@testable import CutCore

// K-9 (E1-S4c) — performans KANITI: 500 parçalık deterministik sentetik portföy <2sn
// (docs/03; M1'de release <0.5sn beklenir). Kural: yalnız ÖLÇ, optimizasyon önerme.
// PERF_LOOP ortam değişkeni profil almak içindir (sample/xctrace koşarken döngü uzatılır).
final class PerformanceTests: XCTestCase {

    // Deterministik boyut üretimi — platform RNG yasak (motor kuralıyla tutarlı test).
    private func syntheticRequest(partCount: Int) -> OptimizeRequest {
        var state: UInt64 = 0x4B45_5246 // "KERF"
        func next(_ range: ClosedRange<Int>) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return range.lowerBound + Int((state >> 33) % UInt64(range.count))
        }
        // Gerçekçi dağılım: %20 büyük panel, %50 orta, %30 küçük şerit (mm → Units ×100).
        var parts: [PartSpec] = []
        for i in 0..<partCount {
            let kind = next(0...9)
            let (w, h): (Int, Int) = kind < 2
                ? (next(600...1200), next(400...800))
                : kind < 7
                    ? (next(300...600), next(200...500))
                    : (next(80...300), next(60...200))
            parts.append(PartSpec(id: "p\(i)", name: "P\(i)", materialId: "m1",
                                  w: Units(w) * 100, h: Units(h) * 100, qty: 1,
                                  rotation: kind % 3 == 0 ? .fixed : .allowed))
        }
        return OptimizeRequest(unitMode: .metricMM, kerf: 300, trim: 1000,
                               objective: .sheets, seed: 1,
                               stocks: [StockSpec(id: "s1", materialId: "m1",
                                                  w: 244_000, h: 122_000, qty: 200)],
                               parts: parts)
    }

    func testK9_500PartsUnder2Seconds() throws {
        let request = syntheticRequest(partCount: 500)
        let loops = max(1, Int(ProcessInfo.processInfo.environment["PERF_LOOP"] ?? "1") ?? 1)

        let start = Date()
        var lastResult: OptimizeResult?
        for _ in 0..<loops { lastResult = try optimize(request) }
        let elapsed = Date().timeIntervalSince(start) / Double(loops)

        let result = try XCTUnwrap(lastResult)
        // Ölçümün anlamlı olması için planın gerçekten kurulduğunu doğrula.
        XCTAssertTrue(result.stats.sheetCount > 0)
        XCTAssertTrue(result.unplaced.isEmpty, "Sentetik portföy tamamen yerleşmeli")
        print("K-9 ölçüm: 500 parça = \(String(format: "%.3f", elapsed))sn · " +
              "\(result.stats.sheetCount) levha · fire \(result.stats.wastePercentText)bps")
        XCTAssertLessThan(elapsed, 2.0, "K-9 AC: 500 parça <2sn (docs/03 E1-S4c)")
    }
}

private extension PlanStats {
    var wastePercentText: String { String(wasteBps) }
}
