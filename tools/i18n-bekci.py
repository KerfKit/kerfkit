#!/usr/bin/env python3
# L-1 bekçisi (docs/18 §2, E8-S1 AC): uygulama kaynaklarında hardcoded Türkçe
# KULLANICI metni kalmamalı — taban dil EN, Türkçe yalnız String Catalog'da yaşar.
# Yorumlar Türkçe kalabilir (anayasa dili); yalnız string LİTERALLERİ taranır.
import re
import sys
from pathlib import Path

APP_DIR = Path(__file__).resolve().parent.parent / "apps/ios/KerfKit"
TR_CHARS = re.compile(r"[çğıöşüÇĞİÖŞÜ]")

def stripped_literals(source: str):
    """Yorumları at, string literallerini (satır, içerik) olarak döndür."""
    out, i, line = [], 0, 1
    n = len(source)
    while i < n:
        ch = source[i]
        if ch == "\n":
            line += 1; i += 1
        elif source.startswith("//", i):
            j = source.find("\n", i); i = n if j < 0 else j
        elif source.startswith("/*", i):
            j = source.find("*/", i + 2)
            j = n if j < 0 else j + 2
            line += source.count("\n", i, j); i = j
        elif ch == '"':
            multi = source.startswith('"""', i)
            quote = '"""' if multi else '"'
            j = i + len(quote)
            while j < n:
                if source[j] == "\\":
                    j += 2; continue
                if source.startswith(quote, j):
                    break
                j += 1
            content = source[i + len(quote):j]
            out.append((line, content))
            line += source.count("\n", i, j)
            i = j + len(quote)
        else:
            i += 1
    return out

failures = []
for path in sorted(APP_DIR.rglob("*.swift")):
    for line, content in stripped_literals(path.read_text()):
        if TR_CHARS.search(content):
            failures.append(f"{path.relative_to(APP_DIR.parent.parent.parent)}:{line}: \"{content[:60]}\"")

if failures:
    print("HATA: hardcoded Türkçe kullanıcı metni bulundu (String Catalog'a taşı):")
    print("\n".join(failures))
    sys.exit(1)
print("i18n bekçisi temiz: uygulama kaynaklarında Türkçe literal yok.")
