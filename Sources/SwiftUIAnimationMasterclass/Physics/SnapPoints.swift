import Foundation

/// Resting positions for something that is dragged and released, such as sheet detents or
/// carousel pages.
///
/// On release, ``index(forRelease:velocity:decay:)`` projects where the momentum would carry
/// the value and picks the resting position closest to that point, so a quick flick moves on
/// to the next position while a slow release goes back to the nearest one.
public struct SnapPoints: Hashable, Sendable {
    /// The resting positions, sorted in ascending order.
    public let positions: [Double]

    /// Creates snap points.
    ///
    /// - Parameter positions: At least one position, in any order.
    public init(_ positions: [Double]) {
        precondition(!positions.isEmpty, "SnapPoints needs at least one position")
        self.positions = positions.sorted()
    }

    /// Index in ``positions`` of the position closest to `value`. Ties go to the lower position.
    public func index(nearest value: Double) -> Int {
        var best = 0
        for (index, position) in positions.enumerated() where abs(position - value) < abs(positions[best] - value) {
            best = index
        }
        return best
    }

    /// Index in ``positions`` where a value released at `value` with `velocity` should rest.
    ///
    /// - Parameters:
    ///   - value: Position at the moment of release.
    ///   - velocity: Velocity at release, in units per second.
    ///   - decay: How quickly the momentum dies away.
    public func index(forRelease value: Double, velocity: Double, decay: Decay = .normal) -> Int {
        index(nearest: value + decay.projectedDistance(initialVelocity: velocity))
    }
}
