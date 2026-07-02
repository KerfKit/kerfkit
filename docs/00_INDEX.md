# CutWise — Plan Paketi (v1.0, 2 Temmuz 2026)

> **Ürün:** Marangoz Kesim Planlayıcı (2D panel + 1D doğrusal kesim optimizasyonu)
> **Platformlar:** iOS (önce) → Android (Skip) → Web (lite → tam)
> **Model:** Solo geliştirici; tüm geliştirme Claude Fable 5 ile yürütülür.
> **Hedef:** Pazar liderliği — hiçbir rakip iOS+Android+Web üçlüsünü tek üründe sunmuyor (bkz. 02).
> **Çalışma adı:** "CutWise" — kesinleşmeden önce marka/ticari-marka kontrolü yapılacak (Backlog G-0.3).

## Bu paket nasıl kullanılır

Bu paket, GitHub Spec Kit'in **Specify → Plan → Tasks → Implement** akışına göre düzenlendi.
Kod değil, **spec birincil artefakttır**: her değişiklik önce ilgili dosyaya işlenir, sonra koda gider.
Dosyalar Fable 5 oturumlarına **bağlam olarak verilmek üzere** yazıldı — bir oturuma yalnız ilgili
dosyayı/bölümü ver, tamamını değil ("curse of instructions"tan kaçın).

| # | Dosya | Ne işe yarar | Hangi oturumda verilir |
|---|-------|--------------|------------------------|
| 01 | VISION_VE_PRD.md | Problem, persona, kapsam, metrikler, non-goals | Her yeni epik başlangıcında |
| 02 | RAKIP_MATRISI.md | Özellik matrisi, liderlik seti, "asla yapma" listesi | Özellik tasarımı oturumlarında |
| 03 | BACKLOG.md | Epikler → hikâyeler → kabul kriterleri → oturum-boyu görevler | Her inşa oturumunda (yalnız ilgili görev) |
| 04 | ALGORITMA_SPEC.md | Çekirdek motor: guillotine 2D + 1D, kerf, grain, golden testler | Motor oturumlarında (tamamı) |
| 05 | VERI_MODELI.md | Varlıklar, .cutproj JSON şeması, değişmezler | Motor + veri oturumlarında |
| 06 | MIMARI.md | Platform kararı, repo yapısı, senkron, ödeme mimarisi | Kurulum + platform oturumlarında |
| 07 | UI_UX.md | Ekranlar, akışlar, boş durumlar, atölye modu | UI oturumlarında (ekran başına bölüm) |
| 08 | MONETIZASYON.md | Fiyat, katmanlar, StoreKit2/Play/Stripe, şeffaf fatura | Paywall + ödeme oturumlarında |
| 09 | GTM_LANSMAN.md | Hafta −8→+90 playbook, ASO, kanallar, şablon metinler | Pazarlama görevlerinde |
| 10 | YOL_HARITASI_VE_FABLE5.md | 12 haftalık plan, CLAUDE.md şablonu, prompt desenleri, kapılar | Her Pazartesi planlama oturumunda |
| 11 | MARKA_KIMLIGI.md | İsim (UYARI: CutWise→Kerf), kişilik, ton, logo/ikon brief'i, renk sahipliği | Marka/ikon oturumlarında |
| 12 | TASARIM_SISTEMI.md | Token mimarisi, palet+kontrast, tipografi, diyagram dili, bileşen spec'leri | Her tasarım oturumunda (tokens.css ile) |
| — | tokens/tokens.json | DTCG 2025.10 tek-kaynak token dosyası → CSS + Swift üretilir | Pipeline (15 §1) |
| 13 | MOBIL_TASARIM_BRIEF.md | iOS ekran-ekran tasarım brief'leri + mockup odakları | Mobil UI mockup oturumlarında (ekran başına bölüm) |
| 14 | WEB_TASARIM_BRIEF.md | Landing, lite hesaplayıcı, SEO şablonu, karşılaştırma sayfası | Web oturumlarında |
| 15 | FABLE5_TASARIM_IS_AKISI.md | Mockup→kod döngüsü, ikon hattı, tasarım QA, Figma kararı | Tasarım sürecinin kendisi |

## Haftalık ritim (10 numaralı dosyada detay)

- **Pazartesi:** planla — BACKLOG'dan 3-5 görev seç, spec dilimlerini hazırla.
- **Salı-Perşembe:** inşa — görev başına bir Fable 5 oturumu; oturum sonunda "bitti + sıradaki spesifik görev" notu.
- **Cuma:** test + sevkiyat + spec senkronu (kesilen/değişen her şey bu dosyalara geri işlenir).

## Değişmez kurallar (tüm paketin üstünde)

1. **Doğrulanamayan hiçbir şey sevk edilmez** — her kabul kriteri bir teste eşlenir (golden testler: 04).
2. **Non-goals kutsaldır** — v1'de yapılmayacaklar listesi (01) scope-creep'in frenidir; yeni fikir → backlog'a.
3. **Şeffaf fatura launch kapısıdır** — rakiplerin 1★ nedenleri (02 §4) bizim yasak listemizdir.
4. **Motor saf Swift + tamsayı aritmetik** — platform paritesi golden vektörlerle kanıtlanır (04 §5).
5. **Spec canlı belgedir** — kod spec'ten saparsa ya kod düzelir ya spec güncellenir; ikisi asla çelişik kalmaz.

## Kaynak zinciri

Bu paket 4 öğrenme ajanının çıktısından sentezlendi: PO/spec-driven metodolojisi (GitHub Spec Kit,
Anthropic best practices, Addy Osmani, Simon Willison), 8-rakip teardown (~15 kaynak), algoritma/mimari
araştırması (Jylänki RectangleBinPack, Skip/SwiftWasm resmî durumu), GTM playbook (forum/kanal doğrulamalı).
Kaynak URL'leri ilgili dosyaların sonunda.
