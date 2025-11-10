// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "BetterSyncSCUI",
    platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .macCatalyst(.v16), .visionOS(.v1)],
    products: [
        .library(
            name: "BetterSyncSCUI",
            targets: ["BetterSyncSCUI", "BetterSyncSCUIMacros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/miakoring/BetterSync", branch: "main"),
        //.package(name: "BetterSync", path: "../BetterSync"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0" ..< "601.0.0"),
        .package(url: "https://github.com/miakoring/swift-cross-ui.git", branch: "usemylatestchanges"),
    ],
    targets: [
        .target(
            name: "BetterSyncSCUI",
            dependencies: [
                "BetterSyncSCUIMacros",
                .byName(name: "BetterSync"),
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
            ]
        ),
        .macro(
            name: "BetterSyncSCUIMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "BetterSyncSCUITests",
            dependencies: ["BetterSyncSCUI"]
        ),
    ]
)
