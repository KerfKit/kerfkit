# 19 — Ahmet'in Kontrol Listesi (canlı belge — her oturumda güncellenir)

> İnsan içindir. Fable 5 geliştirmeyi bitirdikçe burada yalnız SENİN yapabileceğin
> adımlar kalır. Tamamlananlar tarihle işaretlenir, yenileri eklenir.
> Son güncelleme: 3 Tem 2026 gece (TR onayı işlendi).

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

- [ ] **GitHub branch protection için plan** — repo private + Free plan'da koruma
  kuralı yok (K-17'de 403). Seçenek: GitHub Pro/Team'e geç YA DA repo'yu public yap
  (motor açık kaynak stratejisi ayrı karar). O zamana dek kural süreçte: CI 'pass'
  okunmadan merge yok (hafıza + CLAUDE.md).

- [ ] **Buttondown hesabı** (kullanıcı adı: kerfkit; gönderen: hello@kerfkit.app) —
  açılınca söyle: landing + lite'taki e-posta formlarını embed-subscribe'a bağlayacağım.
- [ ] **Sosyal @kerfkit rezervasyonları:** X, Instagram, YouTube, TikTok, Pinterest,
  Reddit u/kerfkit. Alınamazsa yedek: @kerfkitapp. (thekerfapp.com rakip — benzer görünme.)

## 🟢 Launch penceresinde

- [ ] P-4 Privacy/Terms taslağını ONAYLA (ben yazacağım; hukuki-tavsiye-değildir notuyla
  sana gelecek — launch-blocker).
- [ ] Founding fiyat/koltuk sayısı son onayı (docs/08-09: $49 → $99.99, 300 koltuk).
- [ ] **Founding penceresini AÇ (K-16 hazır):** kerfkit.app yayına girince
  `founding.json`'da `"active": true` + `futurePrice` yaz; `claimed` sayacını mağaza
  satış verisinden güncelle (sahte kıtlık yasak — docs/08 §4). Kapatmak = `active: false`;
  uygulama her açılışta çeker, kalıcı fiyat görünümüne kendiliğinden döner.
- [ ] TestFlight beta davetlileri (20-30 marangoz; forum/tanıdık) — K-20'de liste lazım.
- [ ] (Opsiyonel, launch sonrası) USPTO/EUIPO sınıf-9 "KerfKit" başvurusu.

## ✅ Tamamlananlar

- [x] **T1 anadil onayı (DE FR ES IT)** — 4 Tem 2026 (Ahmet; katalog "translated" damgalı)
- [x] **TR çeviri onayı** — 3 Tem 2026 (Ahmet; String Catalog TR seti onaylı — docs/18 §5 üslup kuralına göre)
