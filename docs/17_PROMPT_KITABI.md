# 17 — Prompt Kitabı (Claude Code: projenin başından sonuna her oturum)

> Kullanım: her prompt TEK oturumdur; oturumlar arası `/clear`. Promptu aynen yapıştır.
> Kural hatırlatma: plan-önce (onaylamadan kod yok), test-önce, bitişte "test çıktısı +
> değişen dosyalar + diff'in tek cümlesi". `[...]` içini sen doldurursun.
> Numaralama: K=kod, D=tasarım, W=web, P=pazarlama-içerik, R=rutin, A=acil durum.

## 0. TEKRARLAYAN RUTİNLER (her hafta aynı)

**R-1 · Pazartesi planlama:** "docs/03 ve docs/10 §1'e bak. Bu hafta [hafta no] — bağımlılık
sırasına göre 3-5 görev seç, her biri için oturum-bağlam listesi (hangi doc bölümleri) çıkar.
Geçen haftanın Cuma notunu dikkate al: [notu yapıştır]."

**R-2 · Cuma senkron:** "Bu hafta merge edilen commit'leri listele. docs/ ile çelişen karar
var mı tara; varsa ilgili doc'a düzeltme diff'i öner (kendin uygulama, bana göster). Haftalık
kapanış notu yaz: Bitti / Sıradaki / Öğrendik."

**R-3 · Haftalık adversarial inceleme (taze oturumda, implementasyonu görmemiş):** "Bu diff'i
docs/03'teki kabul kriterlerine ve docs/04 kurallarına karşı denetle: [diff/PR linki]. Eksik
AC, kural ihlali (Double, platform-RNG, hardcode hex/px), test boşluğu raporla. Stil zevki
yorumu isteme."

**R-4 · Golden vektör güncellemesi (motor davranışı bilinçli değiştiğinde):** "Şu değişiklik
sonrası etkilenen vektörlerin expected değerlerini yeniden üret: [değişiklik]. Her değişen
hash için 1 satır gerekçe yaz; ayrı commit olarak hazırla."

---

## HAFTA 1 — Kurulum + motor başlangıcı

**K-0 · Ortam doğrulama:** "CLAUDE.md ve docs/00_INDEX.md'yi oku. `swift test` koş (8 test
yeşil olmalı), `node tools/gen-tokens.mjs` koş (62 token). CI durumunu özetle. Sorun varsa
düzeltme planı sun, kod yazma."

**K-1 · E1-S1a Yerleştirme çekirdeği:** "docs/04 §2-3'ü oku. E1-S1a: kesim-ağaçlı serbest
dikdörtgen yapısı + Best-Area-Fit yerleştirme (kerf=0, trim=0 basit hal). Önce docs/03
E1-S1 AC-1..AC-4'ü kırmızı testlere çevir, sonra implement et. Double/Float görürsen dur."

**K-2 · E1-S1b Guillotine doğrulayıcı + ilk golden:** "docs/04 §5'i oku. verifyInvariants'a
guillotine-geçerlilik (kesim ağacının yeniden inşası), çakışma ve sınır kontrolünü ekle;
FNV-1a placementsHash'i alan sırasına birebir uygulayarak yaz. 001 vektörünün expected'ını
doldur, pending:false yap. 3 yeni basit vektör ekle."

**D-1 · İkon varyantları:** "docs/11 §4 ve docs/15 §3'ü oku. 'kerf işareti' için 5 katmanlı-SVG
varyantı üret (kerf-çizgisi / V-kertik / çizecek-izi aileleri; düz form, gölge yok) →
assets/icon/. 29pt küçültmeyi gösteren tek sayfalık HTML kontakt-tabakası yaz."

## HAFTA 2 — Motor: kerf/trim/grain + landing

**K-3 · E1-S2 Kerf+trim:** "docs/04 §3'teki kerf modelini uygula (bölme anında düşülür, levha
kenarında düşülmez; trim kullanılabilir alanı daraltır). E1-S2 AC'leri + kerf 0/12mm uç
vektörleri + 002 vektörünü tamamla (pending:false)."

**K-4 · E1-S3 Damar kilidi:** "rotation:fixed parçada 90° adayı üretilmez; yalnız döndürünce
sığan fixed parça unplaced+nedenle döner (sessiz atlama YASAK). E1-S3 AC'leri + 3 vektör."

**W-1 · E7-S1 Landing + founding ön-satış:** "docs/14 W-1 ve docs/09 §1'i oku. apps/web'de
Astro projesi kur; tek sayfa landing: başlık/alt-başlık docs/09 §1'deki İngilizce metinler,
GERÇEK founding sayacı (basit JSON endpoint stub), e-posta listesi CTA + mağaza rozetleri (ödeme yalnız mağaza içi), 14 gün
iade + KDV + cayma metinleri. tokens.css kullan, hex yazma. Lighthouse ≥90 hedef."

