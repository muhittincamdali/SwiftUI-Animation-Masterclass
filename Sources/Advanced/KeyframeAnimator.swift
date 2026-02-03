//
//  KeyframeAnimator.swift
//  SwiftUI-Animation-Masterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Keyframe Value Protocol

/// A protocol that defines animatable values for keyframe animations.
///
/// Conform to this protocol to create custom types that can be interpolated
/// between keyframes in an animation sequence.
///
/// ## Overview
/// Keyframe animations provide precise control over animation timing and values.
/// Unlike standard animations that interpolate between two states, keyframe
/// animations allow you to define multiple intermediate states with exact timing.
///
/// ## Example
/// ```swift
/// struct MyAnimationValue: KeyframeValue {
///     var position: CGPoint = .zero
///     var scale: Double = 1.0
///     var rotation: Angle = .zero
/// }
/// ```
public protocol KeyframeValue: Equatable {
    /// Creates a linearly interpolated value between self and another value.
    /// - Parameters:
    ///   - to: The target value.
    ///   - progress: Interpolation progress from 0.0 to 1.0.
    /// - Returns: The interpolated value.
    func interpolated(to: Self, progress: Double) -> Self
}

// MARK: - Standard Animation Values

/// A comprehensive animation value type for common transformations.
///
/// `StandardAnimationValue` encapsulates position, scale, rotation, and opacity
/// in a single animatable type suitable for most UI animations.
public struct StandardAnimationValue: KeyframeValue {
    /// The x-axis offset from the original position.
    public var offsetX: Double
    
    /// The y-axis offset from the original position.
    public var offsetY: Double
    
    /// The uniform scale factor.
    public var scale: Double
    
    /// The rotation angle in degrees.
    public var rotation: Double
    
    /// The opacity value from 0.0 to 1.0.
    public var opacity: Double
    
    /// The corner radius for rounded rectangles.
    public var cornerRadius: Double
    
    /// Creates a new standard animation value.
    /// - Parameters:
    ///   - offsetX: Horizontal offset. Defaults to 0.
    ///   - offsetY: Vertical offset. Defaults to 0.
    ///   - scale: Scale factor. Defaults to 1.0.
    ///   - rotation: Rotation in degrees. Defaults to 0.
    ///   - opacity: Opacity value. Defaults to 1.0.
    ///   - cornerRadius: Corner radius. Defaults to 0.
    public init(
        offsetX: Double = 0,
        offsetY: Double = 0,
        scale: Double = 1.0,
        rotation: Double = 0,
        opacity: Double = 1.0,
        cornerRadius: Double = 0
    ) {
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.scale = scale
        self.rotation = rotation
        self.opacity = opacity
        self.cornerRadius = cornerRadius
    }
    
    /// The default resting value with no transformations.
    public static let identity = StandardAnimationValue()
    
    public func interpolated(to: StandardAnimationValue, progress: Double) -> StandardAnimationValue {
        StandardAnimationValue(
            offsetX: offsetX + (to.offsetX - offsetX) * progress,
            offsetY: offsetY + (to.offsetY - offsetY) * progress,
            scale: scale + (to.scale - scale) * progress,
            rotation: rotation + (to.rotation - rotation) * progress,
            opacity: opacity + (to.opacity - opacity) * progress,
            cornerRadius: cornerRadius + (to.cornerRadius - cornerRadius) * progress
        )
    }
}

/// A 3D transformation value for perspective animations.
///
/// Use this type when you need to animate elements in 3D space
/// with rotation around multiple axes.
public struct Transform3DValue: KeyframeValue {
    /// Rotation around the X-axis in degrees.
    public var rotationX: Double
    
    /// Rotation around the Y-axis in degrees.
    public var rotationY: Double
    
    /// Rotation around the Z-axis in degrees.
    public var rotationZ: Double
    
    /// Translation along the X-axis.
    public var translateX: Double
    
    /// Translation along the Y-axis.
    public var translateY: Double
    
