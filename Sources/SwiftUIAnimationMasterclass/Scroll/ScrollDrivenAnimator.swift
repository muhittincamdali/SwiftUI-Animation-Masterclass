import SwiftUI

/// Moves a view inside a scroll view at a fraction of the scroll speed, so it looks further
/// away than the content around it (parallax).
///
/// Apply it with ``SwiftUICore/View/scrollDriven(multiplier:)``:
///
/// ```swift
/// ScrollView {
///     Image("mountains")
///         .scrollDriven(multiplier: 0.4)
///     ArticleText()
/// }
/// ```
///
/// The offset is applied with `visualEffect`, so it changes how the view is drawn every frame
/// without changing the layout. With Reduce Motion on, the view scrolls normally.
public struct ScrollDrivenAnimator: ViewModifier {
    /// Share of the scroll distance the view lags behind: `0` scrolls normally, `0.5` moves at
    /// half the scroll speed, `1` keeps the view still on screen.
    public let multiplier: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates the modifier.
    ///
    /// - Parameter multiplier: Share of the scroll distance the view lags behind.
    public init(multiplier: CGFloat = 0.5) {
        self.multiplier = multiplier
    }

    public func body(content: Content) -> some View {
        let multiplier = reduceMotion ? 0 : multiplier
        content.visualEffect { effect, proxy in
            effect.offset(y: ScrollParallax.offset(minY: proxy.frame(in: .scrollView).minY, multiplier: multiplier))
        }
    }
}

/// The math behind ``ScrollDrivenAnimator``.
enum ScrollParallax {
    /// Vertical offset for a view whose top is `minY` points below the top of its scroll view.
    /// Scrolling moves `minY`; offsetting by `-minY · multiplier` takes back that share of the
    /// motion. Non-finite values give no offset.
    static func offset(minY: CGFloat, multiplier: CGFloat) -> CGFloat {
        let offset = -minY * multiplier
        return offset.isFinite ? offset : 0
    }
}

public extension View {
    /// Moves the view at a fraction of the scroll speed inside a scroll view (parallax).
    ///
    /// - Parameter multiplier: Share of the scroll distance the view lags behind: `0` scrolls
    ///   normally, `0.5` moves at half the scroll speed, `1` keeps the view still on screen.
    func scrollDriven(multiplier: CGFloat = 0.5) -> some View {
        modifier(ScrollDrivenAnimator(multiplier: multiplier))
    }
}
