//
//  SwiftUIAnimationMasterclass.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - SwiftUI Animation Masterclass
// The most comprehensive SwiftUI animation library
// 50+ production-ready animations, zero dependencies

/// Main entry point for SwiftUI Animation Masterclass
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SwiftUIAnimationMasterclass {
    
    /// Library version
    public static let version = "2.0.0"
    
    /// Library name
    public static let name = "SwiftUI Animation Masterclass"
    
    /// Check if reduce motion is enabled
    @MainActor
    public static var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    private init() {}
}

// MARK: - Re-exports

// Animations
@_exported import struct SwiftUI.Animation

// Animation Types
public typealias SAMAnimationType = AnimationType
public typealias SAMAnimationCategory = AnimationCategory

// Transitions
public typealias SAMTransitionPresets = TransitionPresets
public typealias SAMPageTransitionType = PageTransitionType

// Loading
public typealias SAMLoadingAnimationType = LoadingAnimationType
public typealias SAMLoadingView = LoadingView
public typealias SAMLoadingButton = LoadingButton

// Micro-interactions
public typealias SAMMicroInteractionType = MicroInteractionType
public typealias SAMSuccessCheckView = SuccessCheckView
public typealias SAMLikeHeartButton = LikeHeartButton
public typealias SAMAddToCartButton = AddToCartButton
public typealias SAMAnimatedToggle = AnimatedToggle
public typealias SAMExpandableView = ExpandableView

// 3D
public typealias SAMFlipCard = FlipCard
public typealias SAMCube3D = Cube3D
public typealias SAMCarousel3D = Carousel3D

// Particles
public typealias SAMParticleEffectType = ParticleEffectType
public typealias SAMConfettiView = ConfettiView
public typealias SAMSnowView = SnowView
public typealias SAMSparkleView = SparkleView
public typealias SAMBubblesView = BubblesView

// Physics
public typealias SAMSpringPresets = SpringPresets
public typealias SAMPhysicsAnimationType = PhysicsAnimationType
public typealias SAMPendulumView = PendulumView

// Keyframes
public typealias SAMKeyframePresets = KeyframePresets
public typealias SAMKeyframeAnimationState = KeyframeAnimationState
public typealias SAMAnimationPhase = AnimationPhase

// Paths
public typealias SAMPathPresets = PathPresets
public typealias SAMDrawingPathView = DrawingPathView
public typealias SAMPathFollowingView = PathFollowingView
public typealias SAMSignatureView = SignatureView