    /// Translation along the Z-axis (affects perspective).
    public var translateZ: Double
    
    /// Uniform scale factor.
    public var scale: Double
    
    /// Perspective value for 3D effect depth.
    public var perspective: Double
    
    /// Creates a new 3D transformation value.
    public init(
        rotationX: Double = 0,
        rotationY: Double = 0,
        rotationZ: Double = 0,
        translateX: Double = 0,
        translateY: Double = 0,
        translateZ: Double = 0,
        scale: Double = 1.0,
        perspective: Double = 1.0
    ) {
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.rotationZ = rotationZ
        self.translateX = translateX
        self.translateY = translateY
        self.translateZ = translateZ
        self.scale = scale
        self.perspective = perspective
    }
    
    /// Identity transformation with no changes.
    public static let identity = Transform3DValue()
    
    public func interpolated(to: Transform3DValue, progress: Double) -> Transform3DValue {
        Transform3DValue(
            rotationX: rotationX + (to.rotationX - rotationX) * progress,
            rotationY: rotationY + (to.rotationY - rotationY) * progress,
            rotationZ: rotationZ + (to.rotationZ - rotationZ) * progress,
            translateX: translateX + (to.translateX - translateX) * progress,
            translateY: translateY + (to.translateY - translateY) * progress,
            translateZ: translateZ + (to.translateZ - translateZ) * progress,
            scale: scale + (to.scale - scale) * progress,
            perspective: perspective + (to.perspective - perspective) * progress
        )
    }
}

// MARK: - Keyframe Definition

/// Represents a single keyframe in an animation sequence.
///
/// Each keyframe defines a value at a specific point in time,
/// along with an easing function for interpolation.
public struct Keyframe<Value: KeyframeValue> {
    /// The value at this keyframe.
    public let value: Value
    
    /// The time offset for this keyframe (0.0 to 1.0).
    public let time: Double
    
    /// The easing function for interpolation from the previous keyframe.
    public let easing: KeyframeEasing
    
    /// Creates a new keyframe.
    /// - Parameters:
    ///   - value: The value at this keyframe.
    ///   - time: The time offset (0.0 to 1.0).
    ///   - easing: The easing function. Defaults to linear.
    public init(value: Value, time: Double, easing: KeyframeEasing = .linear) {
        self.value = value
        self.time = max(0, min(1, time))
        self.easing = easing
    }
}

/// Easing functions for keyframe interpolation.
///
/// These functions control the rate of change between keyframes,
/// allowing for smooth, natural-looking animations.
public enum KeyframeEasing {
    /// Linear interpolation with constant speed.
    case linear
    
    /// Starts slow and accelerates.
    case easeIn
    
    /// Starts fast and decelerates.
    case easeOut
    
    /// Starts slow, speeds up, then slows down.
    case easeInOut
    
    /// Cubic bezier easing with custom control points.
    case cubicBezier(x1: Double, y1: Double, x2: Double, y2: Double)
    
    /// Spring-like easing with overshoot.
    case spring(damping: Double)
    
    /// Elastic easing with bouncy effect.
    case elastic(amplitude: Double, period: Double)
    
    /// Bouncing easing that simulates a ball dropping.
    case bounce
    
    /// Exponential ease in.
    case exponentialIn
    
    /// Exponential ease out.
    case exponentialOut
    
