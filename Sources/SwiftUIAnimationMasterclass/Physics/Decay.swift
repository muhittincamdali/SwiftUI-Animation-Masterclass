import Foundation

/// Momentum that slows down by a fixed fraction every millisecond, like a flicked scroll view.
///
/// After a fling, the velocity keeps `decelerationRate` of itself each millisecond:
/// `v(t) = v₀ · rate^(1000·t)`. Integrating that gives how far the content travels, which is
/// what you need to decide where a flicked card or sheet should land:
///
/// ```swift
/// let landing = position + Decay.normal.projectedDistance(initialVelocity: velocity)
/// ```
public struct Decay: Hashable, Sendable {
    /// Fraction of the velocity kept after each millisecond, between 0 and 1 (exclusive).
    public var decelerationRate: Double

    /// Creates a decay.
    ///
    /// - Parameter decelerationRate: Fraction of the velocity kept after each millisecond,
    ///   greater than 0 and less than 1. Higher values glide further.
    public init(decelerationRate: Double) {
        precondition(decelerationRate > 0 && decelerationRate < 1, "decelerationRate must be between 0 and 1")
        self.decelerationRate = decelerationRate
    }

    /// The deceleration of a scroll view on iOS (0.998).
    public static let normal = Decay(decelerationRate: 0.998)
    /// The faster deceleration iOS uses for paging scroll views (0.99).
    public static let fast = Decay(decelerationRate: 0.99)

    /// Velocity after `time` seconds.
    public func velocity(at time: Double, initialVelocity: Double) -> Double {
        initialVelocity * pow(decelerationRate, 1000 * max(0, time))
    }

    /// Distance travelled after `time` seconds.
    public func distance(at time: Double, initialVelocity: Double) -> Double {
        let elapsed = max(0, time)
        return initialVelocity * (pow(decelerationRate, 1000 * elapsed) - 1) / (1000 * log(decelerationRate))
    }

    /// Total distance travelled until the motion stops.
    ///
    /// The sign follows `initialVelocity`.
    public func projectedDistance(initialVelocity: Double) -> Double {
        -initialVelocity / (1000 * log(decelerationRate))
    }

    /// Time until the speed drops below `threshold` units per second.
    ///
    /// - Returns: Seconds; `0` when the motion starts below the threshold.
    public func duration(initialVelocity: Double, threshold: Double = 0.5) -> Double {
        precondition(threshold > 0, "threshold must be greater than zero")
        let speed = abs(initialVelocity)
        guard speed > threshold else { return 0 }
        return log(threshold / speed) / (1000 * log(decelerationRate))
    }
}
