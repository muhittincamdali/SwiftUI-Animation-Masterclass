```
<p align="center">
  <a href="README.md">🇺🇸 English</a> |
  <a href="README_TR.md">🇹🇷 Türkçe</a>
</p>

╔══════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                      ║
║   ███████╗██╗    ██╗██╗███████╗████████╗██╗   ██╗██╗                                ║
║   ██╔════╝██║    ██║██║██╔════╝╚══██╔══╝██║   ██║██║                                ║
║   ███████╗██║ █╗ ██║██║█████╗     ██║   ██║   ██║██║                                ║
║   ╚════██║██║███╗██║██║██╔══╝     ██║   ██║   ██║██║                                ║
║   ███████║╚███╔███╔╝██║██║        ██║   ╚██████╔╝██║                                ║
║   ╚══════╝ ╚══╝╚══╝ ╚═╝╚═╝        ╚═╝    ╚═════╝ ╚═╝                                ║
║                                                                                      ║
║    █████╗ ███╗   ██╗██╗███╗   ███╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗           ║
║   ██╔══██╗████╗  ██║██║████╗ ████║██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║           ║
║   ███████║██╔██╗ ██║██║██╔████╔██║███████║   ██║   ██║██║   ██║██╔██╗ ██║           ║
║   ██╔══██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║   ██║   ██║██║   ██║██║╚██╗██║           ║
║   ██║  ██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║           ║
║   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝           ║
║                                                                                      ║
║   ████████████████████████████████████████████████████████████████████████████████   ║
║   █ Beautiful, performant, and production-ready animations for SwiftUI          █   ║
║   ████████████████████████████████████████████████████████████████████████████████   ║
║                                                                                      ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

<div align="center">

**50+ production-ready SwiftUI animations with zero dependencies. Drop-in and go.**

[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![macOS](https://img.shields.io/badge/macOS-14.0+-000000?style=for-the-badge&logo=macos&logoColor=white)](https://developer.apple.com/macos/)
[![visionOS](https://img.shields.io/badge/visionOS-1.0+-007AFF?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/visionos/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![CI](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/actions)

[Features](#-features) • [Quick Start](#-quick-start) • [Animations](#-animation-catalog) • [Advanced](#-advanced-usage) • [Docs](Documentation/)

</div>

---

## ✨ Features

- 🎨 **50+ Animations** — Bounce, shake, pulse, morph, flip, and more
- ⚡ **Zero Dependencies** — Pure SwiftUI, no external libraries
- 🎯 **Type-Safe API** — Compile-time safety with Swift 6
- 📱 **Multi-Platform** — iOS, iPadOS, macOS, watchOS, tvOS, visionOS
- 🔧 **Customizable** — Full control over timing, easing, and parameters
- ♿ **Accessible** — Respects reduce motion preferences
- 🧪 **Fully Tested** — 95%+ code coverage
- 📖 **Well Documented** — DocC documentation with examples

---

## 🏗️ Architecture

```mermaid
graph TB
    subgraph "🎬 Animation Engine"
        A[AnimationType] --> B[AnimationModifier]
        B --> C[Core Animation Layer]
    end
    
    subgraph "📱 SwiftUI Integration"
        D[View] --> E[.animate() Modifier]
        E --> A
    end
    
    subgraph "⚙️ Configuration"
        F[Duration]
        G[Spring]
        H[Repeat]
        I[Accessibility]
    end
    
    F --> B
    G --> B
    H --> B
    I --> B
    
    C --> J[Rendered Animation]
    
    style A fill:#FA7343,stroke:#D35400,color:#fff
    style D fill:#4A90D9,stroke:#2E5A8B,color:#fff
    style J fill:#50C878,stroke:#3D9B5C,color:#fff
```

---

## 🚀 Quick Start

### Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import SwiftUIAnimationMasterclass

struct ContentView: View {
    @State private var animate = false
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 60))
            .foregroundStyle(.red)
            .animate(.heartbeat, trigger: animate)
            .onTapGesture { animate.toggle() }
    }
}
```

### One-Line Magic

```swift
// Before: Complex animation code
withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
    // Multiple state changes...
}

// After: One line with Animation Masterclass
Button("Tap Me")
    .animate(.bounce)
```

---