    /// Applies the easing function to a linear progress value.
    /// - Parameter t: Linear progress from 0.0 to 1.0.
    /// - Returns: Eased progress value.
    public func apply(_ t: Double) -> Double {
        switch self {
        case .linear:
            return t
            
        case .easeIn:
            return t * t * t
            
        case .easeOut:
            let f = t - 1.0
            return f * f * f + 1.0
            
        case .easeInOut:
            if t < 0.5 {
                return 4.0 * t * t * t
            } else {
                let f = 2.0 * t - 2.0
                return 0.5 * f * f * f + 1.0
            }
            
        case .cubicBezier(let x1, let y1, let x2, let y2):
            return solveCubicBezier(t: t, x1: x1, y1: y1, x2: x2, y2: y2)
            
        case .spring(let damping):
            let omega = 10.0
            let dampedT = 1.0 - exp(-damping * omega * t) * cos(omega * sqrt(1 - damping * damping) * t)
            return dampedT
            
        case .elastic(let amplitude, let period):
            if t == 0 || t == 1 { return t }
            let s = period / (2 * .pi) * asin(1 / amplitude)
            return amplitude * pow(2, -10 * t) * sin((t - s) * (2 * .pi) / period) + 1
            
        case .bounce:
            if t < 1 / 2.75 {
                return 7.5625 * t * t
            } else if t < 2 / 2.75 {
                let t2 = t - 1.5 / 2.75
                return 7.5625 * t2 * t2 + 0.75
            } else if t < 2.5 / 2.75 {
                let t2 = t - 2.25 / 2.75
                return 7.5625 * t2 * t2 + 0.9375
            } else {
                let t2 = t - 2.625 / 2.75
                return 7.5625 * t2 * t2 + 0.984375
            }
            
        case .exponentialIn:
            return t == 0 ? 0 : pow(2, 10 * (t - 1))
            
        case .exponentialOut:
            return t == 1 ? 1 : 1 - pow(2, -10 * t)
        }
    }
    
    /// Solves the cubic bezier curve for a given t value.
    private func solveCubicBezier(t: Double, x1: Double, y1: Double, x2: Double, y2: Double) -> Double {
        let cx = 3.0 * x1
        let bx = 3.0 * (x2 - x1) - cx
        let ax = 1.0 - cx - bx
        
        let cy = 3.0 * y1
        let by = 3.0 * (y2 - y1) - cy
        let ay = 1.0 - cy - by
        
        func sampleCurveX(_ t: Double) -> Double {
            return ((ax * t + bx) * t + cx) * t
        }
        
        func sampleCurveY(_ t: Double) -> Double {
            return ((ay * t + by) * t + cy) * t
        }
        
        func solveCurveX(_ x: Double) -> Double {
            var t2 = x
            for _ in 0..<8 {
                let x2 = sampleCurveX(t2) - x
                if abs(x2) < 0.001 { return t2 }
                let d2 = (3.0 * ax * t2 + 2.0 * bx) * t2 + cx
                if abs(d2) < 1e-6 { break }
                t2 = t2 - x2 / d2
            }
            return t2
        }
        
        return sampleCurveY(solveCurveX(t))
    }
}

// MARK: - Keyframe Track

/// A collection of keyframes that define an animation track.
///
/// `KeyframeTrack` manages a sequence of keyframes and provides
/// methods for evaluating the animated value at any point in time.
public struct KeyframeTrack<Value: KeyframeValue> {
    /// The keyframes in this track, sorted by time.
    public private(set) var keyframes: [Keyframe<Value>]
    
    /// The total duration of the animation in seconds.
    public let duration: TimeInterval
    
    /// Creates a new keyframe track.
    /// - Parameters:
    ///   - duration: Total animation duration in seconds.
    ///   - keyframes: The keyframes in the track.
    public init(duration: TimeInterval, keyframes: [Keyframe<Value>]) {
        self.duration = duration
        self.keyframes = keyframes.sorted { $0.time < $1.time }
    }
    
