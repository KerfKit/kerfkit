# kerf (çalışma adı)

Marangoz kesim planlayıcı — 2D panel + 1D doğrusal kesim optimizasyonu.
iOS (SwiftUI) → Android (Skip) → Web (Wasm motor + TS UI).

- **Spec ground truth:** `docs/` (00_INDEX.md'den başla)
- **Ajan anayasası:** `CLAUDE.md`
- **Motor:** `Sources/CutCore` (saf Swift, stdlib-only, Int aritmetik — `docs/04`)
- **Token pipeline:** `tokens/tokens.json` → `node tools/gen-tokens.mjs` → `apps/web/styles/tokens.css`

## Kurulum (Mac)
```
git clone <repo> && cd kerf
swift test          # motor + golden testler
node tools/gen-tokens.mjs   # tasarım token'larını üret
```
Oturum protokolü: `docs/10_YOL_HARITASI_VE_FABLE5.md` §2.
