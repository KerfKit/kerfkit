#!/usr/bin/env bash
# Mac'te tek komutluk kurulum: gh CLI ile private repo olusturur ve push'lar.
# Gereksinim: `gh auth login` yapilmis olmali. Kullanim: ./tools/bootstrap-github.sh [owner]
set -euo pipefail
OWNER="${1:-TapForge}"
gh repo create "$OWNER/kerf" --private --source=. --remote=origin --push \
  --description "Kesim planlayici — 2D/1D cut list optimizer (iOS/Android/Web)"
echo "Tamam: https://github.com/$OWNER/kerf"
