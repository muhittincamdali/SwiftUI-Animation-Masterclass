import SwiftUI
import SwiftUIAnimationMasterclass

struct TransitionExample: View {
    @State private var showFirstView = true
    @State private var showSecondView = false
    @State private var showThirdView = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Transition Examples")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Slide Transition
            VStack {
                Text("Slide Transition")
                    .font(.headline)
                
                if showFirstView {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 150, height: 100)
                        .transition(.slide)
                        .animation(.easeInOut(duration: 0.5), value: showFirstView)
                }
                
                Button("Toggle Slide") {
                    withAnimation {
                        showFirstView.toggle()
                    }
                }
                .padding()
            }
            
            // Scale Transition
            VStack {
                Text("Scale Transition")
                    .font(.headline)
                
                if showSecondView {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.5), value: showSecondView)
                }
                
                Button("Toggle Scale") {
                    withAnimation {
                        showSecondView.toggle()
                    }
                }
                .padding()
            }
            
            // Opacity Transition
            VStack {
                Text("Opacity Transition")
                    .font(.headline)
                
                if showThirdView {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.orange)
                        .frame(width: 120, height: 80)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: showThirdView)
                }
                
                Button("Toggle Opacity") {
                    withAnimation {
                        showThirdView.toggle()
                    }
                }
                .padding()
            }
            
            // Combined Transition
            VStack {
                Text("Combined Transition")
                    .font(.headline)
                
                if showFirstView && showSecondView {
                    Capsule()
                        .fill(Color.purple)
                        .frame(width: 100, height: 60)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .slide.combined(with: .opacity)
                        ))
                        .animation(.easeInOut(duration: 0.8), value: showFirstView && showSecondView)
                }
                
                Button("Toggle Combined") {
                    withAnimation {
                        showFirstView.toggle()
                        showSecondView.toggle()
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}

struct TransitionExample_Previews: PreviewProvider {
    static var previews: some View {
        TransitionExample()
    }
} 