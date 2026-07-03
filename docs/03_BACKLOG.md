# 03 — Özellik Backlog'u (Epik → Hikâye → Kabul Kriteri → Fable-5 Görevi)

> Kurallar: her görev **tek Fable-5 oturumunda bitecek, izole test edilebilir** bir dilimdir.
> Kabul kriterleri hibrit: dallanan davranışta Given/When/Then, basit doğrulamada checklist.
> Her hikâyede zorunlu minimum: 1 happy path + 2 edge case + 1 hata senaryosu.
> RICE: Reach/Impact 0-3, Confidence 0-1, Effort = oturum sayısı. Skor = R×I×C/E.

## Epik G-0: Proje kurulumu (Hafta 1)

| Görev | İçerik | DoD |
|---|---|---|
| G-0.1 | Monorepo iskeleti (06 §3'teki yapı) + SwiftLint + CI (GitHub Actions: test+lint) | `swift test` yeşil, CI badge |
| G-0.2 | CLAUDE.md (10 §3 şablonundan) + bu paketin repo'ya `docs/` olarak konması | Dosyalar commit'li |
| G-0.3 | İsim kontrolü: "CutWise" App Store/Play/ticari-marka/domain taraması; 3 yedek aday (SheetWise, KerfKit, BoardCut) | Karar notu docs/NAME.md |
| G-0.4 | Golden test altyapısı: `vectors/` klasörü + koşucu (JSON→motor→beklenen çıktı diff) | 2 örnek vektörle yeşil |

## Epik E1: Çekirdek Motor — 2D (Hafta 1-3) — spec: 04

### E1-S1: Parça yerleştirme (guillotine, kerf'siz basit hal)
- **AC-1 (happy):** Given 2440×1220 levha + [600×400 ×4] parça, When optimize edilir,
  Then 4 parça tek levhaya çakışmasız yerleşir ve guillotine-geçerlilik doğrulayıcısı geçer.
- **AC-2 (edge):** Parça levhadan büyükse → `PlacementError.partExceedsStock` (crash değil).
- **AC-3 (edge):** 0 parça → boş plan, 0 levha, hata yok.
- **AC-4 (hata):** Negatif/0 boyutlu parça → `ValidationError` doğrulama katmanında yakalanır.
- Görevler: E1-S1a serbest-dikdörtgen ağacı + yerleştirme (1 oturum) · E1-S1b guillotine
  doğrulayıcı + 5 golden vektör (1 oturum) · E1-S1c motor girdi sınırları — taşma guard'ı (04 §2).

### E1-S2: Kerf + trim
- **AC-1:** kerf=3mm iken iki komşu parça arasında tam 3mm boşluk; levha kenarında kerf düşülmez.
- **AC-2:** trim=10mm iken kullanılabilir alan (W−2·trim)×(H−2·trim).
- **AC-3 (edge):** kerf 0 ve 12mm uçları golden vektörlerle.
- Görev: 1 oturum + 4 vektör.

### E1-S3: Damar yönü (rotasyon kısıtı)
- **AC-1:** `rotation: fixed` parça 90° denenmez; `allowed` parça iki yönde denenir.
- **AC-2 (edge):** Yalnız döndürülünce sığan parça, fixed ise `doesNotFit` raporlanır (sessiz atlanmaz).
- Görev: 1 oturum + 3 vektör.

### E1-S4: Çoklu levha + çoklu malzeme + hedef fonksiyonu
- **AC-1:** Malzemeler ayrı havuzlarda optimize edilir (18mm huş parçası 12mm MDF'e yerleşmez).
- **AC-2:** Hedef leksikografik: (a) min levha→min atık→min kesim; (b) min atık; (c) min kesim —
  kullanıcı seçimine göre üç golden vektör üçlüsü farklı planlar döndürür.
- **AC-3 (edge):** Stok tükenirse yerleşmeyen parçalar `unplaced[]` listesinde nedenle döner.
- Görevler: E1-S4a çoklu-levha (1) · E1-S4b hedef portföyü — 6-12 heuristik koşusu + seçim (1) ·
  E1-S4c performans: 500 parça <2 sn ölçümü, Instruments raporu (1).

### E1-S5: Kenar bandı hesabı
- **AC-1:** Parça başına 0-4 kenar seçimi; toplam bant = Σ(seçili kenar uzunlukları)×(1+fire%);
  malzemeye göre gruplu döner.
- **AC-2 (edge):** fire %0 ve %20 uçları; bantlı parçada opsiyonel boyut büyütme doğru uygulanır.
- Görev: 1 oturum + 2 vektör.

## Epik E2: Çekirdek Motor — 1D (Hafta 3)
### E2-S1: Doğrusal kesim (FFD + küçük-n optimal)
- **AC-1:** [2400mm ×3 stok] + [800×5, 600×3] → FFD planı kerf'li doğru; atık raporu doğru.
- **AC-2:** n≤15 benzersiz parçada DP/branch-bound sonucu ≥FFD kalitesinde (golden karşılaştırma).
- **AC-3 (hata):** Parça > en uzun stok → `unplaced` + neden.
- Görevler: E2-S1a FFD (1) · E2-S1b optimal küçük-n + 4 vektör (1).

## Epik E3: Veri Katmanı (Hafta 3-4) — spec: 05
- E3-S1: Codable modeller + `.cutproj` JSON şeması + sürüm alanı + migrasyon iskeleti (1 oturum).
  AC: örnek dosya round-trip (decode→encode) bit-eşit; bilinmeyen alanlar korunur (forward-compat).
- E3-S2: Yerel kalıcılık (GRDB) + otomatik kayıt (her değişiklikte, 500ms debounce) (1 oturum).
  AC: uygulama öldürülüp açılınca son durum tam; 100 projede liste <100ms açılır.
- E3-S3: CSV import/export (1 oturum). AC: virgül/noktalı-virgül/tab ayraç otomatik algı;
  hatalı satırlar satır-numaralı raporla atlanır; export→import kayıpsız.

## Epik E4: iOS UI (Hafta 4-7) — spec: 07
- E4-S1: Proje listesi + oluşturma + stok kütüphanesi seçimi (1 oturum)
- E4-S2: Parça tablosu girişi — hızlı klavye akışı, kesir pad'i, birim değişimi (2 oturum)
  AC (kritik): 10 parçalık liste yalnız klavyeyle <60 sn'de girilebilir; kesir pad'i 1/2..63/64.
- E4-S3: Sonuç ekranı — diyagram (Canvas), pinch-zoom, levha sekmeleri, israf kartı (2 oturum)
  AC: 20 levhalı planda 60fps kaydırma; bayat-sonuç durumunda "Yeniden hesapla" bandı görünür.
- E4-S4: PDF export (diyagram+parça listesi+özet; A4/Letter) (1 oturum)
- E4-S5: Atölye modu lite — kesim listesi, tek dokunuş "kesildi", dev font, ekran-uyanık (1 oturum)
- E4-S6: Onboarding: 3 ekran + **örnek proje ile ilk optimizasyon** (aktivasyon garantisi) (1 oturum)
- E4-S7: Ayarlar: birim, varsayılan kerf/trim, tema (1 oturum)

## Epik E5: Monetizasyon (Hafta 7-8) — spec: 08
- E5-S1: StoreKit2: lifetime (non-consumable) + yıllık (auto-renew) + hafta-sonu geçişi
  (non-renewing, 72 saat) + restore (1 oturum)
  AC (Given/When/Then zorunlu): satın alma→kilit açılır→uygulama silinip kurulunca restore
  çalışır→iade edilirse kilit kapanır (StoreKitTest ile otomasyonlu).
- E5-S2: Paywall ekranı — şeffaf fatura kuralları (08 §4) + free-tier sınır kapıları (2 proje /
  20 parça) nazik üst-limit diyaloğu (1 oturum)
- E5-S3: Fiyat A/B altyapısı DEĞİL (v1'de tek fiyat — karmaşıklık freni); yalnız founding-fiyat
  remote flag (1 oturum)

## Epik E6: Kalite + Mağaza (Hafta 8-9)
- E6-S1: Golden CI matrisi (motor vektörleri macOS+iOS sim) + UI smoke testleri (1 oturum)
- E6-S2: Erişilebilirlik geçişi (Dynamic Type, VoiceOver, kontrast) (1 oturum)
- E6-S3: App Store varlıkları: 6 ekran görüntüsü (09 §2 hikâyesi), önizleme videosu, metadata (1 oturum)
- E6-S4: TestFlight beta (20-30 marangoz) + geri bildirim formu + crash izleme (1 oturum)

## Epik E7: Web-lite + Landing (Hafta 2 ve 6, paralel hafif iş) — spec: 06 §4, 09 §1
- E7-S1: Landing + founding duyurusu (e-posta listesi + mağaza rozetleri; ödeme yalnız mağaza içi; AB-uyumlu metin) (1 oturum)
- E7-S2: Wasm motor derlemesi + tek-levha lite hesaplayıcı (2 oturum)
  AC: aynı golden vektör tarayıcıda bit-eşit sonuç verir (parite kanıtı).
- E7-S3: SEO sayfaları ilk 5 (09 §3 listesinden) (1 oturum)
- E7-S4: Web→mobil huni: lite kapıları (3. hesapta banner; PDF/kaydet/çok-levha → mağaza
  modalı + QR) + rehberlerde "App'te aç" şeridi (docs/18 §6) (1 oturum)
- E7-S5: Compare sayfaları: cutlist-optimizer · cutplan · opticutter — dürüst tablo
  (02 §3 kuralı; en yüksek niyetli SEO trafiği) (1 oturum)

## Epik E8: Yerelleştirme + Global ASO (v1.0 T1 → v1.1 T2) — spec: 18 (karar: Ahmet, 3 Tem 2026)
- E8-S1 (L-1): i18n altyapısı — iOS String Catalog; **taban dil TR→EN çevrilir**, TR locale
  olur; sayı/ölçü Locale'den; imperial otomatiği ABD locale'inde (kesir pad'i E4-S2 ön koşul) (2 oturum)
  AC: hardcoded kullanıcı-metni kalmaz (bekçi test); TR+EN'de tüm snapshot'lar yeşil.
- E8-S2 (L-2): T1 UI çevirileri: DE FR ES IT (anadil gözden geçirme işaretiyle) (1 oturum)
- E8-S3 (L-3): Çok dilli SEO: Astro /{lang}/ + hreflang + dil başına anahtar kelime araştırması
  + ilk 3 rehberin T1 çevirileri; `reviewed: true` CI bekçisi (2 oturum)
- E8-S4 (L-4): Çok-locale ASO: T1 metadata (yerel jenerik terimli başlıklar) + fastlane
  snapshot çok-locale (K-19 ile birleşir) (1 oturum)
- E8-S5 (L-5): T2 dilleri: PT-BR PL NL RU UK CS — UI+SEO+ASO (v1.1) (2 oturum)
- E8-S6 (L-6): RTL hazırlık + T3 (v1.2 — ayrı taahhüt, 18 §5)

## Epik E9: Android (Skip UI; v1.1'e öne çekildi — docs/18 §8) — spec: 06, 18
- E9-S1 (K-31): Skip app iskeleti: paket app.kerfkit, motor bağlama (K-30 paritesi hazır ✓),
  M-1/M-2/M-4 ekranları (2 oturum)
- E9-S2: M-5 Atölye + M-6 onboarding + M-8 ayarlar Android paritesi (2 oturum)
- E9-S3: Play Store: T1 metadata + görseller + Play Billing (2 oturum)
- E9-S4: DXF export (CNC kitlesi; v1.2→v1.1 öne çekildi — docs/18 §7) (1 oturum)

## v1.1+ (launch sonrası — RICE sıralı, launch verisiyle yeniden puanlanır)

| Özellik | R | I | C | E | Skor | Not |
|---|---|---|---|---|---|---|
| Offcut envanteri | 3 | 3 | 0.8 | 3 | 2.4 | Yorum talebi güçlü; veri modeli hazır (05) |
| Board-foot + maliyet + alışveriş listesi | 3 | 2 | 0.8 | 3 | 1.6 | CutList Plus'tan kaçanlar için |
| Atölye modu v2 | 2 | 3 | 0.7 | 3 | 1.4 | Farklılaştırıcı; lite'ın verisiyle |
| Etiket baskısı (QR/Avery) | 2 | 2 | 0.8 | 2 | 1.6 | Yarı-pro segment |
| iCloud senkron | 2 | 2 | 0.9 | 2 | 1.8 | iOS-içi çoklu cihaz |
| Siper-ayarı minimizasyonu | 1 | 2 | 0.6 | 3 | 0.4 | FineWoodworking talebi; niş |
| DXF + OpenCutList import | 1 | 2 | 0.7 | 2 | 0.7 | Pro köprüsü |
| Foto→parça listesi (LLM-OCR) | 2 | 3 | 0.5 | 3 | 1.0 | Wow; maliyet dikkat (bulut) |
| Android (Skip) | 3 | 2 | 0.7 | 5 | 0.84 | Kapı-2 geçilince |
| Web tam + Supabase lisans | 2 | 2 | 0.7 | 5 | 0.56 | Üçlü-platform liderlik hamlesi |