## 🎭 Animation Catalog

### Attention Seekers

| Animation | Usage |
|-----------|-------|
| 🔵 Bounce | `.animate(.bounce)` |
| 🔴 Shake | `.animate(.shake)` |
| 🟢 Pulse | `.animate(.pulse)` |
| 🟡 Wobble | `.animate(.wobble)` |
| 🟣 Swing | `.animate(.swing)` |
| ❤️ Heartbeat | `.animate(.heartbeat)` |
| ⚡ Flash | `.animate(.flash)` |
| 🎉 Tada | `.animate(.tada)` |

### Entrances & Exits

| Entrance | Exit | Usage |
|----------|------|-------|
| Fade In | Fade Out | `.animate(.fadeIn)` / `.animate(.fadeOut)` |
| Slide In | Slide Out | `.animate(.slideIn(from: .leading))` |
| Zoom In | Zoom Out | `.animate(.zoomIn)` / `.animate(.zoomOut)` |
| Flip In | Flip Out | `.animate(.flipIn)` / `.animate(.flipOut)` |
| Bounce In | — | `.animate(.bounceIn)` |
| Drop In | Hinge | `.animate(.dropIn)` / `.animate(.hinge)` |

### Continuous

| Animation | Usage |
|-----------|-------|
| 🔄 Spin | `.animate(.spin, repeatForever: true)` |
| 🎈 Float | `.animate(.float, repeatForever: true)` |
| ✨ Glow | `.animate(.glow, repeatForever: true)` |
| 🌬️ Breathe | `.animate(.breathe, repeatForever: true)` |

---

## ⚡ Advanced Usage

### Chained Animations

```swift
Text("Hello")
    .animate(.fadeIn)
    .then(.bounce)
    .then(.pulse)
```

### Custom Timing

```swift
Image(systemName: "star.fill")
    .animate(.bounce, duration: 0.5, delay: 0.2)
```

### Spring Customization

```swift
Button("Tap")
    .animate(.bounce, spring: .bouncy(duration: 0.6, extraBounce: 0.2))
```

### Repeat & Infinite

```swift
// Repeat 3 times
Circle().animate(.pulse, repeatCount: 3)

// Infinite
Circle().animate(.glow, repeatForever: true)
```

### Accessibility

```swift
// Automatically respects reduce motion
Button("Submit")
    .animate(.bounce)

// Override for essential animations
Button("Submit")
    .animate(.bounce, reducedMotionBehavior: .fade)
```

---

## 📁 Project Structure

```
SwiftUI-Animation-Masterclass/
├── 📂 Sources/
│   ├── Core/                    # Animation engine
│   ├── Animations/              # 50+ animation types
│   ├── Modifiers/               # View modifiers
│   └── Utilities/               # Helpers & extensions
├── 📂 Examples/                 # Sample projects
├── 📂 Tests/                    # Unit & UI tests
└── 📂 Documentation/            # Guides
```

---

## 📋 Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 17.0+ |
| macOS | 14.0+ |
| watchOS | 10.0+ |
| tvOS | 17.0+ |
| visionOS | 1.0+ |
| Swift | 6.0+ |
| Xcode | 16.0+ |

---

## 📊 Performance

| Metric | Value |
|--------|-------|
| Memory Overhead | < 1KB per animation |
| CPU Impact | Minimal (Core Animation) |
| Battery | Optimized for 60fps |
| Bundle Size | ~50KB |

---

## 📖 Documentation

| Guide | Description |
|-------|-------------|
| [Getting Started](Documentation/GettingStarted.md) | Installation and basics |
| [Animation Guide](Documentation/AnimationGuide.md) | Complete animation catalog |
| [Advanced Usage](Documentation/AdvancedUsage.md) | Chaining, customization |
| [Best Practices](Documentation/BestPractices.md) | Performance tips |

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

```bash
git clone https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git
cd SwiftUI-Animation-Masterclass
open Package.swift
```

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

## 👨‍💻 Author

**Muhittin Camdali**

[![GitHub](https://img.shields.io/badge/GitHub-muhittincamdali-181717?style=for-the-badge&logo=github)](https://github.com/muhittincamdali)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/muhittincamdali)

---

**⭐ Star this repo if you find it useful!**

</div>
