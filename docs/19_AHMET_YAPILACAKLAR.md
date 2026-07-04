# 19 — Ahmet'in Kontrol Listesi (canlı belge — her oturumda güncellenir)

> İnsan içindir. Fable 5 geliştirmeyi bitirdikçe burada yalnız SENİN yapabileceğin
> adımlar kalır. Tamamlananlar tarihle işaretlenir, yenileri eklenir.
> Son güncelleme: 4 Tem 2026 akşam (K-17 matris yeşil; mağaza-dışı kuyruk bitti).

> **Sıra kararı (Ahmet, 4 Tem 2026):** mağaza kayıtları EN SONA alındı — mağaza-bağımlı
> işler (K-19/K-20, huni gerçek rozetleri, ASO yayını) o zamana park; geri kalan her şey sürer.

## 🔴 Bloklayanlar (geliştirme bunlara dayanınca durur)

- [ ] **App Store Connect'te uygulama kaydı** — ad "KerfKit", bundle `app.kerfkit.KerfKit`
  (Xcode projesiyle birebir). K-20 TestFlight ve K-19 mağaza görselleri buna bağlı.
- [ ] **Mağaza URL'leri** — App Store/Play kayıtları oluşunca iki mağaza linkini bana ver;
  web hunisindeki "yakında" rozetlerini gerçek rozet+QR'a çevireceğim (W-3).
  Not: 6 dilin TÜM mağaza metinleri hazır (apps/ios/fastlane/metadata + apps/android/metadata,
  limit bekçisi CI'da) — kayıtlar açılınca fastlane deliver ile tek geçişte yüklerim (L-4 ✓).
- [ ] **Google Play Console'da uygulama kaydı** — ad "KerfKit", paket `app.kerfkit`
  (E9 Android hattı buna bağlı; K-31 başlamadan şart değil ama yaklaşıyor).
- [ ] **kerfkit.app domaini** (birincil; .app'te HTTPS zorunlu — sorun değil) +
  kerfkit.com (koruma). Registrar önerisi: Cloudflare Registrar ya da Porkbun.
- [ ] **hello@kerfkit.app e-postası** — en kolay: Cloudflare Email Routing (ücretsiz
  yönlendirme); gönderim için iCloud+ özel domain ya da Fastmail.

## 🟡 Yakında gerekecek

- [ ] **LICENSE kararı** — repo 4 Tem'de PUBLIC oldu ve LICENSE dosyası yok =
  "tüm hakları saklı" (ticari ürün için savunulabilir varsayılan). Karar senin:
  böyle mi kalsın, yoksa motor (CutCore) ayrı lisansla mı açılsın? Söyle, uygularım.
- [ ] **Buttondown hesabı** (kullanıcı adı: kerfkit; gönderen: hello@kerfkit.app) —
  açılınca söyle: landing + lite'taki e-posta formlarını embed-subscribe'a bağlayacağım.
- [ ] **Sosyal @kerfkit rezervasyonları:** X, Instagram, YouTube, TikTok, Pinterest,
  Reddit u/kerfkit. Alınamazsa yedek: @kerfkitapp. (thekerfapp.com rakip — benzer görünme.)

## 🟢 Launch penceresinde

- [ ] **P-4 Privacy/Terms taslağını ONAYLA — TASLAK HAZIR: docs/20** (4 Tem; Privacy +
  Terms EN + App Store "Data Not Collected" etiket tablosu; hukuki-tavsiye-değildir.
  İki boşluk senin: yürürlük tarihi + Terms §7 yargı bölgesi. Onay sonrası web
  sayfaları + Ayarlar linklerini ben eklerim — launch-blocker).
- [ ] Founding fiyat/koltuk sayısı son onayı (docs/08-09: $49 → $99.99, 300 koltuk).
- [ ] **Founding penceresini AÇ (K-16 hazır):** kerfkit.app yayına girince
  `founding.json`'da `"active": true` + `futurePrice` yaz; `claimed` sayacını mağaza
  satış verisinden güncelle (sahte kıtlık yasak — docs/08 §4). Kapatmak = `active: false`;
  uygulama her açılışta çeker, kalıcı fiyat görünümüne kendiliğinden döner.
- [ ] TestFlight beta davetlileri (20-30 marangoz; forum/tanıdık) — K-20'de liste lazım.
- [ ] (Opsiyonel, launch sonrası) USPTO/EUIPO sınıf-9 "KerfKit" başvurusu.

## ✅ Tamamlananlar

- [x] **Repo org'a taşındı + PUBLIC yapıldı** — 4 Tem 2026 (KerfKit/kerfkit; branch
  protection AKTİF: test check zorunlu, admin dahil — GitHub plan maddesi kapandı)
- [x] **Paywall A varyantı seçimi** — 4 Tem 2026 (Ahmet; K-15 bu seçimle yayında)

- [x] **T1 anadil onayı (DE FR ES IT)** — 4 Tem 2026 (Ahmet; katalog "translated" damgalı)
- [x] **TR çeviri onayı** — 3 Tem 2026 (Ahmet; String Catalog TR seti onaylı — docs/18 §5 üslup kuralına göre)
