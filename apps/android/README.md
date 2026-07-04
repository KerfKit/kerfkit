# KerfKit Android (K-31 — E9-S1 iskelet)

Skip Fuse çift-platform app projesi: SwiftUI kodu Android'de **native Swift**
derlenir, UI Compose'a köprülenir (docs/06 §1). Motor `CutCore`/`CutModels`
kök paketten yerel bağımlılıkla gelir — tek kaynak, transpile yok.

## Derleme

```sh
# Swift tarafı (mac doğrulaması)
cd apps/android && swift build

# Android APK (ANDROID_HOME şart; Swift Android SDK: `skip android sdk install`)
cd Android && ANDROID_HOME=~/Library/Android/sdk gradle assembleDebug
# çıktı: .build/Android/app/outputs/apk/debug/app-debug.apk
```

- Kimlikler: `applicationId = app.kerfkit` (Skip.env); iç Kotlin paketi `kerf.kit`
  (Skip modül adından türetir — değiştirme).
- Yerelleştirme: `Sources/KerfKit/Resources/Localizable.xcstrings` — iOS kataloğunun
  kopyası (docs/18 §5.2c); anahtar eklerken iki kataloğu senkron tut.
- Bilinen iskelet sınırları + Compose köprü notları: docs/13 "Android notları".
- `metadata/` = Play Store çok-dilli ASO metinleri (L-4; fastlane supply ile
  mağaza fazında yüklenir).
