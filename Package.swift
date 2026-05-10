// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Partition",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Partition",
            targets: ["Partition"]
        ),
        .executable(
            name: "partest",
            targets: ["PartitionTestFlows"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Primitives.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Path.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Milieu.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/TestFlows.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Partition",
            dependencies: [
                "Primitives",
                "Path",
                "Milieu",
            ],
        ),
        .executableTarget(
            name: "PartitionTestFlows",
            dependencies: [
                "Partition",
                "Path",
                "TestFlows",
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
