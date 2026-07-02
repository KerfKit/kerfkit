# 16 — El Kitabı (Ahmet için: nasıl başlarım, nasıl yürütürüm)

> Bu dosya SANA yazıldı — diğer dokümanlar Fable 5'in tüketmesi için, bu senin okuma kılavuzun.
> Repo'ya ekle: `git add docs/16_EL_KITABI.md && git commit -m "docs: el kitabı"`

## 1. Büyük resim (30 saniyede)

Kerf = kesim planlayıcı. 12 haftada iOS launch; para modeli tek-seferlik lifetime ($99.99,
founding $49). Senin rolün: **yönetmen** — karar verir, seçer, onaylar. Fable 5'in rolü:
**usta kalfa** — spec'ten kod/tasarım üretir, test eder, raporlar. Anayasa: kod değil spec
birincildir; doğrulanamayan hiçbir şey sevk edilmez; non-goals listesi kutsaldır.

## 2. İki çalışma alanın var — karıştırma

- **Claude Code (Mac, repo içinde):** kod + tasarım-mockup + testler + commit'ler.
  Neden: dosya sistemi, Xcode, git hep orada.
- **Cowork (burası):** araştırma, pazarlama içeriği, rakip takibi, raporlar, App Store
  metinleri, yeni ürün planlaması. Neden: paralel ajanlar ve web araştırması burada güçlü.
- Köprü: Cowork'te üretilen her kalıcı çıktı repo'nun `docs/`una taşınır (sen commit'lersin
  ya da GitHub bağlantısıyla ben eklerim). Tek gerçek kaynak repo'dur.

## 3. İlk hafta — bugünden itibaren sırayla

1. **Doğrulama (10 dk):** Mac'te `cd kerf && swift test` → 8 test yeşil. `node tools/gen-tokens.mjs`
   → "62 token" çıktısı. CI'ın GitHub Actions'ta yeşil olduğuna bak.
