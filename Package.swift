// swift-tools-version: 6.0
import PackageDescription

// K-30 (Android paritesi): skipstone eklentisi motor kaynaklarını Kotlin'e çevirir;
// motor kodu değişmez (saf Swift, stdlib-only kuralı aynen geçerli).
// K-10/K-11: CutProj (.cutproj şeması) + CutPersist (GRDB) uygulama katmanıdır — motor değil;
// skipstone'a dahil edilmez (Android karşılığı K-31'de SkipSQL ile). GRDB Linux'ta
// desteklenmediğinden CutPersist yalnız Apple platformlarında derlenir (CI ubuntu → atlar;
// macOS kapsaması K-17 CI matrisinde).

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://source.skip.tools/skip.git", from: "1.6.0"),
    .package(url: "https://source.skip.tools/skip-lib.git", from: "1.0.0"),
    .package(url: "https://source.skip.tools/skip-foundation.git", from: "1.0.0"),
]

var packageTargets: [Target] = [
    .target(name: "CutModels",
            dependencies: [.product(name: "SkipLib", package: "skip-lib")],
            plugins: [.plugin(name: "skipstone", package: "skip")]),
    // SkipFoundation yalnız Kotlin tarafı test cephesi için (Bundle/JSONDecoder);
    // motor Swift kaynakları stdlib-only kalır — Sources/CutCore'da Foundation import YASAK.
    .target(name: "CutCore",
            dependencies: ["CutModels",
                           .product(name: "SkipFoundation", package: "skip-foundation")],
            plugins: [.plugin(name: "skipstone", package: "skip")]),
    .target(name: "CutProj", dependencies: ["CutModels"]),
    // Birim bekçileri macOS-yalnız; Android parite kanıtı golden koşucudur (CutCoreTests —
    // Skip konvansiyonu: <Modül>Tests, CutCore'un Kotlin test modülü olarak çevrilir).
    .testTarget(name: "CutCoreUnitTests", dependencies: ["CutCore"]),
    .testTarget(name: "CutProjTests", dependencies: ["CutProj"]),
    .testTarget(name: "CutCoreTests",
                dependencies: ["CutCore",
                               .product(name: "SkipTest", package: "skip"),
                               .product(name: "SkipFoundation", package: "skip-foundation")],
                resources: [.copy("vectors")],
                plugins: [.plugin(name: "skipstone", package: "skip")]),
]

#if !os(Linux)
packageDependencies.append(.package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"))
packageTargets.append(.target(name: "CutPersist",
                              dependencies: ["CutProj", .product(name: "GRDB", package: "GRDB.swift")]))
packageTargets.append(.testTarget(name: "CutPersistTests", dependencies: ["CutPersist"]))
#endif

var packageProducts: [Product] = [
    .library(name: "CutCore", targets: ["CutCore"]),
    .library(name: "CutModels", targets: ["CutModels"]),
    .library(name: "CutProj", targets: ["CutProj"]),
]
#if !os(Linux)
packageProducts.append(.library(name: "CutPersist", targets: ["CutPersist"]))
#endif

let package = Package(
    name: "kerfkit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: packageProducts,
    dependencies: packageDependencies,
    targets: packageTargets
)
