import SwiftUI

/// One particle of a ``ParticleSystem``.
///
/// Positions are in points inside the canvas, with the origin at the top-left corner and
/// `y` growing downward, the same as SwiftUI.
public struct Particle: Hashable, Sendable {
    /// Position in points.
    public var x: Double
    /// Position in points, growing downward.
    public var y: Double
    /// Horizontal velocity in points per second.
    public var velocityX: Double
    /// Vertical velocity in points per second, positive downward.
    public var velocityY: Double
    /// Seconds since the particle was born.
    public var age: Double
    /// Seconds the particle lives.
    public var lifetime: Double
    /// Size at birth in points: the diameter of a circle or the width of a rectangle.
    public var size: Double
    /// Rotation in radians.
    public var rotation: Double
    /// Rotation speed in radians per second.
    public var spin: Double
    /// Tumble speed in radians per second; the particle looks like it flips around its
    /// horizontal axis.
    public var tumble: Double
    /// Index into the emitter's ``ParticleEmitter/colors``.
    public var colorIndex: Int
    /// Index into the emitter's ``ParticleEmitter/shapes``.
    public var shapeIndex: Int

    /// Share of the lifetime that has passed, from 0 to 1.
    public var progress: Double { lifetime > 0 ? min(1, age / lifetime) : 1 }

    /// Whether the particle has outlived its lifetime.
    public var isExpired: Bool { age >= lifetime }

    /// Current speed in points per second.
    public var speed: Double { (velocityX * velocityX + velocityY * velocityY).squareRoot() }
}

/// What a particle looks like.
public enum ParticleShape: Hashable, Sendable {
    /// A filled circle.
    case circle
    /// A circle outline, like a bubble.
    case ring
    /// A rectangle whose height is `aspectRatio` times its width: below 1 for confetti strips,
    /// above 1 for rain streaks.
    case rectangle(aspectRatio: Double)
    /// An equilateral triangle.
    case triangle
    /// A five-pointed star.
    case star
    /// An SF Symbol, tinted with the particle color.
    case symbol(String)
    /// A short text, typically an emoji, drawn in its own colors.
    case text(String)
}

/// How particles are combined with what is behind them.
public enum ParticleBlending: Hashable, Sendable {
    /// Particles cover what is behind them.
    case normal
    /// Overlapping particles add up toward white, which suits sparks and fire.
    case additive
}
