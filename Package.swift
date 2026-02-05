// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIAnimationMasterclass",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftUIAnimationMasterclass",
            targets: ["SwiftUIAnimationMasterclass"]
        )
    ],
    targets: [
        .target(
            name: "SwiftUIAnimationMasterclass",
            dependencies: [],
            path: "Sources",
            exclude: ["Core/MainFramework.swift"],
            sources: [
                "SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.swift",
                "Animations/AnimationType.swift",
                "Animations/AnimationModifier.swift",
                "Transitions/TransitionPresets.swift",
                "Loading/LoadingAnimations.swift",
                "MicroInteractions/MicroInteractions.swift",
                "PageTransitions/PageTransitions.swift",
                "Physics/PhysicsAnimations.swift",
                "Keyframes/KeyframeAnimations.swift",
                "Path/PathAnimations.swift",
                "3D/Transform3D.swift",
                "Particles/ParticleEffects.swift",
                "Animation/AnimationEngine.swift"
            ]
        ),
        .testTarget(
            name: "SwiftUIAnimationMasterclassTests",
            dependencies: ["SwiftUIAnimationMasterclass"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