    /// Evaluates the track at a specific time.
    /// - Parameter time: The time in seconds.
    /// - Returns: The interpolated value at the specified time.
    public func evaluate(at time: TimeInterval) -> Value {
        let normalizedTime = max(0, min(1, time / duration))
        
        guard keyframes.count >= 2 else {
            return keyframes.first?.value ?? keyframes[0].value
        }
        
        var previousKeyframe = keyframes[0]
        var nextKeyframe = keyframes[1]
        
        for i in 0..<keyframes.count - 1 {
            if keyframes[i].time <= normalizedTime && keyframes[i + 1].time >= normalizedTime {
                previousKeyframe = keyframes[i]
                nextKeyframe = keyframes[i + 1]
                break
            }
        }
        
        if normalizedTime <= keyframes[0].time {
            return keyframes[0].value
        }
        if normalizedTime >= keyframes[keyframes.count - 1].time {
            return keyframes[keyframes.count - 1].value
        }
        
        let segmentDuration = nextKeyframe.time - previousKeyframe.time
        let segmentProgress = (normalizedTime - previousKeyframe.time) / segmentDuration
        let easedProgress = nextKeyframe.easing.apply(segmentProgress)
        
        return previousKeyframe.value.interpolated(to: nextKeyframe.value, progress: easedProgress)
    }
    
    /// Adds a keyframe to the track.
    /// - Parameter keyframe: The keyframe to add.
    public mutating func addKeyframe(_ keyframe: Keyframe<Value>) {
        keyframes.append(keyframe)
        keyframes.sort { $0.time < $1.time }
    }
    
    /// Removes a keyframe at the specified index.
    /// - Parameter index: The index of the keyframe to remove.
    public mutating func removeKeyframe(at index: Int) {
        guard keyframes.indices.contains(index) else { return }
        keyframes.remove(at: index)
    }
}

// MARK: - Keyframe Animator

/// A view modifier that applies keyframe-based animations.
///
/// `KeyframeAnimator` provides precise control over multi-step animations
/// with customizable easing between each keyframe.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@MainActor
public final class KeyframeAnimatorController<Value: KeyframeValue>: ObservableObject {
    /// The current animated value.
    @Published public private(set) var currentValue: Value
    
    /// The keyframe track being animated.
    public let track: KeyframeTrack<Value>
    
    /// Whether the animation is currently playing.
    @Published public private(set) var isPlaying: Bool = false
    
    /// The current playback position in seconds.
    @Published public private(set) var currentTime: TimeInterval = 0
    
    /// The playback speed multiplier.
    public var playbackSpeed: Double = 1.0
    
    /// Whether the animation should loop.
    public var shouldLoop: Bool = true
    
    /// Whether to reverse on each loop (ping-pong).
    public var pingPong: Bool = false
    
    /// Current playback direction.
    private var isReversed: Bool = false
    
    /// Display link for smooth animation updates.
    private var displayLink: CADisplayLink?
    
    /// Last frame timestamp.
    private var lastTimestamp: CFTimeInterval?
    
    /// Callback when animation completes a cycle.
    public var onCycleComplete: (() -> Void)?
    
    /// Creates a new keyframe animator controller.
    /// - Parameter track: The keyframe track to animate.
    public init(track: KeyframeTrack<Value>) {
        self.track = track
        self.currentValue = track.evaluate(at: 0)
    }
    
