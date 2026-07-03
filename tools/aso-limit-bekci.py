#!/usr/bin/env python3
# L-4 bekçisi (docs/17 P-3: "karakter limitlerini doğrula"):
# App Store: name≤30, subtitle≤30, keywords≤100, description≤4000
# Play:      title≤30, short_description≤80, full_description≤4000
# Ekran görüntüsü başlıkları: 6 satır, her biri ≤50 (K-19 çerçeve şablonu sınırı).
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIMITS_IOS = {"name.txt": 30, "subtitle.txt": 30, "keywords.txt": 100, "description.txt": 4000}
LIMITS_PLAY = {"title.txt": 30, "short_description.txt": 80, "full_description.txt": 4000}

fails = []

def check(base: Path, limits: dict):
    for loc_dir in sorted(base.iterdir()):
        if not loc_dir.is_dir():
            continue
        for fn, limit in limits.items():
            f = loc_dir / fn
            if not f.exists():
                fails.append(f"{f.relative_to(ROOT)}: DOSYA YOK")
                continue
            n = len(f.read_text().rstrip("\n"))
            if n > limit:
                fails.append(f"{f.relative_to(ROOT)}: {n} > {limit}")
        cap = loc_dir / "screenshot_captions.txt"
        if cap.exists():
            lines = [l for l in cap.read_text().splitlines() if l.strip()]
            if len(lines) != 6:
                fails.append(f"{cap.relative_to(ROOT)}: {len(lines)} satır (6 olmalı)")
            for i, l in enumerate(lines, 1):
                if len(l) > 50:
                    fails.append(f"{cap.relative_to(ROOT)}:{i}: {len(l)} > 50")

check(ROOT / "apps/ios/fastlane/metadata", LIMITS_IOS)
check(ROOT / "apps/android/metadata", LIMITS_PLAY)

if fails:
    print("HATA — ASO limit aşımı:")
    print("\n".join(" " + f for f in fails))
    sys.exit(1)
print("ASO limitleri OK — tüm locale'ler sınır içinde.")
