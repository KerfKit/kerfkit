// FoundationEssentials: JSON için yeterli — tam Foundation, ICU verisiyle wasm'ı
// ~40MB şişiriyor. macOS'ta (Apple SDK) modül yok → Foundation'a düşer.
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import CutModels
import CutCore

// W-2 (E7-S2): JS köprüsü — docs/06 §1/4. Tampon protokolü:
//   JS: ptr = kk_input_alloc(len) → isteği yaz → n = kk_optimize(len)
//       n < 0 ise hata; değilse kk_output_ptr()'dan n bayt JSON oku.
// Yanıt zarfı: { ok, error?, result?, placementsHash? } — hash motorun kendi
// FNV-1a'sı (docs/04 §5), Node paritesi golden'la birebir aynı alanları karşılaştırır.

// Wasm tek iş parçacıklı — global tamponlar güvenli (nonisolated(unsafe) bu yüzden).
nonisolated(unsafe) private var inputBuffer: UnsafeMutableBufferPointer<UInt8>?
nonisolated(unsafe) private var outputBuffer: UnsafeMutableBufferPointer<UInt8>?

private struct Envelope: Encodable {
    var ok: Bool
    var error: String?
    var result: OptimizeResult?
    var placementsHash: String?
}

@_cdecl("kk_input_alloc")
public func kkInputAlloc(_ len: Int32) -> UnsafeMutablePointer<UInt8>? {
    inputBuffer?.deallocate()
    let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: Int(len))
    inputBuffer = buffer
    return buffer.baseAddress
}

@_cdecl("kk_output_ptr")
public func kkOutputPtr() -> UnsafeMutablePointer<UInt8>? {
    outputBuffer?.baseAddress
}

@_cdecl("kk_optimize")
public func kkOptimize(_ len: Int32) -> Int32 {
    guard let inputBuffer, let base = inputBuffer.baseAddress,
          len >= 0, Int(len) <= inputBuffer.count else { return -1 }
    let requestData = Data(bytes: base, count: Int(len))

    let envelope: Envelope
    do {
        let request = try JSONDecoder().decode(OptimizeRequest.self, from: requestData)
        let result = try optimize(request)
        envelope = Envelope(ok: true, error: nil, result: result,
                            placementsHash: placementsHash(result.placements))
    } catch {
        envelope = Envelope(ok: false, error: "\(error)", result: nil, placementsHash: nil)
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys] // deterministik çıktı (parite diff'i okunur kalsın)
    guard let payload = try? encoder.encode(envelope) else { return -2 }

    outputBuffer?.deallocate()
    let out = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: payload.count)
    _ = out.initialize(from: payload)
    outputBuffer = out
    return Int32(payload.count)
}

// Reactor modelinde (_initialize) üst-düzey kod çağrılmaz — main bilinçli boş.
