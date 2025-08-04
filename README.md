# SwiftUI Animation Masterclass

<div align="center">

![SwiftUI Animation Masterclass](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-2.1.0-brightgreen.svg)

**Advanced SwiftUI animation techniques, custom transitions, and micro-interactions library**

[Features](#features) • [Installation](#installation) • [Quick Start](#quick-start) • [Documentation](#documentation) • [Examples](#examples) • [Contributing](#contributing)

</div>

---

## 🎨 Features

### ✨ Advanced Animation Engine
- **60fps+ Performance**: Optimized for smooth animations on all devices
- **Custom Easing Curves**: Bezier-based animation curves for precise control
- **Physics-Based Animations**: Realistic spring and bounce effects
- **3D Transformations**: Metal shader support for complex animations

### 🎯 Micro-Interactions
- **Gesture-Driven Animations**: Responsive to user touch and gestures
- **Haptic Feedback Integration**: Tactile feedback for enhanced UX
- **State-Based Animations**: Automatic animations based on view state
- **Transition Effects**: Custom view transitions and morphing

### 🚀 Performance Optimizations
- **Memory Management**: Efficient animation lifecycle handling
- **GPU Acceleration**: Metal shader support for complex effects
- **Lazy Loading**: On-demand animation resource loading
- **Caching System**: Intelligent animation result caching

### 🎪 Animation Components
- **Particle Systems**: Dynamic particle effects and explosions
- **Morphing Shapes**: Smooth shape transitions and transformations
- **Text Animations**: Typography and text effect animations
- **Color Transitions**: Smooth color blending and gradients

## 📦 Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git", from: "2.1.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git`
3. Select version: `2.1.0`

### Requirements

- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+
- Swift 5.9+
- Xcode 15.0+

## 🚀 Quick Start

### Basic Animation

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

struct ContentView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.blue)
                .frame(width: 200, height: 100)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                .onTapGesture {
                    isAnimating.toggle()
                }
        }
    }
}
```

### Advanced Particle System

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

struct ParticleView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onTapGesture {
            createParticleExplosion()
        }
    }
    
    private func createParticleExplosion() {
        // Implementation details in documentation
    }
}
```

### Custom Transition Animation

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

struct CustomTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0.0)
            .rotation3DEffect(
                .degrees(isActive ? 0 : 45),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.6), value: isActive)
    }
}
```

## 📚 Documentation

### Core Concepts

#### Animation Engine
The animation engine provides a high-performance foundation for all animations:

```swift
// Custom animation curve
let customCurve = AnimationCurve(
    controlPoints: [
        CGPoint(x: 0.25, y: 0.1),
        CGPoint(x: 0.25, y: 1.0)
    ]
)

// Physics-based spring
let springAnimation = SpringAnimation(
    mass: 1.0,
    stiffness: 100.0,
    damping: 10.0
)
```

#### Animation Components
Pre-built components for common animation patterns:

```swift
// Morphing shape
MorphingShape(from: Circle(), to: Rectangle())
    .animation(.easeInOut(duration: 1.0))

// Particle system
ParticleSystem(configuration: ParticleConfiguration())
    .onAppear { system.start() }
```

### Performance Guidelines

1. **Use Appropriate Animation Types**
   - Simple animations: `.animation()` modifier
   - Complex animations: Custom animation curves
   - Physics-based: Spring animations

2. **Optimize for Performance**
   - Avoid animating layout properties frequently
   - Use `withAnimation` for programmatic animations
   - Cache expensive animation calculations

3. **Memory Management**
   - Dispose of animation resources properly
   - Use weak references in animation closures
   - Monitor memory usage during complex animations

## 🎪 Examples

### Interactive Examples

Check out the `Examples/` directory for complete sample projects:

- **Basic Animations**: Simple view animations and transitions
- **Advanced Effects**: Complex particle systems and 3D transformations
- **Micro-Interactions**: Gesture-driven animations and haptic feedback
- **Performance Optimization**: Advanced techniques and best practices

### Animation Gallery

| Animation Type | Description | Performance |
|---------------|-------------|-------------|
| Spring Animations | Physics-based spring effects | 60fps+ |
| Particle Systems | Dynamic particle explosions | 60fps+ |
| Morphing Shapes | Smooth shape transitions | 60fps+ |
| 3D Transformations | Metal-powered 3D effects | 60fps+ |

## 🧪 Testing

Run the test suite to ensure everything works correctly:

```bash
swift test
```

For performance testing:

```bash
swift test --filter PerformanceTests
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Build and run tests
4. Create a feature branch
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**⭐ Star this repository if it helped you!**

## 📊 Project Statistics

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/muhittincamdali/SwiftUI-Animation-Masterclass?style=social)](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/muhittincamdali/SwiftUI-Animation-Masterclass?style=social)](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/network)
[![GitHub issues](https://img.shields.io/github/issues/muhittincamdali/SwiftUI-Animation-Masterclass)](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/muhittincamdali/SwiftUI-Animation-Masterclass)](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/pulls)

</div>

## 🌟 Stargazers

[![Stargazers repo roster for @muhittincamdali/SwiftUI-Animation-Masterclass](https://reporoster.com/stars/muhittincamdali/SwiftUI-Animation-Masterclass)](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/stargazers)

## 🙏 Acknowledgments

- Apple's SwiftUI team for the amazing framework
- The Swift community for inspiration and feedback
- Contributors who help improve this library

## 📞 Support

- **Documentation**: [Full Documentation](Documentation/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/discussions)

---

<div align="center">

**Made with ❤️ by the SwiftUI Animation Masterclass Team**

[GitHub](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass) • [Issues](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/issues) • [Discussions](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/discussions)

</div>
