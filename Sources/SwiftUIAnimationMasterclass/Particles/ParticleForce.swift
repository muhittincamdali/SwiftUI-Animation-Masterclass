import SwiftUI

/// A force that accelerates every particle of an emitter.
///
/// Forces add up. Positions such as an attractor's center are relative to the canvas, so the
/// same emitter works at any size.
public enum ParticleForce: Hashable, Sendable {
    /// Constant downward acceleration in points per second squared. Negative values make
    /// particles rise, like bubbles or embers.
    case gravity(Double)
    /// Constant acceleration in any direction, in points per second squared.
    case wind(x: Double, y: Double)
    /// A smooth, slowly changing flow that makes particles drift and sway.
    ///
    /// - Parameters:
    ///   - strength: Largest acceleration in points per second squared.
    ///   - scale: Size of the swirls in points.
    case turbulence(strength: Double, scale: Double)
    /// Pulls particles toward `center` (pushes them away when `strength` is negative).
    ///
    /// - Parameters:
    ///   - center: Position relative to the canvas.
    ///   - strength: Acceleration toward the center, in points per second squared.
    case attractor(center: UnitPoint, strength: Double)
    /// Turns particles around `center`, clockwise for a positive `strength`.
    ///
    /// - Parameters:
    ///   - center: Position relative to the canvas.
    ///   - strength: Acceleration across the line to the center, in points per second squared.
    case vortex(center: UnitPoint, strength: Double)

    /// Distance in points inside which attractors and vortices fade out, so particles at the
    /// center do not jitter.
    static let coreRadius = 8.0

    /// Acceleration of `particle` at `time`, in points per second squared.
    func acceleration(for particle: Particle, time: Double, canvas: CGSize) -> (x: Double, y: Double) {
        switch self {
        case let .gravity(strength):
            return (0, strength)
        case let .wind(x, y):
            return (x, y)
        case let .turbulence(strength, scale):
            let angle = Self.flowAngle(x: particle.x / scale, y: particle.y / scale, time: time)
            return (strength * cos(angle), strength * sin(angle))
        case let .attractor(center, strength):
            let (dx, dy, distance) = Self.offset(from: particle, to: center, canvas: canvas)
            guard distance > 0 else { return (0, 0) }
            let falloff = min(1, distance / Self.coreRadius)
            return (strength * falloff * dx / distance, strength * falloff * dy / distance)
        case let .vortex(center, strength):
            let (dx, dy, distance) = Self.offset(from: particle, to: center, canvas: canvas)
            guard distance > 0 else { return (0, 0) }
            let falloff = min(1, distance / Self.coreRadius)
            // Perpendicular to the line to the center. With y pointing down, a particle to the
            // right of the center (dx < 0) is pushed down, which is clockwise on screen.
            return (strength * falloff * dy / distance, -strength * falloff * dx / distance)
        }
    }

    private static func offset(from particle: Particle, to center: UnitPoint, canvas: CGSize) -> (Double, Double, Double) {
        let dx = center.x * canvas.width - particle.x
        let dy = center.y * canvas.height - particle.y
        return (dx, dy, (dx * dx + dy * dy).squareRoot())
    }

    /// Direction of a smooth flow field: overlapping waves at unrelated frequencies, so the
    /// pattern does not visibly repeat, drifting slowly over time.
    static func flowAngle(x: Double, y: Double, time: Double) -> Double {
        let first = sin(x * 1.7 + time * 0.6) + sin(y * 2.3 - time * 0.4)
        let second = sin((x + y) * 1.1 + time * 0.3)
        return (first + second) * .pi / 1.5
    }
}
