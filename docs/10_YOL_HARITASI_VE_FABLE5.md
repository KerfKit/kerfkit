# 10 — 12 Haftalık Yol Haritası + Fable 5 Çalışma Rehberi

## 1. Hafta hafta plan (Tem-Eyl 2026; kural: aynı hafta 1 inşa odağı + 1 hafif GTM işi)

| Hafta | İnşa (Fable 5 oturumları) | GTM (paralel hafif iş) |
|---|---|---|
| 1 | G-0.1..0.4 kurulum + CLAUDE.md + golden altyapı; **motor prototip riski erit:** E1-S1a | İsim kararı (G-0.3); domain + sosyal hesaplar |
| 2 | E1-S1b, E1-S2 (kerf/trim) | E7-S1 landing + founding ön-satış CANLI (H−8) |
| 3 | E1-S3 (grain), E1-S4a-b (çoklu levha + hedefler) | Forum değer-postları başlar; modmail izinleri |
| 4 | E1-S4c perf + E1-S5 (bant) + E2-S1a-b (1D) → **MOTOR TAMAM** | Landing verisi ilk okuma (≥%1.5-2 niyet?) |
| 5 | E3-S1..S3 veri katmanı + CSV | TestFlight gönüllü toplama başlar (H−6) |
| 6 | E4-S1, E4-S2 (parça girişi — kritik ekran) | E7-S2 Wasm lite hesaplayıcı CANLI (parite kanıtı + lead-gen) |
| 7 | E4-S3 (sonuç/diyagram), E4-S4 (PDF) | YouTube pitch dalgası-1 (5 kanal) |
| 8 | E4-S5 (atölye lite), E4-S6 (onboarding), E4-S7 | E7-S3 SEO ilk 5 sayfa |
| 9 | E5-S1..S3 monetizasyon + paywall | YouTube dalgası-2; bülten #4 |
| 10 | E6-S1..S2 kalite + erişilebilirlik; **TestFlight beta açılır (E6-S4)** | Beta geri bildirim döngüsü; founding son çağrı hazırlığı |
| 11 | Beta düzeltmeleri; E6-S3 mağaza varlıkları; App Review'a gönder | Launch postları taslakları; basın e-postaları |
| 12 | **LAUNCH** + hotfix nöbeti | Kurucu postu + PH + bülten; yorum ritmi başlar |

Sonrası: 01 §8 kapıları → v1.1 (offcut, maliyet, atölye v2, iCloud) → Kapı-2 → v1.2 Android/Web.

## 2. Oturum protokolü (her Fable 5 inşa oturumu)

1. **Bağlam:** CLAUDE.md (otomatik) + ilgili spec bölümü (örn. 04 tamamı veya 07 §E-3) +
   03'ten TEK görev. Fazlasını verme — talimat kalabalığı kaliteyi düşürür.
2. **Akış:** Plan Mode'da yaklaşımı yazdır → onayla → test-önce implementasyon → `swift test`
   çıktısı + değişen dosya listesi → kendi gözünle diff oku.
3. **Kapanış notu:** "Bitti: … / Sıradaki spesifik görev: … / Spec'e işlenecek: …" (5 dk'da
   koda dönebilme garantisi).
4. **Adversarial inceleme (haftada 1):** implementasyonu görmemiş TAZE oturuma:
   "Bu diff'i docs/03 ve docs/04'e karşı denetle; eksik kabul kriteri, kural ihlali ve riskleri
   raporla — stil yorumu isteme." Bulgular ya düzeltilir ya bilinçli-red gerekçesiyle nota geçer.
5. **Cuma senkronu:** kesilen/değişen her karar docs/'a işlenir (spec = ground truth).

## 3. CLAUDE.md şablonu (repo köküne aynen konur, ≤60 satır tutulur)

