import XCTest
@testable import CutCore

final class PCG32Tests: XCTestCase {
    func testDeterminism_sameSeedSameSequence() {
        var a = PCG32(seed: 42), b = PCG32(seed: 42)
        for _ in 0..<100 { XCTAssertEqual(a.next(), b.next()) }
    }
    func testDifferentSeedsDiverge() {
        var a = PCG32(seed: 1), b = PCG32(seed: 2)
        let av = (0..<8).map { _ in a.next() }, bv = (0..<8).map { _ in b.next() }
        XCTAssertNotEqual(av, bv)
    }
}
