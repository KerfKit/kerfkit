# 07 — UI/UX Akışları (iOS v1)

> İlke: mobil-öncelikli; rakiplerin "mobile'a sıkıştırılmış masaüstü" hatasının tersi.
> Her ekran bölümü tek Fable-5 oturumuna bağlam olarak verilebilir.

## 1. Bilgi mimarisi

```
TabView yok — tek yığın (proje-merkezli):
Projeler Listesi → Proje Detayı (3 sekme: Parçalar | Stok | Plan) → Atölye Modu (tam ekran)
Ayarlar: liste ekranından dişli.
```

## 2. Ekranlar

### E-1 Projeler Listesi
- Kartlar: proje adı, malzeme rozetleri, son plan özeti (n levha · %x atık), tarih.
- Boş durum: "İlk projeni oluştur" + **"Örnek projeyi dene"** (aktivasyon garantisi — tek dokunuş
  dolu proje + otomatik ilk optimizasyon; onboarding'in kalbi).
- Ücretsiz katman: 2 kayıtlı proje; 3.'de nazik paywall (silme/arşivleme seçeneği sunarak — asla köşeye sıkıştırma).

### E-2 Parçalar sekmesi (EN KRİTİK EKRAN — E4-S2)
- Tablo: ad · G × Y · adet · malzeme · damar kilidi ikonu · bant rozetleri.
- **Hızlı giriş akışı:** satır sonunda Return → yeni satır; boyut alanında birim-akıllı klavye;
  imperial modda **kesir pad'i** (1/2 … 63/64 hızlı butonlar + tam sayı).
  Hedef AC: 10 parça yalnız klavyeyle <60 sn.
- Satır kaydırma: çoğalt / sil. Toplu yapıştır: panodan TSV/CSV algıla ("Excel'den yapıştır").
- Bant düzenleyici: parça detayında 4 kenar dokunmatik seçim (görsel dikdörtgen üzerinde).

### E-3 Stok sekmesi
- Hazır kütüphane (yerel pazara göre: 4×8/5×5 ft; 2440×1220, 2800×2070, 3050×1220 mm; çıta boyları).
- Özel stok ekleme; adet; (v1.1) offcut rozetli satırlar en üstte "önce artıkları kullan" anahtarıyla.

### E-4 Plan sekmesi (sonuç)
- Üst kart: levha sayısı · atık % (büyük) · toplam kesim · bant metrajı. Hedef seçici
  (levha/atık/kesim) segment kontrol — değişince anında yeniden hesap.
- Diyagram: Canvas; levha sekmeleri (yatay kaydırma); pinch-zoom; parçaya dokun → vurgula +
  isim/ölçü baloncuğu. Kesim numaraları gösterilebilir (aç/kapa).
- **Bayat sonuç bandı:** girdiler değiştiyse sarı şerit "Girdiler değişti — Yeniden hesapla"
  (gizli menü YASAK — 02 §4/7).
- Paylaş: PDF (diyagram+liste+özet, A4/Letter) · CSV · .cutproj.
- Yerleşmeyen parçalar varsa: kırmızı bölüm, neden + öneri ("stok ekle / damar kilidini gevşet").

### E-5 Atölye Modu (v1 lite — farklılaştırıcı)
- Tam ekran, **ekran uykusu kapalı**, yüksek kontrast, dev tipografi (eldivenli kullanım).
- Kesim sırası listesi: sıradaki kesim en üstte dev kart (Kesim #7: 2440 yönünde, x=600'den) +
  "✓ Kesildi" koca butonu; ilerleme halkası (12/34); geri al.
- İlerleme .cutproj'a yazılır (05 §2 workshopProgress) — yarıda kalıp dönülebilir.

### E-6 Onboarding (3 ekran + örnek proje)
1. "Levhayı gir, parçaları yaz, planı al" (10 sn animasyon)
2. "Kerf, damar, kenar bandı — pro detaylar hazır"
3. "Tek seferlik satın al. Abonelik yok." → "Örnek projeyle dene" CTA (ilk optimizasyonu
   YAŞATMADAN paywall gösterme).

### E-7 Paywall (08 §3-4 kurallarıyla)
- Başlık: fayda ("Sınırsız proje + PDF + atölye modu").
- Üç kutu: **Lifetime $99.99 (manşet, "en popüler")** · Yıllık $39.99 · Hafta sonu $4.99 (72 saat).
- Altında: "Fiyatlar bir kez/dönem başı açıkça yazılır · istediğin an iptal · 14 gün iade" —
  küçük punto oyunu YOK. Restore butonu görünür.

### E-8 Ayarlar
Birim modu · varsayılan kerf/trim · hedef varsayılanı · tema · "Verilerim" (tümünü dışa aktar) ·
gizlilik (analitik opt-out) · destek (e-posta; hedef yanıt <24s) · hakkında/lisanslar.

## 3. Görsel dil

- SF Symbols + sistem renkleri; ahşap-tonu vurgu paleti (amber-700 birincil); karanlık mod gün-1.
- Diyagram: levha=açık zemin, parçalar=malzeme-bazlı pastel + isim etiketi, atık=taralı,
  kerf çizgileri ince koyu. Renk-körlüğü: deseni renkten bağımsız oku (etiket + doku).
- Dynamic Type tam destek; diyagramın VoiceOver özeti: "Levha 1: 12 parça, %8.4 atık…".

## 4. Mikro-metinler (ton: usta-dili, abartısız)

- Boş plan: "Henüz plan yok. Parçaları girdiysen tek dokunuş kaldı."
- Yerleşmeyen parça: "Bu 3 parça stok yetmediği için yerleşmedi — stok ekle veya boyutları kontrol et."
- Paywall reddi sonrası: sessizlik (nagging yok; bir sonraki doğal sınıra kadar sorulmaz).

## 5. Fable-5 oturum talimatı (UI işleri)

- Her ekran ayrı oturum; bu dosyanın yalnız ilgili bölümü + 03'teki ilgili hikâye verilir.
- Snapshot testleri: her ekranın light/dark + küçük/büyük Dynamic Type dört görüntüsü.
- Erişilebilirlik denetimi ekran DoD'sine dahil (E6-S2 toplu geçişten önce ekran-bazlı).
