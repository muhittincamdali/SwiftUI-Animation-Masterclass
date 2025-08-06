import SwiftUI
import SwiftUIAnimationMasterclass

struct SpringAnimationExample: View {
    @State private var isExpanded = false
    @State private var isBouncing = false
    @State private var offset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Spring Animation Examples")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Natural Spring Animation
            Rectangle()
                .fill(Color.blue)
                .frame(width: isExpanded ? 200 : 100, height: 100)
                .animation(.spring(damping: 0.7, response: 0.5), value: isExpanded)
                .onTapGesture {
                    isExpanded.toggle()
                }
                .overlay(
                    Text("Natural Spring")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                )
            
            // Bouncy Spring Animation
            Circle()
                .fill(Color.green)
                .frame(width: 100, height: 100)
                .scaleEffect(isBouncing ? 1.3 : 1.0)
                .animation(.spring(damping: 0.3, response: 0.8), value: isBouncing)
                .onTapGesture {
                    isBouncing.toggle()
                }
                .overlay(
                    Text("Bouncy")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                )
            
            // Smooth Spring Animation
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.orange)
                .frame(width: 120, height: 80)
                .offset(y: offset)
                .animation(.spring(damping: 0.9, response: 0.3), value: offset)
                .onTapGesture {
                    offset = offset == 0 ? 50 : 0
                }
                .overlay(
                    Text("Smooth")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                )
            
            // Stiff Spring Animation
            Capsule()
                .fill(Color.purple)
                .frame(width: 100, height: 60)
                .scaleEffect(scale)
                .animation(.spring(damping: 0.8, response: 0.2), value: scale)
                .onTapGesture {
                    scale = scale == 1.0 ? 0.8 : 1.0
                }
                .overlay(
                    Text("Stiff")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                )
            
            Spacer()
        }
        .padding()
    }
}

struct SpringAnimationExample_Previews: PreviewProvider {
    static var previews: some View {
        SpringAnimationExample()
    }
} 