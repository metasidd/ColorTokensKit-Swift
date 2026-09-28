// swift-tools-version: 5.10
// Measures what drawing ColorTokensKit colors costs. Separate from the library's package, so apps never build it.
// Run from the repository root: swift run -c release --package-path Benchmarks

import PackageDescription

let package = Package(
    name: "ColorTokensKitBenchmarks",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    dependencies: [
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "ColorTokensKitBenchmarks",
            dependencies: [
                .product(name: "ColorTokensKit", package: "ColorTokensKit"),
            ]
        ),
    ]
)
