// swift-tools-version: 5.10

import PackageDescription

let exampleDependencies: [Target.Dependency] = [
    .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
    .product(name: "DefaultBackend", package: "swift-cross-ui"),
    .byName(name: "BetterSyncSCUI"),
    .byName(name: "BetterSync"),
]

let package = Package(
    name: "Examples",
    platforms:  [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .macCatalyst(.v16), .visionOS(.v1)],
    dependencies: [
        .package(
            url: "https://github.com/miakoring/swift-cross-ui",
            branch: "usemylatestchanges"
        ),
        .package(path: "../"),
        .package(path: "../../BetterSync"),
    ],
    targets: [
        .executableTarget(
            name: "BasicExample",
            dependencies: exampleDependencies
        )
    ]
)
