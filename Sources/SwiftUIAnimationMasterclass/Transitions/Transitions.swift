import SwiftUI

/// Reveals or hides a view through a growing or shrinking circle.
///
/// Use it through ``SwiftUI/Transition/iris(origin:)``. With Reduce Motion on, the view fades
/// instead.
public struct IrisTransition: Transition {
    /// Center of the circle, relative to the view.
    public var origin: UnitPoint

    /// Creates the transition.
    public init(origin: UnitPoint = .center) {
        self.origin = origin
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        MotionAwareTransition(phase: phase) { phase in
            content.mask {
                GeometryReader { proxy in
                    let radius = Self.coveringRadius(in: proxy.size, origin: origin)
                    let center = CGPoint(x: origin.x * proxy.size.width, y: origin.y * proxy.size.height)
                    Circle()
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                        .scaleEffect(phase.isIdentity ? 1 : Self.hiddenScale, anchor: origin)
                }
            }
        }
    }

    /// Scale of the circle while the view is hidden. Zero makes the transform singular.
    nonisolated static let hiddenScale: CGFloat = 0.001

    /// Radius of a circle centered at `origin` that covers the whole of `size`: the distance to
    /// the farthest corner.
    nonisolated static func coveringRadius(in size: CGSize, origin: UnitPoint) -> CGFloat {
        let center = CGPoint(x: origin.x * size.width, y: origin.y * size.height)
        let corners = [CGPoint.zero, CGPoint(x: size.width, y: 0), CGPoint(x: 0, y: size.height), CGPoint(x: size.width, y: size.height)]
        let farthest = corners.map { hypot($0.x - center.x, $0.y - center.y) }.max() ?? 0
        return farthest.isFinite ? farthest : 0
    }
}

/// Reveals a view from one edge to the opposite edge, like a wipe in a slide show.
///
/// Use it through ``SwiftUI/Transition/wipe(from:)``. With Reduce Motion on, the view fades
/// instead.
public struct WipeTransition: Transition {
    /// Edge the wipe starts from when the view appears; it leaves toward the same edge.
    public var edge: Edge

    /// Creates the transition.
    public init(edge: Edge = .leading) {
        self.edge = edge
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        MotionAwareTransition(phase: phase) { phase in
            content.mask {
                Rectangle()
                    .scaleEffect(Self.scale(for: edge, isIdentity: phase.isIdentity), anchor: Self.anchor(for: edge))
            }
        }
    }

    /// Point the mask grows from.
    nonisolated static func anchor(for edge: Edge) -> UnitPoint {
        switch edge {
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    /// Scale of the mask: full size at rest, collapsed along the axis of the wipe otherwise.
    nonisolated static func scale(for edge: Edge, isIdentity: Bool) -> CGSize {
        guard !isIdentity else { return CGSize(width: 1, height: 1) }
        switch edge {
        case .leading, .trailing: return CGSize(width: 0.001, height: 1)
        case .top, .bottom: return CGSize(width: 1, height: 0.001)
        }
    }
}

/// Turns a view in 3D around one axis, like a card being flipped in or out.
///
/// Use it through ``SwiftUI/Transition/flip(axis:)``. With Reduce Motion on, the view fades
/// instead.
public struct FlipTransition: Transition {
    /// Axis the view turns around.
    public var axis: Axis

    /// Creates the transition.
    public init(axis: Axis = .vertical) {
        self.axis = axis
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        MotionAwareTransition(phase: phase) { phase in
            content
                .rotation3DEffect(
                    Self.angle(for: phase),
                    axis: axis == .vertical ? (x: 0, y: 1, z: 0) : (x: 1, y: 0, z: 0),
                    perspective: 0.5
                )
                .opacity(phase.isIdentity ? 1 : 0)
        }
    }

    /// Angle in each phase: an appearing view turns in from one side and a disappearing view
    /// leaves toward the other, so a swap reads as one continuous flip.
    nonisolated static func angle(for phase: TransitionPhase) -> Angle {
        switch phase {
        case .willAppear: .degrees(-90)
        case .identity: .zero
        case .didDisappear: .degrees(90)
        }
    }
}

/// Grows a view from a smaller, blurred, transparent version of itself.
///
/// Use it through ``SwiftUI/Transition/pop``. Pair it with a spring for a small overshoot.
/// With Reduce Motion on, the view fades instead.
public struct PopTransition: Transition {
    /// Scale of the view while it is hidden.
    public var hiddenScale: CGFloat
    /// Blur radius of the view while it is hidden, in points.
    public var hiddenBlur: CGFloat

    /// Creates the transition.
    public init(hiddenScale: CGFloat = 0.6, hiddenBlur: CGFloat = 8) {
        self.hiddenScale = hiddenScale
        self.hiddenBlur = hiddenBlur
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        MotionAwareTransition(phase: phase) { phase in
            content
                .scaleEffect(phase.isIdentity ? 1 : hiddenScale)
                .blur(radius: phase.isIdentity ? 0 : hiddenBlur)
                .opacity(phase.isIdentity ? 1 : 0)
        }
    }
}

public extension Transition where Self == IrisTransition {
    /// Reveals the view through a circle that grows from `origin`, and hides it the same way.
    ///
    /// ```swift
    /// if showsPhoto {
    ///     PhotoView()
    ///         .transition(.iris(origin: .topTrailing))
    /// }
    /// ```
    static func iris(origin: UnitPoint = .center) -> IrisTransition { IrisTransition(origin: origin) }
}

public extension Transition where Self == WipeTransition {
    /// Reveals the view from `edge` to the opposite edge, and hides it back toward `edge`.
    static func wipe(from edge: Edge = .leading) -> WipeTransition { WipeTransition(edge: edge) }
}

public extension Transition where Self == FlipTransition {
    /// Turns the view in and out in 3D around `axis`: `.vertical` turns it like a card on a
    /// table, `.horizontal` like a calendar page.
    static func flip(axis: Axis = .vertical) -> FlipTransition { FlipTransition(axis: axis) }
}

public extension Transition where Self == PopTransition {
    /// Grows the view from a smaller, blurred version of itself, and shrinks it away.
    static var pop: PopTransition { PopTransition() }
}

/// Shows the motion of a transition, or only a fade when Reduce Motion is on. A `Transition`
/// cannot read the environment itself, so this view does it and hands the content the phase to
/// draw: the real one, or `.identity` with the fade applied on top.
struct MotionAwareTransition<Content: View>: View {
    let phase: TransitionPhase
    @ViewBuilder let content: (TransitionPhase) -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            content(.identity).opacity(phase.isIdentity ? 1 : 0)
        } else {
            content(phase)
        }
    }
}
