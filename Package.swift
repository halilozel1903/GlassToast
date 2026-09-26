// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "GlassToast",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "GlassToast", targets: ["GlassToast"]),
    ],
    targets: [
        .target(name: "GlassToast"),
        .testTarget(name: "GlassToastTests", dependencies: ["GlassToast"]),
    ]
)
