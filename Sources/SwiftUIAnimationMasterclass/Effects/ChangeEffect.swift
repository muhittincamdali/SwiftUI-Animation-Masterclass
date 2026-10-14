import SwiftUI

/// A short animation that draws attention to a view when a value changes, such as a shake
/// for a wrong password or a jump for a new message.
///
/// Apply one with ``SwiftUICore/View/changeEffect(_:value:)``:
///
/// ```swift
/// SecureField("Password", text: $password)
///     .changeEffect(.shake(), value: failedAttempts)
/// ```
///
/// Every effect is a function of its progress from 0 to 1 (see ``state(at:)``), so it can be
/// tested and previewed frame by frame.
public enum ChangeEffect: Hashable, Sendable {
    /// Moves the view left and right with a decaying swing, like a head shaking "no".
    ///
    /// - Parameters:
    ///   - distance: Largest offset in points.
    ///   - count: Number of full swings.
    case shake(distance: CGFloat = 10, count: Int = 3)
    /// Lifts the view and drops it back with a small squash on landing.
    ///
    /// - Parameter height: Height of the jump in points.
    case jump(height: CGFloat = 18)
    /// Turns the view around its center.
    ///
    /// - Parameter turns: Number of full turns; negative values turn counterclockwise.
    case spin(turns: Int = 1)
    /// Grows the view and lets it settle back to its size.
    ///
    /// - Parameter scale: Largest scale.
    case pulse(scale: CGFloat = 1.25)
    /// Sends a fading copy of the view outward from behind it, like a sonar ping.
    ///
    /// - Parameter scale: Scale the copy reaches as it disappears.
    case ping(scale: CGFloat = 1.8)
    /// Sweeps a band of light across the view, clipped to its opaque pixels.
    case shine

    /// Seconds the effect lasts.
    public var duration: Double {
        switch self {
        case let .shake(_, count): 0.12 * Double(Self.clampedCount(count)) + 0.1
        case .jump: 0.5
        case let .spin(turns): 0.45 + 0.25 * Double(min(abs(Self.clampedTurns(turns)), 8))
        case .pulse: 0.35
        case .ping: 0.7
        case .shine: 0.8
        }
    }

    /// What the effect does to the view at `progress`, from 0 (start) to 1 (end). Values
    /// outside `0...1`, and NaN, count as the nearest end; at both ends the view is unchanged.
    public func state(at progress: Double) -> ChangeEffectState {
        let progress = Self.clampedProgress(progress)
        var state = ChangeEffectState()
        switch self {
        case let .shake(distance, count):
            let swings = Double(Self.clampedCount(count))
            state.offset.width = Self.finite(distance) * sin(progress * swings * 2 * .pi) * (1 - progress)
        case let .jump(height):
            // A parabola reads as a throw: up quickly, slowest at the top, down quickly.
            state.offset.height = -Self.finite(height) * 4 * progress * (1 - progress)
            // A squash in the last fifth, when the view lands.
            let landing = max(0, (progress - 0.8) / 0.2)
            let squash = 0.12 * sin(landing * .pi)
            state.scale = CGSize(width: 1 + squash, height: 1 - squash)
        case let .spin(turns):
            state.rotation = .degrees(360 * Double(Self.clampedTurns(turns)) * Self.easeInOut(progress))
        case let .pulse(scale):
            let grown = 1 + (Self.finite(scale, default: 1) - 1) * sin(progress * .pi)
            state.scale = CGSize(width: grown, height: grown)
        case let .ping(scale):
            if progress > 0, progress < 1 {
                state.echoScale = 1 + (Self.finite(scale, default: 1) - 1) * Self.easeOut(progress)
                state.echoOpacity = 0.6 * (1 - progress)
            }
        case .shine:
            if progress > 0, progress < 1 {
                state.shinePosition = Self.easeInOut(progress)
            }
        }
        return state
    }

    // Large counts would make the effect last for minutes; these limits keep it a gesture.
    static func clampedCount(_ count: Int) -> Int { min(max(count, 1), 20) }
    static func clampedTurns(_ turns: Int) -> Int { min(max(turns, -20), 20) }

    static func clampedProgress(_ progress: Double) -> Double {
        progress.isNaN ? 1 : min(max(progress, 0), 1)
    }

    static func finite(_ value: CGFloat, default fallback: CGFloat = 0) -> CGFloat {
        value.isFinite ? value : fallback
    }

