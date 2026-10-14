import SwiftUI

/// Information about the package.
public enum AnimationMasterclass {
    /// Version of the package, following semantic versioning.
    public static let version = "2.0.0"
}

/// A one-screen tour of the package: a bouncing drop, a change effect, a particle burst, a
/// transition and a draggable card.
///
/// Drop it into a preview or a scene to see the package work before writing any code:
///
/// ```swift
/// #Preview {
///     AnimationShowcase()
/// }
/// ```
public struct AnimationShowcase: View {
    @State private var isDropped = false
    @State private var likes = 0
    @State private var showsBadge = true

    /// Creates the showcase.
    public init() {}

    public var body: some View {
        VStack(spacing: 32) {
            Text("Animation Masterclass")
                .font(.title.bold())

            HStack(spacing: 28) {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 44, height: 44)
                    .offset(y: isDropped ? 60 : -20)
                    .animation(.gravityBounce(), value: isDropped)
                    .onTapGesture { isDropped.toggle() }
                    .accessibilityLabel("Drop the ball")
                    .accessibilityAddTraits(.isButton)

                Button {
                    likes += 1
                } label: {
                    Label("\(likes)", systemImage: "heart.fill")
                }
                .buttonStyle(.borderedProminent)
                .changeEffect(.jump(), value: likes)
                .particleBurst(.hearts, trigger: likes)
                .zIndex(1)

                Button(showsBadge ? "Hide" : "Show") {
                    withAnimation(.smooth(duration: 0.5)) { showsBadge.toggle() }
                }
                .buttonStyle(.bordered)
            }
            .frame(height: 140)

            ZStack {
                if showsBadge {
                    Label("New", systemImage: "sparkles")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.blue.opacity(0.15), in: .capsule)
                        .transition(.iris())
                }
            }
            .frame(height: 44)

            RoundedRectangle(cornerRadius: 20)
                .fill(.blue.gradient)
                .frame(width: 180, height: 110)
                .overlay {
                    Text("Drag me")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .elasticDrag()
        }
        .padding()
    }
}

#Preview {
    AnimationShowcase()
}
