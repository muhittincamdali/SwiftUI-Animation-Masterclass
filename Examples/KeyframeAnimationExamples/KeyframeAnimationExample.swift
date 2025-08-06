import SwiftUI

struct KeyframeAnimationExample: View {
    @State private var animationPhase = 0
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .scaleEffect(animationPhase >= 1 ? 1.3 : 1.0)
                .rotationEffect(.degrees(animationPhase >= 2 ? 180 : 0))
                .opacity(animationPhase >= 3 ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: animationPhase)
            
            Button("Next Phase") {
                animationPhase = (animationPhase + 1) % 4
            }
            .padding()
        }
    }
}

#Preview {
    KeyframeAnimationExample()
}
