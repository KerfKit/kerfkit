# 13 — Mobil Tasarım Brief'i (iOS; ekran ekran)

> Kullanım: her ekran için Fable 5'e BU bölüm + 12 (tasarım sistemi) + tokens.css verilir;
> önce 3-5 HTML mockup varyantı istenir (15 §2 döngüsü), seçilen SwiftUI'a çevrilir.
> Tüm ekranlar koyu-öncelikli tasarlanır; açık tema semantic token'lardan türer.

## M-1 Projeler Listesi
- Yapı: büyük başlık "Projeler" + arama; kart listesi (bg.surface, radius.card).
- Kart anatomisi: proje adı (headline) · malzeme rozetleri (raised zemin, caption) ·
  alt satır: "3 levha · %7,2 fire · 2g önce" (secondary, tabular rakam).
- Boş durum: kerf-motifi minimal çizim + "Örnek projeyi dene" (primary lg) + "Yeni proje" (ghost).
- FAB yok; üst-sağ "+" (44pt). Ücretsiz sınır: 3. proje kartı yerine nazik kilit kartı.
- Mockup odağı: kart yoğunluğu (rahat vs sıkı) iki varyant.

## M-2 Parça Girişi (EN KRİTİK — E4-S2)
- Tablo satırı: ad (body) · G×Y (tabular) · ×adet · damar kilidi ikonu · bant rozeti (4 nokta).
- Giriş modu: alt yapışık "hızlı giriş çubuğu" — alan sırası ad→G→Y→adet, Return zinciri;
  imperial'da kesir pad'i (1/2 1/4 3/4 1/8 … hızlı; tam liste kaydırmalı), 60pt tuşlar.
- Toplu yapıştır algısı: pano TSV/CSV ise üstte amber bilgi bandı "12 satır algılandı — İçe aktar".
- Hata: satır içi danger sınır + altta kısa mesaj; asla toast-yalnız.
- Mockup odağı: kesir pad yerleşimi (2 varyant) + satır yoğunluğu.

## M-3 Stok Sekmesi
- Hazır kütüphane bölümü (yatay çipler: 4×8, 5×5, 2440×1220…) + "Özel stok" satırı.
- Offcut satırları (v1.1): üstte, kerf-ikonu + "artık" rozeti, "önce artıkları kullan" anahtarı.

## M-4 Plan / Sonuç Ekranı
- Üst istatistik kartı: 3 büyük sayı (levha · fire% · kesim) display boyut, tabular; hedef
  segmenti altında (SegmentedControl).
- Diyagram alanı: levha sekmeleri (üstte, raised çipler "Levha 1/3"), Canvas pinch-zoom;
  12 §5 diyagram dili (doku + etiket + hatch atık + amber kerf).
- Stale bandı: sarı (amber.700 zemin, timber.950 metin) tam-genişlik "Girdiler değişti — Yeniden hesapla".
- Alt eylem çubuğu: "Atölye Modu" (primary) · Paylaş (PDF/CSV/.cutproj) · hedef değiştir.
- Yerleşmeyenler: kırmızı bölüm listesi + neden + öneri butonları.
- Mockup odağı: istatistik kartı kompozisyonu + diyagram etiket yoğunluğu (2×2 varyant).

## M-5 Atölye Modu (farklılaştırıcı)
- Tam ekran, statusbar gizli, ekran-uyanık rozeti; **Tezgâh Modu anahtarı** üstte (12 §7:
  ultra-kontrast açık tema + dev tipografi — parlama gerçeği).
- Sıradaki kesim kartı: "KESİM 7/34" (caption) · talimat (display, ≥34pt): "Rip @ 600mm —
  Levha 2" · mini-diyagram (o kesimin vurgulu hali).
- "✓ KESİLDİ" tam-genişlik 60pt primary; altında "Geri al" ghost; ilerleme halkası köşede.
- Eldiven kuralı: tüm hedefler ≥56pt, hedef arası ≥8pt.
- Mockup odağı: koyu vs Tezgâh modu yan yana.

## M-6 Onboarding (3 ekran + örnek proje)
- Her ekran: tek cümle + tek görsel (gerçek diyagram render'ı); ilerleme noktaları amber.
- 3. ekran CTA: "Örnek projeyle dene" → otomatik ilk optimizasyon → sonuç ekranına iniş
  (aha-anı garantisi). Paywall onboarding'de GÖSTERİLMEZ.

## M-7 Paywall
- Başlık fayda-dili; 3 kutu (12 §6 PaywallCard): Lifetime manşet (amber sınır + "En popüler"),
  Yıllık, Hafta sonu. Fiyat + koşul aynı punto; Restore görünür link; kapat-X her zaman aktif.
- Yasak: sayaç, sahte kıtlık, küçük punto (08 §4 listesi tasarım DoD'sidir).

## M-8 Ayarlar
- Gruplu liste: Birimler · Varsayılanlar (kerf/trim/hedef) · Görünüm (tema: Koyu/Açık/Sistem) ·
  Verilerim (tümünü dışa aktar — her zaman erişilir) · Gizlilik (analitik anahtarı) ·
  Destek ("<24s yanıt" notu) · Hakkında.

## App Store ekran şablonu (6 görsel — 09 §2 hikâyesiyle)
Koyu cihaz çerçevesi, amber başlık şeridi, gerçek veri; sıra: giriş hızı → sonuç → pro detaylar →
atölye modu → export → "One-time. No subscription."


## Android notları (K-31 iskelet bulguları — 4 Tem 2026)

SwiftUI→Compose köprüsünde (Skip Fuse 1.9.4) iOS kodundan sapmalar:
- `Text(_:bundle:)` ve `String(localized:)` köprülenmiyor — yerelleştirme yalnız
  `LocalizedStringKey` yoluyla (Text/TextField literal anahtarları). Veri-değerleri
  (örn. varsayılan proje adı) şimdilik EN düz metin; E9-S2'de çözülecek.
- `.monospacedDigit()` yok — düz font kullan.
- `GeometryReader`+`aspectRatio` kombinasyonu iOS'la birebir ölçeklemiyor: M-4
  diyagramında parçalar levha kutusundan taşabiliyor (iskelette bilinen kusur;
  E9-S2'de Canvas köprüsü ya da manuel frame hesabıyla yeniden yapılacak).
- Yerelleştirme paketi Android'de `res/values-*/strings.xml` DEĞİL, Skip'in
  `assets/**/*.lproj/Localizable.strings` mekanizması — tek String Catalog iki
  platformu besler (6 dil APK'da doğrulandı); ASO/store metinleri bundan bağımsız.
- İç Kotlin paketi `kerf.kit` (Skip, modül adından türetir — değiştirilemez);
  mağaza kimliği `applicationId = app.kerfkit` (Skip.env ANDROID_APPLICATION_ID).
