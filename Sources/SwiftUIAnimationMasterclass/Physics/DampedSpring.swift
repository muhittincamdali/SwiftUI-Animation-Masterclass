import Foundation
import SwiftUI

/// A damped harmonic oscillator, solved in closed form.
///
/// A spring pulls a value toward its target with a force proportional to the distance
/// (`stiffness`) and slows it with a force proportional to its speed (`damping`). The
/// position at any time comes from the analytic solution of `m·x″ + c·x′ + k·x = 0`, so it
/// does not drift with the frame rate the way a step-by-step integration does.
///
/// ```swift
/// let spring = DampedSpring(response: 0.4, dampingRatio: 0.6)
/// let offset = spring.displacement(at: 0.1, initialDisplacement: 120, initialVelocity: 0)
/// let settles = spring.settlingDuration(initialDisplacement: 120, initialVelocity: 0)
/// ```
///
/// Use ``animation(initialVelocity:)`` to run the same spring as a SwiftUI animation.
public struct DampedSpring: Hashable, Sendable {
    /// Mass of the moving object. A heavier object accelerates more slowly.
    public var mass: Double
    /// Spring constant: how hard the spring pulls per unit of distance.
    public var stiffness: Double
    /// Damping coefficient: how much the motion is slowed per unit of speed.
    public var damping: Double

    /// Creates a spring from its physical constants.
    ///
    /// - Parameters:
    ///   - mass: Mass of the object, greater than zero.
    ///   - stiffness: Spring constant, greater than zero.
    ///   - damping: Damping coefficient, zero or more.
    public init(mass: Double = 1, stiffness: Double, damping: Double) {
        precondition(mass > 0, "mass must be greater than zero")
        precondition(stiffness > 0, "stiffness must be greater than zero")
        precondition(damping >= 0, "damping must not be negative")
        self.mass = mass
        self.stiffness = stiffness
        self.damping = damping
    }

    /// Creates a spring from the parameters SwiftUI uses for `.spring(response:dampingFraction:)`.
    ///
    /// - Parameters:
    ///   - response: Period of the undamped oscillation in seconds, greater than zero.
    ///   - dampingRatio: `1` stops without overshooting; lower values bounce, higher values
    ///     approach the target more slowly.
    ///   - mass: Mass of the object, greater than zero.
    public init(response: Double, dampingRatio: Double, mass: Double = 1) {
        precondition(response > 0, "response must be greater than zero")
        let angularFrequency = 2 * Double.pi / response
        self.init(
            mass: mass,
            stiffness: mass * angularFrequency * angularFrequency,
            damping: 2 * dampingRatio * mass * angularFrequency
        )
    }

    /// Angular frequency of the spring without damping, in radians per second.
    public var naturalFrequency: Double { (stiffness / mass).squareRoot() }

    /// Ratio of the damping to critical damping. Below `1` the spring overshoots.
    public var dampingRatio: Double { damping / (2 * (stiffness * mass).squareRoot()) }

    /// Period of the undamped oscillation in seconds.
    public var response: Double { 2 * Double.pi / naturalFrequency }

    /// Distance from the target at `time`.
    ///
    /// - Parameters:
    ///   - time: Seconds since the motion started.
    ///   - initialDisplacement: Start position minus target position.
    ///   - initialVelocity: Velocity at the start, in units per second.
    public func displacement(at time: Double, initialDisplacement: Double, initialVelocity: Double) -> Double {
        solution(initialDisplacement: initialDisplacement, initialVelocity: initialVelocity).displacement(at: time)
    }

    /// Velocity at `time`, in units per second.
    ///
    /// - Parameters:
    ///   - time: Seconds since the motion started.
    ///   - initialDisplacement: Start position minus target position.
    ///   - initialVelocity: Velocity at the start, in units per second.
    public func velocity(at time: Double, initialDisplacement: Double, initialVelocity: Double) -> Double {
        solution(initialDisplacement: initialDisplacement, initialVelocity: initialVelocity).velocity(at: time)
    }

    /// Value of a property that springs from `start` to `target`.
    ///
    /// - Parameters:
    ///   - start: Value at time zero.
    ///   - target: Value the spring settles at.
    ///   - time: Seconds since the motion started.
    ///   - initialVelocity: Velocity at the start, in units per second.
    public func value(from start: Double, to target: Double, at time: Double, initialVelocity: Double = 0) -> Double {
        target + displacement(at: time, initialDisplacement: start - target, initialVelocity: initialVelocity)
    }

