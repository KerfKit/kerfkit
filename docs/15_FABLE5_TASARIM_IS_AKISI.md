# 15 — Fable 5 ile Tasarım İş Akışı (design-as-code)

> Cevap netleşsin: tasarım NE ayrı bir araçta NE de "code tarafında sonra" — **bu pakette
> dokümante edilir (11-14 + tokens.json), Fable 5 ile mockup→kod döngüsünde üretilir.**
> Figma opsiyoneldir; tek gerçek kaynak tokens.json'dur.

## 1. Kurulum (tek seferlik — Hafta 1, G-0 ile birlikte)

1. `tokens/tokens.json` repo'ya girer. `npm i -D style-dictionary` + config:
   çıktılar `apps/web/styles/tokens.css` (css/variables) ve
   `apps/ios/DesignTokens/` (xcassets colorset'ler + `Space/Radius/FontSize.swift` sabitleri).
2. Build'e kontrast bekçisi: her `text.*`×`bg.*` çifti (light+dark) WCAG AA testi
   (`wcag-contrast` npm) — eşik altı = build fail (12 §8 otomasyonu).
3. `docs/DESIGN.md` (bileşen envanteri) başlatılır: bileşen adı · varyantlar · kullandığı
   token'lar · do/don't. Her yeni bileşen buraya işlenmeden merge edilmez.
4. CLAUDE.md'ye tasarım kuralları eklenir (10 §3 Sınırlar'a): "🚫 hex/px hardcode — önce token
   öner; ✅ her UI PR'ında light/dark + DynamicType-XXL ekran görüntüsü".

## 2. Mockup döngüsü (her ekran için — 13/14 brief'leriyle)

```
Oturum A (üretim):  bağlam = 12_TASARIM_SISTEMI + tokens.css + 13/14'ün İLGİLİ bölümü
  → "Bu ekran için 3 HTML mockup varyantı üret. KURALLAR: yalnız var(--...) token'ları,
     hex yasak; 4/8px boşluk ritmi; gerçekçi veri (Mutfak Dolabı projesi); koyu tema;
     varyantlar kompozisyonda ayrışsın (yoğunluk/hiyerarşi), renkte değil."
İnsan seçimi:       tarayıcıda aç, birini seç (gerekirse "V2'nin üstü + V3'ün alt çubuğu" melezi)
Oturum B (çeviri):  bağlam = seçilen HTML + 12 §6 bileşen spec'i
  → "Bunu SwiftUI'a çevir; yalnız DesignTokens sabitleri; snapshot testleri
     (light/dark × DynamicType M/XXL) dahil; 44pt hedef denetimini testte assert et."
Oturum C (kritik, haftalık): implementasyonu görmemiş taze oturum
  → "Ekran görüntülerini 12/13'e karşı denetle: token ihlali, ritim kırığı, kontrast,
     hedef boyutu. Stil zevki yorumu isteme, kural ihlali raporla."
```

- Web'de aynı döngü: Oturum B çıktısı Astro bileşeni; mockup zaten HTML olduğundan çeviri hafif.
- Diyagram render'ı istisna: önce Swift Canvas implementasyonu (motorla), web'e SVG eşleniği;
  mockup'larda gerçek motor çıktısı JSON'u kullanılır (sahte yerleşim YASAK — parite kültürü).

## 3. İkon üretim hattı (11 §4 brief'iyle)

1. Fable 5'ten **katmanlı SVG** 5 varyant (kerf-çizgisi / V-kertik / çizecek-izi aileleri;
   düz formlar, gölge-gradyan pişirme yok).
2. Kısa liste 2'ye iner → TestFlight kitlesine mini-anket (H−5).
3. Seçilen: katman başına 1024 şeffaf PNG (resvg) → **Icon Composer** (.icon; Default/Dark/
   Clear/Tinted otomatik) → Xcode target. Pazarlama için flattened 1024 export.
4. Ret kriterleri: 29pt'te okunmuyor · testere-dişi/grid klişesine benzedi · amber<%40 alan.

## 4. Tasarım QA kontrol listesi (her ekran DoD'si)

- [ ] Hardcode grep temiz (hex/px yalnız tokens dosyalarında)
- [ ] Boşluklar 4/8 ritminde; kart köşeleri radius token'larından
- [ ] Kontrast çiftleri AA (otomatik test yeşil)
- [ ] Dokunma hedefleri ≥44pt (atölye birincil ≥56pt) — snapshot üzerinde ölçüldü
- [ ] Dynamic Type XXL taşma yok; VoiceOver etiketleri anlamlı
- [ ] Light/dark + Tezgâh Modu görüntüleri PR'da
- [ ] Yeni bileşen DESIGN.md envanterine işlendi
- [ ] Diyagram: etiket+desen+hatch üçlüsü (asla yalnız renk)

## 5. Figma ne zaman gerekir? (dürüst cevap)

Gerekmez — şu üç durum hariç: (a) App Store ekran görselleri için pazarlama kompozisyonu
(alternatif: HTML şablon + ekran görüntüsü, bu pakette varsayılan), (b) dış tasarımcıyla
çalışma kararı, (c) çok karmaşık illüstrasyon. Karar: v1 tamamen design-as-code; Figma'ya
geçiş ancak (b) gerçekleşirse — o zaman tokens.json Tokens Studio ile Figma'ya import edilir
(format zaten DTCG, kayıpsız geçer).

## 6. Sıralama (12-hafta planına ekleme — 10 §1 revizyonu)

- Hafta 1: §1 kurulum (0.5 gün) + ikon SVG varyantları (0.5 gün, paralel).
- Hafta 5-8 UI haftalarında: her ekran için §2 döngüsü (mockup A oturumu ekran-başına ~30dk).
- Hafta 6: web landing mockup'ları aynı döngüyle (14 W-1/W-2).
- Hafta 10: §4 listesiyle toplu tasarım denetimi + App Store görselleri.
