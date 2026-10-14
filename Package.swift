// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftUIAnimationMasterclass",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SwiftUIAnimationMasterclass", targets: ["SwiftUIAnimationMasterclass"])
    ],
    targets: [
        .target(
            name: "SwiftUIAnimationMasterclass",
            path: "Sources/SwiftUIAnimationMasterclass"
        )
    ]
)
