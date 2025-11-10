// swift-tools-version: 5.10

import PackageDescription

let exampleDependencies: [Target.Dependency] = [
    .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
    .product(name: "DefaultBackend", package: "swift-cross-ui"),
    .product(name: "BetterSyncSCUI", package: "bettersyncscui"),
    .product(name: "BetterSync", package: "bettersync"),
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
        //.package(path: "../../BetterSync"),
	.package(
	    url: "https://github.com/miakoring/BetterSync.git",
	    branch: "main"
	)
    ],
    targets: [
        .executableTarget(
            name: "BasicExample",
            dependencies: exampleDependencies
        )
    ]
)