**P-1 · Landing metin cilası (SEN onaylayacaksın):** "docs/09 §1'deki başlık iskeletinden
landing'in tam EN metnini yaz: hero, 3-adım, SSS (5 soru), footer. Ton: usta-dili, abartısız.
'Founding 300 koltuk' gerçek-sayaç dilinde; sahte aciliyet ifadesi kullanma."

## HAFTA 3 — Motor bitişi: çoklu levha + hedefler + 1D

**K-5 · E1-S4a Çoklu levha/malzeme:** "Malzeme havuzları ayrık optimize edilir; stok tükenince
unplaced+neden. E1-S4 AC-1/AC-3 testleri + 4 vektör (çoklu levha, çoklu malzeme)."

**K-6 · E1-S4b Heuristik portföyü + hedef fonksiyonu:** "docs/04 §3 adım 3-5: {sıralama ×
bölme × ilk-yön} portföyünü (6-12 koşu) koş, leksikografik hedefe göre seç (sheets/waste/cuts).
Üç hedef için aynı girdiden farklı plan döndüren vektör üçlüsü ekle. PCG32 dışında rastgelelik
kullanma; koşu sırası deterministik."

**K-7 · E1-S5 Kenar bandı:** "docs/03 E1-S5: kenar-başına seçim, fire payı, malzeme-gruplu
toplam; opsiyonel boyut büyütme yerleştirme ÖNCESİ. 2 vektör."

**K-8 · E2-S1 1D motor:** "docs/04 §4: FFD+kerf; benzersiz parça ≤15'te branch-and-bound
(500ms sınır, aşarsa FFD). E2-S1 AC'leri + 4 vektör. 2D ile aynı çıktı yapısı."

## HAFTA 4 — Performans + veri katmanı

**K-9 · E1-S4c Performans kanıtı:** "500 parçalık sentetik vektör üret; XCTest measure ile
portföy süresini ölç. Hedef <2sn (M1 Mac'te <0.5sn beklenir). Instruments'ta en pahalı 3
fonksiyonu raporla; optimizasyon ÖNERME, sadece ölç (erken optimizasyon yasak)."

**K-10 · E3-S1 .cutproj şeması:** "docs/05 §2-3'ü oku. Codable modeller + schemaVersion +
bilinmeyen-alan koruması (round-trip bit-eşit testi) + migrasyon iskeleti."

**K-11 · E3-S2 GRDB kalıcılık:** "GRDB ekle (⚠️ yeni bağımlılık — önce onay iste, gerekçesiyle).
Otomatik kayıt 500ms debounce; öldür-aç testinde son durum tam; 100 projede liste <100ms."

**K-12 · E3-S3 CSV import/export:** "Ayraç otomatik algı (virgül/noktalı-virgül/tab); hatalı
satır satır-numaralı raporla atlanır; export→import kayıpsız. Gerçekçi 3 CSV fixture ile test."

## HAFTA 5-7 — iOS UI (her ekran: önce D-mockup, sonra K-kod)

**D-2 · Mockup döngüsü şablonu (her ekran için aynı kalıp):** "docs/12 + apps/web/styles/
tokens.css + docs/13 §[M-x]'i oku. Bu ekran için 3 HTML mockup varyantı üret: yalnız
var(--...) token'ları, 4/8px ritim, gerçekçi veri (Mutfak Dolabı projesi), koyu tema.
Varyantlar kompozisyonda ayrışsın, renkte değil." → (sen seçersin) →
**K-UI · Çeviri şablonu:** "Seçilen mockup şu: [dosya]. docs/12 §6 bileşen spec'ine uyarak
SwiftUI'a çevir; yalnız DesignTokens sabitleri; snapshot testleri (light/dark × DynamicType
M/XXL); 44pt dokunma hedefi assert'i."

