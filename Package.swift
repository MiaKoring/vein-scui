// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "vein-scui",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .macCatalyst(.v16), .visionOS(.v1)],
    products: [
        .library(
            name: "VeinSCUI",
            targets: ["VeinSCUI", "VeinSCUIMacros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/amethystsoft/vein", branch: "main"),
        //.package(name: "Vein", path: "../vein"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0" ... "610.0.0"),
        .package(url: "https://github.com/stackotter/swift-cross-ui.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "VeinSCUI",
            dependencies: [
                "VeinSCUIMacros",
                .product(name: "Vein", package: "vein"),
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
            ]
        ),
        .macro(
            name: "VeinSCUIMacros",
            dependencies: [
                .product(name: "CommonVeinMacroLogic", package: "vein"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "VeinSCUITests",
            dependencies: ["VeinSCUI"]
        ),
    ]
)
