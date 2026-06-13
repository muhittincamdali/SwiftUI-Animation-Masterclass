// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftUIAnimationMasterclass",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SwiftUIAnimationMasterclass", targets: ["SwiftUIAnimationMasterclass"]),
    ],
    targets: [
        .target(
            name: "SwiftUIAnimationMasterclass",
            path: "Sources/SwiftUIAnimationMasterclass",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftUIAnimationMasterclassTests",
            dependencies: ["SwiftUIAnimationMasterclass"]
        )
    ]
)
