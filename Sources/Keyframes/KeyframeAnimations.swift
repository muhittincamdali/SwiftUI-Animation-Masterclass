//
//  KeyframeAnimations.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Keyframe Animation State

/// State object for keyframe animations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct KeyframeAnimationState {
    public var scale: CGFloat
    public var rotation: Double
    public var offsetX: CGFloat
    public var offsetY: CGFloat
    public var opacity: Double
    
    public init(
        scale: CGFloat = 1,
        rotation: Double = 0,
        offsetX: CGFloat = 0,
        offsetY: CGFloat = 0,
        opacity: Double = 1
    ) {
        self.scale = scale
        self.rotation = rotation
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.opacity = opacity
    }
}

// MARK: - Keyframe Animation View

/// View wrapper for keyframe animations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct KeyframeAnimationView<Content: View>: View {
    
    @Binding var trigger: Bool
    let content: Content
    let keyframes: (KeyframeAnimationState) -> some Keyframes<KeyframeAnimationState>
    
    public init(
        trigger: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        @KeyframesBuilder<KeyframeAnimationState> keyframes: @escaping (KeyframeAnimationState) -> some Keyframes<KeyframeAnimationState>
    ) {
        self._trigger = trigger
        self.content = content()
        self.keyframes = keyframes
    }
    
    public var body: some View {
        content
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger
            ) { view, state in
                view
                    .scaleEffect(state.scale)
                    .rotationEffect(.degrees(state.rotation))
                    .offset(x: state.offsetX, y: state.offsetY)
                    .opacity(state.opacity)
            } keyframes: { initial in
                keyframes(initial)
            }
    }
}

