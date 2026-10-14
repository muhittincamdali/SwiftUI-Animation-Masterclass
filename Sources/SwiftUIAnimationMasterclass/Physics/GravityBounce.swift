import Foundation

/// An object that falls onto a floor and bounces, losing energy at every impact.
///
/// Positions are measured as the distance fallen: `0` at the start and `height` on the floor.
/// Each bounce leaves the floor at `restitution` times the impact speed, so each bounce is
/// `restitution²` as high as the one before. The motion stops when a bounce would be slower
/// than ``minimumBounceSpeed`` or after ``maximumBounces`` (at most ``bounceLimit``).
///
/// ```swift
/// let drop = GravityBounce(gravity: 2000, restitution: 0.5)
/// let y = drop.position(at: 0.3, height: 400)
/// let total = drop.duration(height: 400)
/// ```
///
/// To animate a SwiftUI value this way, use ``SwiftUICore/Animation/gravityBounce(fallDuration:restitution:)``.
public struct GravityBounce: Hashable, Sendable {
    /// Acceleration toward the floor, in units per second squared, finite and greater than zero.
    ///
    /// Setting it checks the same rule as the initializer: every time in the motion is divided
    /// by the gravity.
    public var gravity: Double {
        didSet { precondition(gravity.isFinite && gravity > 0, "gravity must be finite and greater than zero") }
    }
    /// Share of the speed kept at each impact, from 0 (no bounce) to 1 (exclusive).
    public var restitution: Double
    /// Bounces slower than this, in units per second, are skipped and the object rests.
    public var minimumBounceSpeed: Double
    /// Upper limit on the number of bounces; values above ``bounceLimit`` count as ``bounceLimit``.
    public var maximumBounces: Int

    /// Most bounces ever computed. The properties are mutable, so a restitution of 1 or more set
    /// after creation would otherwise bounce forever and grow the bounce list without limit.
    public static let bounceLimit = 100

    /// Creates a bouncing fall.
    ///
    /// - Parameters:
    ///   - gravity: Acceleration in units per second squared, finite and greater than zero.
    ///   - restitution: Share of the speed kept at each impact, `0..<1`.
    ///   - minimumBounceSpeed: Bounces slower than this are skipped.
    ///   - maximumBounces: Upper limit on the number of bounces.
    public init(gravity: Double, restitution: Double, minimumBounceSpeed: Double = 1, maximumBounces: Int = 12) {
        precondition(gravity.isFinite && gravity > 0, "gravity must be finite and greater than zero")
        precondition(restitution >= 0 && restitution < 1, "restitution must be in 0..<1")
        precondition(maximumBounces >= 0, "maximumBounces must not be negative")
        self.gravity = gravity
        self.restitution = restitution
        self.minimumBounceSpeed = max(0, minimumBounceSpeed)
        self.maximumBounces = maximumBounces
    }

    /// Times of every impact with the floor, in seconds, starting with the first landing.
    ///
    /// - Parameters:
    ///   - height: Distance to the floor, zero or more.
    ///   - initialVelocity: Speed toward the floor at the start, zero or more.
    public func impactTimes(height: Double, initialVelocity: Double = 0) -> [Double] {
        flights(height: height, initialVelocity: initialVelocity).map(\.impact)
    }

    /// Number of bounces before the object rests.
    public func bounceCount(height: Double, initialVelocity: Double = 0) -> Int {
        flights(height: height, initialVelocity: initialVelocity).count - 1
    }

    /// Time until the object comes to rest on the floor, in seconds.
    public func duration(height: Double, initialVelocity: Double = 0) -> Double {
        let path = flights(height: height, initialVelocity: initialVelocity)
        guard let last = path.last else { return 0 }
        return last.impact + last.airTime(gravity: gravity)
    }

    /// Distance fallen at `time`: `0` at the start, `height` on the floor.
    public func position(at time: Double, height: Double, initialVelocity: Double = 0) -> Double {
        guard time > 0 else { return 0 }
        let path = flights(height: height, initialVelocity: initialVelocity)
        guard let first = path.first else { return 0 }
        if time < first.impact {
            return initialVelocity * time + 0.5 * gravity * time * time
        }
        for flight in path {
            let elapsed = time - flight.impact
            if elapsed < flight.airTime(gravity: gravity) {
                let heightAboveFloor = flight.launchSpeed * elapsed - 0.5 * gravity * elapsed * elapsed
                return height - heightAboveFloor
            }
        }
        return height
    }

    /// One time on the floor and the bounce that follows it.
    private struct Flight {
        var impact: Double
        var launchSpeed: Double
        func airTime(gravity: Double) -> Double { 2 * launchSpeed / gravity }
    }

    private func flights(height: Double, initialVelocity: Double) -> [Flight] {
        precondition(height >= 0, "height must not be negative")
        precondition(initialVelocity >= 0, "initialVelocity must not be negative")
        // Solve height = v₀t + g·t²/2 for the first landing.
        let firstImpact = ((initialVelocity * initialVelocity + 2 * gravity * height).squareRoot() - initialVelocity) / gravity
        var impactSpeed = initialVelocity + gravity * firstImpact
        var path = [Flight(impact: firstImpact, launchSpeed: 0)]
        let bounces = min(maximumBounces, Self.bounceLimit)
        while path.count <= bounces {
            let launchSpeed = impactSpeed * restitution
            guard launchSpeed >= minimumBounceSpeed, launchSpeed > 0 else { break }
            path[path.count - 1].launchSpeed = launchSpeed
            let nextImpact = path[path.count - 1].impact + 2 * launchSpeed / gravity
            path.append(Flight(impact: nextImpact, launchSpeed: 0))
            impactSpeed = launchSpeed
        }
        return path
    }
}
