---
key: "cutting-calculator"
reviewed: true
title: "Plattenzuschnitt-Rechner: Mehr Teile aus jeder Platte holen"
description: "Wie ein Zuschnitt-Rechner arbeitet, was die Schnittfuge wirklich ändert und wie du eine 2800×2070-Platte ohne Kopfzerbrechen aufteilst."
date: "2026-07-04"
---

Du hast einen Stapel Teile zu sägen und eine Platte, die echtes Geld gekostet hat. Die Frage am Zuschnitttisch ist immer dieselbe: *passt alles auf eine Platte — oder brauche ich eine zweite?*

Man kann das mit Bleistift und Karopapier beantworten. Die meisten von uns haben das jahrelang genau so gemacht — bis eine Schnittfuge vergessen wurde oder die Tür wegen der Maserung doch nicht gedreht werden durfte. Ergebnis: ein fehlendes Teil und eine zweite Fahrt zum Holzhandel.

Ein Zuschnitt-Rechner macht dieselbe Skizze in Millisekunden — und vergisst die Fuge nie.

## Was ein Zuschnitt-Rechner eigentlich tut

Im Kern ist das ein *2D-Packproblem*: Rechtecke (deine Teile) so auf ein größeres Rechteck (deine Platte) legen, dass möglichst wenig Verschnitt bleibt. Klingt simpel, ist es berühmt-berüchtigt nicht — die Zahl möglicher Anordnungen explodiert lange bevor ein Schrank komplett ist. Genau deshalb kostet „mach ich nach Gefühl" Platten.

Ein guter Rechner beherrscht vier Dinge gleichzeitig:

1. **Platzierung.** Wo jedes Teil liegt, damit die Plattenzahl minimal bleibt.
2. **Schnittfuge.** Jeder Sägeschnitt frisst Blattbreite. Zwei Teile teilen sich nie eine Kante — dazwischen liegt immer eine Fuge. Wer sie ignoriert, sägt zu kurze Teile.
3. **Maserung.** Eine Seitenwand mit stehender Maserung darf nicht um 90° gedreht werden, nur weil sie so besser packt. Der Rechner braucht eine Dreh-Sperre pro Teil.
4. **Schnittführung.** Für Formatkreissäge und Tauchsäge brauchst du *durchgehende Schnitte* von Kante zu Kante. Ein Layout, das nur eine CNC nesten kann, nützt in der Werkstatt nichts.

Stimmen diese vier Punkte, kannst du den Plan wirklich an der Säge abarbeiten.

## Warum die Schnittfuge wichtiger ist, als du denkst

Ein Klassiker: Schubladenblenden à 396 mm aus einem 2800-mm-Streifen. Ohne Fuge sagt 2800 ÷ 396: sieben Stück, locker. Mit 3-mm-Blatt: 7 × 396 + 6 × 3 = 2790 mm — passt noch, aber aus 28 mm Luft wurden 10. Mach die Blenden 400 mm breit, und das Papier verspricht weiter sieben; die Säge liefert sechs und einen Reststreifen. Das ist der ganze Fehlermodus: Papier sagt ja, Blatt sagt nein.

## Plattenmaße in Deutschland

Im Handel ist die Spanplatte meist **2800 × 2070 mm** (Großformat), daneben 2650 × 2070; Baumärkte führen kleinere Zuschnitte. Gib deinem Rechner das echte Maß — nicht das nordamerikanische „4×8" (1220 × 2440 mm). Und plane das Besäumen ein: Fabrikkanten sind selten sauber und Transportkanten haben Macken; 5–10 mm Besäumzugabe pro Kante ist bei vielen Schreinern Standard.

## Einen Schnittplan lesen

Ein gutes Schnittbild zeigt dir auf einen Blick:

- **Welche Teile auf welche Platte gehören** — du weißt vor dem ersten Schnitt, wie viele Platten du brauchst.
- **Verschnitt in Prozent** — wie viel der Platte übrig bleibt. Nutze die Zahl zum Vergleichen von Plänen, nicht als Fetisch: ein Projekt voller maserungsgebundener Fronten hat naturgemäß mehr Verschnitt als ein Stapel Regalböden.
- **Dreh-Markierungen** an Teilen, die der Optimierer um 90° gelegt hat. Muss die Maserung stehen, sperren und neu rechnen.
- **Schnittzahl.** Weniger Schnitte heißt weniger Zeit an der Säge und weniger Gelegenheiten, von der Linie zu wandern.

## Von Hand zeichnen oder rechnen lassen?

Handarbeit hat einen echten Vorteil: Du denkst beim Zeichnen über jedes Teil nach, die Schnittfolge entsteht nebenbei. Für das Drei-Teile-Wochenendprojekt: weiter so.

Ab einer Handvoll Teile kippt die Rechnung. Software probiert Anordnungen, die du nie skizzieren würdest, setzt die Fuge jedes Mal exakt und plant die ganze Platte neu, sobald sich ein Maß ändert. Wenn der Kunde den Schrank von 600 auf 650 verbreitert, ist der Unterschied zwischen Neuzeichnen und Neutippen dein Feierabend.

## Probier's mit deiner eigenen Liste

Der Rechner unten läuft mit exakt derselben Engine wie unsere iOS-App — gleicher Code, kompiliert für deinen Browser, komplett offline. Eine Platte, bis zu zwanzig Teile, Fuge und Maserung eingerechnet. Tipp deine Teile ein und schau zu, wie sich das Layout beim Tippen neu zeichnet.

**[Kostenlosen Zuschnitt-Rechner öffnen →](/de/lite)**

Kein Konto, kein Upload — deine Schnittliste verlässt die Seite nicht.
