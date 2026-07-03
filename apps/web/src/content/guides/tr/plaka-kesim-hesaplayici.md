---
key: "cutting-calculator"
reviewed: true
title: "Plaka Kesim Hesaplayıcı: Her Levhadan Daha Çok Parça Çıkarın"
description: "Kesim planı programı nasıl çalışır, testere payını hesaba katmak neyi değiştirir, 210×280 levhayı kafa yormadan nasıl yerleştirirsiniz — hepsi bu rehberde."
date: "2026-07-04"
---

Elinizde kesilecek bir parça listesi, önünüzde parasını saydığınız bir levha var. Hırdavatçının önünde herkesin sorduğu soru aynı: *hepsi tek levhaya sığar mı, yoksa ikinciyi mi almam gerekecek?*

Bu soruya kağıt kalemle de cevap verebilirsiniz — kareli kağıt, biraz çizim, yirmi dakika. Çoğumuz yıllarca tam olarak böyle yaptık. Ta ki bir testere payını unutana, ya da kapağın damar yönü yüzünden döndürülemeyeceğini atlayana kadar. Sonuç: eksik parça ve hırdavatçıya ikinci yol.

Kesim hesaplayıcı aynı çizimi milisaniyeler içinde yapar — ve testere payını asla unutmaz.

## Kesim planı programı aslında ne yapar?

İşin özü *iki boyutlu yerleştirme problemi*: dikdörtgen parçaları, büyük bir dikdörtgenin (levhanızın) üzerine en az fire verecek şekilde dizmek. Kulağa basit geliyor; değil — parça sayısı arttıkça olası dizilimlerin sayısı patlar. "Göz kararı hallederim" yaklaşımının levha kaybettirmesinin sebebi bu.

İyi bir hesaplayıcı dört şeyi aynı anda yönetir:

1. **Yerleşim.** Her parçanın levha üzerindeki yeri — toplam levha sayısı en aza inecek şekilde.
2. **Testere payı (kerf).** Her kesim, bıçak kalınlığı kadar malzeme yer. İki parça asla sırt sırta duramaz — aralarında her seferinde bir testere payı vardır. Hesaba katmazsanız parçalar eksik çıkar.
3. **Damar yönü.** Kapak ya da görünen yan panel, sırf daha iyi sığıyor diye 90° döndürülemez. Programda parça başına döndürme kilidi olmalı.
4. **Kesim sırası.** Daire testere ya da yatar daire için *boydan boya (giyotin)* kesimler gerekir. Yalnız CNC'nin kesebileceği bir yerleşim, ev atölyesinde işe yaramaz.

Bu dördü doğruysa, programın bastığı plan gerçekten testere başında kesilebilir bir plandır.

## Testere payı sandığınızdan daha önemli

Bildik bir örnek: 2800 mm'lik boydan 396 mm'lik çekmece önleri. Kağıt üzerinde 2800 ÷ 396, yedi parça der ve pay da artar. 3 mm bıçakla gerçek hesap: 7 × 396 + 6 × 3 = 2790 mm — sığıyor ama pay 28 mm'den 10 mm'ye düştü. Parçayı 400 mm yapın: kağıt yine yedi diyor; testere altı verir, yedincisi hurda olur. Bütün mesele bu: kağıt "olur" der, bıçak "olmaz".

Testere payını baştan soran — ve *her* parça çifti arasında kullanan — bir hesaplayıcı, plan ile temenni arasındaki farktır.

## Türkiye'de levha ölçüleri

Piyasada suntalam ve MDF çoğunlukla **210 × 280 cm** boyunda satılır; 183 × 366 cm de görürsünüz. Hesaplayıcıya gerçek levha ölçünüzü girin — "standart 4×8" diye geçiştirmeyin, o Kuzey Amerika ölçüsüdür (122 × 244 cm). Kenar tıraşını da unutmayın: fabrika kenarı düzgün görünse de kanallı ya da hasarlı olabilir; kenarlardan 5-10 mm tıraş payı bırakmak birçok ustanın alışkanlığıdır.

## Kesim planını okumak

İyi bir yerleşim şeması size tek bakışta şunları söyler:

- **Hangi parçalar aynı levhada** — kaç levha alacağınızı işe başlamadan bilirsiniz.
- **Fire yüzdesi** — levhanın ne kadarının artığa gittiği. Bunu planları karşılaştırmak için kullanın, sihirli bir sayı kovalamak için değil: damar kilitli büyük kapaklarla dolu bir iş, raf dolusu küçük parçadan doğal olarak daha çok fire verir.
- **Döndürme işaretleri** — programın 90° çevirdiği parçalar. Damarı tek yöne akması gereken bir parça döndürülmüş görünüyorsa kilitleyip yeniden hesaplatın.
- **Kesim sayısı** — az kesim, testere başında az vakit ve az hata demektir.

## Elle çizmek mi, programa bırakmak mı?

Elle çizimin gerçek bir artısı var: her parçayı çizerken düşünürsünüz, kesim sırası kafanızda kurulur. Üç parçalık hafta sonu işinde buna devam edin.

Parça sayısı bir elin parmaklarını geçince denge tersine döner. Program, sizin asla deneyemeyeceğiniz dizilimleri dener, testere payını her seferinde kusursuz uygular ve tek bir ölçü değiştiğinde bütün levhayı yeniden planlar. Müşteri dolabı 60'tan 65'e çıkardığında, aradaki fark bir akşamınızdır.

## Kendi listenizle deneyin

Aşağıdaki hesaplayıcı, iOS uygulamamızla aynı motoru tarayıcınızda çalıştırır — aynı kod, tamamen çevrimdışı. Tek levha, 20 parçaya kadar, testere payı ve damar hesapta. Parçalarınızı yazın, yerleşimin siz yazdıkça yeniden çizilişini izleyin.

**[Ücretsiz kesim hesaplayıcıyı aç →](/tr/lite)**

Üyelik yok, yükleme yok — parça listeniz sayfadan dışarı çıkmaz.
