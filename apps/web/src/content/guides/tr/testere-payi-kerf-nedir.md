---
key: "what-is-kerf"
reviewed: true
title: "Testere Payı (Kerf) Nedir? Levhanızı Yiyen O İnce Çizgi"
description: "Kerf, bıçağın her geçişte talaşa çevirdiği malzemedir. Gerçekte ne kadar, kağıt hesabını neden bozar, kendi bıçağınızınkini nasıl ölçersiniz?"
date: "2026-07-04"
---

Testere payı — İngilizcede *kerf* — bıçağın arkasında bıraktığı boşluktur: her geçişte talaşa dönüşen malzeme. Özenle hesaplanmış bir parça listesinin eksik çıkmasının bir numaralı sebebi de odur.

Her bıçağın bir payı var. Tezgahlı daire testere bıçağı tipik olarak 2,8–3,2 mm alır. İnce bıçaklar 2,4 mm civarındadır; ray testere (track saw) bıçakları 2,2 mm'ye iner. Şerit testere daha az yer; CNC frezesi tam bıçak çapı kadar. Doğru rakam bıçağın üstünde ya da kutusunda yazar — hesabınıza girmesi gereken sayı tahmininiz değil, o rakamdır.

## "Sığması lazımdı" hesabını kerf nasıl bozar?

Diyelim 2100 mm'lik enden 300 mm'lik dört şerit istiyorsunuz. Kağıtta: 4 × 300 = 1200, geriye 900 mm — bol bol yer var, mesele yok.

Şimdi aynı enden **yedi** şerit isteyin: 7 × 300 = 2100 — kağıt "tam sığar" der. Testere başka der: yedi şeridi ayırmak için altı kesim gerekir, 3 mm bıçakla 6 × 3 = 18 mm talaş. 2100 + 18 = sığmıyor; yedinci şerit 282 mm çıkar ya da hurdaya gider.

Kural basit: **yan yana n parça, aralarında n − 1 testere payı ister.** Bu kuralı atlayan her liste, var olmayan parçalar vaat eder.

## Hızlı başvuru tablosu

| Testere / bıçak | Tipik pay |
|---|---|
| Tezgahlı daire testere (standart bıçak) | ~3 mm |
| İnce kerf bıçak | ~2,4 mm |
| Ray testere (track saw) | ~2,2 mm |
| El daire testeresi | ~2,5–3 mm |
| Şerit testere | ~0,5–1 mm |
| CNC freze | bıçak çapı (6–12 mm yaygın) |

Bunlar tipik aralıklar — marka markaya, bileme bilemeye değişir. Tabloyu başlangıç sayın, kendi bıçağınızı ölçün.

## Kendi payınızı ölçmek

Beş dakika, bir parça hurda:

1. Hurda parçaya boydan boya geçmeyen sığ bir kanal açın.
2. Kanalı kumpasla ölçün. Bıçak salgısı dahil gerçek payınız budur.
3. Alternatif: bir parçayı ikiye kesin, iki yarımı uç uca dayayın, toplamın orijinalden kaç mm kısa kaldığını ölçün. Fark, bir kesimin payıdır.

Bıçak başına bir kez yapın, rakamı bıçağın kutusuna yazın. Testerenizde salgı varsa *etkin* payınız etikettekinden geniştir — ölçüm bunu yakalar, etiket yakalamaz.

## Kerf ve parça listeniz

Levha planında testere payı, komşu her parça çiftinin arasına girer — hem yatayda hem dikeyde. Dolap dolusu parçada bu, tek levhada 100 mm'yi aşan "görünmez" malzeme demektir. Kareli kağıtta harika sığan listenin atölyede ikinci levha istemesinin sebebi budur.

İki alışkanlık sizi dertten uzak tutar:

- **Ölçtüğünüz payla plan yapın**, varsayılanla değil. Kesim başına 0,8 mm'lik fark, levha boyunca hızla birikir.
- **Sıfır boşlukla sığan sıraya asla güvenmeyin.** Hesap "tam sığıyor" diyorsa, sığmıyordur — bir parçayı küçültün ya da başka sıraya alın.

## Payı program taşısın

Bir levha boyunca, iki yönde, n − 1 payı damar yönüyle birlikte akılda tutmak tam olarak bilgisayar işidir. Ücretsiz hesaplayıcımız bıçak payınızı her parça çiftinin arasına kendiliğinden koyar — rakamı bir kez yazın, çizdiği her plan bıçağa göre düzeltilmiş olsun.

**[Kerf hesaplı kesim planını dene →](/tr/lite)**

Tarayıcıda, çevrimdışı — kerfkit iOS uygulamasıyla aynı motor.
