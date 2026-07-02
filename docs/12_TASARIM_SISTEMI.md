# 12 — Tasarım Sistemi (token'lar + bileşenler + diyagram dili)

> Tek kaynak: `tokens/tokens.json` (yanındaki dosya, DTCG 2025.10 formatı) → Style Dictionary v4
> ile `tokens.css` (web) + `ColorTokens.swift`/xcassets (iOS) üretilir. UI kodu YALNIZ semantic
> katmana dokunur. Build'de kontrast testi: eşik altı çift = build fail.

## 1. Renk — primitive'ler

| Token | Hex | Not |
|---|---|---|
| timber.950 | #141210 | En koyu zemin (atölye) |
| timber.900 | #1C1917 | Ana koyu yüzey (kontrast tabanı) |
| timber.800 | #292524 | Yükseltilmiş yüzey |
| timber.700 | #44403C | Sınır/ayraç |
| timber.200 | #E7E5E4 | Açık tema yüzey-2 |
| timber.100 | #F5F0E6 | Krem — koyu temada birincil metin (15.4:1) |
| timber.50 | #FAF8F5 | Açık tema zemini |
| amber.400 | #FBBF24 | Vurgu-parlak (10.5:1 koyuda) |
| **amber.500** | **#F59E0B** | **Ana vurgu (8.1:1 koyuda — AAA)** |
| amber.600 | #D97706 | Vurgu-basılı (5.5:1 — koyuda metin alt sınırı) |
| amber.700 | #B45309 | Yalnız büyük metin/çizgi koyuda (3.5:1); açık temada ana vurgu metni |
| walnut.600 | #8A5A2B | YALNIZ yüzey/dekor — koyuda metin YASAK (3.0:1) |
| oak.500 | #C9A227 | Diyagram malzeme paleti üyesi (7.2:1) |
| green.500 / red.500 / blue.500 | #34D399 / #F87171 / #60A5FA | Semantik başarı/hata/bilgi (koyu uyumlu) |

## 2. Renk — semantic (mod: koyu → açık)

| Semantic | Koyu (birincil) | Açık | Kullanım |
|---|---|---|---|
| bg.canvas | timber.950 | timber.50 | Ekran zemini |
| bg.surface | timber.900 | #FFFFFF | Kart/panel |
| bg.raised | timber.800 | timber.200 | Sekme/segment zemini |
| text.primary | timber.100 | timber.900 | Gövde |
| text.secondary | #A8A29E | #57534E | İkincil (4.6:1 koyuda) |
| accent | amber.500 | amber.700 | CTA, vurgu, seçim |
| accent.pressed | amber.600 | #92400E | Basılı |
| border | timber.700 | #D6D3D1 | 3:1 UI sınırı |
| success/danger/info | green/red/blue.500 | koyulaştırılmış eşdeğer | Durum |

Kural: koyu zeminde metin/ikon amber'ı **amber.600'den koyu olamaz**; walnut asla ön plan olmaz.

## 3. Tipografi