// MARK: - Preset Keyframe Animations

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct KeyframePresets {
    
    /// Bouncy entrance animation
    public static func bouncyEntrance<Content: View>(
        trigger: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(scale: 0, opacity: 0),
                trigger: trigger.wrappedValue
            ) { view, state in
                view
                    .scaleEffect(state.scale)
                    .opacity(state.opacity)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.2, duration: 0.3, spring: .bouncy)
                    SpringKeyframe(0.9, duration: 0.15)
                    SpringKeyframe(1.05, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.1)
                }
                KeyframeTrack(\.opacity) {
                    LinearKeyframe(1.0, duration: 0.2)
                }
            }
    }
    
    /// Shake animation
    public static func shake<Content: View>(
        trigger: Binding<Bool>,
        intensity: CGFloat = 10,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger.wrappedValue
            ) { view, state in
                view.offset(x: state.offsetX)
            } keyframes: { _ in
                KeyframeTrack(\.offsetX) {
                    LinearKeyframe(intensity, duration: 0.08)
                    LinearKeyframe(-intensity, duration: 0.08)
                    LinearKeyframe(intensity * 0.8, duration: 0.08)
                    LinearKeyframe(-intensity * 0.8, duration: 0.08)
                    LinearKeyframe(intensity * 0.5, duration: 0.08)
                    LinearKeyframe(-intensity * 0.5, duration: 0.08)
                    LinearKeyframe(0, duration: 0.08)
                }
            }
    }
    
    /// Spin animation
    public static func spin<Content: View>(
        trigger: Binding<Bool>,
        rotations: Int = 1,
        duration: Double = 0.5,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger.wrappedValue
            ) { view, state in
                view.rotationEffect(.degrees(state.rotation))
            } keyframes: { _ in
                KeyframeTrack(\.rotation) {
                    CubicKeyframe(Double(rotations) * 360, duration: duration)
                }
            }
    }
    
    /// Pop animation
    public static func pop<Content: View>(
        trigger: Binding<Bool>,
        scale: CGFloat = 1.2,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger.wrappedValue
            ) { view, state in
                view.scaleEffect(state.scale)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(scale, duration: 0.15, spring: .bouncy)
                    SpringKeyframe(1.0, duration: 0.2, spring: .bouncy)
                }
            }
    }
    
    /// Attention animation
    public static func attention<Content: View>(
        trigger: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger.wrappedValue
            ) { view, state in
                view
                    .scaleEffect(state.scale)
                    .rotationEffect(.degrees(state.rotation))
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.1, duration: 0.1)
                    SpringKeyframe(0.9, duration: 0.1)
                    SpringKeyframe(1.1, duration: 0.1)
                    SpringKeyframe(1.0, duration: 0.15, spring: .bouncy)
                }
                KeyframeTrack(\.rotation) {
                    LinearKeyframe(-5, duration: 0.1)
                    LinearKeyframe(5, duration: 0.1)
                    LinearKeyframe(-3, duration: 0.1)
                    LinearKeyframe(3, duration: 0.1)
                    LinearKeyframe(0, duration: 0.1)
                }
            }
    }
    
    /// Float animation (continuous)
    public static func float<Content: View>(
        trigger: Binding<Bool>,
        distance: CGFloat = 10,
        duration: Double = 2.0,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger.wrappedValue
            ) { view, state in
                view.offset(y: state.offsetY)
            } keyframes: { _ in
                KeyframeTrack(\.offsetY) {
                    CubicKeyframe(-distance, duration: duration / 2)
                    CubicKeyframe(0, duration: duration / 2)
                }
            }
    }
    
    /// Heartbeat animation
    public static func heartbeat<Content: View>(
        trigger: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger.wrappedValue
            ) { view, state in
                view.scaleEffect(state.scale)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    LinearKeyframe(1.0, duration: 0.1)
                    SpringKeyframe(1.3, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.15)
                    SpringKeyframe(1.3, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.25)
                }
            }
    }
    
    /// Swing animation
    public static func swing<Content: View>(
        trigger: Binding<Bool>,
        angle: Double = 15,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger.wrappedValue
            ) { view, state in
                view.rotationEffect(.degrees(state.rotation), anchor: .top)
            } keyframes: { _ in
                KeyframeTrack(\.rotation) {
                    SpringKeyframe(angle, duration: 0.2)
                    SpringKeyframe(-angle * 0.8, duration: 0.2)
                    SpringKeyframe(angle * 0.5, duration: 0.2)
                    SpringKeyframe(-angle * 0.3, duration: 0.2)
                    SpringKeyframe(0, duration: 0.2)
                }
            }
    }
    
    /// Wiggle animation
    public static func wiggle<Content: View>(
        trigger: Binding<Bool>,
        angle: Double = 3,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .keyframeAnimator(
                initialValue: KeyframeAnimationState(),
                trigger: trigger.wrappedValue
            ) { view, state in
                view.rotationEffect(.degrees(state.rotation))
            } keyframes: { _ in
                KeyframeTrack(\.rotation) {
                    LinearKeyframe(angle, duration: 0.1)
                    LinearKeyframe(-angle, duration: 0.1)
                    LinearKeyframe(angle, duration: 0.1)
                    LinearKeyframe(-angle, duration: 0.1)
                    LinearKeyframe(0, duration: 0.1)
                }
            }
    }
    
    /// Rubber band animation
    public static func rubberBand<Content: View>(
        trigger: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        KeyframeAnimationState()
        
        return content()
            .keyframeAnimator(
                initialValue: (scaleX: 1.0, scaleY: 1.0),
                trigger: trigger.wrappedValue
            ) { view, state in
                view.scaleEffect(x: state.scaleX, y: state.scaleY)
            } keyframes: { _ in
                KeyframeTrack(\.scaleX) {
                    SpringKeyframe(1.25, duration: 0.15)
                    SpringKeyframe(0.75, duration: 0.15)
                    SpringKeyframe(1.15, duration: 0.15)
                    SpringKeyframe(0.95, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.1)
                }
                KeyframeTrack(\.scaleY) {
                    SpringKeyframe(0.75, duration: 0.15)
                    SpringKeyframe(1.25, duration: 0.15)
                    SpringKeyframe(0.85, duration: 0.15)
                    SpringKeyframe(1.05, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.1)
                }
            }
    }
}

// MARK: - Phase Animation Extensions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum AnimationPhase: CaseIterable {
    case initial
    case scaled
    case rotated
    case final
    
    var scale: CGFloat {
        switch self {
        case .initial: return 1.0
        case .scaled: return 1.2
        case .rotated: return 1.1
        case .final: return 1.0
        }
    }
    
    var rotation: Double {
        switch self {
        case .initial: return 0
        case .scaled: return 0
        case .rotated: return 10
        case .final: return 0
        }
    }
    
    var opacity: Double {
        switch self {
        case .initial: return 0.7
        case .scaled: return 1.0
        case .rotated: return 1.0
        case .final: return 1.0
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct PhaseAnimationModifier: ViewModifier {
    
    @Binding var trigger: Bool
    
    public func body(content: Content) -> some View {
        content
            .phaseAnimator(AnimationPhase.allCases, trigger: trigger) { view, phase in
                view
                    .scaleEffect(phase.scale)
                    .rotationEffect(.degrees(phase.rotation))
                    .opacity(phase.opacity)
            } animation: { phase in
                switch phase {
                case .initial: return .easeIn(duration: 0.1)
                case .scaled: return .spring(duration: 0.2)
                case .rotated: return .spring(duration: 0.2)
                case .final: return .spring(duration: 0.3)
                }
            }
    }
}

// MARK: - View Extension

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension View {
    
    /// Applies phase animation
    func phaseAnimation(trigger: Binding<Bool>) -> some View {
        modifier(PhaseAnimationModifier(trigger: trigger))
    }
}
