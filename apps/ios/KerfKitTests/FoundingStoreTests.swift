import XCTest
@testable import KerfKit

// K-16 kabulleri: bayrak varsayılan kapalı; geçerli config uygulanır; bozuk gövde
// durumu bozmaz; önbellek yeni açılışta okunur; eski stub (active'siz) kapalı sayılır.
@MainActor
final class FoundingStoreTests: XCTestCase {

    private var suite: UserDefaults!

    override func setUp() {
        super.setUp()
        suite = UserDefaults(suiteName: "founding-tests")
        suite.removePersistentDomain(forName: "founding-tests")
    }

    func testDefaultClosed() {
        let store = FoundingStore(defaults: suite)
        XCTAssertEqual(store.config, .closed)
        XCTAssertFalse(store.config.active)
        XCTAssertNil(store.config.seatsLeft)
    }

    func testApplyValidConfig() {
        let store = FoundingStore(defaults: suite)
        let json = #"{ "active": true, "claimed": 120, "seats": 300, "futurePrice": "$99.99" }"#
        XCTAssertTrue(store.apply(Data(json.utf8)))
        XCTAssertTrue(store.config.active)
        XCTAssertEqual(store.config.seatsLeft, 180)
        XCTAssertEqual(store.config.futurePrice, "$99.99")
    }

    func testLegacyStubWithoutActiveIsClosed() {
        // Yayındaki mevcut stub: { "claimed": 0, "seats": 300 } — sayaç var, bayrak yok.
        let store = FoundingStore(defaults: suite)
        XCTAssertTrue(store.apply(Data(#"{ "claimed": 0, "seats": 300 }"#.utf8)))
        XCTAssertFalse(store.config.active)
        XCTAssertEqual(store.config.seatsLeft, 300)
    }

    func testMalformedBodyKeepsCurrentState() {
        let store = FoundingStore(defaults: suite)
        XCTAssertTrue(store.apply(Data(#"{ "active": true, "seats": 300, "claimed": 10 }"#.utf8)))
        XCTAssertFalse(store.apply(Data("<html>bakım sayfası</html>".utf8)))
        XCTAssertTrue(store.config.active, "Bozuk gövde son geçerli durumu silmemeli")
        XCTAssertEqual(store.config.seatsLeft, 290)
    }

    func testCacheRoundTrip() {
        let first = FoundingStore(defaults: suite)
        first.apply(Data(#"{ "active": true, "claimed": 42, "seats": 300 }"#.utf8), cache: true)

        let second = FoundingStore(defaults: suite) // yeni açılış — önbellekten okur
        XCTAssertTrue(second.config.active)
        XCTAssertEqual(second.config.seatsLeft, 258)
    }

    func testSeatsLeftNeverNegative() {
        let store = FoundingStore(defaults: suite)
        store.apply(Data(#"{ "active": true, "claimed": 310, "seats": 300 }"#.utf8))
        XCTAssertEqual(store.config.seatsLeft, 0)
    }
}
