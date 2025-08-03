// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIAnimationMasterclass",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SwiftUIAnimationMasterclass",
            targets: ["SwiftUIAnimationMasterclass"]
        ),
        .library(
            name: "AnimationComponents",
            targets: ["AnimationComponents"]
        ),
        .library(
            name: "AnimationUtilities",
            targets: ["AnimationUtilities"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftUIAnimationMasterclass",
            dependencies: [
                "AnimationComponents",
                "AnimationUtilities",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            path: "Sources/Animation"
        ),
        .target(
            name: "AnimationComponents",
            dependencies: ["AnimationUtilities"],
            path: "Sources/Components"
        ),
        .target(
            name: "AnimationUtilities",
            path: "Sources/Utilities"
        ),
        .testTarget(
            name: "SwiftUIAnimationMasterclassTests",
            dependencies: [
                "SwiftUIAnimationMasterclass",
                "AnimationComponents",
                "AnimationUtilities"
            ],
            path: "Tests"
        )
    ]
) 