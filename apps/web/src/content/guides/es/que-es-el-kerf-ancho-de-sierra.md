---
key: "what-is-kerf"
reviewed: true
title: "¿Qué es el kerf? El ancho de sierra que se come tu tablero"
description: "El kerf es el material que la hoja convierte en serrín en cada pasada. Cuánto mide de verdad, por qué arruina las cuentas en papel y cómo medir el tuyo."
date: "2026-07-04"
---

El kerf — en castellano, el **ancho de sierra** o ancho de corte — es la ranura que deja la hoja a su paso: el material que se convierte en serrín en cada corte. Y es la causa número uno de que una lista de corte bien calculada no cuadre al final.

Toda hoja tiene el suyo. Una hoja normal de sierra de mesa se lleva entre 2,8 y 3,2 mm por corte. Las hojas finas rondan los 2,4 mm; las de sierra de incisión suelen andar por 2,2 mm. La sierra de cinta se lleva menos; una fresa de CNC, exactamente su diámetro. La cifra exacta viene grabada en la hoja o en su ficha — y esa cifra, no una estimación, es la que va en tus cuentas.

## Por qué el kerf rompe el « debería caber »

Supón que quieres cuatro tiras de 300 mm en 1220 mm de ancho de tablero. En papel: 4 × 300 = 1200, sobran 20 mm. Sin problema.

Ahora pide **cuatro tiras de 305 mm**: 4 × 305 = 1220 — el papel dice « justo ». La sierra dice otra cosa: cuatro tiras piden tres cortes, y con hoja de 3 mm eso son 9 mm de serrín. 1220 + 9 = no cabe; la cuarta tira sale 9 mm estrecha.

La regla es simple: **n piezas en fila piden n − 1 anchos de sierra entre ellas.** Cualquier lista que se salte esa regla promete piezas que no existen.

## Tabla rápida

| Sierra / hoja | Kerf típico |
|---|---|
| Sierra de mesa (hoja estándar) | ~3 mm |
| Hoja fina | ~2,4 mm |
| Sierra de incisión | ~2,2 mm |
| Circular de mano | ~2,5–3 mm |
| Sierra de cinta | ~0,5–1 mm |
| Fresa CNC | diámetro de la fresa (6–12 mm habitual) |

Son rangos típicos, no promesas — cambian con la marca y el afilado. Toma la tabla como punto de partida y mide tu hoja.

## Medir tu ancho de sierra

Cinco minutos y un recorte:

1. Haz una ranura poco profunda en el recorte — sin atravesar, solo un ancho de hoja.
2. Mide la ranura con el calibre. Ese es tu kerf, con el alabeo de tu sierra incluido.
3. Alternativa: tronza una pieza en dos, junta las mitades canto con canto y mide cuánto se acortó el conjunto respecto al original. La diferencia es un kerf.

Hazlo una vez por hoja y apunta la cifra en la caja. Si tu sierra tiene alabeo, tu kerf *efectivo* es más ancho que el de la ficha — la medición lo pilla, la ficha no.

## El kerf y tu lista de corte

En el plano del tablero, el kerf se cuela entre cada par de piezas vecinas — en horizontal y en vertical. En un mueble completo son docenas de kerfs: más de 100 mm de material « invisible » en un solo tablero, fácilmente. Por eso la lista que cabía de maravilla en papel cuadriculado pide un segundo tablero en el taller.

Dos costumbres te libran de sustos:

- **Calcula con tu kerf medido,** no con uno por defecto. 0,8 mm de diferencia por corte se acumulan rápido a lo ancho de un tablero.
- **No te fíes de una fila que cuadra a cero.** Si la cuenta dice « cabe exacto », no cabe — rebaja una pieza o pásala a otra fila.

## Que el programa cargue con los kerfs

Llevar n − 1 kerfs por todo un tablero, en dos direcciones, mientras vigilas la veta: exactamente la contabilidad para la que se inventaron los ordenadores. Nuestra calculadora gratis mete tu kerf entre cada par de piezas automáticamente — teclea la cifra de tu hoja una vez y cada plano sale ya corregido.

**[Probar la calculadora con kerf →](/es/lite)**

En el navegador, sin conexión — el mismo motor que la app kerfkit.
