//
//  AnimationModifier.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Main Animation Modifier

/// High-performance animation modifier for SwiftUI views
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct AnimationModifier: ViewModifier {
    
    // MARK: - Properties
    
    let animationType: AnimationType
    let duration: Double
    let delay: Double
    let repeatCount: Int
    let repeatForever: Bool
    let autoReverses: Bool
    let spring: Spring?
    let reducedMotionBehavior: ReducedMotionBehavior
    
    @Binding var trigger: Bool
    @State private var animationProgress: CGFloat = 0
    @State private var isAnimating: Bool = false
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Initialization
    
    public init(
        type: AnimationType,
        trigger: Binding<Bool>,
        duration: Double? = nil,
        delay: Double = 0,
        repeatCount: Int = 1,
        repeatForever: Bool = false,
        autoReverses: Bool = false,
        spring: Spring? = nil,
        reducedMotionBehavior: ReducedMotionBehavior = .fade
    ) {
        self.animationType = type
        self._trigger = trigger
        self.duration = duration ?? type.defaultDuration
        self.delay = delay
        self.repeatCount = repeatCount
        self.repeatForever = repeatForever
        self.autoReverses = autoReverses
        self.spring = spring
        self.reducedMotionBehavior = reducedMotionBehavior
    }
    
    // MARK: - Body
    
    public func body(content: Content) -> some View {
        content
            .modifier(AnimationEffectModifier(
                type: animationType,
                progress: animationProgress,
                reduceMotion: reduceMotion,
                reducedMotionBehavior: reducedMotionBehavior
            ))
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    startAnimation()
                }
            }
    }
    
    // MARK: - Private Methods
    
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let animation = createAnimation()
        
        withAnimation(animation) {
            animationProgress = 1
        }
        
        // Reset after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + delay) {
            if !repeatForever {
                animationProgress = 0
                isAnimating = false
                trigger = false
            }
        }
    }
    
    private func createAnimation() -> Animation {
        var animation: Animation
        
        if let spring = spring {
            animation = .spring(spring)
        } else {
            animation = .easeInOut(duration: duration)
        }
        
        if delay > 0 {
            animation = animation.delay(delay)
        }
        
        if repeatForever {
            animation = animation.repeatForever(autoreverses: autoReverses)
        } else if repeatCount > 1 {
            animation = animation.repeatCount(repeatCount, autoreverses: autoReverses)
        }
        
        return animation
    }
}

// MARK: - Animation Effect Modifier

