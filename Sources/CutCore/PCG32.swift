// docs/04 §2 — deterministik RNG; platform random() YASAK.
// Kotlin/Skip uyumu (K-30): sabitler 32-bit yarımlardan kurulur, bileşik atama yok,
// truncatingIfNeeded yerine maske — davranış bit-eşit (PCG32Tests bekçi).
public struct PCG32: Sendable {
    private var state: UInt64
    private let inc: UInt64
    private static let defaultSequence: UInt64 = (UInt64(0xDA3E_39CB) << 32) | UInt64(0x94B9_5BDB)
    private static let multiplier: UInt64 = (UInt64(0x5851_F42D) << 32) | UInt64(0x4C95_7F2D)

    public init(seed: UInt64) {
        self.init(seed: seed, sequence: PCG32.defaultSequence)
    }
    public init(seed: UInt64, sequence: UInt64) {
        state = UInt64(0)
        inc = (sequence << 1) | UInt64(1)
        _ = next()
        state = state &+ seed
        _ = next()
    }
    public mutating func next() -> UInt32 {
        let old = state
        state = (old &* PCG32.multiplier) &+ inc
        let shifted = ((old >> 18) ^ old) >> 27
        let xorshifted = UInt32(shifted & UInt64(0xFFFF_FFFF))
        let rot = Int(old >> 59) // 0..31
        let inv = (32 - rot) & 31
        return (xorshifted >> rot) | (xorshifted << inv)
    }
}
