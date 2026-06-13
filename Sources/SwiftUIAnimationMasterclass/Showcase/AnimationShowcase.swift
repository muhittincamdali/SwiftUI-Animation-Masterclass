import SwiftUI

/// Main entry point for the SwiftUI Animation Masterclass.
public enum AnimationMasterclass {
    public static let version = "2.0.0"
}

@MainActor
public struct AnimationShowcase: View {
    @State private var animate: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 40) {
            Text("Animation Masterclass")
                .font(.largeTitle.bold())
            
            RoundedRectangle(cornerRadius: animate ? 50 : 12)
                .fill(animate ? .blue : .red)
                .frame(width: animate ? 200 : 100, height: 100)
                .rotationEffect(.degrees(animate ? 360 : 0))
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animate)
            
            Button("Animate") {
                animate.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
