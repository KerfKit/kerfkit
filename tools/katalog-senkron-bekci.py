#!/usr/bin/env python3
"""Katalog senkron bekçisi (E9-S2 — docs/18 §5.2c).

Android modülü iOS String Catalog'unun kopyasını taşır. Kural:
  1. iOS'taki HER anahtar Android kopyasında da olmalı (Android ⊇ iOS).
  2. Ortak anahtarların çevirileri birebir aynı olmalı (kopya sürüklenmesin).
Android'e özgü ekstra anahtarlar serbest.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IOS = ROOT / "apps/ios/KerfKit/Localizable.xcstrings"
AND = ROOT / "apps/android/Sources/KerfKit/Resources/Localizable.xcstrings"


def yukle(p):
    with open(p, encoding="utf-8") as f:
        return json.load(f)["strings"]


def main():
    ios, android = yukle(IOS), yukle(AND)
    hatalar = []

    eksik = sorted(set(ios) - set(android))
    for k in eksik:
        hatalar.append(f"Android kopyasında eksik anahtar: {k!r}")

    for k in sorted(set(ios) & set(android)):
        i_loc = ios[k].get("localizations", {})
        a_loc = android[k].get("localizations", {})
        for dil, i_veri in i_loc.items():
            if dil == "en":
                continue  # kaynak dil: aşağıdaki Android-özel kurala bakılır
            a_veri = a_loc.get(dil)
            if a_veri is None:
                hatalar.append(f"{k!r}: Android kopyasında {dil} çevirisi yok")
            elif a_veri != i_veri:  # stringUnit VE plural variations dahil tam kıyas
                hatalar.append(f"{k!r} ({dil}): çeviri sürüklendi")

    # SKIP TUZAĞI (E9-S2'de yaşandı): Android kopyasında 'en' stringUnit girdisi
    # en.lproj/Localizable.strings tablosu doğurur; SkipUI diğer anahtarların
    # çözümünü bozup format çökmesine yol açar. Plural variations serbest.
    for k, e in android.items():
        en = e.get("localizations", {}).get("en", {})
        if "stringUnit" in en:
            hatalar.append(f"{k!r}: Android kopyasında 'en' stringUnit YASAK (Skip çökme tuzağı)")

    if hatalar:
        for h in hatalar[:40]:
            print(f"HATA: {h}")
        print(f"\nToplam {len(hatalar)} sorun. Çözüm: iOS kataloğundaki değişikliği "
              "apps/android kopyasına da işle (docs/18 §5.2c).")
        return 1
    print(f"Katalog senkron bekçisi temiz: {len(ios)} iOS anahtarının tamamı Android'de, "
          "çeviriler birebir.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
