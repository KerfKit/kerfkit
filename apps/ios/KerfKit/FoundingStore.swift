import Foundation
import Observation

// K-16 (E5-S3) — founding penceresi için TEK uzak bayrak (docs/08 §2). Fiyat A/B YOK.
// Varsayılan KAPALI: ağ yok / endpoint yok / bozuk JSON → kalıcı fiyat görünümü.
// Sayaç yalnız gerçek veriden (claimed/seats); veri yoksa sayaç hiç gösterilmez.
struct FoundingConfig: Equatable {
    var active = false
    var claimed: Int?
    var seats: Int?
    var futurePrice: String? // AB Omnibus: "gelecekteki fiyat" etiketi — "indirim" DENMEZ

    static let closed = FoundingConfig()

    var seatsLeft: Int? {
        guard let claimed, let seats else { return nil }
        return max(0, seats - claimed)
    }
}

extension FoundingConfig: Codable {
    private enum CodingKeys: String, CodingKey { case active, claimed, seats, futurePrice }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // "active" alanı olmayan eski stub (yalnız sayaç) → kapalı sayılır.
        active = try c.decodeIfPresent(Bool.self, forKey: .active) ?? false
        claimed = try c.decodeIfPresent(Int.self, forKey: .claimed)
        seats = try c.decodeIfPresent(Int.self, forKey: .seats)
        futurePrice = try c.decodeIfPresent(String.self, forKey: .futurePrice)
    }
}

@MainActor @Observable
final class FoundingStore {
    private(set) var config: FoundingConfig = .closed

    static let endpoint = URL(string: "https://kerfkit.app/founding.json")
    private static let cacheKey = "foundingConfigCache"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // Son bilinen durum: offline açılışta founding görünümü korunur.
        if let data = defaults.data(forKey: cacheKey) { apply(data) }
    }

    private var cacheKey: String { Self.cacheKey }

    func refresh() async {
        guard let endpoint = Self.endpoint,
              let (data, response) = try? await URLSession.shared.data(from: endpoint),
              (response as? HTTPURLResponse)?.statusCode == 200 else { return }
        apply(data, cache: true)
    }

    // Bozuk gövde mevcut durumu BOZMAZ (kapalıya da çekmez) — testle kanıtlı.
    @discardableResult
    func apply(_ data: Data, cache: Bool = false) -> Bool {
        guard let decoded = try? JSONDecoder().decode(FoundingConfig.self, from: data) else {
            return false
        }
        config = decoded
        if cache { defaults.set(data, forKey: cacheKey) }
        return true
    }
}
