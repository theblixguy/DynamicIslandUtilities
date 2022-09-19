// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DynamicIslandUtilities",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "DynamicIslandUtilities",
            targets: ["DynamicIslandUtilities"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DynamicIslandUtilities",
            dependencies: []),
    ]
)