Sıra (D+K çifti olarak): **M-1 Proje listesi → M-2 Parça girişi** ("10 parça klavyeyle <60sn"
UI testi zorunlu; kesir pad'i ayrı varyant turu) → **M-3 Stok** → **M-4 Plan/diyagram**
(Canvas render docs/12 §5 diliyle: doku+etiket+hatch; 20 levhada 60fps; bayat-sonuç bandı) →
**M-5 Atölye lite** (ekran-uyanık + 60pt hedefler + Tezgâh Modu anahtarı) → **M-6 Onboarding**
(örnek-proje ilk-optimizasyon garantisi) → **M-8 Ayarlar**.

**K-13 · PDF export (E4-S4):** "Plan ekranından A4/Letter PDF: diyagram (HER ZAMAN açık tema),
parça listesi, özet. Golden bir projenin PDF'ini snapshot testle sabitle."

## HAFTA 6 (paralel) — Web lite

**W-2 · E7-S2 Wasm motor + lite hesaplayıcı:** "docs/06 §1/4'ü oku. CutCoreWasm hedefini
SwiftWasm ile derle; apps/web'de tek-levha lite hesaplayıcı (≤20 parça): sol panel giriş,
sağ canlı diyagram (<100ms). PARİTE KANITI: 001 ve 002 vektörlerini tarayıcıda koşup hash'leri
Swift çıktısıyla diff'le; CI'a Node parite adımı ekle. PDF indirme → e-posta modalı."

**P-2 · SEO ilk 3 sayfa:** "docs/09 §3 listesinden 'plywood cutting calculator', 'what is kerf',
'how to minimize plywood waste' sayfalarını yaz (her biri 900-1200 kelime, EN, usta-dili,
uydurma istatistik yok, lite-hesaplayıcıya tek CTA). Astro content collection olarak."

## HAFTA 7-8 — Monetizasyon

**K-14 · E5-S1 StoreKit2:** "docs/08 §3'ü oku. lifetime (non-consumable) + yıllık (auto-renew)
+ hafta-sonu geçişi (non-renewing 72s) + restore. StoreKitTest ile: satın al→kilit açılır→
sil-kur→restore çalışır→iade→kilit kapanır senaryolarını otomatikleştir. Entitlement tek
kaynak: ProStatus."

**K-15 · E5-S2 Paywall + katman kapıları:** "docs/07 E-7 + docs/08 §1/§4'ü oku. Paywall ekranı
(mockup döngüsüyle: D-2 kalıbı) + ücretsiz sınır diyalogları (3. proje / 21. parça — nazik,
silme/arşiv seçenekli). §4 şeffaf-fatura kontrol listesinin HER maddesini UI testiyle kanıtla."

**K-16 · E5-S3 Founding remote flag:** "Founding fiyat penceresi için tek remote flag
(basit JSON config fetch + cache); kapanınca kalıcı fiyata döner. Fiyat A/B YOK."

## HAFTA 8-9 — Kalite + mağaza hazırlığı

**K-17 · E6-S1 CI matrisi:** "Golden vektörleri macOS+iOS-sim+Wasm'da koşan CI matrisi;
UI smoke testi (proje aç→parça gir→optimize→PDF). Kırmızıda merge engeli."

**K-18 · E6-S2 Erişilebilirlik geçişi:** "docs/12 §8 listesiyle tüm ekranları denetle:
Dynamic Type XXL taşmaları, VoiceOver etiketleri (diyagram özet cümlesi dahil), kontrast,
Reduce Motion. Bulguları düzelt; ekran başına önce/sonra ekran görüntüsü."

**P-3 · App Store metadata:** "docs/09 §2'yi oku. Final EN metadata yaz: başlık (30), altbaşlık
(30), keywords (100), açıklama, 'what's new'. 6 ekran görüntüsünün başlık metinleri + hangi
gerçek ekrandan alınacağı. Karakter limitlerini doğrula."

**K-19 · E6-S3 Mağaza görselleri:** "Simülatörden 6.7/6.1/iPad ekran görüntülerini fastlane
snapshot ile üret; docs/09 §2 hikâye sırasına göre HTML çerçeve şablonuyla kompoze et."

**K-20 · E6-S4 TestFlight:** "fastlane ile TestFlight internal lane kur; beta notları + geri
bildirim formu linki; crash izleme (MetricKit) ekle. Build'i yükle, kontrol listesini raporla."

**P-4 · Gizlilik + koşullar (launch-blocker):** "docs/06 §6 ve veri modelini oku. Privacy
policy + Terms taslağı yaz (EN; cihaz-içi veri, anonim opt-out analitik, üçüncü-taraf yok);
App Store gizlilik etiketi eşlemesini tablo olarak çıkar. Hukuki-tavsiye-değildir notuyla bana
onaya sun."

## HAFTA 10-11 — Beta düzeltmeleri + gönderim

**K-21 · Beta triyaj (tekrarlanır):** "TestFlight geri bildirimleri: [yapıştır]. Kök-neden
grupla, docs/03 AC'lerine eşle, düzeltme sırası öner (crash > veri > UX > kozmetik). İlk 3'ü
bu oturumda düzelt, test ekle."

**K-22 · App Review gönderimi:** "Review notu yaz: 'meaningfully different' kanıtı (atölye
modu + 2D+1D + tam offline + golden doğruluk), demo videosu senaryosu, test hesabı gereksiz
açıklaması. docs/10 §6 launch kontrol listesini işaretleyerek raporla; eksik varsa gönderme."

## HAFTA 12 — LAUNCH

**K-23 · Launch günü nöbeti:** "Sürüm yayında. Crash/analitik panosunu kur (MetricKit +
TelemetryDeck sorguları): aktivasyon hunisi, paywall dönüşümü, crash-free %. İlk 24 saat
anomali eşiklerini tanımla ve izleme talimatı yaz."

