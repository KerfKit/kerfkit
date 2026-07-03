# Kerf — Ajan Anayasası

## Komutlar
- Test: `swift test` (motor+model+golden) — Linux'ta Swift yoksa Mac'te koş
- Token üretimi: `node tools/gen-tokens.mjs` (tokens.json → tokens.css + DesignTokens.swift)
- Vektör gömme: `node tools/gen-vectors-swift.mjs` (vectors/*.json → VectorData.swift; bekçi test senkron zorlar)
- Golden vektörler: Tests/CutCoreTests/vectors/*.json (pending:true olanlar atlanır)

## Proje yapısı
- Sources/CutCore = motor (SAF Swift, stdlib-only, Int aritmetik — Double YASAK)
- Sources/CutModels = OptimizeRequest/Result + .cutproj şemaları (docs/05)
- docs/ = spec (ground truth) · apps/ios = SwiftUI (hafta 4+) · apps/web = landing+lite

## Stil
- Swift 6, strict concurrency; erken-dönüş; kuvvet-unwrap yasak; struct varsayılan.
- Örnek: `public func optimize(_ req: OptimizeRequest) throws -> OptimizeResult` — saf, yan-etkisiz.

## Git
- Dal: `feat/E1-S2-kerf-trim` biçimi; commit görev ID ile başlar; main'e doğrudan push yasak.

## Sınırlar
- ✅ Her zaman: test-önce; golden vektör güncellemesi ayrı commit + gerekçe; spec bölümüne atıf.
- ⚠️ Önce sor: yeni bağımlılık; şema değişikliği (docs/05); public API değişimi; fiyat/paywall metni.
- 🚫 Asla: motorda Double/platform-RNG/Foundation-bağımlılığı; SwiftData; hesaplama sayacı;
  reklam SDK'sı; secret commit; docs/ ile çelişen kod ("önce spec'i güncelle" de).

## Tanım-of-Done
Kabul kriterleri testle eşlendi ve yeşil · lint temiz · docs güncel · diff tek cümlede
anlatılabiliyor · non-goal dışına dosya değişmedi.
