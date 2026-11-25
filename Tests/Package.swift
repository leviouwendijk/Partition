// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PartitionTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "partest",
            targets: ["PartitionTestFlows"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-lco/Path.git", branch: "master"),
        .package(url: "https://github.com/swift-tooling/TestFlows.git", branch: "master"),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "PartitionTestFlows",
            dependencies: [
                .product(name: "Partition", package: "Partition"),
                "Path",
                "TestFlows",
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