    /// Starts the animation playback.
    public func play() {
        guard !isPlaying else { return }
        isPlaying = true
        
        displayLink = CADisplayLink(target: DisplayLinkTarget { [weak self] link in
            self?.handleDisplayLinkUpdate(link)
        }, selector: #selector(DisplayLinkTarget.handleDisplayLink(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Pauses the animation playback.
    public func pause() {
        isPlaying = false
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = nil
    }
    
    /// Stops the animation and resets to the beginning.
    public func stop() {
        pause()
        currentTime = 0
        isReversed = false
        currentValue = track.evaluate(at: 0)
    }
    
    /// Seeks to a specific time in the animation.
    /// - Parameter time: The target time in seconds.
    public func seek(to time: TimeInterval) {
        currentTime = max(0, min(track.duration, time))
        currentValue = track.evaluate(at: currentTime)
    }
    
    /// Handles display link updates.
    private func handleDisplayLinkUpdate(_ link: CADisplayLink) {
        guard let lastTimestamp = lastTimestamp else {
            self.lastTimestamp = link.timestamp
            return
        }
        
        let deltaTime = (link.timestamp - lastTimestamp) * playbackSpeed
        self.lastTimestamp = link.timestamp
        
        if isReversed {
            currentTime -= deltaTime
        } else {
            currentTime += deltaTime
        }
        
        if currentTime >= track.duration {
            if pingPong {
                isReversed = true
                currentTime = track.duration
            } else if shouldLoop {
                currentTime = 0
            } else {
                currentTime = track.duration
                pause()
            }
            onCycleComplete?()
        } else if currentTime <= 0 && isReversed {
            if shouldLoop {
                isReversed = false
                currentTime = 0
            } else {
                currentTime = 0
                pause()
            }
            onCycleComplete?()
        }
        
        currentValue = track.evaluate(at: currentTime)
    }
}

/// Helper class for CADisplayLink target.
private class DisplayLinkTarget {
    let handler: (CADisplayLink) -> Void
    
    init(handler: @escaping (CADisplayLink) -> Void) {
        self.handler = handler
    }
    
    @objc func handleDisplayLink(_ link: CADisplayLink) {
        handler(link)
    }
}

// MARK: - Keyframe Builder

/// A result builder for creating keyframe tracks declaratively.
@resultBuilder
public struct KeyframeBuilder<Value: KeyframeValue> {
    public static func buildBlock(_ components: Keyframe<Value>...) -> [Keyframe<Value>] {
        components
    }
    
    public static func buildArray(_ components: [[Keyframe<Value>]]) -> [Keyframe<Value>] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: [Keyframe<Value>]?) -> [Keyframe<Value>] {
        component ?? []
    }
    
    public static func buildEither(first component: [Keyframe<Value>]) -> [Keyframe<Value>] {
        component
    }
    
    public static func buildEither(second component: [Keyframe<Value>]) -> [Keyframe<Value>] {
        component
    }
}

// MARK: - Keyframe Track Builder Extension

public extension KeyframeTrack {
    /// Creates a keyframe track using the result builder syntax.
    /// - Parameters:
    ///   - duration: Total animation duration.
    ///   - builder: A closure that builds the keyframes.
    init(duration: TimeInterval, @KeyframeBuilder<Value> builder: () -> [Keyframe<Value>]) {
        self.init(duration: duration, keyframes: builder())
    }
}

// MARK: - Preset Keyframe Tracks

/// A collection of preset keyframe tracks for common animations.
public enum KeyframePresets {
    /// Creates a shake animation track.
    /// - Parameters:
    ///   - intensity: The shake intensity in points.
    ///   - duration: Total animation duration.
    /// - Returns: A keyframe track for shaking.
    public static func shake(intensity: Double = 10, duration: TimeInterval = 0.5) -> KeyframeTrack<StandardAnimationValue> {
        KeyframeTrack(duration: duration) {
            Keyframe(value: StandardAnimationValue(), time: 0)
            Keyframe(value: StandardAnimationValue(offsetX: intensity), time: 0.1, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(offsetX: -intensity), time: 0.2, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: intensity * 0.7), time: 0.3, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: -intensity * 0.7), time: 0.4, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: intensity * 0.4), time: 0.5, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: -intensity * 0.4), time: 0.6, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: intensity * 0.2), time: 0.7, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: -intensity * 0.2), time: 0.8, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(), time: 1.0, easing: .easeIn)
        }
    }
    
    /// Creates a heartbeat animation track.
    /// - Parameter duration: Total animation duration.
    /// - Returns: A keyframe track for heartbeat effect.
    public static func heartbeat(duration: TimeInterval = 1.0) -> KeyframeTrack<StandardAnimationValue> {
        KeyframeTrack(duration: duration) {
            Keyframe(value: StandardAnimationValue(scale: 1.0), time: 0)
            Keyframe(value: StandardAnimationValue(scale: 1.15), time: 0.15, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(scale: 1.0), time: 0.25, easing: .easeIn)
            Keyframe(value: StandardAnimationValue(scale: 1.25), time: 0.4, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(scale: 1.0), time: 0.6, easing: .spring(damping: 0.5))
            Keyframe(value: StandardAnimationValue(scale: 1.0), time: 1.0)
        }
    }
    
    /// Creates a jelly wiggle animation track.
    /// - Parameter duration: Total animation duration.
    /// - Returns: A keyframe track for jelly effect.
    public static func jelly(duration: TimeInterval = 0.8) -> KeyframeTrack<StandardAnimationValue> {
        KeyframeTrack(duration: duration) {
            Keyframe(value: StandardAnimationValue(scale: 1.0), time: 0)
            Keyframe(value: StandardAnimationValue(scale: 1.25), time: 0.1, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(scale: 0.9), time: 0.25, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.15), time: 0.4, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 0.95), time: 0.55, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.05), time: 0.7, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.0), time: 1.0, easing: .easeIn)
        }
    }
    
    /// Creates a bounce in animation track.
    /// - Parameter duration: Total animation duration.
    /// - Returns: A keyframe track for bounce in effect.
    public static func bounceIn(duration: TimeInterval = 0.6) -> KeyframeTrack<StandardAnimationValue> {
        KeyframeTrack(duration: duration) {
            Keyframe(value: StandardAnimationValue(scale: 0.3, opacity: 0), time: 0)
            Keyframe(value: StandardAnimationValue(scale: 1.05, opacity: 1), time: 0.4, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(scale: 0.9, opacity: 1), time: 0.6, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.02, opacity: 1), time: 0.8, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.0, opacity: 1), time: 1.0, easing: .easeIn)
        }
    }
    
    /// Creates a flip animation track.
    /// - Parameter duration: Total animation duration.
    /// - Returns: A keyframe track for flip effect.
    public static func flip(duration: TimeInterval = 0.8) -> KeyframeTrack<StandardAnimationValue> {
        KeyframeTrack(duration: duration) {
            Keyframe(value: StandardAnimationValue(rotation: 0, scale: 1.0), time: 0)
            Keyframe(value: StandardAnimationValue(rotation: -20, scale: 1.0), time: 0.2, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(rotation: 180, scale: 1.3), time: 0.5, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(rotation: 340, scale: 1.0), time: 0.8, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(rotation: 360, scale: 1.0), time: 1.0, easing: .easeIn)
        }
    }
    
    /// Creates a swing animation track.
    /// - Parameter duration: Total animation duration.
    /// - Returns: A keyframe track for swing effect.
    public static func swing(duration: TimeInterval = 1.0) -> KeyframeTrack<StandardAnimationValue> {
        KeyframeTrack(duration: duration) {
            Keyframe(value: StandardAnimationValue(rotation: 0), time: 0)
            Keyframe(value: StandardAnimationValue(rotation: 15), time: 0.2, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(rotation: -10), time: 0.4, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(rotation: 5), time: 0.6, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(rotation: -5), time: 0.8, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(rotation: 0), time: 1.0, easing: .easeIn)
        }
    }
    
    /// Creates a tada animation track.
    /// - Parameter duration: Total animation duration.
    /// - Returns: A keyframe track for tada effect.
    public static func tada(duration: TimeInterval = 1.0) -> KeyframeTrack<StandardAnimationValue> {
        KeyframeTrack(duration: duration) {
            Keyframe(value: StandardAnimationValue(scale: 1.0, rotation: 0), time: 0)
            Keyframe(value: StandardAnimationValue(scale: 0.9, rotation: -3), time: 0.1, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(scale: 0.9, rotation: -3), time: 0.2, easing: .linear)
            Keyframe(value: StandardAnimationValue(scale: 1.1, rotation: 3), time: 0.3, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(scale: 1.1, rotation: -3), time: 0.4, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.1, rotation: 3), time: 0.5, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.1, rotation: -3), time: 0.6, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.1, rotation: 3), time: 0.7, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.1, rotation: -3), time: 0.8, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.1, rotation: 3), time: 0.9, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(scale: 1.0, rotation: 0), time: 1.0, easing: .easeIn)
        }
    }
    
    /// Creates a wobble animation track.
    /// - Parameter duration: Total animation duration.
    /// - Returns: A keyframe track for wobble effect.
    public static func wobble(duration: TimeInterval = 1.0) -> KeyframeTrack<StandardAnimationValue> {
        KeyframeTrack(duration: duration) {
            Keyframe(value: StandardAnimationValue(offsetX: 0, rotation: 0), time: 0)
            Keyframe(value: StandardAnimationValue(offsetX: -25, rotation: -5), time: 0.15, easing: .easeOut)
            Keyframe(value: StandardAnimationValue(offsetX: 20, rotation: 3), time: 0.3, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: -15, rotation: -3), time: 0.45, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: 10, rotation: 2), time: 0.6, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: -5, rotation: -1), time: 0.75, easing: .easeInOut)
            Keyframe(value: StandardAnimationValue(offsetX: 0, rotation: 0), time: 1.0, easing: .easeIn)
        }
    }
}