    /// Time after which the spring stays within `tolerance` of its target and moves slower than
    /// `tolerance` units per second.
    ///
    /// - Parameters:
    ///   - initialDisplacement: Start position minus target position.
    ///   - initialVelocity: Velocity at the start, in units per second.
    ///   - tolerance: Distance and speed that count as "at rest".
    /// - Returns: Seconds, accurate to a millisecond. `0` when the spring starts at rest.
    ///   `infinity` for an undamped spring that does not start at rest, for a start that is not
    ///   finite, and for a spring so lightly damped that it may still be moving after
    ///   ``longestSettlingDuration``.
    public func settlingDuration(initialDisplacement: Double, initialVelocity: Double, tolerance: Double = 0.001) -> Double {
        precondition(tolerance > 0, "tolerance must be greater than zero")
        guard initialDisplacement.isFinite, initialVelocity.isFinite else { return .infinity }
        let motion = solution(initialDisplacement: initialDisplacement, initialVelocity: initialVelocity)
        guard damping > 0 else {
            return initialDisplacement == 0 && initialVelocity == 0 ? 0 : .infinity
        }
        let step = 0.001
        let limit = motion.timeUntilBound(below: tolerance, searchingUpTo: Self.longestSettlingDuration)
        guard limit.isFinite else { return .infinity }
        var time = (limit / step).rounded(.up) * step
        // Walk back from a time where the motion is certainly settled to the last moment it was not.
        while time > 0 {
            let previous = time - step
            if !motion.isSettled(at: previous, tolerance: tolerance) {
                return time
            }
            time = previous
        }
        return 0
    }

    /// Longest settling time ``settlingDuration(initialDisplacement:initialVelocity:tolerance:)``
    /// looks for, in seconds. A spring that may still be moving after it reports `infinity`
    /// rather than a cut-off time.
    public static let longestSettlingDuration: Double = 3600

    /// The spring as a SwiftUI animation.
    ///
    /// - Parameter initialVelocity: Starting velocity relative to the change being animated:
    ///   `1` means the value would cover the whole change in one second. Use
    ///   ``relativeVelocity(_:from:to:)`` to convert a gesture velocity.
    public func animation(initialVelocity: Double = 0) -> Animation {
        .interpolatingSpring(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
    }

    /// Converts a velocity in points per second into the relative velocity SwiftUI springs expect.
    ///
    /// - Parameters:
    ///   - velocity: Velocity of the value, in units per second.
    ///   - start: Value when the animation starts.
    ///   - target: Value the animation moves to.
    /// - Returns: `velocity / (target - start)`, or `0` when start and target are equal or a
    ///   value is not finite (a gesture can report NaN or infinity).
    public static func relativeVelocity(_ velocity: Double, from start: Double, to target: Double) -> Double {
        let distance = target - start
        guard distance != 0, distance.isFinite, velocity.isFinite else { return 0 }
        return velocity / distance
    }

    // MARK: Presets

    /// Slow and soft, without visible overshoot (response 0.55 s, damping ratio 0.9).
    public static let gentle = DampedSpring(response: 0.55, dampingRatio: 0.9)
    /// Quick with a small overshoot (response 0.3 s, damping ratio 0.8).
    public static let snappy = DampedSpring(response: 0.3, dampingRatio: 0.8)
    /// Visibly bounces before settling (response 0.45 s, damping ratio 0.5).
    public static let bouncy = DampedSpring(response: 0.45, dampingRatio: 0.5)
    /// Critically damped: the fastest motion that never overshoots (response 0.4 s).
    public static let smooth = DampedSpring(response: 0.4, dampingRatio: 1)

    // MARK: Solution

    private func solution(initialDisplacement: Double, initialVelocity: Double) -> Solution {
        Solution(
            naturalFrequency: naturalFrequency,
            dampingRatio: dampingRatio,
            initialDisplacement: initialDisplacement,
            initialVelocity: initialVelocity
        )
    }
}

/// Closed-form motion of one spring from one starting state.
private struct Solution {
    private enum Regime {
        /// Oscillates inside a decaying envelope: x = e^(−at)·(A·cos ωt + B·sin ωt).
        case underdamped(decay: Double, frequency: Double, cosine: Double, sine: Double)
        /// Fastest return without oscillation: x = (A + B·t)·e^(−ω₀t).
        case critical(frequency: Double, constant: Double, linear: Double)
        /// Two exponentials: x = c₁·e^(r₁t) + c₂·e^(r₂t), with r₂ < r₁ < 0.
        case overdamped(slowRate: Double, fastRate: Double, slow: Double, fast: Double)
    }