/// Applies the actual visual effect based on animation type
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct AnimationEffectModifier: ViewModifier {
    
    let type: AnimationType
    let progress: CGFloat
    let reduceMotion: Bool
    let reducedMotionBehavior: ReducedMotionBehavior
    
    func body(content: Content) -> some View {
        if reduceMotion {
            content
                .opacity(reducedMotionBehavior == .fade ? Double(progress) : 1)
        } else {
            applyAnimation(to: content)
        }
    }
    
    @ViewBuilder
    private func applyAnimation(to content: Content) -> some View {
        switch type {
        // MARK: Attention Seekers
        case .bounce:
            content
                .scaleEffect(1 + 0.2 * sin(progress * .pi * 2))
                .offset(y: -20 * sin(progress * .pi * 2) * (1 - progress))
            
        case .shake:
            content
                .offset(x: 10 * sin(progress * .pi * 6) * (1 - progress))
            
        case .pulse:
            content
                .scaleEffect(1 + 0.1 * sin(progress * .pi * 2))
                .opacity(0.7 + 0.3 * cos(progress * .pi * 2))
            
        case .wobble:
            content
                .rotationEffect(.degrees(15 * sin(progress * .pi * 4) * (1 - progress)))
                .offset(x: 10 * sin(progress * .pi * 6) * (1 - progress))
            
        case .swing:
            content
                .rotationEffect(.degrees(20 * sin(progress * .pi * 3) * (1 - progress)), anchor: .top)
            
        case .heartbeat:
            let scale = 1 + 0.3 * (sin(progress * .pi * 4) > 0 ? 1 : 0) * (1 - progress)
            content
                .scaleEffect(scale)
            
        case .flash:
            content
                .opacity(progress < 0.5 ? (progress * 4).truncatingRemainder(dividingBy: 2) : 1)
            
        case .tada:
            let rotation = 15 * sin(progress * .pi * 6) * (1 - progress)
            let scale = 1 + 0.1 * sin(progress * .pi * 2)
            content
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
            
        case .jello:
            let skewX = 12.5 * sin(progress * .pi * 4) * (1 - progress)
            content
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: tan(skewX * .pi / 180), d: 1, tx: 0, ty: 0))
            
        case .rubberBand:
            let scaleX = 1 + 0.25 * sin(progress * .pi * 4) * (1 - progress)
            let scaleY = 1 - 0.25 * sin(progress * .pi * 4) * (1 - progress)
            content
                .scaleEffect(x: scaleX, y: scaleY)
            
        // MARK: Entrance Animations
        case .fadeIn:
            content
                .opacity(Double(progress))
            
        case .fadeInUp:
            content
                .opacity(Double(progress))
                .offset(y: 50 * (1 - progress))
            
        case .fadeInDown:
            content
                .opacity(Double(progress))
                .offset(y: -50 * (1 - progress))
            
        case .fadeInLeft:
            content
                .opacity(Double(progress))
                .offset(x: -50 * (1 - progress))
            
        case .fadeInRight:
            content
                .opacity(Double(progress))
                .offset(x: 50 * (1 - progress))
            
        case .slideIn(let edge):
            content
                .offset(
                    x: edge == .leading ? -200 * (1 - progress) : (edge == .trailing ? 200 * (1 - progress) : 0),
                    y: edge == .top ? -200 * (1 - progress) : (edge == .bottom ? 200 * (1 - progress) : 0)
                )
            
        case .zoomIn:
            content
                .scaleEffect(progress)
                .opacity(Double(progress))
            
        case .zoomInUp:
            content
                .scaleEffect(progress)
                .opacity(Double(progress))
                .offset(y: 100 * (1 - progress))
            
        case .zoomInDown:
            content
                .scaleEffect(progress)
                .opacity(Double(progress))
                .offset(y: -100 * (1 - progress))
            
        case .bounceIn:
            let bounceProgress = bounceEaseOut(progress)
            content
                .scaleEffect(bounceProgress)
                .opacity(Double(min(progress * 2, 1)))
            
        case .bounceInUp:
            let bounceProgress = bounceEaseOut(progress)
            content
                .scaleEffect(bounceProgress)
                .offset(y: 200 * (1 - bounceProgress))
            
        case .bounceInDown:
            let bounceProgress = bounceEaseOut(progress)
            content
                .scaleEffect(bounceProgress)
                .offset(y: -200 * (1 - bounceProgress))
            
        case .flipInX:
            content
                .rotation3DEffect(.degrees(90 * (1 - progress)), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
                .opacity(Double(progress))
            
        case .flipInY:
            content
                .rotation3DEffect(.degrees(90 * (1 - progress)), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                .opacity(Double(progress))
            
        case .dropIn:
            let bounceProgress = bounceEaseOut(progress)
            content
                .offset(y: -300 * (1 - bounceProgress))
                .opacity(Double(min(progress * 2, 1)))
            
        case .rollIn:
            content
                .rotationEffect(.degrees(-360 * (1 - progress)))
                .offset(x: -200 * (1 - progress))
                .opacity(Double(progress))
            
        // MARK: Exit Animations
        case .fadeOut:
            content
                .opacity(Double(1 - progress))
            
        case .fadeOutUp:
            content
                .opacity(Double(1 - progress))
                .offset(y: -50 * progress)
            
        case .fadeOutDown:
            content
                .opacity(Double(1 - progress))
                .offset(y: 50 * progress)
            
        case .fadeOutLeft:
            content
                .opacity(Double(1 - progress))
                .offset(x: -50 * progress)
            
        case .fadeOutRight:
            content
                .opacity(Double(1 - progress))
                .offset(x: 50 * progress)
            
        case .slideOut(let edge):
            content
                .offset(
                    x: edge == .leading ? -200 * progress : (edge == .trailing ? 200 * progress : 0),
                    y: edge == .top ? -200 * progress : (edge == .bottom ? 200 * progress : 0)
                )
            
        case .zoomOut:
            content
                .scaleEffect(1 - progress)
                .opacity(Double(1 - progress))
            
        case .zoomOutUp:
            content
                .scaleEffect(1 - progress)
                .opacity(Double(1 - progress))
                .offset(y: -100 * progress)
            
        case .zoomOutDown:
            content
                .scaleEffect(1 - progress)
                .opacity(Double(1 - progress))
                .offset(y: 100 * progress)
            
        case .bounceOut:
            let bounceProgress = 1 - bounceEaseOut(1 - progress)
            content
                .scaleEffect(1 - bounceProgress)
                .opacity(Double(1 - progress))
            
        case .bounceOutUp:
            content
                .scaleEffect(max(0.001, 1 - progress))
                .offset(y: -200 * progress)
            
        case .bounceOutDown:
            content
                .scaleEffect(max(0.001, 1 - progress))
                .offset(y: 200 * progress)
            
        case .flipOutX:
            content
                .rotation3DEffect(.degrees(90 * progress), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
                .opacity(Double(1 - progress))
            
        case .flipOutY:
            content
                .rotation3DEffect(.degrees(90 * progress), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                .opacity(Double(1 - progress))
            
        case .hinge:
            content
                .rotationEffect(.degrees(80 * progress), anchor: .topLeading)
                .offset(y: 300 * pow(progress, 2))
                .opacity(Double(1 - progress))
            
        case .rollOut:
            content
                .rotationEffect(.degrees(360 * progress))
                .offset(x: 200 * progress)
                .opacity(Double(1 - progress))
            
        // MARK: Continuous Animations
        case .spin:
            content
                .rotationEffect(.degrees(360 * progress))
            
        case .spinReverse:
            content
                .rotationEffect(.degrees(-360 * progress))
            
        case .float:
            content
                .offset(y: 10 * sin(progress * .pi * 2))
            
        case .glow:
            content
                .shadow(color: .white.opacity(0.5 + 0.5 * sin(progress * .pi * 2)), radius: 10 + 5 * sin(progress * .pi * 2))
            
        case .breathe:
            content
                .scaleEffect(1 + 0.05 * sin(progress * .pi * 2))
                .opacity(0.8 + 0.2 * sin(progress * .pi * 2))
            
        case .shimmer:
            content
                .overlay(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: UnitPoint(x: -0.5 + progress * 2, y: 0.5),
                        endPoint: UnitPoint(x: 0.5 + progress * 2, y: 0.5)
                    )
                    .mask(content)
                )
            
        case .wave:
            content
                .offset(x: 5 * sin(progress * .pi * 4), y: 5 * cos(progress * .pi * 4))
            
        case .orbit:
            let angle = progress * .pi * 2
            content
                .offset(x: 20 * cos(angle), y: 20 * sin(angle))
            
        // MARK: Special Effects
        case .morphRect, .morphCircle, .morphStar:
            content
                .clipShape(MorphingShape(type: type, progress: progress))
            
        case .explode:
            content
                .scaleEffect(1 + 2 * progress)
                .opacity(Double(1 - progress))
            
        case .implode:
            content
                .scaleEffect(max(0.001, 1 - progress))
                .opacity(Double(1 - progress))
            
        case .glitch:
            content
                .offset(x: CGFloat.random(in: -5...5) * (1 - progress))
                .overlay(
                    content
                        .foregroundStyle(.red.opacity(0.5))
                        .offset(x: 3 * (1 - progress))
                        .blendMode(.screen)
                )
                .overlay(
                    content
                        .foregroundStyle(.cyan.opacity(0.5))
                        .offset(x: -3 * (1 - progress))
                        .blendMode(.screen)
                )
            
        case .typewriter, .countUp:
            content
                .mask(
                    Rectangle()
                        .size(width: .infinity, height: .infinity)
                        .offset(x: -200 * (1 - progress))
                )
            
        case .confetti:
            content
            
        case .ripple:
            content
                .overlay(
                    Circle()
                        .stroke(lineWidth: 2)
                        .scaleEffect(1 + progress * 2)
                        .opacity(Double(1 - progress))
                )
        }
    }
    
    // MARK: - Helper Functions
    
    private func bounceEaseOut(_ t: CGFloat) -> CGFloat {
        if t < 1/2.75 {
            return 7.5625 * t * t
        } else if t < 2/2.75 {
            let t2 = t - 1.5/2.75
            return 7.5625 * t2 * t2 + 0.75
        } else if t < 2.5/2.75 {
            let t2 = t - 2.25/2.75
            return 7.5625 * t2 * t2 + 0.9375
        } else {
            let t2 = t - 2.625/2.75
            return 7.5625 * t2 * t2 + 0.984375
        }
    }
}

// MARK: - Morphing Shape

/// Shape that morphs between different forms
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct MorphingShape: Shape {
    let type: AnimationType
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        switch type {
        case .morphCircle:
            return morphToCircle(in: rect)
        case .morphStar:
            return morphToStar(in: rect)
        default:
            return morphToRect(in: rect)
        }
    }
    
    private func morphToRect(in rect: CGRect) -> Path {
        let cornerRadius = 20 * (1 - progress)
        return Path(roundedRect: rect, cornerRadius: cornerRadius)
    }
    
    private func morphToCircle(in rect: CGRect) -> Path {
        let maxRadius = min(rect.width, rect.height) / 2
        let currentRadius = maxRadius * progress
        let cornerRadius = currentRadius
        return Path(roundedRect: rect, cornerRadius: cornerRadius)
    }
    
    private func morphToStar(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5
        
        for i in 0..<(points * 2) {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let interpolatedRadius = outerRadius - (outerRadius - radius) * progress
            let x = center.x + cos(angle) * interpolatedRadius
            let y = center.y + sin(angle) * interpolatedRadius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Reduced Motion Behavior

/// Behavior when reduce motion is enabled
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum ReducedMotionBehavior: Sendable {
    case none       // No animation
    case fade       // Simple fade
    case instant    // Instant transition
}

// MARK: - View Extension

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension View {
    
    /// Applies an animation to the view
    /// - Parameters:
    ///   - type: The animation type to apply
    ///   - trigger: Binding that triggers the animation when set to true
    ///   - duration: Custom duration (defaults to animation's default duration)
    ///   - delay: Delay before animation starts
    ///   - repeatCount: Number of times to repeat
    ///   - repeatForever: Whether to repeat forever
    ///   - autoReverses: Whether animation auto-reverses
    ///   - spring: Optional spring configuration
    ///   - reducedMotionBehavior: Behavior when reduce motion is enabled
    /// - Returns: Modified view with animation
    func animate(
        _ type: AnimationType,
        trigger: Binding<Bool>,
        duration: Double? = nil,
        delay: Double = 0,
        repeatCount: Int = 1,
        repeatForever: Bool = false,
        autoReverses: Bool = false,
        spring: Spring? = nil,
        reducedMotionBehavior: ReducedMotionBehavior = .fade
    ) -> some View {
        modifier(AnimationModifier(
            type: type,
            trigger: trigger,
            duration: duration,
            delay: delay,
            repeatCount: repeatCount,
            repeatForever: repeatForever,
            autoReverses: autoReverses,
            spring: spring,
            reducedMotionBehavior: reducedMotionBehavior
        ))
    }
}
