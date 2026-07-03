#if os(macOS)
import SkipTest

// Skip köprüsü: macOS'ta bu test, Kotlin'e çevrilen GoldenTests'i Gradle ile koşar —
// golden vektörler Android tarafında da bit-eşit geçmek zorunda (K-30 parite kanıtı).
final class XCSkipTests: XCTestCase, XCGradleHarness {
    public func testSkipModule() async throws {
        try await runGradleTests()
    }
}
#endif
