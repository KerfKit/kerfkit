# 06 — Mimari ve Platform Stratejisi

## 1. Karar: Swift-first, motor tek kaynak

**Motor = bağımsız saf-Swift SPM paketi (CutCore):** yalnız stdlib, platform API'siz, Int aritmetik.
- **iOS:** native SwiftUI (birincil platform).
- **Android (Kapı-2 sonrası):** Skip Fuse — Swift'i Android'de native derler, SwiftUI'ı Compose'a
  köprüler. Skip v1.7+ **tamamen ücretsiz ve açık kaynak** (Ocak 2026); resmî Swift SDK for
  Android üstüne oturur (swift.org, Ekim 2025 nightly → resmileşme yolunda; Swift Package
  Index'in >%25'i Android-uyumlu).
- **Web:** motor **Swift→WebAssembly** (SwiftWasm resmî SDK, Swift 6.2+; üretim kanıtı: Goodnotes
  2+ yıldır Wasm'da Swift çekirdek koşturuyor). UI TypeScript kalır — tam-uygulama Wasm'ı büyük
  olur (Goodnotes 12MB Brotli); biz yalnız motoru Wasm yaparız (Embedded Swift modu), lite
  hesaplayıcı + landing TS/HTML.

**Neden Rust/TS değil:** tek dil = tek zihinsel model; Fable 5 Swift'te güçlü; parite golden
vektörlerle mekanik. Rust ikinci dil + FFI bakımı; TS motoru mobilde köprüye mahkûm eder.
**Toolchain risk sigortası:** motor bağımlılıksız ~2-3K satır; en kötü senaryoda TS'e port,
golden vektörler sayesinde sınırlı ve doğrulanabilir iş.

## 2. Sıralama (yeniden değerlendirilmiş)

1. **v1.0 (Hafta 1-10):** iOS + web-landing/lite (E7 — lite hesaplayıcı Wasm motoruyla; hem
   cüzdan testi hem parite kanıtı hem lead-gen).
2. **v1.1 (launch+90g):** iOS derinleşir (offcut, maliyet, atölye v2, iCloud).
3. **v1.2 (Kapı-2 geçilince):** Android (Skip) + tam Web + Supabase senkron/lisans →
   "iOS+Android+Web üçlüsü tek üründe" liderlik hamlesi (02 matrisinde kimsede yok).

## 3. Repo yapısı (monorepo)

```
cutwise/
├─ CLAUDE.md                    # ajan anayasası (10 §3)
├─ docs/                        # BU PAKET (00-10) — spec ground truth
├─ Package.swift
├─ Sources/
│  ├─ CutCore/                  # motor: saf Swift, stdlib-only, Int aritmetik
│  ├─ CutModels/                # .cutproj Codable şemaları (05)
│  └─ CutCoreWasm/              # JS export sarmalayıcı (E7-S2)
├─ Tests/
│  ├─ CutCoreTests/             # birim + değişmez testleri
│  └─ GoldenTests/vectors/*.json
├─ apps/
│  ├─ ios/                      # SwiftUI app (Xcode projesi)
│  ├─ android/                  # Skip hedefi (v1.2'de aktifleşir)
│  └─ web/                      # landing + lite (TS + wasm; Astro/Vite)
└─ tools/                       # vektör üretici, benchmark, parite-CI scriptleri
```

## 4. Web kapsamı (v1)

- Landing (09 §1): founding ön-satış + e-posta listesi.
- Lite hesaplayıcı: tek levha, ≤20 parça, gerçek Wasm motor; PDF/paylaşım için e-posta ister
  (lead-gen). "Tam sürüm iOS'ta" köprüsü. SEO sayfaları (09 §3) aynı Astro sitede.

## 5. Ödeme mimarisi (08 ile birlikte okunur)

- **iOS:** StoreKit 2 — lifetime non-consumable + yıllık auto-renew + 72-saat non-renewing geçiş;
  StoreKitTest ile otomasyon. ABD harici-link durumu oynak (%0 şimdilik, mahkeme süreci) —
  ekonomi %0 varsayımına KURULMAZ; v1 IAP-yalnız.
- **Web: SATIŞ YOK (karar: Ahmet, Tem 2026 — Stripe kaldırıldı).** Ödeme yalnız mağaza içi:
  App Store (StoreKit 2) + Google Play Billing. Landing e-posta listesi toplar ve mağaza
  rozetlerine yönlendirir; founding fiyat mağaza-içi launch teklifi olarak uygulanır.
- **Android (v1.2):** Play Billing (30 Haz 2026 düzeni: %10 ilk $1M + %5 Play-billing ücreti;
  alternatif faturalama serbest ama MVP'de Play Billing yeter).
- **Lifetime'ın üç platformda dürüst yönetimi:** v1'de platform-başına satın alma (her mağaza
  kendi restore'u; sayfada açıkça yazılır). v2'de çok-platform lisans yeniden değerlendirilir:
  mağaza-içi alımlar isteğe bağlı e-postaya bağlanır (Supabase licenses) → "bir kez al, her
  yerde" ancak backend'le dürüst verilir; web satışı bu karar değişmedikçe YOK.

## 6. Analitik ve gizlilik

- TelemetryDeck veya benzeri gizlilik-öncelikli, anonim, opt-out; olaylar: activation funnel
  (install→ilk-optimizasyon), paywall görüntüleme→satın alma, crash. Kişisel veri yok, proje
  içeriği ASLA gönderilmez. App Store gizlilik etiketi: "Data Not Collected"a en yakın profil.

## 7. CI/CD

- GitHub Actions: her PR'da `swift test` (motor+modeller) + SwiftLint + golden vektör diff +
  (web değiştiyse) Wasm build + Node parite koşusu. main'e merge = TestFlight internal otomatik
  (fastlane). Sürümleme: motor semver'i uygulamadan bağımsız (engineVersion sonuçlara yazılır).

## Kaynaklar
skip.dev/docs/faq (ücretsiz/AK) · infoq.com/news/2026/01/swift-skip-open-sourced ·
swift.org/blog/nightly-swift-sdk-for-android · forums.swift.org Wasm SDK duyurusu ·
swift.org/documentation/articles/wasm-getting-started · swift.org Goodnotes vakası ·
android-developers.googleblog.com/2026/06 (Play %10 düzeni) · macrumors.com 2025/12/11
(Apple harici-link komisyon süreci) · GRDB (MIT) · TelemetryDeck
