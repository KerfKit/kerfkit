---
key: "cutting-calculator"
reviewed: true
title: "Calculadora de despiece: saca más piezas de cada tablero"
description: "Cómo trabaja un optimizador de corte, qué cambia de verdad el ancho de sierra y cómo despiezar un tablero de 244 × 122 sin quebraderos de cabeza."
date: "2026-07-04"
---

Tienes una lista de piezas por cortar y un tablero que ha costado dinero de verdad. Delante del mostrador la pregunta es siempre la misma: *¿cabe todo en un tablero o necesito otro?*

Se puede responder con lápiz y papel cuadriculado: veinte minutos de croquis. Casi todos lo hemos hecho así durante años — hasta que se te olvida un ancho de sierra, o resulta que la puerta no se puede girar por la veta. Resultado: una pieza que falta y otro viaje al almacén.

Una calculadora de despiece hace el mismo croquis en milisegundos. Y el ancho de sierra no se le olvida nunca.

## Qué hace de verdad una calculadora de despiece

En el fondo es un problema de *empaquetado en dos dimensiones*: colocar rectángulos (tus piezas) sobre un rectángulo grande (tu tablero) desperdiciando lo mínimo. Suena fácil; famosamente no lo es — el número de colocaciones posibles se dispara mucho antes de llegar a un mueble completo. Por eso el « lo cuadro a ojo » acaba costando tableros.

Una buena calculadora maneja cuatro cosas a la vez:

1. **La colocación.** Dónde va cada pieza para que el número de tableros sea mínimo.
2. **El ancho de sierra.** Cada pasada de la hoja se come su grosor en material. Dos piezas nunca comparten arista — entre ellas siempre hay una sierra de por medio. Si lo ignoras, las piezas salen cortas.
3. **La veta.** Un costado visible con la veta en vertical no se gira 90° porque encaje mejor. Hace falta un bloqueo de rotación por pieza.
4. **El orden de corte.** En sierra de mesa o de incisión necesitas cortes *pasantes*, de canto a canto. Una colocación que solo puede cortar una CNC no sirve en un taller normal.

Si la herramienta respeta esas cuatro cosas, el plano que imprime se puede cortar de verdad, de pie junto a la sierra.

## El ancho de sierra importa más de lo que crees

Un ejemplo de siempre: frentes de cajón de 396 mm en un largo de 2440 mm. Sin sierra, 2440 ÷ 396 promete seis frentes con margen. Con hoja de 3 mm: 6 × 396 + 5 × 3 = 2391 mm — aún cabe, pero el margen bajó de 64 a 49 mm. Sube los frentes a 405 mm: el papel sigue prometiendo seis; la sierra entrega cinco y un recorte. Ahí está toda la trampa: el papel dice sí, la hoja dice no.

## Formatos de tablero en España

En el almacén, el contrachapado y el melamínico se venden sobre todo en **2440 × 1220 mm** (el clásico 244 × 122), y el melamínico de gran formato en 2800 × 2070 mm. Dale a la calculadora tu medida real y no olvides el recorte de borde: los cantos de fábrica rara vez vienen rectos y las esquinas se golpean en el transporte; recortar 5–10 mm por canto es costumbre en muchos talleres.

## Leer un plano de despiece

Un buen esquema te dice de un vistazo:

- **Qué piezas comparten tablero** — sabes cuántos comprar antes del primer corte.
- **El porcentaje de desperdicio.** Úsalo para comparar planos, no para perseguir un número mágico: un proyecto lleno de frentes con veta bloqueada siempre pierde más que una pila de baldas.
- **Las marcas de rotación** en las piezas que el optimizador giró. Si la veta debía ir en un sentido, bloquéala y recalcula.
- **El número de cortes.** Menos cortes es menos tiempo en la sierra y menos ocasiones de salirse de la línea.

## ¿A mano o con programa?

El croquis a mano conserva una ventaja real: piensas cada pieza mientras la dibujas y el orden de corte sale solo. Para el proyecto de tres piezas del fin de semana, sigue así.

En cuanto pasas de un puñado de piezas, la balanza se invierte. El programa prueba colocaciones que tú nunca dibujarías, aplica la sierra perfecta cada vez y replantea el tablero entero en cuanto cambias una medida. Cuando el cliente pasa el módulo de 600 a 650, la diferencia entre redibujar y reteclear es tu tarde.

## Pruébalo con tu propia lista

La calculadora de abajo corre exactamente el mismo motor que nuestra app de iOS — el mismo código, compilado para tu navegador, totalmente sin conexión. Un tablero, hasta veinte piezas, sierra y veta incluidas. Escribe tus piezas y mira cómo el plano se redibuja mientras tecleas.

**[Abrir la calculadora de despiece gratis →](/es/lite)**

Sin cuenta, sin subir nada — tu lista de corte no sale de la página.
