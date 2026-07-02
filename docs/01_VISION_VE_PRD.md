# 01 — Ürün Vizyonu ve PRD (CutWise)

## 1. Problem cümlesi

Levha malzeme (kontrplak, MDF, sunta) pahalı ($80-100/plaka huş kontrplak) ve elle kesim planı
yapmak hem israfa hem hataya yol açar. Web'deki lider araç abonelik dayatıyor, ödeme sonrası
bozuluyor ve iOS'ta hiç yok; iOS klonları öğrenmeye izin vermeyen deneme tuzaklarıyla dolu;
masaüstü araçlar Windows'a hapsolmuş. **Hobici ve yarı-pro marangoz, güvenilir, tek-seferlik
ödenen, cebinde ve atölyesinde çalışan bir kesim planlayıcıdan yoksun.**

## 2. Birincil persona ve JTBD

**Persona: "Garaj Atölyecisi" (birincil).** 30-65 yaş, ABD/Kanada/UK/AU/DACH; hafta sonu mobilya/
dolap projesi yapar; haftada ≥1 levha keser; table saw veya track saw sahibi ($500-3.000 alet
yatırımı); r/woodworking-YouTube ekosisteminde yaşar; iPhone kullanıcısı ağırlıklı; aboneliğe
alerjik, tek-seferlik ödemeye alışkın (alet kültürü: bir kez al, ömür boyu kullan).

- **JTBD-1:** "Yeni bir projeye başlarken, parça listemi kaç plakaya sığdıracağımı ve nasıl
  keseceğimi bilmek istiyorum ki fazla malzeme almayayım ve israf etmeyeyim."
- **JTBD-2:** "Atölyede kesim yaparken, sırayla neyi keseceğimi net görmek istiyorum ki hata
  yapıp plakayı çöpe atmayayım."
- **JTBD-3:** "Projeden artan parçaları hatırlamak istiyorum ki bir sonraki projede önce onları
  kullanayım."

**İkincil persona: "Küçük Atölye" (v1.1+ hedefi).** Tek-iki kişilik dolap/mobilya atölyesi;
müşteri teklifi + maliyet hesabı ister; etiket basar. v1'de hedeflenmez ama veri modeli bunu
dışlamayacak şekilde kurulur.

## 3. Çözüm hipotezi

Tek çekirdek motorla (saf Swift, cihaz-içi, çevrimdışı) iOS+Android+Web'de çalışan; 2D panel ve
1D doğrusal kesimi tek uygulamada birleştiren; kerf/damar/kenar bandını doğru modelleyen; sonucu
etkileşimli "atölye modu"yla kesim anına taşıyan; **tek-seferlik lifetime fiyatla** satılan bir
kesim planlayıcı, 12 ay içinde iOS'ta "cut list" aramasının varsayılan sonucu olur.

## 4. North Star ve metrikler

- **North Star:** haftalık tamamlanan optimizasyon sayısı (WCO — Weekly Completed Optimizations).
- Destek metrikleri: install→ilk-optimizasyon ≥%50 (aktivasyon) · D7 retention ≥%20 ·
  ücretsiz→ödeme ≥%3-5 · mağaza puanı ≥4.7 · sayfa→install ≥%5.
- İş hedefi (3. Dalga raporundan): ay-12 aylık net $1.2K (kötü) / $7K (baz) / $22K (iyi).

## 5. Kapsam — MoSCoW

