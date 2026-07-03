---
key: "cutting-calculator"
reviewed: true
title: "Calcolatore piano di taglio: più pezzi da ogni pannello"
description: "Come lavora un ottimizzatore di taglio, cosa cambia davvero lo spessore lama e come sezionare un pannello 2800 × 2070 senza rompicapi."
date: "2026-07-04"
---

Hai una lista di pezzi da tagliare e un pannello pagato con soldi veri. Davanti al bancone la domanda è sempre quella: *ci sta tutto in un pannello o me ne serve un altro?*

Puoi rispondere con matita e carta a quadretti: venti minuti di schizzi. L'abbiamo fatto tutti per anni — finché non salta uno spessore lama, o scopri che l'anta non si può girare per via della venatura. Risultato: un pezzo mancante e un altro giro dal rivenditore.

Un calcolatore di taglio fa lo stesso schizzo in pochi millisecondi. E la lama non se la dimentica mai.

## Cosa fa davvero un ottimizzatore di taglio

Il cuore del problema è il *piazzamento in due dimensioni*: sistemare rettangoli (i tuoi pezzi) su un rettangolo grande (il pannello) sprecando il meno possibile. Sembra facile; notoriamente non lo è — il numero di disposizioni possibili esplode molto prima di completare un mobile. Ecco perché il « faccio a occhio » finisce per costare pannelli.

Un buon calcolatore tiene insieme quattro cose:

1. **Il piazzamento.** Dove va ogni pezzo, perché il numero di pannelli resti minimo.
2. **Lo spessore lama.** Ogni passata si mangia la sua larghezza di materiale. Due pezzi non condividono mai uno spigolo — in mezzo c'è sempre una lama. Ignorarla vuol dire pezzi corti.
3. **La venatura.** Un fianco a vista con la venatura verticale non si gira di 90° solo perché impacchetta meglio. Serve un blocco di rotazione per pezzo.
4. **L'ordine dei tagli.** Con sega da banco o a immersione servono tagli *passanti*, da bordo a bordo. Un layout che solo una CNC può nestare non serve a niente in officina.

Se lo strumento rispetta questi quattro punti, il piano stampato si taglia davvero, in piedi davanti alla sega.

## Lo spessore lama conta più di quanto pensi

Esempio classico: frontali di cassetto da 396 mm in una striscia di 2800 mm. Senza lama, 2800 ÷ 396 promette sette frontali con margine. Con lama da 3 mm: 7 × 396 + 6 × 3 = 2790 mm — ci sta ancora, ma il margine è sceso da 28 a 10 mm. Porta i frontali a 400 mm: la carta promette sempre sette; la sega ne consegna sei e uno sfrido. Tutto il tranello è qui: la carta dice sì, la lama dice no.

## Formati di pannello in Italia

Il nobilitato grande formato è di solito **2800 × 2070 mm**; per il multistrato è comune il 2500 × 1250. Dai al calcolatore la misura vera del tuo pannello — non il « 4×8 » nordamericano (2440 × 1220). E metti in conto il rifilo: i bordi di fabbrica raramente sono dritti e in squadra, gli angoli si ammaccano nel trasporto; 5–10 mm di rifilo per lato sono abitudine in molte falegnamerie.

## Leggere un piano di taglio

Un buon schema ti dice a colpo d'occhio:

- **Quali pezzi stanno sullo stesso pannello** — sai quanti comprarne prima del primo taglio.
- **La percentuale di sfrido.** Usala per confrontare i piani, non per inseguire un numero magico: un progetto pieno di ante a venatura bloccata sfrida per forza più di una pila di ripiani.
- **I segni di rotazione** sui pezzi che l'ottimizzatore ha girato. Se la venatura doveva restare dritta, blocca e ricalcola.
- **Il numero di tagli.** Meno tagli, meno tempo alla sega e meno occasioni di uscire dalla riga.

## A mano o col programma?

Il disegno a mano ha un vantaggio vero: pensi a ogni pezzo mentre lo tracci, e la sequenza di taglio nasce da sola. Per il progettino da tre pezzi del fine settimana, continua pure così.

Superata la manciata di pezzi, il conto si ribalta. Il programma prova disposizioni che non disegneresti mai, applica la lama perfetta ogni volta e ripianifica l'intero pannello appena cambi una quota. Quando il cliente porta il modulo da 600 a 650, la differenza tra ridisegnare e ribattere un numero è la tua serata.

## Provalo con la tua lista

Il calcolatore qui sotto fa girare esattamente lo stesso motore della nostra app iOS — stesso codice, compilato per il tuo browser, completamente offline. Un pannello, fino a venti pezzi, lama e venatura comprese. Scrivi i tuoi pezzi e guarda il piano ridisegnarsi mentre digiti.

**[Apri il calcolatore di taglio gratis →](/it/lite)**

Niente account, niente upload — la tua lista di taglio non lascia la pagina.
