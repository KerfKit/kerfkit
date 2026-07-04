#!/usr/bin/env python3
"""Kontrast bekçisi (K-18 — docs/12 §8: metin 4.5:1, büyük metin/UI 3:1).

tokens/tokens.json'dan renkleri okur; uygulamada KULLANILAN çiftleri doğrular.
Yeni bir metin/zemin çifti kullanıma girince bu listeye eklenir — liste dışı
çift kullanmak yasak (docs/12 §8 asla-yalnız-renk + kontrast DoD).
"""
import json
import sys
from pathlib import Path

TOKENS = Path(__file__).resolve().parent.parent / "tokens/tokens.json"

# (ön plan, zemin, min oran, kullanım notu)
CIFTLER = [
    # metin (≥4.5) — koyu tema
    ("timber.50",  "timber.950", 4.5, "başlıklar"),
    ("timber.100", "timber.950", 4.5, "gövde (text.primary dark)"),
    ("timber.200", "timber.950", 4.5, "paywall fayda listesi"),
    ("timber.300", "timber.950", 4.5, "ikincil metin / caption (K-18: 500'den taşındı)"),
    ("timber.300", "timber.900", 4.5, "kart içi ikincil metin"),
    ("amber.400",  "timber.950", 4.5, "fiyat vurgusu"),
    ("amber.500",  "timber.950", 4.5, "vurgu metni"),
    ("timber.950", "amber.500",  4.5, "CTA metni"),
    ("green.500",  "timber.950", 4.5, "başarı metni"),
    ("red.500",    "timber.950", 4.5, "hata metni"),
    ("timber.950", "oak.500",    4.5, "bayat-plan bandı"),
    # açık tema (Tezgâh Modu / PDF)
    ("timber.950", "timber.50",  4.5, "tezgâh modu metin"),
    ("timber.700", "timber.50",  4.5, "tezgâh modu ikincil"),
    # ikon/dekor + büyük metin (≥3)
    ("timber.500", "timber.950", 3.0, "dekor ikonlar (boş durum, kapat) — METİNDE YASAK"),
    ("timber.500", "timber.900", 3.0, "dekor — METİNDE YASAK"),
]


def parse(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def lum(rgb):
    def kanal(c):
        c = c / 255
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (kanal(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def oran(a, b):
    la, lb = lum(parse(a)), lum(parse(b))
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def main():
    d = json.load(open(TOKENS, encoding="utf-8"))["color"]
    renk = {}
    for aile, tonlar in d.items():
        if not isinstance(tonlar, dict):
            continue
        for ton, node in tonlar.items():
            if isinstance(node, dict) and isinstance(node.get("$value"), str) \
               and node["$value"].startswith("#"):
                renk[f"{aile}.{ton}"] = node["$value"]

    hatalar = []
    for on, arka, esik, not_ in CIFTLER:
        if on not in renk or arka not in renk:
            hatalar.append(f"{on}/{arka}: token bulunamadı ({not_})")
            continue
        o = oran(renk[on], renk[arka])
        if o < esik:
            hatalar.append(f"{on}/{arka}: {o:.2f} < {esik} ({not_})")

    if hatalar:
        for h in hatalar:
            print(f"HATA: {h}")
        return 1
    print(f"Kontrast bekçisi temiz: {len(CIFTLER)} çift docs/12 §8 eşiklerini sağlıyor.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
