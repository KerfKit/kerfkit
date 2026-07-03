// swift-tools-version: 6.0
import PackageDescription

// K-30 (Android paritesi): skipstone eklentisi motor kaynaklarını Kotlin'e çevirir;
// motor kodu değişmez (saf Swift, stdlib-only kuralı aynen geçerli). skip-* bağımlılıkları
// yalnız çeviri/test altyapısıdır (Ahmet onayı: Tem 2026, Android öne çekildi).
let package = Package(
    name: "kerf",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CutCore", targets: ["CutCore"]),
        .library(name: "CutModels", targets: ["CutModels"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.6.0"),
        .package(url: "https://source.skip.tools/skip-lib.git", from: "1.0.0"),
        .package(url: "https://source.skip.tools/skip-foundation.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "CutModels",
                dependencies: [.product(name: "SkipLib", package: "skip-lib")],
                plugins: [.plugin(name: "skipstone", package: "skip")]),
        // SkipFoundation yalnız Kotlin tarafı test cephesi için (Bundle/JSONDecoder);
        // motor Swift kaynakları stdlib-only kalır — Sources/CutCore'da Foundation import YASAK.
        .target(name: "CutCore",
                dependencies: ["CutModels",
                               .product(name: "SkipFoundation", package: "skip-foundation")],
                plugins: [.plugin(name: "skipstone", package: "skip")]),
        // Birim bekçileri macOS-yalnız; Android parite kanıtı golden koşucudur (CutCoreTests —
        // Skip konvansiyonu: <Modül>Tests, CutCore'un Kotlin test modülü olarak çevrilir).
        .testTarget(name: "CutCoreUnitTests", dependencies: ["CutCore"]),
        .testTarget(name: "CutCoreTests",
                    dependencies: ["CutCore",
                                   .product(name: "SkipTest", package: "skip"),
                                   .product(name: "SkipFoundation", package: "skip-foundation")],
                    resources: [.copy("vectors")],
                    plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
