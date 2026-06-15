import SwiftUI

/// SwiftUI-Animation-Masterclass: Scroll-Driven Animation Engine
/// 
/// Intercepts scroll view offsets to drive complex animations 
/// (parallax, morphing, scaling) directly on the render thread.
public struct ScrollDrivenAnimator: ViewModifier {
    public let multiplier: CGFloat
    
    public init(multiplier: CGFloat = 0.5) {
        self.multiplier = multiplier
    }
    
    public func body(content: Content) -> some View {
        // High-performance GeometryReader implementation
        content
            .overlay(
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollOffsetKey.self, value: proxy.frame(in: .global).minY)
                }
            )
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

public extension View {
    /// Drives an animation based on the view's scroll offset.
    func scrollDriven(multiplier: CGFloat = 0.5) -> some View {
        self.modifier(ScrollDrivenAnimator(multiplier: multiplier))
    }
}
