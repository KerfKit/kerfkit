---
key: "what-is-kerf"
reviewed: true
title: "Schnittfuge: Die Blattbreite, die deine Platte auffrisst"
description: "Die Schnittfuge ist das Material, das dein Sägeblatt bei jedem Schnitt in Späne verwandelt. Wie breit sie wirklich ist, warum sie Papierrechnungen ruiniert und wie du deine misst."
date: "2026-07-04"
---

Die Schnittfuge — im Englischen *kerf* — ist der Spalt, den das Sägeblatt hinterlässt: das Material, das bei jedem Schnitt zu Spänen wird. Sie ist der häufigste Grund, warum eine sauber gerechnete Schnittliste am Ende nicht aufgeht.

Jedes Blatt hat eine. Ein normales Kreissägeblatt nimmt etwa 2,8–3,2 mm pro Schnitt. Dünnschnittblätter liegen um 2,4 mm, Tauchsägenblätter oft bei 2,2 mm. Die Bandsäge nimmt weniger; ein CNC-Fräser exakt seinen Durchmesser. Die genaue Zahl steht auf dem Blatt oder im Datenblatt — und genau diese Zahl gehört in deine Rechnung, keine Schätzung.

## Warum die Fuge das „müsste passen" kaputt macht

Angenommen, du willst vier 300-mm-Streifen aus 2070 mm Plattenbreite. Auf dem Papier: 4 × 300 = 1200, bleiben 870 mm. Kein Thema.

Jetzt willst du **sechs** Streifen à 345 mm: 6 × 345 = 2070 — das Papier sagt „passt exakt". Die Säge sagt was anderes: Sechs Streifen brauchen fünf Schnitte, mit 3-mm-Blatt sind das 15 mm Späne. 2070 + 15 = passt nicht; der sechste Streifen kommt 15 mm zu schmal raus.

Die Regel ist simpel: **n Teile nebeneinander brauchen n − 1 Fugen dazwischen.** Jede Liste, die das ignoriert, verspricht Teile, die es nicht gibt.

## Schnellübersicht

| Säge / Blatt | Typische Fuge |
|---|---|
| Kreissägeblatt (Standard) | ~3 mm |
| Dünnschnittblatt | ~2,4 mm |
| Tauchsäge | ~2,2 mm |
| Handkreissäge | ~2,5–3 mm |
| Bandsäge | ~0,5–1 mm |
| CNC-Fräser | Fräserdurchmesser (6–12 mm üblich) |

Das sind typische Bereiche, keine Garantie — Hersteller und Schärfzustand machen den Unterschied. Nimm die Tabelle als Startpunkt und miss dein eigenes Blatt.

## Deine Fuge selbst messen

Fünf Minuten, ein Reststück:

1. Säge eine flache Nut in den Rest — nicht durchtrennen, nur eine Blattbreite tief.
2. Miss die Nut mit dem Messschieber. Das ist deine Fuge, inklusive allem, was deine Säge an Schlag dazugibt.
3. Alternative: ein Stück durchtrennen, beide Hälften wieder aneinanderlegen und messen, wie viel kürzer das Paar gegenüber dem Original ist. Die Differenz ist eine Fuge.

Einmal pro Blatt machen und die Zahl auf den Blattkoffer schreiben. Hat deine Säge Schlag oder das Blatt Verzug, ist deine *effektive* Fuge breiter als der Aufdruck — die Messung fängt das ein, das Datenblatt nicht.

## Fuge und Schnittliste

Im Plattenlayout sitzt die Fuge zwischen jedem benachbarten Teilepaar — waagerecht und senkrecht. Bei einem Schrank voller Teile sind das Dutzende Fugen, locker 100+ mm „unsichtbares" Material pro Platte. Deshalb braucht eine Liste, die auf Karopapier wunderbar passte, in der Werkstatt eine zweite Platte.

Zwei Gewohnheiten halten dich raus aus dem Ärger:

- **Rechne mit deiner gemessenen Fuge,** nicht mit einem Standardwert. 0,8 mm Unterschied pro Schnitt summieren sich über die Platte schnell.
- **Trau keiner Reihe, die auf null aufgeht.** Wenn die Rechnung „passt exakt" sagt, passt es nicht — ein Teil schmaler machen oder in eine andere Reihe schieben.

## Lass die Software die Fugen tragen

n − 1 Fugen über eine ganze Platte, in zwei Richtungen, zusammen mit der Maserung im Kopf zu behalten — genau dafür gibt es Computer. Unser kostenloser Rechner setzt deine Fuge automatisch zwischen jedes Teilepaar: Zahl einmal eintippen, und jedes Layout ist blattkorrigiert.

**[Zuschnitt-Rechner mit Fuge ausprobieren →](/de/lite)**

Läuft im Browser, offline — dieselbe Engine wie in der kerfkit-App.
