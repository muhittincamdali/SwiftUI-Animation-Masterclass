import SwiftUI

/// Describes how particles are born, how they move and what they look like.
///
/// Start from a preset such as ``confetti`` or ``snow`` and change what you need:
///
/// ```swift
/// var hearts = ParticleEmitter.hearts
/// hearts.burstCount = 40
/// hearts.colors = [.pink, .purple]
/// ```
///
/// Ranges are sampled uniformly for every particle.
public struct ParticleEmitter: Hashable, Sendable {
    /// Where particles are born.
    public enum Source: Hashable, Sendable {
        /// At ``ParticleEmitter/position``.
        case point
        /// Anywhere on a circle of `radius` points around ``ParticleEmitter/position``.
        case circle(radius: Double)
        /// Anywhere along one edge of the canvas; ``ParticleEmitter/position`` is ignored.
        case edge(Edge)
        /// Anywhere inside the canvas; ``ParticleEmitter/position`` is ignored.
        case area
    }

    /// Where particles are born.
    public var source: Source
    /// Position of a ``Source/point`` or ``Source/circle(radius:)`` source, relative to the
    /// canvas.
    public var position: UnitPoint
    /// Particles born per second while the emitter is on. `0` emits only in bursts.
    public var birthRate: Double
    /// Particles born at once by a burst.
    public var burstCount: Int
    /// Upper limit on living particles; births beyond it are skipped.
    public var maxParticles: Int
    /// Seconds each particle lives.
    public var lifetime: ClosedRange<Double>
    /// Speed at birth, in points per second.
    public var speed: ClosedRange<Double>
    /// Direction at birth. `0°` points right and `90°` points down, as in SwiftUI.
    public var direction: Angle
    /// Total width of the cone around ``direction`` that particles are launched in. `360°`
    /// launches in every direction.
    public var spread: Angle
    /// Size at birth, in points.
    public var size: ClosedRange<Double>
    /// Size at the end of the life relative to the size at birth.
    public var endScale: Double
    /// Rotation speed in radians per second.
    public var spin: ClosedRange<Double>
    /// Tumble speed in radians per second, which makes flat particles look like they flip.
    /// `0...0` turns it off.
    public var tumble: ClosedRange<Double>
    /// Whether each particle points along its direction of travel, like rain streaks.
    /// Overrides ``spin``.
    public var alignsWithMotion: Bool
    /// Fraction of the speed lost per second to air resistance. `0` keeps the speed.
    public var drag: Double
    /// Forces applied to every particle.
    public var forces: [ParticleForce]
    /// Colors picked at random for each particle. ``ParticleShape/text(_:)`` keeps its own colors.
    public var colors: [Color]
    /// Shapes picked at random for each particle.
    public var shapes: [ParticleShape]
    /// Share of the life, from the start, over which a particle fades in.
    public var fadeIn: Double
    /// Share of the life after which a particle starts to fade out; `1` keeps it opaque.
    public var fadeOutStart: Double
    /// How overlapping particles combine.
    public var blending: ParticleBlending
    /// Distance in points that particles of a burst travel from the view before they fade.
    /// ``SwiftUICore/View/particleBurst(_:trigger:)`` draws into a square of twice this size.
    public var reach: Double

    /// Creates an emitter. Every parameter has a default, so set only what you need.
    public init(
        source: Source = .point,
        position: UnitPoint = .center,
        birthRate: Double = 0,
        burstCount: Int = 60,
        maxParticles: Int = 600,
        lifetime: ClosedRange<Double> = 1.5...2.5,
        speed: ClosedRange<Double> = 150...300,
        direction: Angle = .degrees(-90),
        spread: Angle = .degrees(360),
        size: ClosedRange<Double> = 6...10,
        endScale: Double = 1,
        spin: ClosedRange<Double> = 0...0,
        tumble: ClosedRange<Double> = 0...0,
        alignsWithMotion: Bool = false,
        drag: Double = 0,
        forces: [ParticleForce] = [],
        colors: [Color] = [.accentColor],
        shapes: [ParticleShape] = [.circle],
        fadeIn: Double = 0,
        fadeOutStart: Double = 0.7,
        blending: ParticleBlending = .normal,
        reach: Double = 300
    ) {
        precondition(!colors.isEmpty, "ParticleEmitter needs at least one color")
        precondition(!shapes.isEmpty, "ParticleEmitter needs at least one shape")
        precondition(lifetime.lowerBound > 0, "lifetime must be greater than zero")
        self.source = source
        self.position = position
        self.birthRate = max(0, birthRate)
        self.burstCount = max(0, burstCount)
        self.maxParticles = max(0, maxParticles)
        self.lifetime = lifetime
        self.speed = speed
        self.direction = direction
        self.spread = spread
        self.size = size
        self.endScale = endScale
        self.spin = spin
        self.tumble = tumble
        self.alignsWithMotion = alignsWithMotion
        self.drag = max(0, drag)
        self.forces = forces
        self.colors = colors
        self.shapes = shapes
        self.fadeIn = min(max(fadeIn, 0), 1)
        self.fadeOutStart = min(max(fadeOutStart, 0), 1)
        self.blending = blending
        self.reach = reach
    }

    /// Opacity of a particle at `progress` (0 at birth, 1 at the end of its life).
    public func opacity(at progress: Double) -> Double {
        if fadeIn > 0, progress < fadeIn {
            return progress / fadeIn
        }
        if progress <= fadeOutStart {
            return 1
        }
        guard fadeOutStart < 1 else { return 1 }
        return max(0, 1 - (progress - fadeOutStart) / (1 - fadeOutStart))
    }

    /// Size multiplier of a particle at `progress`, from 1 at birth to ``endScale``.
    public func scale(at progress: Double) -> Double {
        1 + (endScale - 1) * progress
    }
}
