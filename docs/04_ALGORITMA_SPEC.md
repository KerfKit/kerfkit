# 04 — Algoritma Spesifikasyonu (CutCore motoru)

> Bu dosya motor oturumlarında Fable 5'e TAMAMEN verilir. Motor: saf Swift, yalnız stdlib,
> platform API'siz, kayan nokta YOK.

## 1. Problem tanımı

- **2D:** Dikdörtgen parçaları, dikdörtgen stok levhalara, **guillotine kısıtıyla** (her kesim
  kenardan kenara düz geçer — panel testere gerçeği) yerleştir. NP-zor → heuristik portföy.
- **1D:** Doğrusal parçaları (çıta/pervaz/boru) stok boylara yerleştir (cutting stock).

## 2. Birimler ve determinizm (TAVİZSİZ)

- İç birim: `Int64`, 1 birim = 0.01mm. İnç girişi 1/64″ çözünürlükte tam sayıya çevrilir
  (1″ = 2540 birim; 1/64″ = 39.6875 → **1/64″ tabanlı ayrı gösterim katmanı**: iç değer
  imperial projelerde 1 birim = 1/6400″ olacak şekilde proje-birim-modu ile saklanır;
  karışık birim tek projede YASAK — doğrulama hatası).
- Atık yüzdesi çıktısı "baz puan" (Int, 1/100 %) olarak raporlanır.
- **Motor sınırları (taşma güvenliği):** her boyut (parça/stok w,h) ≤ 10⁸ birim (metrik ~1 km,
  imperial ~397 m); toplam stok alanı Σ(w·h·qty) ≤ 5×10¹⁴ birim². Gerekçe: wasteBps = alan×10⁴
  aritmetiğinin Int64 tavanı 9,22×10¹⁴ birim²; bu iki sınır motordaki tüm ara çarpımları Int64
  içinde tutar. Aşan girdi doğrulama hatasıdır (dimensionTooLarge / totalStockAreaTooLarge).
- RNG: kendi PCG32 implementasyonu, seed proje dosyasında; platform `random()` YASAK.
- Sıralamalar: kararlı + deterministik tie-break (alan → uzun kenar → parça ID).
- Hedef: **aynı girdi JSON → her platformda (iOS/Android/Wasm) bit-eşit çıktı hash'i.**

## 3. 2D motor — adımlar

Referans: Jylänki, "A Practical Approach to Two-Dimensional Rectangle Bin Packing"
(kod: github.com/juj/RectangleBinPack — **Public Domain**, port serbest). Kesim-odaklı emsal:
github.com/jasonrhansen/cut-optimizer-2d (MIT). GPL kaynaklardan (OpenCutList, opcut) KOD ALINMAZ,
yalnız davranış referansı.

```
OPTIMIZE(parts, stocks, config):
1. Doğrula: boyutlar >0 ve ≤ 10^8 birim; toplam stok alanı ≤ 5×10^14 birim² (§2 motor
   sınırları); parça ≤ (en büyük stok − 2·trim); birim modu tutarlı.
2. Malzemeye göre grupla (18mm-birch ayrı havuz, 12mm-mdf ayrı).
3. Her malzeme havuzu için heuristik PORTFÖYÜ koştur (6-12 kombinasyon):
   sıralama ∈ {alan↓, uzunKenar↓, çevre↓} × bölme ∈ {SAS kısa-eksen, min-artık-alan}
   × ilkKesimYönü ∈ {yatay, dikey}
4. Tek koşu:
   a. Levha aç (trim uygulanmış kullanılabilir alan; offcut'lar stok sırasında ÖNE alınabilir - config).
   b. Sıradaki parça için tüm açık levhalardaki serbest dikdörtgenlerde aday konum skorla:
      Best Area Fit (min artık alan), eşitlikte Best Short Side Fit, sonra ID.
      rotation==allowed ise 90° varyantı da adaydır (grain-fixed ise ASLA).
   c. Yerleştir; serbest dikdörtgeni KESİM AĞACINA göre ikiye böl (guillotine korunur):
      çocuk boyutlarından kerf düşülür (levha kenarında düşülmez).
   d. Hiçbir levhaya sığmazsa yeni levha; stok bittiyse unplaced[] + neden.
5. Koşular arasından hedefe göre seç (leksikografik):
   objective=sheets: (levha, atıkBps, kesimSayısı) · =waste: (atıkBps, levha, kesim) ·
   =cuts: (kesim, levha, atıkBps)
6. Çıktı: placements[], cutTree (kesim sırası numaralı), stats, offcuts[] (min-boyut üstü
   serbest dikdörtgenler), unplaced[].
```