**P-5 · Launch içerikleri:** "docs/09 §4'ü oku. Kurucu postunun final metnini (r/Beginner
WoodWorking + 3 forum varyantı), Product Hunt taglineı, basın e-postasını (5 hedef) yaz.
Her varyant kanal kurallarına uygun; link yorumda kuralına dikkat."

## LAUNCH SONRASI (30-90 gün)

**R-5 · Haftalık yorum yanıtları:** "Bu haftanın mağaza yorumları: [yapıştır]. Her birine
<24s tonunda yanıt taslağı (EN); tekrar eden temaları docs/03 v1.1 aday listesine işle."

**K-24 · Kapı-1 analizi (gün 30):** "Analitik verisi: [yapıştır]. docs/01 §8 Kapı-1 eşiklerine
karşı değerlendir; aktivasyon <%50 ise onboarding iterasyon planı (E7-S3 örnek-proje
derinleştirme) çıkar. Karar önerisi: devam/iterasyon."

**v1.1 serisi (Kapı-1 sonrası, RICE sırasıyla — docs/03 tablosu):**
- **K-25 Offcut envanteri:** "docs/05 offcut alanları + docs/03 v1.1: plan tamamlanınca
  min-boyut üstü artıklar stok havuzuna 'offcut' bayrağıyla düşer; 'önce artıkları kullan'
  anahtarı motor config'ine bağlanır. Vektörler + UI."
- **K-26 iCloud senkron:** "iCloud Documents ile .cutproj klasörü; çakışmada son-yazan-kazanır
  + yedek kopya (sessiz veri kaybı YASAK — test et)."
- **K-27 Maliyet + board-foot + alışveriş listesi:** "Malzemeye maliyet alanı; plan başına
  toplam + board-foot; eksik stok için alışveriş listesi PDF'i."
- **K-28 Atölye modu v2:** "Adım-adım kesim rehberi: cutSequence'ı interaktif akışa bağla,
  ilerleme workshopProgress'e; Tezgâh Modu tam spec (docs/12 §7)."
- **K-29 Etiket baskısı:** "QR'lı parça etiketleri, Avery şablonları (5160/5163), AirPrint."

**Kapı-2 sonrası (v1.2):**
- **K-30 Android/Skip kurulumu:** "docs/06 §1-2'yi oku. Skip Fuse toolchain kur; apps/android
  hedefini aç; CutCore+CutModels'in Android'de derlendiğini ve TÜM golden vektörlerin
  Android emülatörde bit-eşit geçtiğini kanıtla (parite raporu)."
- **K-31 Android UI uyarlaması:** "SkipFuseUI köprüsüyle ekranları derle; Compose tarafında
  kırılan bileşenleri listele, docs/13'e Android-notları bölümü ekle; Material ayarları
  (geri tuşu, tipografi eşlemesi)."
- **K-32 Play Billing + mağaza:** "Play Billing (yeni %10 düzeni) entegrasyonu + Play metadata
  + kapalı test track. Şeffaf-fatura listesi Android'de de kanıtlanır."
- **K-33 Çok-platform lisans (v2):** "docs/06 §5 v2: Supabase licenses; mağaza-içi alımların
  e-postaya bağlanması; mobil platformlar arası tanıma (30 gün offline grace); fiyat paritesi."

## ACİL DURUM PROMPTLARI

**A-1 · Regresyon:** "Şu golden vektörler kırıldı: [liste]. Önce hangi commit'in kırdığını
bisect ile bul; davranış değişikliği KASITLI mı spec'e karşı kontrol et; değilse düzelt,
kasıtlıysa R-4 akışını uygula."
**A-2 · App Review reddi:** "Ret metni: [yapıştır]. Guideline maddesini docs/02 §4 ve docs/10
§6'ya karşı analiz et; itiraz mı düzeltme mi öner; gerekli değişikliği tek diff'te hazırla."
**A-3 · Kötü yorum dalgası:** "Şu tema tekrar ediyor: [tema]. Kök neden analizi; hotfix mi
iletişim mi; yorum yanıt şablonu + düzeltme planı."
**A-4 · Performans şikâyeti:** "Şu cihazda yavaşlık: [model/senaryo]. Reprodüksiyon testi yaz,
Instruments profili al, docs/04 §6 bütçesine karşı ölç; optimizasyonu ölçümle kanıtla."

---
**Not:** Bu kitap docs/'a `17_PROMPT_KITABI.md` olarak girer (önerilen gelecek dokümanlar
kayar: analitik=18, gizlilik=19, metadata=20, SEO=21, destek=22). Promptlar spec değiştikçe
Cuma senkronunda (R-2) güncellenir — kitap da canlı belgedir.
