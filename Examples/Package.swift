// swift-tools-version: 5.10

import PackageDescription

let exampleDependencies: [Target.Dependency] = [
    .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
    .product(name: "DefaultBackend", package: "swift-cross-ui"),
    .product(name: "VeinSCUI", package: "vein-scui"),
    .product(name: "Vein", package: "vein"),
]

let package = Package(
    name: "Examples",
    platforms:  [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .macCatalyst(.v16), .visionOS(.v1)],
    dependencies: [
        .package(
            url: "https://github.com/stackotter/swift-cross-ui",
            branch: "main"
        ),
        .package(path: "../"),
        .package(path: "../../Vein"),
        //.package(url: "https://github.com/amethystsoft/vein", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "BasicExample",
            dependencies: exampleDependencies
        )
    ]
)