- **Kesim sayısı** = kesim ağacı iç-düğüm sayısı. **Kesim sırası** = ağacın BFS gezintisi
  (atölye gerçeği: önce büyük rip'ler).
- **Opsiyonel iyileştirme turu (v1.1):** sıralama permütasyonu üstünde simulated annealing,
  PCG32 sabit seed, arka planda iptal edilebilir; sonuç yalnız daha iyiyse benimsenir.

## 4. 1D motor

- FFD (azalan sırala, ilk sığan stoğa koy, kerf düş). Garanti: FFD ≤ 11/9·OPT + 6/9 (Dósa 2007).
- Benzersiz parça ≤15 ise: dальше branch-and-bound tam çözüm (zaman sınırı 500ms, aşarsa FFD kal).
- Aynı çıktı yapısı: placements(stok başına segment listesi), stats, offcuts, unplaced.

## 5. Golden test stratejisi (paritenin anayasası)

- `vectors/NNN_isim.json`:
  `{unitMode, kerf, trim, objective, seed, stocks[], parts[], expected:{sheetCount, wasteBps, cutCount, placementsHash}}`
- `placementsHash` = FNV-1a 64-bit; (partId, stokIndex, x, y, w, h, rotated) beşlilerinin
  sıralı serileştirmesi üzerinden.
- **Değişmez doğrulayıcı** her vektörde ayrıca koşar: (1) çakışma yok, (2) sınır içi,
  (3) guillotine-geçerli (yerleşimden kesim ağacı yeniden inşa edilebilir), (4) kerf mesafeleri doğru.
- Minimum vektör seti (v1): 25 adet — basit(5), kerf uçları(4), grain(3), çoklu-levha/malzeme(4),
  hedef-fonksiyon üçlüsü(3), 1D(4), performans-500-parça(1, yalnız süre ölçer), regresyonlar(+).
- CI: vektörler macOS test + iOS simülatör + (E7-S2 sonrası) Wasm/Node koşusunda diff'lenir.

## 6. Performans bütçesi

- 500 parça, 6-12 koşu portföyü: **<2 sn** (iPhone 12 baz; hedef <1 sn iPhone 15+).
  Dayanak: Jylänki C++ implementasyonu binlerce dikdörtgeni ms'lerde paketler; Swift native
  benzer sınıfta. Ölçüm: E1-S4c görevi, Instruments + XCTest measure bloğu, CI'da eşik.
- Bellek: <50MB peak (serbest-dikdörtgen ağaçları levha başına sınırlı).

## 7. API yüzeyi (CutCore public)

```swift
public struct OptimizeRequest: Codable { unitMode, kerf, trim, objective, seed, stocks, parts, config }
public struct OptimizeResult: Codable { placements, cutSequence, stats, offcuts, unplaced, engineVersion }
public func optimize(_ req: OptimizeRequest) throws -> OptimizeResult   // saf, yan-etkisiz
public func validate(_ req: OptimizeRequest) -> [ValidationIssue]        // UI ön-doğrulama
public func verifyInvariants(_ res: OptimizeResult, req: OptimizeRequest) -> [InvariantViolation]
```

- `engineVersion` her sonuçta yazılır; motor değişince golden vektörlerde beklenen hash
  güncellemesi BİLİNÇLİ commit ister (yanlışlıkla davranış değişimi CI'da patlar).

## 8. Fable-5 oturum talimatları (motor işleri için)

1. Önce testi yaz (vektör + doğrulayıcı), sonra implementasyon; kırmızı→yeşil göster.
2. Kayan nokta gördüğün an dur ve reddet (kendi kodunda bile).
3. Heuristik "daha iyi sonuç" iddiası = önce vektörle kanıt, sonra merge.
4. Her motor PR'ında: `swift test` + değişmez doğrulayıcı + performans eşiği çıktısını yapıştır.

## Kaynaklar
juj/RectangleBinPack (Public Domain) · Jylänki PDF · jasonrhansen/cut-optimizer-2d ve
cut-optimizer-1d (MIT) · soimy/maxrects-packer (MIT, web parite karşılaştırması) ·
Dósa 2007 (FFD sınırı, Springer) · OpenCutList (GPL — yalnız davranış referansı) ·
swift.org/blog/bringing-goodnotes-to-web-with-swift (Wasm üretim kanıtı)
