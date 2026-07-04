#!/bin/sh
# E9-S2b — Android motor parite kanıtı (docs/06 §1 native hat).
# mac'te PariteProbe koşar, Android'de uygulama açılış feneri logcat'ten okunur,
# iki satır birebir karşılaştırılır (istatistikler + placementsHash FNV-1a).
# Önkoşul: ANDROID_HOME + bağlı cihaz/emülatör (adb get-state = device) + APK derli.
# K-17 CI matrisinde emülatörlü işe bağlanacak; şimdilik yerel araç.
set -eu

KOK="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$KOK/apps/android"
APK="$ANDROID_DIR/.build/Android/app/outputs/apk/debug/app-debug.apk"
ADB="${ANDROID_HOME:?ANDROID_HOME gerekli}/platform-tools/adb"

durum="$("$ADB" get-state 2>/dev/null || true)"
[ "$durum" = "device" ] || { echo "HATA: bağlı cihaz/emülatör yok (adb get-state: ${durum:-yok})"; exit 1; }
[ -f "$APK" ] || { echo "HATA: APK yok — önce: cd apps/android/Android && gradle assembleDebug"; exit 1; }

echo "→ mac feneri (PariteProbe)..."
MAC_SATIR="$(cd "$ANDROID_DIR" && swift run -c release PariteProbe 2>/dev/null | grep KERFKIT-PARITE)"
echo "  $MAC_SATIR"

echo "→ Android feneri (kurulum + açılış + logcat)..."
"$ADB" install -r "$APK" >/dev/null
"$ADB" logcat -c
"$ADB" shell monkey -p app.kerfkit -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
AND_SATIR=""
i=0
while [ $i -lt 24 ]; do
    AND_SATIR="$("$ADB" logcat -d 2>/dev/null | grep -o 'KERFKIT-PARITE.*' | head -1 || true)"
    [ -n "$AND_SATIR" ] && break
    sleep 5; i=$((i+1))
done
[ -n "$AND_SATIR" ] || { echo "HATA: fener 120sn içinde logcat'e düşmedi"; exit 1; }
echo "  $AND_SATIR"

if [ "$MAC_SATIR" = "$AND_SATIR" ]; then
    echo "PARITE TAM: mac = Android (bit-eşit)."
else
    echo "PARITE KIRIK:"
    echo "  mac    : $MAC_SATIR"
    echo "  android: $AND_SATIR"
    exit 1
fi
