# 02 — Rakip Analizi ve Liderlik Matrisi (2 Temmuz 2026 verisi)

## 1. Rakip envanteri (kanıtlı)

| Rakip | Platform | Fiyat | Güç | Belgeli zaaf |
|---|---|---|---|---|
| **cutlistoptimizer.com** (lider) | Web + Android (1M+, 4.4★/9.3K) | Abonelik kademeleri + $4.90/3-gün | Marka=jenerik terim; bulut senkron; damar/bant/kerf tam | **iOS YOK**; 1D yok; ücretsizde günde 5 hesap; reklam veri girişini bölüyor; "Pro'ya geçtim, diyagram üretemedi" 1★'ları; iptal/fatura şikâyetleri; 2015 arayüzü |
| **iOS "CutList Optimizer"** (XIALIAOBAO, id6465744401) | iOS/Mac/Vision (4.3★/101) | $4.99/ay–$39.99/yıl | Özellik temposu yüksek: DXF+Excel, offcut→yeni proje, etiket, şablon | "5 ücretsiz deneme" öğrenmeye yetmiyor ("Way too limiting"); yeniden-hesapla butonu gizli; destek günler sürüyor; 1D AYRI uygulamada |
| **SmartCut** (id1579298749) + cutlistevo.com | iOS (4.1★/34) + web | $1.99 Premium; Evo kademeleri + 1-gün pass | 2D+1D birlikte; Evo'da PTX/DXF/QR etiket/teklif | Güncellemeyle sesli dikteyi KALDIRDI (1★); yıllık plan yok talebi; küçük taban |
| **MaxCut** | Windows | Ücretsiz CE + ~$200/yıl | Dolap kütüphanesi, teklif, barkod etiket | Windows-only; dik öğrenme eğrisi; bulut yok |
| **CutList Plus fx** | Windows | $89/$249/$499 tek-sefer | Board-foot+maliyet; tam offline; tek-sefer modeli kanıtlı | "Windows 7/8/10" — güncellenmiyor; Mac/mobil yok (mobil salt görüntüleyici); offcut takibi yok |
| **OptiCutter** | Web | €90-190/yıl (+API €99/ay) | Maliyet-minimizasyonu; 5 birim modu | Native mobil/offline yok; ücretsiz katman gerçek projede tükeniyor |
| **CutListCalc** (2025) | Web | Tamamen ücretsiz | Şablonlar, temiz UI | Damar/bant YOK; offline yok; monetizasyonsuz (sürdürülebilirlik ?) |
| **CutPlan.ai** (2025-26) | Web/PWA | Free 30 hesap/ay; $29/ay veya $9/2-gün | Offcut envanteri; **22 locale hreflang + blog/compare SEO makinesi**; bulut senkron; DXF (Pro); malzeme kütüphanesi | Pahalı abonelik; **native mobil YOK (PWA savunusu yazılı)**; offline yok; kesim talimatı statik liste — teardown 3 Tem 2026, docs/18 §7 |
| Yan referanslar | — | — | OpenCutList (ücretsiz SketchUp eklentisi, GPL); workshop-buddy (siper-ayarı min.) | — |

## 2. Özellik matrisi (V=var K=kısmi –=yok)

| Özellik | CLO web/Andr | iOS CLO | SmartCut/Evo | MaxCut | CLPlus | OptiCutter | CutListCalc | CutPlan | **CutWise hedef** |
|---|---|---|---|---|---|---|---|---|---|
| 2D panel + giyotin | V | V | V | V | V | V | V | V | **V (v1)** |
| 1D doğrusal | – | K (ayrı app) | V | V | V | V | V | – | **V (v1, aynı app)** |
| Damar yönü | V | V | V | V | V | V | – | V | **V (v1)** |
| Kenar bandı | V | V | V | V | K | V | – | V | **V (v1)** |
| Kerf + trim | V | V | V | V | V | V | K | K | **V (v1)** |
| İmperial kesir | V | V | V | V | V | V | K | V | **V (v1)** |
| CSV import/export | V | V | V | V | K | V | – | – | **V (v1)** |
| PDF diyagram | V | V | V | V | V | V | V | V | **V (v1)** |
| Tam offline hesap | K | V | K | V | V | – | – | – | **V (v1) — web rakiplerini nötralize eder** |
| Sınırsız ücretsiz hesap | – (5/gün) | – (5 deneme) | K | K | – | – | V | – (30/ay) | **V (v1) — sayaç YOK** |
| Offcut envanteri | – | V | V | V | – | – | – | V | v1.1 |
| Maliyet + board-foot | – | – | V (Evo) | V | V | V | K | – | v1.1 |
| Etiket (QR/Avery) | K | V | V | V | V | K | – | – | v1.1 |
| Atölye modu (interaktif kesim rehberi) | – | – | – | – | – | – | – | K (statik liste, Pro) | **v1 ✓ — interaktifi KİMSEDE YOK** |
| Çok dilli UI + SEO/ASO | K | – | – | – | – | K | – | **V (22 locale)** | **v1: 6 dil → y1: 20+ (docs/18)** |
| DXF | – | V | V | K | K ($499) | V | – | K (Pro) | **v1.1 (öne çekildi — docs/18 §7)** |
| Foto/ses ile parça girişi | – | – | – (kaldırdı!) | – | – | – | – | – | v1.2 — **wow** |
| **iOS+Android+Web üçlüsü** | – | – | – | – | – | – | – | – | **v1.2 — tek üründe İLK** |

