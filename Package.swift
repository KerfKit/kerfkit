// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "kerf",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CutCore", targets: ["CutCore"]),
        .library(name: "CutModels", targets: ["CutModels"]),
    ],
    targets: [
        .target(name: "CutModels"),
        .target(name: "CutCore", dependencies: ["CutModels"]),
        .testTarget(name: "CutCoreTests", dependencies: ["CutCore"]),
        .testTarget(name: "GoldenTests", dependencies: ["CutCore"], resources: [.copy("vectors")]),
    ]
)
