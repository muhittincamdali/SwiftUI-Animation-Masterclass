import Foundation

/// The resistance a scroll view shows when it is dragged past its edge.
///
/// The further you drag, the less the content follows, and it never moves more than
/// `dimension`. This is the formula `(1 − 1 / (x·c / d + 1)) · d` that iOS scroll views are
/// commonly measured to use, with `c = 0.55`.
public enum RubberBand {
    /// The coefficient iOS scroll views use.
    public static let defaultCoefficient = 0.55

    /// How far content moves when it is dragged `overshoot` points past an edge.
    ///
    /// - Parameters:
    ///   - overshoot: Drag distance past the edge; the sign is kept.
    ///   - dimension: Size of the view along the drag; the result never reaches it.
    ///   - coefficient: Higher values follow the finger more closely.
    public static func offset(_ overshoot: Double, dimension: Double, coefficient: Double = defaultCoefficient) -> Double {
        precondition(dimension > 0, "dimension must be greater than zero")
        precondition(coefficient > 0, "coefficient must be greater than zero")
        let magnitude = (1 - 1 / (abs(overshoot) * coefficient / dimension + 1)) * dimension
        return overshoot < 0 ? -magnitude : magnitude
    }

    /// Keeps `value` inside `range`, letting it stretch past either end with rubber-band
    /// resistance.
    ///
    /// - Parameters:
    ///   - value: The unconstrained value, for example a drag translation.
    ///   - range: The values that follow the finger one to one.
    ///   - dimension: Size of the view along the drag.
    ///   - coefficient: Higher values follow the finger more closely.
    public static func clamp(
        _ value: Double,
        to range: ClosedRange<Double>,
        dimension: Double,
        coefficient: Double = defaultCoefficient
    ) -> Double {
        if value < range.lowerBound {
            return range.lowerBound + offset(value - range.lowerBound, dimension: dimension, coefficient: coefficient)
        }
        if value > range.upperBound {
            return range.upperBound + offset(value - range.upperBound, dimension: dimension, coefficient: coefficient)
        }
        return value
    }
}
