# 18 — Yerelleştirme, Çok-Dilli SEO/ASO ve Global Huni

> **Karar (Ahmet, 3 Tem 2026):** kerfkit dünya dillerinde yayınlanır. Hedef: kesim/cut-list
> aramalarında hedef dillerde Google'da (SEO) ve App Store/Play'de (ASO) ilk sıra.
> Android öne çekilir (v1.2 → v1.1 bandı). Web lite belli eşikten sonra mobil indirmeye
> yönlendirir. Tetikleyen istihbarat: CutPlan.ai 22 hreflang locale + içerik makinesi +
> compare-sayfası SEO'suyla web'de hızla yer kapatıyor; ama native uygulaması YOK — bizim
> ayrışmamız native + tam offline + Atölye Modu + tek-seferlik fiyat.

## 1. Dil katmanları (kanıta dayalı sıralama)

Pazar seçimi ölçütü: ahşap/DIY pazarı büyüklüğü + mağaza dil kapsaması + çeviri maliyeti.

| Katman | Diller | Zaman | Gerekçe |
|---|---|---|---|
| **T1 (launch)** | EN (taban), DE, FR, ES, IT, TR | v1.0 | DE Avrupa'nın en büyük DIY pazarı; ES küresel erişim; TR ev sahası + zayıf rekabet |
| **T2 (+90 gün)** | PT-BR, PL, NL, RU, UK, CS | v1.1 | PL/CS mobilya üretim kuşağı; PT-BR dev hobi pazarı |
| **T3 (yıl 1)** | JA, ZH-Hans, AR*, SV, DA, NO, FI, HU, RO, KO | v1.2 | *AR = RTL geçişi ayrı iş kalemi |

Referans: CutPlan 22 locale (ar bg de en es fa fr he hr hu it ja ka kk nl pl pt ru tr uk zh).
Hedefimiz launch'ta 6, 90 günde 12, yıl 1'de 20+ — ama **her locale'de tam kalite**
(yarım çeviri yayınlanmaz; kural §5).

## 2. Uygulama içi i18n mimarisi

- **iOS:** String Catalog (`Localizable.xcstrings`). **Mevcut UI Türkçe hardcoded — L-1'de
  taban dil EN'e çevrilir**, TR ilk locale olur (App Store global başvurusu için ön şart).
  Biçimlendirme daima `Locale` üzerinden: sayı, tarih, ölçü.
