//
//  AnimationType.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Animation Type

/// Comprehensive animation types for SwiftUI - 50+ production-ready animations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum AnimationType: Hashable, Sendable {
    
    // MARK: - Attention Seekers (8)
    case bounce
    case shake
    case pulse
    case wobble
    case swing
    case heartbeat
    case flash
    case tada
    case jello
    case rubberBand
    
    // MARK: - Entrance Animations (12)
    case fadeIn
    case fadeInUp
    case fadeInDown
    case fadeInLeft
    case fadeInRight
    case slideIn(from: Edge)
    case zoomIn
    case zoomInUp
    case zoomInDown
    case bounceIn
    case bounceInUp
    case bounceInDown
    case flipInX
    case flipInY
    case dropIn
    case rollIn
    
    // MARK: - Exit Animations (12)
    case fadeOut
    case fadeOutUp
    case fadeOutDown
    case fadeOutLeft
    case fadeOutRight
    case slideOut(to: Edge)
    case zoomOut
    case zoomOutUp
    case zoomOutDown
    case bounceOut
    case bounceOutUp
    case bounceOutDown
    case flipOutX
    case flipOutY
    case hinge
    case rollOut
    
    // MARK: - Continuous Animations (8)
    case spin
    case spinReverse
    case float
    case glow
    case breathe
    case shimmer
    case wave
    case orbit
    
    // MARK: - Special Effects (10)
    case morphRect
    case morphCircle
    case morphStar
    case explode
    case implode
    case glitch
    case typewriter
    case countUp
    case confetti
    case ripple
    
    // MARK: - Configuration
    
    /// Default duration for each animation type
    public var defaultDuration: Double {
        switch self {
        case .bounce, .shake, .pulse, .flash:
            return 0.6
        case .heartbeat, .breathe:
            return 1.0
        case .wobble, .swing, .jello, .rubberBand, .tada:
            return 0.8
        case .fadeIn, .fadeOut, .fadeInUp, .fadeInDown, .fadeInLeft, .fadeInRight,
             .fadeOutUp, .fadeOutDown, .fadeOutLeft, .fadeOutRight:
            return 0.4
        case .slideIn, .slideOut:
            return 0.5
        case .zoomIn, .zoomOut, .zoomInUp, .zoomInDown, .zoomOutUp, .zoomOutDown:
            return 0.5
        case .bounceIn, .bounceOut, .bounceInUp, .bounceInDown, .bounceOutUp, .bounceOutDown:
            return 0.75
        case .flipInX, .flipInY, .flipOutX, .flipOutY:
            return 0.6
        case .dropIn, .hinge:
            return 1.0
        case .rollIn, .rollOut:
            return 0.8
        case .spin, .spinReverse:
            return 1.0
        case .float, .glow, .wave, .orbit:
            return 2.0
        case .shimmer:
            return 1.5
        case .morphRect, .morphCircle, .morphStar:
            return 0.6
        case .explode, .implode:
            return 0.8
        case .glitch:
            return 0.5
        case .typewriter:
            return 2.0
        case .countUp:
            return 1.5
        case .confetti:
            return 2.0
        case .ripple:
            return 0.8
        }
    }
    
    /// Whether the animation can repeat
    public var canRepeat: Bool {
        switch self {
        case .spin, .spinReverse, .float, .glow, .breathe, .shimmer, .wave, .orbit, .pulse, .heartbeat:
            return true
        default:
            return false
        }
    }
    
    /// Category for organization
    public var category: AnimationCategory {
        switch self {
        case .bounce, .shake, .pulse, .wobble, .swing, .heartbeat, .flash, .tada, .jello, .rubberBand:
            return .attention
        case .fadeIn, .fadeInUp, .fadeInDown, .fadeInLeft, .fadeInRight,
             .slideIn, .zoomIn, .zoomInUp, .zoomInDown, .bounceIn, .bounceInUp, .bounceInDown,
             .flipInX, .flipInY, .dropIn, .rollIn:
            return .entrance
        case .fadeOut, .fadeOutUp, .fadeOutDown, .fadeOutLeft, .fadeOutRight,
             .slideOut, .zoomOut, .zoomOutUp, .zoomOutDown, .bounceOut, .bounceOutUp, .bounceOutDown,
             .flipOutX, .flipOutY, .hinge, .rollOut:
            return .exit
        case .spin, .spinReverse, .float, .glow, .breathe, .shimmer, .wave, .orbit:
            return .continuous
        case .morphRect, .morphCircle, .morphStar, .explode, .implode, .glitch, .typewriter, .countUp, .confetti, .ripple:
            return .special
        }
    }
}

// MARK: - Animation Category

/// Categories for organizing animations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum AnimationCategory: String, CaseIterable, Sendable {
    case attention = "Attention Seekers"
    case entrance = "Entrances"
    case exit = "Exits"
    case continuous = "Continuous"
    case special = "Special Effects"
    
    public var icon: String {
        switch self {
        case .attention: return "bell.badge"
        case .entrance: return "arrow.right.to.line"
        case .exit: return "arrow.left.to.line"
        case .continuous: return "infinity"
        case .special: return "sparkles"
        }
    }
}

// MARK: - Animation Direction

/// Direction for directional animations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum AnimationDirection: Hashable, Sendable {
    case up
    case down
    case left
    case right
    case clockwise
    case counterClockwise
}
