// docs/04 §2 — deterministik RNG; platform random() YASAK.
public struct PCG32: Sendable {
    private var state: UInt64
    private let inc: UInt64
    public init(seed: UInt64, sequence: UInt64 = 0xDA3E_39CB_94B9_5BDB) {
        state = 0; inc = (sequence << 1) | 1
        _ = next(); state &+= seed; _ = next()
    }
    public mutating func next() -> UInt32 {
        let old = state
        state = old &* 6_364_136_223_846_793_005 &+ inc
        let xorshifted = UInt32(truncatingIfNeeded: ((old >> 18) ^ old) >> 27)
        let rot = UInt32(truncatingIfNeeded: old >> 59)
        return (xorshifted >> rot) | (xorshifted << ((32 &- rot) & 31))
    }
}