2. **G-0.3 isim kararı (30 dk, SEN):** "kerf" için App Store/Play araması + USPTO/EUIPO
   sınıf-9 + domain bak (docs/11 §0'daki kontrol listesi). Karar notunu `docs/NAME.md`e yaz.
3. **İlk kod oturumu (Fable 5):** aşağıdaki Oturum-1 promptunu aynen ver.
4. **İlk tasarım oturumu (Fable 5):** Oturum-D1 promptu (ikon varyantları).
5. **Landing kararları (SEN):** founding fiyat $49/300 koltuk onayı + Stripe hesabı aç.

## 4. Haftalık ritmin (her hafta aynı)

- **Pazartesi (30-45 dk):** docs/03'ten bu haftanın 3-5 görevini seç. Kural: 1 inşa odağı +
  1 hafif GTM işi. Kendine yaz: "bu hafta bitince şunu göreceğim: …".
- **Salı-Perşembe:** görev başına BİR Fable 5 oturumu (bkz. §5). Günde 2-4 oturum idealdir;
  oturumlar arası `/clear`.
- **Cuma (1 saat):** `swift test` + uygulamayı elle kurcala + spec senkronu (değişen kararları
  docs'a işlet) + haftalık kapanış notu (bitti / sıradaki / öğrendik).
- Yeni fikir geldiğinde: ASLA o hafta yapma → docs/03'ün sonuna "v1.1+ aday" olarak ekletip unut.

## 5. Bir Fable 5 KOD oturumu nasıl açılır (reçete)

1. Bağlam: CLAUDE.md otomatik; sen yalnız İLGİLİ spec bölümünü + TEK görevi işaret et.
2. Önce plan istet (Plan Mode) → planı OKU → onayla → implementasyon.
3. Bitişte iste: test çıktısı + değişen dosya listesi + "diff'i tek cümlede anlat".
4. Diff'i kendin de gözden geçir (anlamadığın kodu merge etme — Willison kuralı).
5. Kapanış notunu al: "Bitti: … / Sıradaki: … / Spec'e işlenecek: …".

**Hazır oturum promptları (ilk beşi):**
- **Oturum-1 (E1-S1a):** "CLAUDE.md ve docs/04 §3'ü oku. E1-S1a'yı uygula: serbest-dikdörtgen
  ağacı + Best-Area-Fit yerleştirme (kerf'siz basit hal). Önce Tests'e kırmızı test yaz
  (docs/03 E1-S1 AC-1..4), sonra implement et. Double görürsen dur. Bitince test çıktısını yapıştır."
- **Oturum-2 (E1-S1b):** "docs/04 §5'e göre guillotine-geçerlilik doğrulayıcısını yaz ve
  001 no'lu golden vektörün expected alanlarını doldurup pending:false yap. Hash üretimini
  FNV-1a ile docs/04 §5'teki alan sırasına birebir uy."
- **Oturum-3 (E1-S2):** "docs/04 §3 kerf+trim modelini uygula; docs/03 E1-S2 AC'lerini testle;
  002 vektörünü tamamla + kerf uç-değer (0 ve 12mm) vektörleri ekle."
- **Oturum-4 (E1-S3):** "Damar kilidi (rotation:fixed) — docs/03 E1-S3; 'yalnız döndürünce
  sığan fixed parça unplaced+neden döner' senaryosunu vektörle kanıtla."
- **Oturum-D1 (ikon):** "docs/11 §4 + docs/15 §3'ü oku. Kerf işareti için 5 katmanlı-SVG
  varyantı üret (kerf-çizgisi/V-kertik/çizecek-izi aileleri); her biri assets/icon/ altına;
  29pt küçültme önizlemesi için tek sayfalık HTML kontakt-tabaka da yaz."

**Tasarım (mockup) oturumu:** docs/15 §2'deki üçlü döngü — üretim promptu orada hazır;
senin işin tarayıcıda varyant seçmek. Seçimde 10 saniye kuralı: hangisi ustaya "aletim" dedirtiyor?

## 6. Neye SEN karar verirsin (devretme)

İsim/marka onayı · fiyat ve founding koşulları · mockup seçimi · paywall metni · launch günü ·
kill/park kararları (kapı verileriyle) · her merge (diff okuyarak). Gerisi delege.

## 7. Kapılar (ezberle)

- **Cüzdan testi (H−8→−4):** ≥500 ziyaretçi, fiyat-sonrası niyet ≥%1.5-2 → devam; <%0.7 →
  mesaj/fiyat revizyonu.
- **Kapı-1 (launch+30g):** sayfa→install ≥%5 · install→ilk-optimizasyon ≥%50 · puan ≥4.5.
- **Kapı-2 (+90-120g):** aylık net ≥$1.000 VE ≥%20 büyüme → Android/Web yolu açılır.
- Öldürme kriteri docs/01 §8'de. Kapı eşiği lastikleşmez; erteleyeceğine küçült.

## 8. Sık düşülen 5 tuzak (bunlara düşme)

1. Spec'i atlayıp "hızlıca kodlayıver" demek → 2 hafta sonra çelişen kod yığını.
2. Aynı oturuma 3 görev sıkıştırmak → talimat kalabalığı, kalite düşer.
3. Paywall/fatura metnini Fable'a bırakmak → 08 §4 listesi SENİN imzanla girer.
4. Yorumları görmezden gelmek → her yorum 24 saat içinde yanıt (rakiplerin 1★ nedeni sessizlik).
5. "Şu özelliği de ekleyeyim" → non-goals (docs/01 §5 WON'T) duvarına çarptır.

## 9. Takıldığında

- Kod takıldı → aynı oturumda debelenme; `/clear` + görevi daralt + taze oturum.
- Karar takıldı → docs'ta ilgili bölümü aç; yoksa bu bir "açık soru"dur → docs/01 §7'ye ekle,
  Cowork'te bana araştırt.
- Motivasyon takıldı → Cuma notlarını oku: iki haftada nereden nereye gelindiğini görürsün.

## 10. Dokümantasyon bakım sözleşmesi

Spec canlıdır: her Cuma, hafta içinde alınan kararlar docs'a işlenir; kod ile docs çelişik
kalamaz. Yeni dokümanlar geldikçe (17+ analitik planı, 18 SEO brief'leri, gizlilik politikası…)
00_INDEX tablosuna satır eklenir. Launch öncesi zorunlu eksikler bu kitabın ekinde listeli —
sırası geldiğinde Cowork'te üretilecekler.
