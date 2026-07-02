# 14 — Web Tasarım Brief'i (pazarlama sitesi + lite hesaplayıcı)

> Aynı tokens.json → tokens.css; koyu-öncelikli marka burada da geçerli (SEO içerik sayfaları
> okunabilirlik için açık-zemin gövde + koyu kabuk hibrit kullanır). Framework: Astro; UI
> bileşenleri vanilla/TS hafif; lite hesaplayıcı Wasm motoru (06 §4).

## W-1 Ana sayfa / Landing (E7-S1; founding dönemi)
- **Hero (koyu):** sol: başlık "Stop paying monthly to cut plywood." + alt "One-time $49,
  yours forever. No subscription. Ever." + founding sayacı (GERÇEK: 217/300) + CTA (amber lg);
  sağ: canlı mini-demo (küçük diyagram animasyonu — gerçek motor çıktısı, 20sn video fallback).
- Sosyal kanıt şeridi: forum/YouTube alıntıları (gerçek, linkli).
- "Nasıl çalışır" 3 adım (giriş → plan → atölye) — ekran görüntüleri koyu cihaz çerçevesinde.
- Karşılaştırma bloğu: "aylık kiralık hesaplayıcı vs Kerf" dürüst tablo (02 verisinden).
- Fiyat bölümü: 3 kutu (08 yapısı) + SSS (iade, platform, offline).
- Footer: gizlilik/iade/iletişim + "Founding Craftsmen" duvarı (beta isimleri, izinli).
- AB uyum notları landing metnine gömülü (09 §1: gerçek sayaç, KDV, 14g iade, cayma onayı).

## W-2 Lite Hesaplayıcı (lead-gen + parite kanıtı)
- Tek sayfa uygulama hissi: sol panel (stok seçimi çipleri + parça tablosu ≤20 satır),
  sağ panel canlı diyagram (Wasm; her değişimde <100ms yeniden hesap).
- Sınırlar nazikçe: 21. parça → "Tam sürüm iOS'ta — sınırsız parça + atölye modu" kartı.
- PDF indir → e-posta modalı (tek alan + "haftada 1 e-posta, istediğin an çık" dürüstlüğü).
- Mobil-responsive: panel dikey yığılır; dokunma hedefleri 44px.
- Diyagram dili birebir 12 §5 (aynı render kodu hedefi — parite).

## W-3 SEO içerik şablonu (09 §3'teki 10 sayfa)
- Kabuk koyu (header/footer marka), **gövde açık-zemin** (uzun okuma için pozitif polarite),
  başlıklar timber.900, linkler amber.700.
- Şablon: H1 + 120 kelime özet + içindekiler + bölümler + gömülü mini-hesaplayıcı CTA'sı
  (sayfa konusuna bağlı ön-ayarlı: "kerf nedir" sayfasında kerf alanı vurgulu) + SSS schema.org.
- Her sayfada tek birincil CTA: lite hesaplayıcı; ikincil: App Store rozeti (launch sonrası).

## W-4 Karşılaştırma sayfası ("cutlistoptimizer alternative")
- Dürüst ton: rakibin güçlü yanları da yazılır (bulut senkron, Android geçmişi); bizim
  eksen: tek-seferlik fiyat, offline, iOS-native, atölye modu. Tablo + 2 ekran görüntüsü.
- Hukuk: marka adı yalnız karşılaştırma bağlamında (nominative use), logo kullanılmaz.

## W-5 Destek/SSS + durum sayfası
- SSS: satın alma/restore/iade, birimler, kerf tanımı, veri gizliliği ("verin cihazında").
- İletişim: e-posta + "<24 saat yanıt" sözü (rakip zaafının tersi — 02 §4/6).

## Web bileşen notları
- Buton/kart/input: 12 §6 spec'lerinin CSS eşleniği (aynı token'lar; hover: accent.bright).
- Performans bütçesi: LCP <2s (hero görseli optimize), Wasm lazy-load (hesaplayıcı sayfasında).
- Analitik: gizlilik-dostu (Plausible/TelemetryDeck-web); e-posta: Buttondown/Loops.