## 3. Liderlik stratejisi (bu matristen çıkan)

1. **Masa bedelini eksiksiz öde (v1 MUST listesi, 01 §5):** damar+bant+kerf+kesir+CSV+PDF —
   bunlar pazarlık değil; eksik olan her satır bir 1★'dır.
2. **Nötralize et:** tam-offline + sınırsız-hesap, web liderinin iki yapısal zaafını (çevrimiçi
   zorunluluğu, günlük sayaç) ve iOS klonunun deneme-tuzağını aynı anda vurur.
3. **Birleştir:** 2D+1D tek uygulamada (lider yapamıyor, iOS klonu iki ayrı uygulamaya bölmüş).
4. **Farklılaş (kimsede yok):** atölye modu — PDF basmak yerine telefonu/iPad'i testere yanına koy;
   kesimleri tek dokunuşla işaretle, sıradaki kesim dev fontla görünsün. Sonra: foto/ses girişi.
5. **Fiyatla kazan:** tek-seferlik model, abonelik-öfkeli pazarda tek başına pazarlama mesajıdır
   (alet kültürüyle uyum: "bir kez al, ömür boyu").

## 4. "ASLA YAPMA" listesi (rakip 1★'larından; launch kapısı)

1. Denemeyi **hesaplama sayısıyla** sınırlama (iOS CLO "5 deneme" öfkesi) → sınır proje/parça
   ekseninde, süre bazlı trial yok, sayaç yok.
2. Ödeme sonrası özelliğin açılmaması / Pro'nun ücretsizden kötü çalışması (Android CLO 1★).
   → Satın alma akışı + restore, golden E2E testiyle her sürümde doğrulanır.
3. Veri girişinin ortasına reklam sokmak → reklam YOK, asla.
4. Veriyi tarayıcı/cihaz çöpüne emanet edip kaybettirmek → otomatik yerel kayıt + export her yerde.
5. Güncellemeyle özellik geri almak (SmartCut sesli-dikte vakası) → özellik kaldırma = major
   sürüm + önceden duyuru + alternatif.
6. İptali/iadeyi zorlaştırmak, faturada sürpriz → şeffaf fatura kontrol listesi (08 §4).
7. Sonucu güncellemek için gizli menü → her girdi değişikliğinde görünür "Yeniden hesapla" durumu
   (bayat sonuç işaretlenir).
8. Platform hapsi + mobilde sıkışan masaüstü UI → mobil-öncelikli tasarım (07).

## 5. Fiyat haritası ve konum (08'de detay)

Rakip bandı: $1.99 Premium (SmartCut) → $39.99/yıl (iOS CLO) → €90-190/yıl (OptiCutter) →
$200/yıl (MaxCut) → $89-499 tek-sefer (CutList Plus). **CutWise: $39.99/yıl VEYA $99.99 lifetime
(manşet) + $4.99 "hafta sonu geçişi" + ücretsiz katman (sınırsız hesaplama, 2 kayıtlı proje,
proje başına 20 parça).** Gerekçe: birebir iOS rakibi $39.99/yıl iken $49.99 ile başlamak yanlış;
lifetime CutList Plus Gold'un ($249) yarısının altında "pro ama tek ödeme" konumuna oturur.

## Kaynaklar
cutlistoptimizer.com · play.google.com/store/apps/details?id=com.cutlistoptimizer ·
apps.apple.com id6465744401, id1579298749 · cutlistevo.com · maxcutsoftware.com ·
cutlistplus.com/purchase · opticutter.com · cutlistcalc.com (+ /blog/cutlistoptimizer-alternative) ·
cutplan.ai · finewoodworking.com/2021/07/20/my-experience-with-cutlistoptimizer-com ·
thenewbiewoodworker.com/articles/cutlistoptimizer