- **Android (Skip):** Skip, String Catalog'u Android `strings.xml`'e çevirir — tek kaynak,
  iki platform (Skip resmî desteği; K-31'de doğrulanır, sürpriz halinde docs/10 risk tablosu).
- **Web (Astro):** yol tabanlı locale: `/{lang}/...`; `hreflang` + `x-default=en`;
  UI stringleri JSON sözlük; rehber içerikleri content collection'da `guides/{lang}/` ağacı.
- **Ölçü otomatiği:** `Locale.measurementSystem == .us` → imperial varsayılan (kesir pad'i
  E4-S2b ön koşul), aksi metrik. PDF kâğıdı zaten bölgeye göre (K-13 ✓).
- **Motor etkilenmez:** motor locale bilmez (Int Units); tüm yerelleştirme sunum katmanında.

## 3. Çok-dilli SEO (web)

- **URL şeması:** `kerfkit.app/{lang}/guides/...`; EN köke de yansır (`/guides/...` → 301 →
  `/en/guides/...` YOK — kök EN kalır, `x-default` kök; diğer diller `/de/`, `/fr/`...
- **Anahtar kelime yerelleştirme = yeniden araştırma, birebir çeviri DEĞİL.** Örnek çekirdek
  terimler (L-3'te her dil için doğrulanır):
  - DE: *Zuschnittoptimierung, Plattenzuschnitt Rechner, Schnittplan*
  - FR: *optimiseur de découpe, plan de débit, calepinage panneau*
  - ES: *optimizador de cortes, despiece de tableros*
  - IT: *ottimizzatore di taglio, piano di taglio pannelli*
  - TR: *kesim planı programı, plaka kesim optimizasyonu, ebatlama programı*
- **Sayfa seti dil başına:** docs/09 §3 ilk-10 listesinin yerel karşılıkları + `compare/`
  sayfaları (aşağıda). Her sayfada tek CTA → `/{lang}/lite` → mağaza rozetleri (§6 huni).
- **Compare sayfaları (İLK İŞ — en yüksek niyetli trafik):** `/compare/cutlist-optimizer`,
  `/compare/cutplan`, `/compare/opticutter` — docs/02 §3 dürüst-tablo kuralı; her hücre
  kanıtlı; kendi zaaflarımız da yazılır (bulut senkron yok v1'de). CutPlan aynı oyunu bize
  karşı oynamadan alan kapatılır.
- **Çeviri süreci:** taslak Fable 5; yayın öncesi anadil kontrol işareti zorunlu
  (`reviewed: true` frontmatter'ı olmadan build o sayfayı yayınlamaz). İlk turda TR'yi Ahmet
  doğrular; diğer diller için topluluk/freelance doğrulama L-3'te planlanır.

## 4. Çok-locale ASO

- **App Store:** başlık/altbaşlık/keywords/açıklama/ekran görüntüsü metinleri locale başına
  (T1 6 locale launch'ta). Başlık kalıbı: `kerfkit: {yerel jenerik terim}` — jenerik terim
  yereldir (örn. DE: "kerfkit: Zuschnitt Optimierer").
- **Play (K-31 sonrası):** kısa+uzun açıklama locale başına; Play'in uzun-açıklama keyword
  ağırlığı yüksek — rehber metinlerinden beslenir.
- **Ekran görüntüleri:** fastlane snapshot çok-locale koşar (K-19 revize); başlık şeritleri
  string catalog'dan.
- **docs/09 §2'deki EN metadata planı (P-3) → P-3g olarak genişler:** EN + T1 dilleri.
- Yorum isteği metni ve destek yanıt şablonları da locale başına (destek: EN+TR canlı,
  diğerleri şablon + çeviri).

## 5. Kalite kuralları (yarım global = kötü global)

1. Bir locale ya TAM olur (UI + mağaza metadata + en az 3 SEO sayfası + lite) ya da yayınlanmaz.
2. `reviewed: true` olmayan çeviri build'e girmez (CI bekçisi L-3'te).
3. Ekran görüntüsü metinleri String Catalog'dan gelir — görselde hardcoded metin yasak.
4. RTL (AR/HE/FA) ayrı iş kalemidir; T3 öncesi taahhüt verilmez.
5. Desteklenmeyen dilde gelen mağaza yorumuna 48s içinde o dilde şablon yanıt.

## 6. Web → mobil huni (Ahmet kararı: web belli aşamadan sonra mobile yönlendirir)

Lite'ın rolü: parite kanıtı + lead-gen + mağaza yönlendirme. Kapılar:

| Aşama | Web lite | Kapı |
|---|---|---|
| Giriş | Tek levha, ≤20 parça, canlı diyagram — sürtünmesiz | — |
| 3. hesaplama | Devam eder | Nazik banner: "Sınırsız + offline: iOS/Android" + rozetler |
| PDF / kaydet / çok-levha / >20 parça | ÇALIŞMAZ | Modal: mağaza rozetleri + QR (masaüstünde) + e-posta köprüsü |
| Rehber CTA'ları | /{lang}/lite | Lite üstünde kalıcı "App'te aç" şeridi |

Kural: web'de İŞLEVİ sakatlamayız (hesap sınırsız kalır — docs/02 "sayaç yok" ilkesi webde de
itibar meselesi); yalnız *taşıma/kalıcılık/derinlik* mobile aittir. Mağaza rozetleri locale'e
göre doğru mağaza sayfasına gider.

## 7. Rakip özellik açıkları → backlog kararları (CutPlan teardown, 3 Tem 2026)

| CutPlan'da var | Bizde durum | Karar |
|---|---|---|
| 22 dil | Yok | **E8 epiği (bu doküman) — launch T1** |
| Offcut envanteri | v1.1 planlı (docs/05 hazır) | v1.1'de kalır ✓ |
| DXF export (Pro) | v1.2 planlıydı | **v1.1'e çekilir** (E-DXF; CNC kitlesi PL/CS/DE'de güçlü — dil stratejisiyle sinerjik) |
| Adım-adım kesim talimatı (statik, Pro) | Atölye Modu (interaktif) ✓ | Bizde ÜSTÜN — compare sayfasında vurgulanır; matris "K" düzeltmesi |
| Bulut senkron | v1.2 (bilinçli local-first) | v1.2'de kalır; "verin cihazında" gizlilik açısı pazarlanır |
| Malzeme kütüphanesi (custom) | M-3 çipler kısmi | v1.1'e madde (E-MAT) |
| Ücretsiz 30 hesap/ay | Lite sınırsız hesap | Bizim model üstün — huni §6 |

## 8. Sıralama etkisi (docs/10 revizyonu — Ahmet onayı 3 Tem)

- **v1.0 (değişmedi + eklendi):** iOS + web-lite + **L-1 i18n altyapısı + T1 dilleri +
  compare sayfaları**. Launch 6 dilde yapılır.
- **v1.1 (öne çekilenler):** **Android (Skip UI, K-31)** — "iOS+Android+Web üçlüsü" kozunu
  CutPlan native'e inmeden oynamak için; + DXF + offcut + maliyet + T2 dilleri.
- **v1.2:** bulut senkron/lisans + T3 + RTL.
- Kapı-2 ölçütleri (01 §8) geçerli kalır; Android öne çekilse de motor paritesi hazır
  olduğundan (K-30 ✓) ana maliyet UI'dır.

## Kaynaklar
cutplan.ai (en/features, en/blog/* — 3 Tem 2026 canlı inceleme; hreflang seti curl ile
doğrulandı) · cutplan.ai/en/blog/cut-list-optimizer-app-guide.html (PWA savunusu, native yok
itirafı) · docs/02 rakip matrisi (2 Tem verisi) · Apple App Store locale listesi · Skip
yerelleştirme dokümantasyonu (K-31'de doğrulanacak).
