# 08 — Monetizasyon ve Fiyatlandırma

## 1. Fiyat yapısı (rakip haritasından türetildi — 02 §5)

| Katman | Fiyat | İçerik | Gerekçe |
|---|---|---|---|
| **Ücretsiz** | $0 | **Sınırsız hesaplama** (sayaç YOK) · 2 kayıtlı proje · proje başına 20 parça · diyagram görüntüleme | Öğrenmeye tam izin (iOS klonunun "5 deneme" öfkesinin tersi); duvar doğal büyüme sınırında (dolap projesi 20 parçayı aşar) |
| **Lifetime (manşet)** | $99.99 (founding: $49) | Her şey, ömür boyu, o platformda | Alet kültürüyle uyum; CutList Plus Gold $249'un altında "pro ama tek ödeme"; pazarlamanın kendisi |
| **Yıllık** | $39.99 | Her şey | Birebir iOS rakibiyle eşit — pahalı başlamıyoruz |
| **Hafta sonu geçişi** | $4.99 / 72 saat | Her şey, non-renewing | Mevsimlik marangoz segmenti (CLO $4.90/3-gün ve CutPlan $9/2-gün ile talep kanıtlı); OTOMATİK YENİLENMEZ |

- Kilitlenen özellikler (paywall'a düşenler): 3+ proje, 21+ parça, PDF/CSV/cutproj export,
  atölye modu tam sürüm, (v1.1) offcut envanteri + maliyet + etiketler.
- ASLA kilitlenmeyenler: hesaplama sayısı, diyagram görüntüleme, birimler, kerf/damar/bant girişi.

## 2. Founding dönemi (GTM hafta −8 → launch+2 hafta)

- $49 lifetime, **300 koltuk, gerçek sayaçlı** (sahte kıtlık yok — AB Omnibus uyumu: $99.99
  "gelecekteki fiyat" olarak etiketlenir, "indirim" DENMEZ).
- Satış YALNIZ mağaza içi (karar: Ahmet, Tem 2026): founding $49, App Store launch teklifi
  (intro/offer code) + Play launch fiyatı olarak uygulanır; web e-posta listesi toplar,
  sayaç mağaza satış verisinden beslenir. İade: mağaza koşulları + 14 gün destek sözü.

## 3. Teknik uygulama

- StoreKit 2: `lifetime.unlock` (non-consumable) · `pro.yearly` (auto-renewable, 1 grup) ·
  `pass.weekend` (non-renewing, 72 saat cihaz-saatinden bağımsız sunucu-doğrulamalı bitiş —
  basit: satın alma zamanı + 72h, receipt'ten).
- Entitlement katmanı tek kaynak: `ProStatus = lifetime | yearly(expiry) | pass(expiry) | free`.
- RevenueCat KULLANILMIYOR v1'de (tek uygulama, StoreKit2 yeterli; bağımlılık azaltma) —
  v1.2 çok-platform lisansta yeniden değerlendirilir.
- StoreKitTest ile otomasyon: satın alma / restore / iade / geçiş-bitişi senaryoları CI'da.

## 4. Şeffaf fatura kontrol listesi (LAUNCH KAPISI — her sürümde işaretlenir)

- [ ] Fiyat, süre, yenileme koşulu paywall'da tam punto — dipnot oyunu yok
- [ ] Hafta sonu geçişi "otomatik yenilenmez" yazar; yıllıkta yenileme tarihi gösterilir
- [ ] Restore butonu paywall'da görünür ve çalışır (E2E test)
- [ ] İade politikası linki + destek e-postası paywall'dan 1 dokunuş
- [ ] Satın alma sonrası TÜM kilitler anında açılır (Android-CLO 1★ dersi; E2E test)
- [ ] Sahte geri sayım / sahte kıtlık / "bugüne özel" YOK (founding sayacı gerçek veriden)
- [ ] Fiyat deneyleri kullanıcı-içinde tutarlı (aynı kullanıcıya iki fiyat gösterilmez)

## 5. Çok-platform lisans (v1.2 — 06 §5 ile)

- Supabase `licenses`: e-posta ↔ platform kayıtları; mağaza-içi alımlar isteğe bağlı e-postaya
  bağlanır, mobil platformlar arası tanıma buradan (offline grace 30 gün). Web satışı YOK.
- Fiyat paritesi platformlarda aynı.

## 6. Gelir modeli bağlantısı (3. Dalga raporuyla tutarlılık)

Ay-12 hedef bandı: $1.2K kötü / $7K baz / $22K iyi (aylık, net). Founding 300×$49 ≈ $14.7K
brüt ön-nakit (build dönemini finanse eder). Karışım beklentisi: %60 lifetime, %25 yıllık,
%15 geçiş (geçiş→lifetime yükseltme akışı: ödenen geçiş tutarı ilk 30 gün lifetime'dan düşülür —
"kredi" iyi niyet jesti, yorumlarda anlatılır).