    static func easeInOut(_ progress: Double) -> Double {
        progress * progress * (3 - 2 * progress)
    }

    static func easeOut(_ progress: Double) -> Double {
        1 - (1 - progress) * (1 - progress)
    }
}

/// The transform a ``ChangeEffect`` applies at one moment.
public struct ChangeEffectState: Hashable, Sendable {
    /// Offset from the resting position, in points.
    public var offset: CGSize = .zero
    /// Horizontal and vertical scale around the center.
    public var scale = CGSize(width: 1, height: 1)
    /// Rotation around the center.
    public var rotation: Angle = .zero
    /// Scale of the fading copy behind the view (``ChangeEffect/ping(scale:)``).
    public var echoScale: CGFloat = 1
    /// Opacity of the fading copy behind the view; `0` hides it.
    public var echoOpacity: Double = 0
    /// Position of the light band from 0 (left of the view) to 1 (right of the view), or `nil`
    /// when there is no band (``ChangeEffect/shine``).
    public var shinePosition: Double?

    /// The state of a view at rest.
    public static let identity = ChangeEffectState()

    /// Creates a resting state.
    public init() {}
}

public extension View {
    /// Plays `effect` every time `value` changes.
    ///
    /// ```swift
    /// Image(systemName: "bell.fill")
    ///     .changeEffect(.jump(), value: unreadCount)
    /// ```
    ///
    /// The effect only changes how the view is drawn, not its layout. With Reduce Motion on,
    /// nothing plays.
    ///
    /// - Parameters:
    ///   - effect: The animation to play.
    ///   - value: Any value; each change plays the effect once.
    func changeEffect(_ effect: ChangeEffect, value: some Equatable) -> some View {
        modifier(ChangeEffectModifier(effect: effect, value: value))
    }
}

struct ChangeEffectModifier<Value: Equatable>: ViewModifier {
    let effect: ChangeEffect
    let value: Value

    @State private var plays = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .modifier(ChangeEffectPlayer(effect: effect, plays: plays))
            .onChange(of: value) {
                guard !reduceMotion else { return }
                plays &+= 1
            }
    }
}

/// Plays `effect` once each time `plays` changes. Kept apart from the generic modifier so the
/// keyframe closures capture only `Sendable` values.
struct ChangeEffectPlayer: ViewModifier {
    let effect: ChangeEffect
    let plays: Int

    func body(content: Content) -> some View {
        let effect = effect
        content
            // A progress of 1 is the resting state; each trigger jumps to 0 and runs to 1.
            .keyframeAnimator(initialValue: 1.0, trigger: plays) { view, progress in
                view.modifier(ChangeEffectFrame(state: effect.state(at: progress)))
            } keyframes: { _ in
                MoveKeyframe(0.0)
                LinearKeyframe(1.0, duration: effect.duration)
            }
    }
}

/// Applies a ``ChangeEffectState`` to a view.
struct ChangeEffectFrame: ViewModifier {
    let state: ChangeEffectState

    // The keyframe animator calls this from a nonisolated closure.
    nonisolated init(state: ChangeEffectState) {
        self.state = state
    }

    func body(content: Content) -> some View {
        content
            .background {
                if state.echoOpacity > 0 {
                    content
                        .scaleEffect(state.echoScale)
                        .opacity(state.echoOpacity)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .overlay {
                if let position = state.shinePosition {
                    ShineBand(position: position)
                        .mask { content }
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .scaleEffect(x: state.scale.width, y: state.scale.height)
            .rotationEffect(state.rotation)
            .offset(state.offset)
    }
}

/// A soft white band that crosses the view from left to right as `position` goes from 0 to 1.
struct ShineBand: View {
    let position: Double

    /// Width of the band relative to the view.
    nonisolated static let relativeWidth = 0.45

    /// Horizontal offset of the band's leading edge in a view `width` points wide: fully left of
    /// the view at 0, fully right of it at 1.
    nonisolated static func offset(at position: Double, width: CGFloat) -> CGFloat {
        let band = width * relativeWidth
        return -band + position * (width + band)
    }

    var body: some View {
        GeometryReader { proxy in
            LinearGradient(
                colors: [.white.opacity(0), .white.opacity(0.75), .white.opacity(0)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: proxy.size.width * Self.relativeWidth)
            .offset(x: Self.offset(at: position, width: proxy.size.width))
        }
    }
}
