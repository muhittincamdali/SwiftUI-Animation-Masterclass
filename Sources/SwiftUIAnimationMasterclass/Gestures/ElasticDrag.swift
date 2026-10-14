import SwiftUI

public extension View {
    /// Lets the view be pulled with rubber-band resistance and springs it back when released,
    /// keeping the speed of the release.
    ///
    /// ```swift
    /// Image(systemName: "hand.draw")
    ///     .font(.system(size: 64))
    ///     .elasticDrag()
    /// ```
    ///
    /// With Reduce Motion on, the view returns with a short ease-out instead of a spring.
    ///
    /// - Parameters:
    ///   - axes: Directions the view can be pulled in.
    ///   - resistance: Distance the view approaches but never reaches, in points. Smaller
    ///     values feel stiffer.
    ///   - spring: Spring that brings the view back.
    func elasticDrag(
        axes: Axis.Set = [.horizontal, .vertical],
        resistance: CGFloat = 240,
        spring: DampedSpring = .bouncy
    ) -> some View {
        modifier(ElasticDragModifier(axes: axes, resistance: resistance, spring: spring))
    }
}

/// The math behind ``SwiftUICore/View/elasticDrag(axes:resistance:spring:)``.
enum ElasticDrag {
    /// Visible offset for a finger translation.
    static func offset(for translation: CGSize, axes: Axis.Set, resistance: CGFloat) -> CGSize {
        CGSize(
            width: axes.contains(.horizontal) ? RubberBand.offset(translation.width, dimension: resistance) : 0,
            height: axes.contains(.vertical) ? RubberBand.offset(translation.height, dimension: resistance) : 0
        )
    }

    /// Speed of the visible offset when the finger moves at `velocity` at `translation`.
    static func offsetVelocity(_ velocity: CGSize, at translation: CGSize, axes: Axis.Set, resistance: CGFloat) -> CGSize {
        CGSize(
            width: axes.contains(.horizontal) ? velocity.width * slope(at: translation.width, resistance: resistance) : 0,
            height: axes.contains(.vertical) ? velocity.height * slope(at: translation.height, resistance: resistance) : 0
        )
    }

    /// Relative spring velocity for the return from `offset` to zero.
    ///
    /// SwiftUI springs take one scalar velocity for the whole change, so the 2D velocity is
    /// projected onto the direction of travel.
    static func returnVelocity(offset: CGSize, velocity: CGSize) -> Double {
        let lengthSquared = offset.width * offset.width + offset.height * offset.height
        guard lengthSquared > 0 else { return 0 }
        // The change is −offset; velocity along it, divided by its length, gives the relative value.
        return -(velocity.width * offset.width + velocity.height * offset.height) / lengthSquared
    }

    /// Derivative of the rubber band at `overshoot`: how much of the finger's motion is shown.
    private static func slope(at overshoot: CGFloat, resistance: CGFloat) -> CGFloat {
        let coefficient = RubberBand.defaultCoefficient
        let denominator = abs(overshoot) * coefficient / resistance + 1
        return coefficient / (denominator * denominator)
    }
}

struct ElasticDragModifier: ViewModifier {
    let axes: Axis.Set
    let resistance: CGFloat
    let spring: DampedSpring

    @State private var offset: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = ElasticDrag.offset(for: value.translation, axes: axes, resistance: resistance)
                    }
                    .onEnded { value in
                        let velocity = ElasticDrag.offsetVelocity(
                            value.velocity, at: value.translation, axes: axes, resistance: resistance
                        )
                        let animation = reduceMotion
                            ? Animation.easeOut(duration: 0.2)
                            : spring.animation(initialVelocity: ElasticDrag.returnVelocity(offset: offset, velocity: velocity))
                        withAnimation(animation) {
                            offset = .zero
                        }
                    }
            )
    }
}
