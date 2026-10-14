import SwiftUI

public extension View {
    /// Makes the view draggable along one axis between resting offsets, such as the detents of
    /// a pull-up panel or the pages of a carousel.
    ///
    /// On release the view lands on the offset its momentum carries it closest to, so a flick
    /// moves on to the next offset and a slow release returns to the nearest one. Past the first
    /// and last offsets the view stretches with rubber-band resistance.
    ///
    /// ```swift
    /// @State private var detent = 1
    ///
    /// PanelView()
    ///     .snapDrag(.vertical, offsets: [0, 260], selection: $detent)
    /// ```
    ///
    /// Changing `selection` from code moves the view with the same spring. With Reduce Motion
    /// on, the view moves with a short ease-out instead.
    ///
    /// - Parameters:
    ///   - axis: Direction of the drag.
    ///   - offsets: Resting offsets in points, at least one, all finite.
    ///   - selection: Index in `offsets` of the current resting offset.
    ///   - decay: How far a flick carries the view before the nearest offset is chosen.
    ///   - spring: Spring that settles the view on its offset.
    func snapDrag(
        _ axis: Axis,
        offsets: [CGFloat],
        selection: Binding<Int>,
        decay: Decay = .normal,
        spring: DampedSpring = .snappy
    ) -> some View {
        modifier(SnapDragModifier(axis: axis, offsets: offsets, selection: selection, decay: decay, spring: spring))
    }
}

struct SnapDragModifier: ViewModifier {
    let axis: Axis
    let offsets: [CGFloat]
    @Binding var selection: Int
    let decay: Decay
    let spring: DampedSpring

    @State private var position: CGFloat?
    @State private var dragStart: CGFloat?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    nonisolated init(axis: Axis, offsets: [CGFloat], selection: Binding<Int>, decay: Decay, spring: DampedSpring) {
        precondition(!offsets.isEmpty, "snapDrag needs at least one offset")
        // A NaN offset would make the drag range NaN...NaN, which traps on the first drag
        // instead of here; an infinite one would move the view out of sight.
        precondition(offsets.allSatisfy(\.isFinite), "snapDrag offsets must be finite")
        self.axis = axis
        self.offsets = offsets
        _selection = selection
        self.decay = decay
        self.spring = spring
    }

    private var restingOffset: CGFloat {
        offsets[min(max(selection, 0), offsets.count - 1)]
    }

    func body(content: Content) -> some View {
        let current = position ?? restingOffset
        content
            .offset(x: axis == .horizontal ? current : 0, y: axis == .vertical ? current : 0)
            .gesture(drag)
            .onChange(of: selection) {
                guard dragStart == nil else { return }
                settle(at: restingOffset, velocity: 0)
            }
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                let start = dragStart ?? (position ?? restingOffset)
                dragStart = start
                let translation = axis == .horizontal ? value.translation.width : value.translation.height
                position = SnapDrag.position(start: start, translation: translation, offsets: offsets)
            }
            .onEnded { value in
                let release = position ?? restingOffset
                let velocity = SnapDrag.finiteVelocity(axis == .horizontal ? value.velocity.width : value.velocity.height)
                let index = SnapPoints(offsets.map(Double.init)).index(forRelease: release, velocity: velocity, decay: decay)
                let target = offsets.sorted()[index]
                dragStart = nil
                settle(at: target, velocity: velocity)
                if let selected = offsets.firstIndex(of: target), selected != selection {
                    selection = selected
                }
            }
    }

    private func settle(at target: CGFloat, velocity: CGFloat) {
        let start = position ?? restingOffset
        let animation = reduceMotion
            ? Animation.easeOut(duration: 0.2)
            : spring.animation(initialVelocity: DampedSpring.relativeVelocity(velocity, from: start, to: target))
        withAnimation(animation) {
            position = target
        }
    }
}

/// The math behind ``SwiftUICore/View/snapDrag(_:offsets:selection:decay:spring:)``.
enum SnapDrag {
    /// Rubber-band resistance used past the first and last offsets, in points.
    static let resistance: CGFloat = 200

    /// The release velocity, or 0 when the gesture reports a non-finite one: NaN would pick the
    /// first offset whatever the position.
    static func finiteVelocity(_ velocity: CGFloat) -> CGFloat {
        velocity.isFinite ? velocity : 0
    }

    /// Position of the view while dragging: follows the finger between the outer offsets and
    /// stretches with resistance beyond them.
    static func position(start: CGFloat, translation: CGFloat, offsets: [CGFloat]) -> CGFloat {
        let lower = offsets.min() ?? 0
        let upper = offsets.max() ?? 0
        return RubberBand.clamp(start + translation, to: lower...upper, dimension: resistance)
    }
}
