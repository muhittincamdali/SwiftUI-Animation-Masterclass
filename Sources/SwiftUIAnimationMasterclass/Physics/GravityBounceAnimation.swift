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
        let gravity = Self.gravity(fallDuration: fallDuration)
        let impactSpeed = gravity * fallDuration
        return GravityBounce(gravity: gravity, restitution: restitution, minimumBounceSpeed: impactSpeed * 0.02)
    }

    /// Creates the animation.
    ///
    /// - Parameters:
    ///   - fallDuration: Seconds to reach the target the first time: finite, greater than zero
    ///     and between about `1e-154` and `1e154`, so that the gravity it implies is a finite
    ///     number above zero.
    ///   - restitution: Share of the speed kept at each bounce, `0..<1`.
    public init(fallDuration: Double, restitution: Double) {
        precondition(fallDuration.isFinite && fallDuration > 0, "fallDuration must be finite and greater than zero")
        let gravity = Self.gravity(fallDuration: fallDuration)
        // T² overflows to infinity for T ≳ 1e154 (gravity 0) and underflows to 0 for T ≲ 1e-154
        // (gravity infinite); either would break GravityBounce while the animation runs.
        precondition(gravity.isFinite && gravity > 0, "fallDuration is too large or too small to animate")
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

    /// Gravity that drops a value of height 1 in `fallDuration`: 1 = g·T²/2, so g = 2 / T².
    static func gravity(fallDuration: Double) -> Double {
        2 / (fallDuration * fallDuration)
    }

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
