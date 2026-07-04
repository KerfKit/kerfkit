# 20 — Privacy Policy + Terms of Use TASLAĞI (P-4 — launch blocker)

> **HUKUKİ TAVSİYE DEĞİLDİR.** Bu taslak Fable 5 tarafından docs/06 §6 + gerçek veri
> modeline göre yazılmıştır; yayına girmeden önce Ahmet onayı şart (docs/19), mümkünse
> bir hukukçuya okutulması önerilir. Yayın yeri: kerfkit.app/privacy + /terms
> (onay sonrası Astro sayfaları — bu PR'da YOK, bilinçli).

> **Dürüstlük notu:** docs/06 §6 "TelemetryDeck opt-out analitik" PLANINI anar; v1
> uygulamada analitik YOKTUR (M-8 "collects no data" metni gerçektir). Taslak bugünkü
> gerçeğe göre yazıldı; analitik eklenirse §"Changes" uyarınca politika güncellenir
> ve App Store etiketi yeniden beyan edilir.

---

## A. Privacy Policy (EN taslak)

**KerfKit Privacy Policy** · Effective: [launch date]

**The short version: KerfKit collects no personal data.** Your projects, parts,
and cut plans live on your device. There are no accounts, no analytics, no ads,
and no third-party SDKs that see your data. The app works fully offline.

**1. What stays on your device.** Everything you create in KerfKit — projects,
parts, sheets, settings, cut plans — is stored locally on your device (and in
your device backups if you have backups enabled). We cannot see it, and we
never transmit it.

**2. What the app fetches from the network.** On launch, KerfKit may fetch one
small configuration file from kerfkit.app (for example, whether the founding
price window is open). This is a plain file download; it carries no personal
data and no identifiers. Like any web request, our hosting provider may briefly
process your IP address in standard server logs to deliver the file. If the
request fails or you are offline, the app simply continues.

**3. Purchases.** Purchases are processed entirely by Apple (App Store) or
Google (Play). We receive no payment details and no identity. The purchase
entitlement is verified on your device via the store's own APIs. Refunds follow
the store's policies.

**4. Crash reports.** If you have opted in to share diagnostics with developers
in your device settings, Apple/Google may share anonymized, aggregated crash
information with us. It contains no project content and no identity. We do not
run our own crash-reporting SDK.

**5. Support e-mail.** If you write to hello@kerfkit.app, we see your e-mail
address and whatever you include. We use it only to answer you, and we do not
add you to any list.

**6. Newsletter (website only).** If you subscribe on kerfkit.app, your e-mail
is stored by our newsletter provider until you unsubscribe. The app itself never
asks for an e-mail.

**7. Children.** KerfKit is a woodworking utility, not directed at children,
and collects no data from anyone.

**8. Your rights (GDPR/CCPA and similar).** Because we hold no personal data
about app users, there is usually nothing for us to access, correct, or delete —
your data is on your device and under your control. For support e-mails or
newsletter data, write to hello@kerfkit.app and we will delete them.

**9. Changes.** If a future version ever adds optional, privacy-respecting
analytics, it will be off-by-default or clearly disclosed, this policy will be
updated first, and the App Store privacy label will be re-declared. The current
version collects nothing.

**Contact:** hello@kerfkit.app

---

## B. Terms of Use (EN taslak)

**KerfKit Terms of Use** · Effective: [launch date]

**1. What KerfKit is.** KerfKit is a cut-list optimization tool for woodworking.
It computes cutting layouts from the dimensions you enter.

**2. License.** We grant you a personal, non-transferable license to use the
app on devices you own, under the store's standard EULA (Apple's Licensed
Application EULA / Google Play terms). You may not resell, decompile beyond
what the law allows, or misrepresent the app as your own.

**3. Purchases and refunds.** Pro features are one-time purchases, yearly
subscriptions, or a non-renewing 72-hour pass, charged by the store. The yearly
plan renews unless cancelled in your store account settings; the Weekend Pass
never renews. Refunds are handled by the store; beyond that we honor a 14-day
support promise — write to us and we will help.

**4. Measure twice, cut once — your responsibility.** Cut plans are
calculations, not workshop supervision. Verify dimensions, kerf, and material
before cutting. Woodworking machinery is dangerous; follow your tools' safety
instructions. To the maximum extent permitted by law, KerfKit is provided
"as is" and we are not liable for material waste, tool damage, or injury
arising from use of the app's output.

**5. Founding pricing.** Founding-price availability and the seat counter shown
in the app reflect real sales data; the later regular price is labeled as the
future price. No artificial scarcity.

**6. Termination.** You may stop using the app anytime; your local data stays
on your device until you delete the app. We may terminate the license if you
breach these terms.

**7. Governing law.** [Ahmet: yargı bölgesi seçimi — şirket kurulan ülke;
taslakta boş bırakıldı.]

**Contact:** hello@kerfkit.app

---

## C. App Store gizlilik etiketi eşlemesi (P-4 istenen tablo)

| Apple kategori | Beyan | Gerekçe (gerçek davranış) |
|---|---|---|
| Contact Info | **Collected DEĞİL** | Uygulama e-posta/ad istemez; destek e-postası kullanıcı-başlatmalı, uygulama dışı |
| Health & Fitness / Financial / Location / Sensitive | **Collected DEĞİL** | İlgili API kullanımı yok |
| User Content (projeler/parçalar) | **Collected DEĞİL** | Yalnız cihazda (SQLite); hiçbir sunucuya gitmez |
| Identifiers (User/Device ID) | **Collected DEĞİL** | Hesap yok; IDFA/IDFV okunmaz; ATT gereksiz |
| Purchases | **Collected DEĞİL** | StoreKit cihaz-içi entitlement; ödemeyi Apple işler, bize kimlik gelmez |
| Usage Data / Analytics | **Collected DEĞİL** | Analitik SDK yok (v1); Apple'ın opt-in toplu çökme verisi Apple beyanı kapsamında |
| Diagnostics | **Collected DEĞİL** | Kendi crash SDK'mız yok; MetricKit eklenirse (K-20) yeniden değerlendirilir → muhtemelen "Diagnostics — Not linked to you" |
| **Sonuç etiketi** | **"Data Not Collected"** | founding.json GET'i kimliksiz statik dosya indirmesi; Apple tanımında "toplama" oluşturmaz (sunucu erişim logu geçici/teşhis) |

Play Console "Data safety" eşlemesi aynı içerikle: "No data collected/shared";
güvenlik uygulamaları: veriler aktarımda TLS (yalnız founding.json), silme talebi
hello@ üzerinden.

## D. Onay + yayın akışı

1. **Ahmet onayı** (docs/19 launch penceresi maddesi) — metin değişiklikleri buraya işlenir.
2. Onay sonrası: apps/web'e `/privacy` + `/terms` Astro sayfaları (EN; T1 çevirileri
   L-5 ile) + iOS Ayarlar'a linkler + App Store Connect gizlilik beyanı (mağaza fazı).
3. MetricKit (K-20) eklenirse: §A.4 + etiket tablosu güncellenir, yeniden onay.
