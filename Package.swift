// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "BetterSyncSCUI",
    platforms: [.macOS(.v13), .iOS(.v14), .tvOS(.v14), .macCatalyst(.v14), .visionOS(.v1)],
    products: [
        .library(
            name: "BetterSyncSCUI",
            targets: ["BetterSyncSCUI", "BetterSyncSCUIMacros"]
        ),
    ],
    dependencies: [
        //.package(url: "https://github.com/miakoring/BetterSync", branch: "main"),
        .package(name: "BetterSync", path: "~/Documents/Fork/BetterSync"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.4"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "5.0.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0" ..< "601.0.0"),
    ],
    targets: [
        .target(
            name: "BetterSyncSCUI",
            dependencies: [
                .byName(name: "BetterSync")
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