```markdown
# CutWise — Ajan Anayasası

## Komutlar
- Test: `swift test` (motor+model); UI: Xcode test planı `CutWiseApp`
- Lint: `swiftlint --strict` · Golden: `swift run golden-runner Tests/GoldenTests/vectors`
- Web: `cd apps/web && npm test && npm run build`

## Proje yapısı
- Sources/CutCore = motor (SAF Swift, stdlib-only, Int aritmetik — Double YASAK)
- Sources/CutModels = .cutproj şemaları · apps/ios = SwiftUI · docs/ = spec (ground truth)

## Stil
- Swift 6, strict concurrency; erken-dönüş; kuvvet-unwrap yasak.
- Örnek: `func optimize(_ req: OptimizeRequest) throws -> OptimizeResult` — saf fonksiyon,
  yan etki yok, hata fırlatır; sınıf yerine struct varsayılan.

## Git
- Dal: `feat/E4-S2-parca-girisi` biçimi; commit: görev ID ile başlar; main'e doğrudan push yasak.

## Sınırlar
- ✅ Her zaman: test-önce; golden vektör güncellemesi ayrı commit + gerekçe; spec bölümüne atıf.
- ⚠️ Önce sor: yeni bağımlılık; şema değişikliği (05); public API değişikliği; fiyat/paywall metni.
- 🚫 Asla: motorda Double/platform-RNG; SwiftData'ya geçiş; hesaplama sayacı ekleme;
  reklam SDK'sı; secret commit; docs/ ile çelişen kod ("önce spec'i güncelle" de).

## Tanım-of-Done
Kabul kriterleri testle eşlendi ve yeşil · lint temiz · docs güncel · diff'i tek cümlede
anlatabiliyorum · non-goal dışına dosya değişmedi.
```

## 4. Prompt desenleri (görev tipine göre)

- **Motor görevi:** "docs/04 §3'ü uygula: [görev]. Önce Tests/…'e kırmızı test + 2 golden vektör
  yaz, sonra implement et. Double görürsen dur. Bitince test çıktısını ve vektör hash'lerini yaz."
- **UI görevi:** "docs/07 §E-2 + docs/03 E4-S2'yi uygula. Snapshot testleri (light/dark ×
  Dynamic Type) dahil. 10 parçayı klavyeyle <60 sn girme AC'sini UI testiyle kanıtla."
- **İnceleme:** (yukarıda §2.4) — implementasyonu görmemiş oturum, yalnız spec + diff.
- **Pazarlama:** "docs/09 §3'ten '[sayfa]' SEO sayfasını yaz; ton usta-dili; lite hesaplayıcıya
  1 CTA; başlıkta hedef anahtar kelime; 900-1200 kelime; uydurma istatistik yok."
- **Haftalık plan (Pzt):** "docs/03'ten bu haftanın 3-5 görevini seç (bağımlılık sırasına göre),
  her biri için oturum-bağlam listesi çıkar."

## 5. Riskler → tetik → yanıt

| Risk | Tetik | Yanıt |
|---|---|---|
| Motor kalitesi rakipten kötü | Golden kıyas vektörlerinde CLO/OptiCutter çıktısından belirgin kötü atık % | Portföye annealing turu erken alınır (v1.1→v1.0); gerekirse launch 2 hafta kayar — kalitesiz motorla launch YOK |
| Founding ön-satış zayıf (<%0.7 niyet) | H−4 okuması | Mesaj/fiyat revizyonu + 2. tur; talep diğer kanıtlarla güçlü — kill değil iterasyon |
| Web lideri iOS'a iner | Mağaza izleme (haftalık) | 09 §6 karşı-hamlesi |
| Skip/Wasm toolchain sürprizi | E7-S2 veya v1.2'de derleme duvarı | Motor TS-portu (golden vektörler sayesinde sınırlı iş — 06 §1 sigortası) |
| Tek kişi hastalık/tatil | — | Haftalık kapanış notları + spec-ground-truth zaten kaldığı yerden devralmayı garantiler |
| App Review reddi (4.3 benzerlik) | Review notu | "Meaningfully different" kanıt paketi hazır: atölye modu + 1D+2D + offline + golden doğruluk |

## 6. Launch-günü kontrol listesi

- [ ] Golden CI yeşil (motor + Wasm parite) · [ ] StoreKitTest senaryoları yeşil
- [ ] Şeffaf fatura listesi (08 §4) işaretli · [ ] Erişilebilirlik geçişi yapıldı
- [ ] Crash-free ≥%99.5 (beta) · [ ] Destek e-postası + SSS sayfası canlı
- [ ] Founding kodları test edildi · [ ] Kurucu postu + görseller hazır · [ ] Analitik funnel doğrulandı
- [ ] docs/ sürüm etiketi: `plan-v1.0-launch`