- Aile: **SF Pro** (iOS) / system-ui + Inter fallback (web). Display'de SF Pro Display Semibold.
- Ölçek (Dynamic Type'a bağlı, `relativeTo` ile): display 34 · title 28 · headline 22 ·
  body 17 · callout 15 · caption 13. **Ölçü rakamları: tabular lining** (monospacedDigit) —
  diyagram ve istatistiklerde hizalı.
- Atölye/Tezgâh modunda ölçü tipografisi ≥ 2× body (min 34pt), ağırlık Bold.

## 4. Boşluk, köşe, yükselti, hareket

- Boşluk: 4pt taban — 4/8/12/16/24/32/48 (space.100..700). Tüm padding'ler bu ritimde (QA grep'i).
- Köşe: 8 (kontrol) · 12 (kart) · 16 (sayfa üstü panel); tam-yuvarlak yalnız FAB/rozet.
- Yükselti: koyu temada gölge yerine **yüzey tonu + 1px sınır**; açık temada yumuşak gölge sm/md.
- Hareket: 150ms (mikro) / 250ms (panel) easeOut; optimizasyon sonucu **tek seferlik** yerleşme
  animasyonu (parçalar 250ms'de kayar — "plan kuruldu" hissi); Reduce Motion'da kapalı.

## 5. Kesim diyagramı görsel dili (ürünün kalbi — renk-bağımsız)

- **Parça:** malzeme-bazlı pastel dolgular üstünde HER ZAMAN etiket (ID + ölçü, tabular).
  Malzeme ayrımı = renk + **doku deseni** (CAD kesit-taraması pratiği: nokta / ince çizgi /
  çapraz) — renk körlüğünde desen tek başına yeter (WCAG 1.4.1).
- **Atık:** çapraz tarama (hatch) + `waste` etiketi — asla yalnız gri ton.
- **Kerf çizgileri:** 1px amber.700; kesim numaraları amber rozetlerde.
- **Damar yönü:** parça içinde ince yön-çizgisi deseni; kilitli parçada kilit ikonu.
- **Seçim:** renk + 2px amber kontur + baloncuk (üçlü sinyal).
- Koyu temada levha zemini timber.800; açık/print'te beyaz — PDF her zaman açık tema.

## 6. Bileşen envanteri (skill formatında kısa spec; detay mockup turunda)

**Button** — Variants: primary(amber dolu, timber.950 metin) / secondary(sınırlı) / ghost.
Sizes: md 44pt · lg 56pt (atölye 60pt+). States: default/pressed(accent.pressed)/disabled(%38)/
loading(spinner+metin kalır). A11y: rol=button, Dynamic Type'ta genişler, min 44pt hedef.

**Card(Plan özeti)** — bg.surface, 12 köşe; içerik: 3 büyük istatistik (tabular) + hedef segmenti.
States: default/stale(sarı üst şerit "Girdiler değişti — Yeniden hesapla")/error.

**Input(Ölçü)** — birim-akıllı; imperial modda kesir pad'i; hata: danger sınır + altta mesaj
(asla yalnız renk); klavye: decimal + özel kesir satırı.

**SegmentedControl(Hedef)** — levha/atık/kesim; değişim anında yeniden hesap tetikler (görünür durum).

**WorkshopCard(Atölye)** — dev tipografi (≥34pt ölçü), tam-genişlik "✓ Kesildi" (≥60pt),
ilerleme halkası; yüksek kontrast; ekran-uyanık göstergesi.

**PaywallCard** — 3 kutu; lifetime "manşet" rozeti; fiyat + koşul aynı punto (08 §4 kuralları);
Restore görünür.

**EmptyState** — illüstrasyon yerine diyagram-motifli minimal çizim + tek CTA ("Örnek projeyi dene").

## 7. Modlar

- **Koyu (varsayılan, marka):** yukarıdaki semantic koyu sütunu.
- **Açık:** türetilmiş; PDF/print her zaman açık.
- **Tezgâh Modu (tek dokunuş, atölye ekranında):** parlama gerçeği (Dobres 2017: aydınlıkta
  pozitif polarite üstün) → ultra-kontrast AÇIK tema + dev tipografi + eldiven hedefleri
  (birincil ≥56-60pt, hedef arası ≥8pt). Koyu marka kimliği korunur; Tezgâh Modu işlevsel istisna.

## 8. Erişilebilirlik kuralları (DoD'ye dahil)

Metin 4.5:1, büyük metin/UI 3:1 (build'de otomatik test) · dokunma ≥44pt (atölye birincil ≥56pt) ·
Dynamic Type XXL taşma testi · VoiceOver: diyagram özet cümlesi + parça listesi okunur ·
Reduce Motion · asla-yalnız-renk (desen/etiket zorunlu).