// MARK: - View Modifier

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct KeyframeAnimatorModifier: ViewModifier {
    @StateObject private var controller: KeyframeAnimatorController<StandardAnimationValue>
    private let autoPlay: Bool
    
    public init(track: KeyframeTrack<StandardAnimationValue>, autoPlay: Bool = true) {
        _controller = StateObject(wrappedValue: KeyframeAnimatorController(track: track))
        self.autoPlay = autoPlay
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(x: controller.currentValue.offsetX, y: controller.currentValue.offsetY)
            .scaleEffect(controller.currentValue.scale)
            .rotationEffect(.degrees(controller.currentValue.rotation))
            .opacity(controller.currentValue.opacity)
            .onAppear {
                if autoPlay {
                    controller.play()
                }
            }
            .onDisappear {
                controller.stop()
            }
    }
}

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    /// Applies a keyframe animation track to the view.
    func keyframeAnimation(_ track: KeyframeTrack<StandardAnimationValue>, autoPlay: Bool = true) -> some View {
        modifier(KeyframeAnimatorModifier(track: track, autoPlay: autoPlay))
    }
    
    /// Applies a shake animation to the view.
    func shakeAnimation(intensity: Double = 10, duration: TimeInterval = 0.5) -> some View {
        keyframeAnimation(KeyframePresets.shake(intensity: intensity, duration: duration))
    }
    
    /// Applies a heartbeat animation to the view.
    func heartbeatAnimation(duration: TimeInterval = 1.0) -> some View {
        keyframeAnimation(KeyframePresets.heartbeat(duration: duration))
    }
    
    /// Applies a jelly animation to the view.
    func jellyAnimation(duration: TimeInterval = 0.8) -> some View {
        keyframeAnimation(KeyframePresets.jelly(duration: duration))
    }
    
    /// Applies a bounce in animation to the view.
    func bounceInAnimation(duration: TimeInterval = 0.6) -> some View {
        keyframeAnimation(KeyframePresets.bounceIn(duration: duration))
    }
    
    /// Applies a tada animation to the view.
    func tadaAnimation(duration: TimeInterval = 1.0) -> some View {
        keyframeAnimation(KeyframePresets.tada(duration: duration))
    }
    
    /// Applies a wobble animation to the view.
    func wobbleAnimation(duration: TimeInterval = 1.0) -> some View {
        keyframeAnimation(KeyframePresets.wobble(duration: duration))
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct KeyframeAnimatorPreview: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("Shake")
                .font(.headline)
            RoundedRectangle(cornerRadius: 12)
                .fill(.red)
                .frame(width: 80, height: 80)
                .shakeAnimation()
            
            Text("Heartbeat")
                .font(.headline)
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(.pink)
                .heartbeatAnimation()
            
            Text("Jelly")
                .font(.headline)
            Circle()
                .fill(.purple)
                .frame(width: 60, height: 60)
                .jellyAnimation()
        }
        .padding()
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Keyframe Animator") {
    KeyframeAnimatorPreview()
}
#endif
