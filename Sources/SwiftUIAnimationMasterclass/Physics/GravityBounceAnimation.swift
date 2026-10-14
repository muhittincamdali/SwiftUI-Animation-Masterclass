import SwiftUI

/// A SwiftUI animation that drops a value onto its target and bounces it there.
///
/// Create it with ``SwiftUICore/Animation/gravityBounce(fallDuration:restitution:)``.
public struct GravityBounceAnimation: CustomAnimation {
    /// Seconds to reach the target the first time.
    public let fallDuration: Double
    /// Share of the speed kept at each bounce, `0..<1`.
    public let restitution: Double

    private var motion: GravityBounce {
        // Normalise the change to a height of 1: falling 1 unit in `fallDuration` needs g = 2 / T².
        let gravity = 2 / (fallDuration * fallDuration)
        let impactSpeed = gravity * fallDuration
        return GravityBounce(gravity: gravity, restitution: restitution, minimumBounceSpeed: impactSpeed * 0.02)
    }

    /// Creates the animation.
    ///
    /// - Parameters:
    ///   - fallDuration: Seconds to reach the target the first time, greater than zero.
    ///   - restitution: Share of the speed kept at each bounce, `0..<1`.
    public init(fallDuration: Double, restitution: Double) {
        precondition(fallDuration > 0, "fallDuration must be greater than zero")
        precondition(restitution >= 0 && restitution < 1, "restitution must be in 0..<1")
        self.fallDuration = fallDuration
        self.restitution = restitution
    }

    /// Share of the change applied at `time`: `0` at the start, `1` on the target. Between
    /// bounces the value moves back toward its start, so the result dips below `1`.
    public func progress(at time: Double) -> Double {
        motion.position(at: time, height: 1)
    }

    /// Seconds until the value rests on its target.
    public var duration: Double { motion.duration(height: 1) }

    public func animate<V: VectorArithmetic>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? {
        guard time < duration else { return nil }
        return value.scaled(by: progress(at: time))
    }
}

public extension Animation {
    /// Drops the value onto its new target and lets it bounce, like a ball landing on a floor.
    ///
    /// ```swift
    /// withAnimation(.gravityBounce()) {
    ///     isDropped = true
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - fallDuration: Seconds to reach the target the first time.
    ///   - restitution: Share of the speed kept at each bounce: `0` lands without bouncing,
    ///     values near `1` bounce for a long time.
    static func gravityBounce(fallDuration: Double = 0.45, restitution: Double = 0.45) -> Animation {
        Animation(GravityBounceAnimation(fallDuration: fallDuration, restitution: restitution))
    }
}
