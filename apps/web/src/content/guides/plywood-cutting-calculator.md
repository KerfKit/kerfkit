---
key: "cutting-calculator"
reviewed: true
title: "Plywood Cutting Calculator: Get More Parts Out of Every Sheet"
description: "How a cut list calculator works, what kerf-aware optimization actually changes, and how to lay out a 4×8 sheet without the guesswork."
date: "2026-07-03"
---

You've got a stack of parts to cut and a sheet of plywood that cost real money. The question every woodworker asks at the tailgate of the truck is the same: *will it all fit on one sheet, or do I need two?*

You can answer that with a pencil, some graph paper, and twenty minutes of sketching rectangles. Most of us have done exactly that for years. It works — until you mis-add a kerf, or forget that the door panel can't be rotated because the grain has to run vertical, and suddenly you're driving back to the yard for another sheet.

A cutting calculator does that same sketch in milliseconds, and it doesn't forget the kerf.

## What a cut list calculator actually does

At its core, the job is called *2D bin packing*: place a set of rectangles (your parts) onto a bigger rectangle (your sheet) so that as little material as possible goes to waste. It sounds simple. It is famously not — the number of possible arrangements explodes long before you reach a real cabinet's worth of parts, which is why "just eyeball it" leaves waste on the table.

A good calculator handles four things at once:

1. **Placement.** Where each part goes on the sheet, so the total number of sheets is minimized.
2. **Kerf.** Every saw cut removes a blade's width of material. Two parts can't share an edge — there's a kerf between them, every time. Ignore it and parts come out short.
3. **Grain direction.** A side panel with vertical grain can't be spun 90° just because it packs tighter that way. The calculator needs a rotation lock per part.
4. **Cut sequence.** For a table saw or track saw you want *guillotine cuts* — straight cuts that run edge to edge. A layout that only a CNC nesting machine could cut is useless in a home shop.

If a tool gets those four right, the layout it prints is one you can actually stand at the saw and cut.

## Why the kerf matters more than you think

Take a common example: drawer fronts at 396 mm wide out of a 2440 mm rip. Without kerf, 2440 ÷ 396 says six fronts fit with room to spare. With a 3 mm blade, six fronts need 396 × 6 + 3 × 5 = 2391 mm — still fits, but the "spare" shrank from 64 mm to 49 mm. Make those fronts 407 mm instead and the no-kerf math still promises six; the real saw gives you five and a strip of scrap. That's the whole failure mode: paper math says yes, the blade says no.

A calculator that asks for your kerf up front — and uses it between *every* pair of parts — is the difference between a plan and a wish.

## Reading a cut layout

A good layout diagram tells you, at a glance:

- **Which parts share a sheet**, so you can pull the right number of sheets before you start.
- **Waste percentage** — how much of the sheet ends up as offcut. Use it to compare layouts, not to chase a magic number; a project with big fixed-grain panels will simply waste more than a pile of shelf blanks, and that's physics, not a bad plan.
- **Rotation marks** on parts the optimizer turned 90°. If a part shows rotated but its grain must run one way, lock it and re-run.
- **Cut count.** Fewer cuts means less time at the saw and fewer chances to drift off the line.

## Doing it by hand vs. letting software try thousands of layouts

Hand layout has one genuine advantage: you think about each part as you draw it, so cut order and handling get planned for free. Keep doing that for a three-part weekend project.

For anything with more than a handful of parts, the trade flips. Software tries orderings and rotations you would never sketch, applies the kerf perfectly every time, and re-plans the whole sheet the moment you change one measurement. When a client bumps a cabinet from 600 to 650 wide, the difference between re-drawing a sheet and re-typing one number is your evening.

## Try it on your own cut list

The calculator below runs the exact same optimization engine as our iOS app — same code, compiled for your browser, working entirely offline. One sheet, up to twenty parts, kerf-aware, grain-aware. Type in your parts and watch the layout redraw as you type.

**[Open the free cut list calculator →](/lite)**

No account, no upload — your cut list never leaves the page.
