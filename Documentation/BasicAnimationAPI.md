# Basic Animation API

<!-- TOC START -->
## Table of Contents
- [Basic Animation API](#basic-animation-api)
- [Overview](#overview)
- [Core Classes](#core-classes)
  - [BasicAnimation](#basicanimation)
  - [AnimationCurve](#animationcurve)
  - [BasicAnimationManager](#basicanimationmanager)
- [Key Methods](#key-methods)
  - [Creating Animations](#creating-animations)
  - [Applying Animations](#applying-animations)
  - [Property Animations](#property-animations)
- [Animation Properties](#animation-properties)
  - [Supported Properties](#supported-properties)
  - [Custom Properties](#custom-properties)
- [Configuration](#configuration)
  - [BasicAnimationConfiguration](#basicanimationconfiguration)
  - [Configuration Example](#configuration-example)
- [Error Handling](#error-handling)
- [Performance Optimization](#performance-optimization)
- [Best Practices](#best-practices)
- [Integration Examples](#integration-examples)
  - [SwiftUI Integration](#swiftui-integration)
  - [UIKit Integration](#uikit-integration)
- [API Reference](#api-reference)
<!-- TOC END -->


## Overview

The `BasicAnimation` class provides fundamental animation capabilities for SwiftUI views. It handles simple property animations with customizable duration, curves, and delays.

## Core Classes

### BasicAnimation

The main class for creating basic animations.

```swift
public struct BasicAnimation {
    public let duration: TimeInterval
    public let curve: AnimationCurve
    public let delay: TimeInterval
    public let repeatCount: Int
    public let autoreverse: Bool
    
    public init(
        duration: TimeInterval = 0.5,
        curve: AnimationCurve = .easeInOut,
        delay: TimeInterval = 0.0,
        repeatCount: Int = 1,
        autoreverse: Bool = false
    )
}
```

### AnimationCurve

Enumeration of available animation curves.

```swift
public enum AnimationCurve {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic
    case custom(BezierCurve)
}
```

### BasicAnimationManager

Manager class for handling basic animations.

```swift
public class BasicAnimationManager {
    public static let shared = BasicAnimationManager()
    
    private var configuration: BasicAnimationConfiguration
    private var activeAnimations: [UUID: BasicAnimation]
    
    public init()
    public func configure(_ configuration: BasicAnimationConfiguration)
    public func animate(_ view: UIView, with animation: BasicAnimation) -> Result<Void, AnimationError>
    public func stopAllAnimations()
}
```

## Key Methods

### Creating Animations

```swift
// Simple animation
let simpleAnimation = BasicAnimation(
    duration: 0.5,
    curve: .easeInOut
)

// Animation with delay
let delayedAnimation = BasicAnimation(
    duration: 1.0,
    curve: .easeIn,
    delay: 0.2
)

// Repeating animation
let repeatingAnimation = BasicAnimation(
    duration: 0.3,
    curve: .easeOut,
    repeatCount: 3,
    autoreverse: true
)
```

### Applying Animations

```swift
// Apply to view
let manager = BasicAnimationManager.shared
let animation = BasicAnimation(duration: 0.5, curve: .easeInOut)

manager.animate(view, with: animation) { result in
    switch result {
    case .success:
        print("Animation completed successfully")
    case .failure(let error):
        print("Animation failed: \(error)")
    }
}
```

### Property Animations

```swift
// Animate opacity
view.animate(.opacity, from: 0.0, to: 1.0, with: animation)

// Animate scale
view.animate(.scale, from: 0.5, to: 1.0, with: animation)

// Animate rotation
view.animate(.rotation, from: 0, to: 360, with: animation)

// Animate position
view.animate(.position, from: CGPoint.zero, to: CGPoint(x: 100, y: 100), with: animation)
```

## Animation Properties

### Supported Properties

```swift
public enum AnimationProperty {
    case opacity
    case scale
    case rotation
    case position
    case backgroundColor
    case cornerRadius
    case borderWidth
    case shadowOpacity
    case shadowRadius
    case shadowOffset
    case transform
}
```

### Custom Properties

```swift
// Custom property animation
let customAnimation = BasicAnimation(duration: 0.5, curve: .easeInOut)

view.animateCustomProperty(
    keyPath: "layer.cornerRadius",
    from: 0,
    to: 20,
    with: customAnimation
)
```

## Configuration

### BasicAnimationConfiguration

```swift
public struct BasicAnimationConfiguration {
    public var enableSmoothAnimations: Bool
    public var enableEasingCurves: Bool
    public var enableDurationControl: Bool
    public var enableDelaySupport: Bool
    public var maxConcurrentAnimations: Int
    public var defaultDuration: TimeInterval
    public var defaultCurve: AnimationCurve
    
    public init()
}
```

### Configuration Example

```swift
let manager = BasicAnimationManager.shared

let config = BasicAnimationConfiguration()
config.enableSmoothAnimations = true
config.enableEasingCurves = true
config.enableDurationControl = true
config.maxConcurrentAnimations = 10
config.defaultDuration = 0.5
config.defaultCurve = .easeInOut

manager.configure(config)
```

## Error Handling

```swift
public enum BasicAnimationError: Error {
    case invalidDuration(TimeInterval)
    case invalidCurve(AnimationCurve)
    case invalidDelay(TimeInterval)
    case invalidRepeatCount(Int)
    case viewNotFound
    case animationInProgress
    case configurationError(String)
}
```

## Performance Optimization

```swift
// Optimize for performance
let optimizedAnimation = BasicAnimation(
    duration: 0.3,
    curve: .easeOut,
    delay: 0.0
)

// Use hardware acceleration
view.layer.shouldRasterize = true
view.layer.rasterizationScale = UIScreen.main.scale
```

## Best Practices

1. **Keep animations short** (0.1-0.5 seconds) for better UX
2. **Use appropriate curves** for different effects
3. **Avoid excessive delays** that might confuse users
4. **Test on different devices** to ensure smooth performance
5. **Consider accessibility** and reduced motion preferences
6. **Clean up animations** when views are deallocated
7. **Use batch animations** for multiple properties

## Integration Examples

### SwiftUI Integration

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

struct AnimatedView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 100, height: 100)
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.5), value: isAnimating)
            .onTapGesture {
                isAnimating.toggle()
            }
    }
}
```

### UIKit Integration

```swift
import UIKit
import SwiftUIAnimationMasterclass

class AnimatedViewController: UIViewController {
    @IBOutlet weak var animatedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimations()
    }
    
    private func setupAnimations() {
        let manager = BasicAnimationManager.shared
        
        let animation = BasicAnimation(
            duration: 0.5,
            curve: .easeInOut
        )
        
        // Animate on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        animatedView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        let animation = BasicAnimation(duration: 0.3, curve: .easeOut)
        
        animatedView.animate(.scale, from: 1.0, to: 0.8, with: animation) { _ in
            // Animate back
            let reverseAnimation = BasicAnimation(duration: 0.3, curve: .easeIn)
            self.animatedView.animate(.scale, from: 0.8, to: 1.0, with: reverseAnimation)
        }
    }
}
```

## API Reference

For related APIs, see:

- [Spring Animation API](SpringAnimationAPI.md)
- [Keyframe Animation API](KeyframeAnimationAPI.md)
- [Transition API](TransitionAPI.md)
- [Gesture Animation API](GestureAnimationAPI.md)
