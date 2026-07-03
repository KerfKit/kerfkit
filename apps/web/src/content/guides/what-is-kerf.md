---
title: "What Is Kerf? The Blade Width That Eats Your Plywood"
description: "Kerf is the material your saw blade removes with every cut. Here's how wide it really is, why it ruins paper math, and how to measure yours."
date: "2026-07-03"
---

Kerf is the slot your saw blade leaves behind — the material that turns into sawdust with every pass. The word is old English for "cut," and it's the single most common reason a carefully measured cut list comes out short.

Every blade has one. A typical full-kerf table saw blade removes about 1/8" (roughly 3.2 mm) with each cut. Thin-kerf blades take around 3/32" (about 2.4 mm). Track saw blades commonly run about 2.2 mm. Band saws less; a CNC router bit takes exactly its diameter. The exact number is stamped on the blade or printed in its spec sheet — and that number, not a guess, is what your math needs.

## Why kerf breaks "it should fit" math

Say you want four 300 mm strips from a 1220 mm panel edge. On paper: 4 × 300 = 1200, leaves 20 mm. Easy.

At the saw: three cuts separate four strips, and each cut eats blade width. With a 3.2 mm blade that's 4 × 300 + 3 × 3.2 = 1209.6 mm. Still fits — with 10.4 mm to spare, half of what paper promised. Now make it five strips of 244 mm: paper says 1220 exactly, a perfect fit. The saw says 1220 + 4 cuts × 3.2 = you're 12.8 mm short. The fifth strip is scrap-plus-a-sliver, and the sheet you budgeted doesn't close.

The rule is simple: **n parts in a row need n − 1 kerfs between them.** Any layout, calculator, or cut list that skips that rule produces parts that don't exist.

## A quick reference

| Saw / blade | Typical kerf |
|---|---|
| Full-kerf table saw blade | ~3.2 mm (1/8") |
| Thin-kerf table saw blade | ~2.4 mm (3/32") |
| Track saw blade | ~2.2 mm |
| Circular saw (framing) | ~2.5–3 mm |
| Band saw | ~0.5–1 mm |
| CNC router | bit diameter (6–12 mm common) |

These are typical ranges, not gospel — blades vary by brand and sharpening history. Treat the table as a starting point and measure your own.

## How to measure your actual kerf

Five minutes, one offcut:

1. Rip a shallow groove into scrap — don't cut through, just a single blade-width slot.
2. Measure the slot with calipers. That's your kerf, including any blade wobble your saw adds.
3. Alternatively: crosscut a piece in two, butt the halves back together, and measure how much shorter the pair is than the original. The difference is one kerf.

Do it once per blade and write the number on the blade case. If your saw has runout or the blade is warped, your *effective* kerf is wider than the stamp says — the measurement catches that, the spec sheet doesn't.

## Kerf and your cut list

When you plan a sheet layout, kerf shows up between every neighboring pair of parts — horizontally and vertically. On a cabinet's worth of parts that's dozens of kerfs, easily 100+ mm of "invisible" material on a single sheet. This is why a cut list that fit beautifully on graph paper needs a second sheet in the shop.

Two habits keep you out of trouble:

- **Plan with your measured kerf,** not a default. 0.8 mm of difference per cut compounds fast across a sheet.
- **Never plan a row that fits with zero slack.** If the math says a row fits exactly, it doesn't — dial one part down or move it to another row.

## Let the software carry the kerf

Keeping n − 1 kerfs straight across a whole sheet, in two directions, while also juggling grain direction is exactly the bookkeeping computers are for. Our free calculator applies your kerf between every pair of parts automatically — type your blade's number once and every layout it draws is already blade-corrected.

**[Try the kerf-aware cut calculator →](/lite)**

It runs in your browser, offline, on the same engine as the kerfkit iOS app.
