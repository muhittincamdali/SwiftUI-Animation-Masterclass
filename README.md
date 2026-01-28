# SwiftUI Animation Masterclass

<p align="center">
  <img src="Assets/banner.png" alt="SwiftUI Animation Masterclass" width="800">
</p>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat&logo=swift&logoColor=white" alt="Swift"></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-15.0+-000000?style=flat&logo=apple&logoColor=white" alt="iOS"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"></a>
</p>

<p align="center">
  <b>Advanced animations, transitions, and micro-interactions for SwiftUI.</b>
</p>

---

## Preview

<p align="center">
  <img src="Assets/animations-demo.gif" alt="Animations Demo" width="300">
</p>

## Animation Types

| Type | Description |
|------|-------------|
| **Basic** | Scale, opacity, rotation, offset |
| **Spring** | Bouncy, physics-based animations |
| **Timing Curves** | Ease in/out, linear, custom bezier |
| **Keyframe** | Multi-step animations (iOS 17+) |
| **Phase** | State-driven animation sequences |
| **Matched Geometry** | Shared element transitions |
| **Transitions** | View insertion/removal effects |

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git", from: "1.0.0")
]
```

## Quick Start

### Basic Animations

```swift
struct ScaleAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .scaleEffect(isAnimating ? 1.5 : 1.0)
            .opacity(isAnimating ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.5), value: isAnimating)
            .onTapGesture {
                isAnimating.toggle()
            }
    }
}
```

### Spring Animation

```swift
struct SpringAnimation: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(.green)
            .frame(width: 80, height: 80)
            .offset(y: offset)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                    offset = offset == 0 ? 200 : 0
                }
            }
    }
}
```

### Rotation Animation

```swift
struct SpinningLoader: View {
    @State private var isRotating = false
    
    var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .font(.system(size: 50))
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}
```

### Matched Geometry Effect

```swift
struct MatchedGeometryExample: View {
    @State private var isExpanded = false
    @Namespace private var animation
    
    var body: some View {
        VStack {
            if isExpanded {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue)
                    .matchedGeometryEffect(id: "card", in: animation)
                    .frame(width: 300, height: 400)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.blue)
                    .matchedGeometryEffect(id: "card", in: animation)
                    .frame(width: 100, height: 100)
            }
        }
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
}
```

### Custom Transitions

```swift
extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        )
    }
}

struct TransitionExample: View {
    @State private var showDetail = false
    
    var body: some View {
        VStack {
            Button("Toggle") {
                withAnimation {
                    showDetail.toggle()
                }
            }
            
            if showDetail {
                DetailView()
                    .transition(.slideAndFade)
            }
        }
    }
}
```

### Keyframe Animation (iOS 17+)

```swift
struct KeyframeExample: View {
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(.purple)
            .frame(width: 100, height: 100)
            .keyframeAnimator(initialValue: AnimationValues(), trigger: animate) { content, value in
                content
                    .scaleEffect(value.scale)
                    .rotationEffect(value.rotation)
                    .offset(y: value.yOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.5, duration: 0.3)
                    SpringKeyframe(1.0, duration: 0.3)
                }
                KeyframeTrack(\.rotation) {
                    LinearKeyframe(.degrees(180), duration: 0.3)
                    LinearKeyframe(.degrees(360), duration: 0.3)
                }
                KeyframeTrack(\.yOffset) {
                    SpringKeyframe(-50, duration: 0.3)
                    SpringKeyframe(0, duration: 0.3)
                }
            }
            .onTapGesture {
                animate.toggle()
            }
    }
}

struct AnimationValues {
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var yOffset: CGFloat = 0
}
```

### Loading Animation

```swift
struct PulsingDots: View {
    @State private var scale: [CGFloat] = [1, 1, 1]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.blue)
                    .frame(width: 12, height: 12)
                    .scaleEffect(scale[index])
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.6)
                    .repeatForever()
                    .delay(Double(i) * 0.2)
                ) {
                    scale[i] = 0.5
                }
            }
        }
    }
}
```

### Shimmer Effect

```swift
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.5), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// Usage
Text("Loading...")
    .shimmer()
```

## Animation Curves

```swift
// Built-in curves
.animation(.linear(duration: 0.5), value: state)
.animation(.easeIn(duration: 0.5), value: state)
.animation(.easeOut(duration: 0.5), value: state)
.animation(.easeInOut(duration: 0.5), value: state)

// Spring animations
.animation(.spring(), value: state)
.animation(.spring(response: 0.5, dampingFraction: 0.6), value: state)
.animation(.interpolatingSpring(stiffness: 100, damping: 10), value: state)

// Custom timing curve
.animation(.timingCurve(0.68, -0.55, 0.27, 1.55, duration: 0.5), value: state)
```

## Project Structure

```
SwiftUI-Animation-Masterclass/
├── Sources/
│   ├── Animations/
│   │   ├── BasicAnimations.swift
│   │   ├── SpringAnimations.swift
│   │   └── KeyframeAnimations.swift
│   ├── Transitions/
│   │   └── CustomTransitions.swift
│   ├── Modifiers/
│   │   ├── ShimmerModifier.swift
│   │   └── PulseModifier.swift
│   └── Examples/
├── Examples/
└── Tests/
```

## Requirements

- iOS 15.0+ (iOS 17+ for Keyframe animations)
- Xcode 15.0+
- Swift 5.9+

## Documentation

- [Animation Basics](Documentation/AnimationBasics.md)
- [Spring Physics](Documentation/SpringPhysics.md)
- [Custom Transitions](Documentation/CustomTransitions.md)
- [Performance Tips](Documentation/Performance.md)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License. See [LICENSE](LICENSE).

## Author

**Muhittin Camdali** — [@muhittincamdali](https://github.com/muhittincamdali)

---

<p align="center">
  <sub>Bring your UI to life ❤️</sub>
</p>
