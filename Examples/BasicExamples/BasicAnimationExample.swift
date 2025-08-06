import SwiftUI
import SwiftUIAnimationMasterclass

struct BasicAnimationExample: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0.0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Basic Animation Examples")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Scale Animation
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 0.5), value: scale)
                .onTapGesture {
                    scale = scale == 1.0 ? 1.5 : 1.0
                }
            
            // Opacity Animation
            Circle()
                .fill(Color.green)
                .frame(width: 100, height: 100)
                .opacity(opacity)
                .animation(.easeInOut(duration: 0.3), value: opacity)
                .onTapGesture {
                    opacity = opacity == 1.0 ? 0.3 : 1.0
                }
            
            // Rotation Animation
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(rotation))
                .animation(.easeInOut(duration: 0.8), value: rotation)
                .onTapGesture {
                    rotation += 360
                }
            
            // Combined Animation
            Capsule()
                .fill(Color.purple)
                .frame(width: 120, height: 60)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.7 : 1.0)
                .rotationEffect(.degrees(isAnimating ? 180 : 0))
                .animation(.easeInOut(duration: 1.0), value: isAnimating)
                .onTapGesture {
                    isAnimating.toggle()
                }
            
            Spacer()
        }
        .padding()
    }
}

struct BasicAnimationExample_Previews: PreviewProvider {
    static var previews: some View {
        BasicAnimationExample()
    }
} 