### MUST (v1.0 — bunlarsız launch yok; "masa bedeli", kanıt: 02 §2)
- 2D panel optimizasyonu: giyotin kısıtı, kerf, trim (kenar temizleme payı), çoklu levha, çoklu malzeme
- 1D doğrusal optimizasyon (çıta/pervaz/boru) — **aynı uygulamada** (lider web'de yok!)
- Parça başına damar yönü kilidi (rotasyon kısıtı)
- Kenar bandı hesabı (kenar-başına seçim, fire payı)
- Birimler: metrik (mm) + ondalık inç + **imperial kesir (1/64″ çözünürlük)**
- Sınırsız parça/hesaplama (ücretsiz katmanda bile hesaplama SAYACI YOK — 02 §4/1 gereği)
- Kesim diyagramı (numaralı kesim sırası) + israf % + levha sayısı özeti
- PDF export + CSV import/export
- Proje kaydet/aç; tamamen çevrimdışı çalışma
- Stok kütüphanesi: yaygın levha ölçüleri hazır (4×8ft, 5×5ft baltic birch, 2440×1220, 2800×2070…)

### SHOULD (v1.1 — launch sonrası ilk 90 gün)
- Offcut/artık envanteri (plan bitince kullanılabilir artıklar stok havuzuna düşer)
- Board-foot + maliyet hesabı; proje bazlı **kereste alışveriş listesi**
- Etiket baskısı (QR'lı, Avery şablonları)
- Atölye modu v2: adım adım kesim işaretleme, kalan-kesim sayacı, koca-buton UI
- "En az siper ayarı" (stripe/shared-cut) optimizasyon önceliği
- Proje şablonları; iCloud senkron (iOS)

### COULD (v1.2+)
- DXF export; SketchUp/OpenCutList CSV içe aktarımı (paylaşım-hedefi)
- Fotoğraftan parça listesi (LLM-OCR ile el yazısı cut list → tablo) — "wow" özelliği
- Sesli dikte girişi (SmartCut kaldırınca kullanıcı 1★ verdi — talep kanıtlı)
- Offcut QR etiketi (artığa yapıştır → sonraki projede taratınca stoğa girer)
- Android (Skip Fuse) ve tam Web sürümü; Supabase senkron + e-posta lisans anahtarı

### WON'T — Non-goals (v1'de BİLİNÇLİ yapılmayacaklar; scope-creep freni)
- Müşteri teklifi/faturalama (MaxCut/CutList Plus alanı — ikincil persona v1.1+)
- CNC/nesting (dikdörtgen-dışı şekiller) — ayrı pazar, ayrı motor
- 3D tasarım/görselleştirme (SketchUp'ın işi; biz kesim planıyız)
- Topluluk/sosyal özellikler; hesap zorunluluğu; reklam (asla)
- Donanım entegrasyonu (testere vb.) — saf yazılım kuralı

## 6. NFR'ler (fonksiyonel olmayan gereksinimler)

- **Performans:** 500 parçaya kadar heuristik sonuç <2 sn (iPhone 12 ve üstü); iyileştirme turu
  arka planda, iptal edilebilir. (Dayanak: 04 §4 — Jylänki benchmarkları.)
- **Determinizm:** aynı girdi → her platformda bit-eşit aynı sonuç (golden vektörler; 04 §5).
- **Çevrimdışı:** motor %100 cihaz-içi; ağ yalnız senkron/lisans içindir, hiçbir hesaplama için gerekmez.
- **Veri güvenliği:** kullanıcı verisi cihazda; analitik anonim ve opt-out; hesap zorunluluğu yok.
- **Erişilebilirlik:** Dynamic Type, VoiceOver etiketleri diyagram özetinde; min dokunma hedefi 44pt;
  atölye modunda yüksek kontrast + dev butonlar (eldivenli kullanım).
- **Yerelleştirme:** v1 EN; string'ler baştan lokalize-edilebilir; v1.1 DE (DACH pazarı), sonra TR/FR/ES.

## 7. Varsayımlar ve açık sorular

- V: iOS klonlarının 4.3★'ta tutunması, iyi yürütülen ürünün 4.7+ alacağını gösterir.
- V: "cut list optimizer" jenerik aramasının App Store trafiği markaya değil kategoriye aittir.
- A1 (açık): "CutWise" adı ticari marka/App Store'da müsait mi? → Backlog G-0.3, hafta 1.
- A2 (açık): founding-lifetime ön-satışında $49 dönüşümü ≥%1.5-2 çıkacak mı? → GTM hafta −8 testi;
  çıkmazsa fiyat/mesaj revizyonu (kill değil — talep başka kanıtlarla zaten güçlü).
- A3 (açık): Web-lite hesaplayıcının lead-gen dönüşümü (e-posta bırakma) ≥%5 mi? → hafta −6 ölçümü.

## 8. Başarı kapıları (12_RISKLER yerine burada — tek kaynak)

- **Kapı-1 (launch+30g):** sayfa→install ≥%5 VE install→ilk-optimizasyon ≥%50 VE puan ≥4.5.
  Aktivasyon <%35 ise: onboarding'e örnek-proje zorunlu ilk-deneyim eklenir (backlog E7-S3).
- **Kapı-2 (launch+90-120g):** aylık net ≥$1.000 VE aylık ≥%20 büyüme VE founding 300 kapanmış.
  Altındaysa: Android/Web hızlandırılmaz; ASO+içerik iterasyonuna 4 hafta daha.
- **Öldürme kriteri (RISKS):** ay-6'da aylık net <$400 VE büyüme <%10 VE 2 iterasyon tükendi →
  ürün bakım moduna alınır, portföyün 2. sırası (Bowling) öne çekilir.
