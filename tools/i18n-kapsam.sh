#!/bin/bash
# L-1b kapsama kanıtı (yerel, macOS): derleyici çıkarımı ↔ katalog çift yönlü diff +
# çevirisiz anahtar taraması. Xcode editöründeki STALE rozetleri IDE indeksidir;
# otorite budur. L-2/L-3 kapılarında merge öncesi koşulur (docs/18 §5).
set -euo pipefail
cd "$(dirname "$0")/../apps/ios"

OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
xcodebuild -exportLocalizations -project KerfKit.xcodeproj \
  -localizationPath "$OUT" -exportLanguage tr -exportLanguage de -exportLanguage fr -exportLanguage es -exportLanguage it -quiet 2>/dev/null

python3 - "$OUT" <<'PYEOF'
import glob, json, re, sys
out = sys.argv[1]
missing_target, extracted = [], set()
for xliff in glob.glob(f"{out}/*.xcloc/Localized Contents/*.xliff"):
    s = open(xliff, encoding='utf-8').read()
    for uid, body in re.findall(r'<trans-unit id="([^"]+)"((?:(?!</trans-unit>).)*?)</trans-unit>', s, re.S):
        uid = uid.replace('&#10;', '\n').replace('\r', '')
        extracted.add(uid)
        if '<target' not in body:
            missing_target.append(uid)

catalog = {k.replace('\r', '') for k in json.load(open('KerfKit/Localizable.xcstrings'))['strings']}
plist_keys = {'CFBundleDisplayName', 'CFBundleName'}
dead = sorted(catalog - extracted)  # katalogda var, derleyici çıkarmıyor

fail = False
if missing_target:
    print("HATA — çevirisiz anahtarlar:"); [print(" ", k) for k in missing_target]; fail = True
if dead:
    print("UYARI — kod artık kullanmıyor (temizlik adayı):"); [print(" ", k) for k in dead]
if not fail:
    print(f"i18n kapsam OK: {len(extracted)} anahtar çıkarıldı, tümü çevirili.")
sys.exit(1 if fail else 0)
PYEOF
