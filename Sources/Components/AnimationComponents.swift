import SwiftUI

/// Animation Components for SwiftUI Animation Masterclass
public struct AnimationComponents {
    public static let version = "1.0.0"
    
    public init() {}
}

/// Basic Animation Component
public struct BasicAnimationComponent: View {
    @State private var isAnimating = false
    
    public var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 100, height: 100)
            .scaleEffect(isAnimating ? 1.5 : 1.0)
            .animation(.easeInOut(duration: 0.5), value: isAnimating)
            .onTapGesture {
                isAnimating.toggle()
            }
    }
}

/// Spring Animation Component
public struct SpringAnimationComponent: View {
    @State private var isAnimating = false
    
    public var body: some View {
        Rectangle()
            .fill(Color.green)
            .frame(width: 120, height: 80)
            .offset(y: isAnimating ? -50 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
            .onTapGesture {
                isAnimating.toggle()
            }
    }
}

/// Keyframe Animation Component
public struct KeyframeAnimationComponent: View {
    @State private var animationPhase = 0
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.orange)
            .frame(width: 100, height: 100)
            .scaleEffect(animationPhase >= 1 ? 1.3 : 1.0)
            .rotationEffect(.degrees(animationPhase >= 2 ? 180 : 0))
            .opacity(animationPhase >= 3 ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.5), value: animationPhase)
            .onTapGesture {
                animationPhase = (animationPhase + 1) % 4
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        BasicAnimationComponent()
        SpringAnimationComponent()
        KeyframeAnimationComponent()
    }
}
