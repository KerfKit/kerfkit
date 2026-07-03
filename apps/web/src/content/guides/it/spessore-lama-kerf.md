---
key: "what-is-kerf"
reviewed: true
title: "Spessore lama (kerf): la riga sottile che si mangia il pannello"
description: "Il kerf è il materiale che la lama trasforma in segatura a ogni passata. Quanto misura davvero, perché rovina i conti su carta e come misurare il tuo."
date: "2026-07-04"
---

Lo spessore lama — *kerf* in inglese — è il solco che la lama lascia al passaggio: il materiale che diventa segatura a ogni taglio. Ed è la causa numero uno delle liste di taglio calcolate con cura che alla fine non tornano.

Ogni lama ha il suo. Una lama normale da sega da banco porta via circa 2,8–3,2 mm a taglio. Le lame sottili stanno sui 2,4 mm; quelle delle seghe a immersione spesso sui 2,2 mm. La sega a nastro toglie meno; una fresa CNC esattamente il suo diametro. Il numero preciso è inciso sulla lama o nella scheda — ed è quel numero che va nei tuoi conti, non una stima.

## Perché il kerf rompe il « dovrebbe starci »

Mettiamo che vuoi quattro strisce da 500 mm in 2070 mm di larghezza pannello. Su carta: 4 × 500 = 2000, avanzano 70 mm. Nessun problema.

Ora chiedi **quattro strisce da 517 mm**: 4 × 517 = 2068 — la carta dice « ci sta al pelo ». La sega dice altro: quattro strisce vogliono tre tagli, con lama da 3 mm sono 9 mm di segatura. 2068 + 9 = non ci sta; la quarta striscia esce 7 mm stretta.

La regola è semplice: **n pezzi affiancati vogliono n − 1 lame in mezzo.** Ogni lista che salta questa regola promette pezzi che non esistono.

## Tabella rapida

| Sega / lama | Kerf tipico |
|---|---|
| Sega da banco (lama standard) | ~3 mm |
| Lama sottile | ~2,4 mm |
| Sega a immersione | ~2,2 mm |
| Circolare portatile | ~2,5–3 mm |
| Sega a nastro | ~0,5–1 mm |
| Fresa CNC | diametro fresa (6–12 mm comune) |

Sono intervalli tipici, non promesse — marca e affilatura fanno la differenza. Prendi la tabella come punto di partenza e misura la tua lama.

## Misurare il tuo kerf

Cinque minuti e uno scarto:

1. Fai una scanalatura poco profonda nello scarto — senza passare da parte a parte, solo una larghezza di lama.
2. Misura la scanalatura col calibro. Quello è il tuo kerf, oscillazione della lama compresa.
3. In alternativa: tronca un pezzo in due, riaccosta le metà bordo a bordo e misura di quanto l'insieme si è accorciato rispetto all'originale. La differenza è un kerf.

Fallo una volta per lama e scrivi il numero sulla custodia. Se la sega ha gioco o la lama è svergolata, il tuo kerf *effettivo* è più largo di quello di targa — la misura lo becca, la scheda no.

## Il kerf e la tua lista di taglio

Nel piano del pannello il kerf si infila tra ogni coppia di pezzi vicini — in orizzontale e in verticale. Su un mobile completo sono decine di kerf: oltre 100 mm di materiale « invisibile » su un solo pannello, senza fatica. Ecco perché la lista che stava benissimo sulla carta a quadretti in officina chiede un secondo pannello.

Due abitudini ti tengono fuori dai guai:

- **Pianifica col tuo kerf misurato,** non con un valore di default. 0,8 mm di scarto a taglio si accumulano in fretta lungo un pannello.
- **Mai fidarsi di una fila che torna a zero.** Se il conto dice « ci sta esatto », non ci sta — riduci un pezzo o spostalo in un'altra fila.

## Lascia che i kerf li porti il programma

Tenere a mente n − 1 kerf su tutto un pannello, in due direzioni, insieme alla venatura: è esattamente la contabilità per cui esistono i computer. Il nostro calcolatore gratuito mette il tuo kerf tra ogni coppia di pezzi in automatico — scrivi il numero della tua lama una volta, e ogni piano esce già corretto.

**[Prova il calcolatore col kerf →](/it/lite)**

Nel browser, offline — lo stesso motore dell'app kerfkit.
