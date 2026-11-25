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
        // the `Partition` Frame module: addresses.frame and map.frame in ~/.config/partition
        .library(
            name: "PartitionFrame",
            targets: ["PartitionFrame"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-lco/Primitives.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Path.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Milieu.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/IO.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Readers.git", branch: "master"),
        .package(url: "https://github.com/lco-langs/Frame.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Partition",
            dependencies: [
                "Primitives",
                "Path",
                "Milieu",
                "IO",
            ],
        ),
        .target(
            name: "PartitionFrame",
            dependencies: [
                "Partition",
                "IO",
                "Readers",
                .product(name: "Frame", package: "Frame"),
            ],
        ),
    ],
    swiftLanguageModes: [.v6]
)