    private let regime: Regime
    private let initialDisplacement: Double
    private let initialVelocity: Double

    init(naturalFrequency omega: Double, dampingRatio zeta: Double, initialDisplacement x0: Double, initialVelocity v0: Double) {
        initialDisplacement = x0
        initialVelocity = v0
        let criticalBand = 1e-9
        if zeta < 1 - criticalBand {
            let decay = zeta * omega
            let frequency = omega * (1 - zeta * zeta).squareRoot()
            regime = .underdamped(decay: decay, frequency: frequency, cosine: x0, sine: (v0 + decay * x0) / frequency)
        } else if zeta > 1 + criticalBand {
            let root = (zeta * zeta - 1).squareRoot()
            let slowRate = -omega * (zeta - root)
            let fastRate = -omega * (zeta + root)
            let slow = (v0 - fastRate * x0) / (slowRate - fastRate)
            regime = .overdamped(slowRate: slowRate, fastRate: fastRate, slow: slow, fast: x0 - slow)
        } else {
            regime = .critical(frequency: omega, constant: x0, linear: v0 + omega * x0)
        }
    }

    func displacement(at time: Double) -> Double {
        guard time > 0 else { return initialDisplacement }
        switch regime {
        case let .underdamped(decay, frequency, cosine, sine):
            return exp(-decay * time) * (cosine * cos(frequency * time) + sine * sin(frequency * time))
        case let .critical(frequency, constant, linear):
            return (constant + linear * time) * exp(-frequency * time)
        case let .overdamped(slowRate, fastRate, slow, fast):
            return slow * exp(slowRate * time) + fast * exp(fastRate * time)
        }
    }

    func velocity(at time: Double) -> Double {
        guard time > 0 else { return initialVelocity }
        switch regime {
        case let .underdamped(decay, frequency, cosine, sine):
            let cosineTerm = sine * frequency - decay * cosine
            let sineTerm = -cosine * frequency - decay * sine
            return exp(-decay * time) * (cosineTerm * cos(frequency * time) + sineTerm * sin(frequency * time))
        case let .critical(frequency, constant, linear):
            return (linear - frequency * (constant + linear * time)) * exp(-frequency * time)
        case let .overdamped(slowRate, fastRate, slow, fast):
            return slow * slowRate * exp(slowRate * time) + fast * fastRate * exp(fastRate * time)
        }
    }

    func isSettled(at time: Double, tolerance: Double) -> Bool {
        abs(displacement(at: time)) < tolerance && abs(velocity(at: time)) < tolerance
    }

    /// A time after which both |x| and |v| are guaranteed to stay below `tolerance`, or
    /// `infinity` when no such time is found up to `longestTime`.
    func timeUntilBound(below tolerance: Double, searchingUpTo longestTime: Double) -> Double {
        var time = 0.125
        while !(upperBound(at: time) < tolerance) {
            guard time < longestTime else { return .infinity }
            time = min(time * 2, longestTime)
        }
        return time
    }

    /// An upper bound for |x(t')| and |v(t')| at every t' ≥ t.
    private func upperBound(at time: Double) -> Double {
        switch regime {
        case let .underdamped(decay, frequency, cosine, sine):
            let amplitude = (cosine * cosine + sine * sine).squareRoot()
            let speed = amplitude * (decay * decay + frequency * frequency).squareRoot()
            return exp(-decay * time) * max(amplitude, speed)
        case let .critical(frequency, constant, linear):
            // (|A| + |B|t)·e^(−ωt) is decreasing once t > 1/ω − |A|/|B|; doubling `time` gets there.
            let position = (abs(constant) + abs(linear) * time) * exp(-frequency * time)
            let speed = (abs(linear) + frequency * (abs(constant) + abs(linear) * time)) * exp(-frequency * time)
            guard time > 1 / frequency else { return .infinity }
            return max(position, speed)
        case let .overdamped(slowRate, fastRate, slow, fast):
            let position = abs(slow) * exp(slowRate * time) + abs(fast) * exp(fastRate * time)
            let speed = abs(slow * slowRate) * exp(slowRate * time) + abs(fast * fastRate) * exp(fastRate * time)
            return max(position, speed)
        }
    }
}
