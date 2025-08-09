# Spring Animation API

<!-- TOC START -->
## Table of Contents
- [Spring Animation API](#spring-animation-api)
- [Overview](#overview)
- [Core Classes](#core-classes)
  - [SpringAnimation](#springanimation)
  - [SpringAnimationManager](#springanimationmanager)
- [Key Methods](#key-methods)
  - [Creating Spring Animations](#creating-spring-animations)
  - [Applying Spring Animations](#applying-spring-animations)
- [Spring Parameters](#spring-parameters)
  - [Damping](#damping)
  - [Response](#response)
  - [Mass](#mass)
- [Predefined Spring Types](#predefined-spring-types)
- [Configuration](#configuration)
  - [SpringAnimationConfiguration](#springanimationconfiguration)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)
- [Integration Examples](#integration-examples)
  - [SwiftUI Integration](#swiftui-integration)
  - [UIKit Integration](#uikit-integration)
- [API Reference](#api-reference)
<!-- TOC END -->


## Overview

The `SpringAnimation` class provides natural, physics-based animations that mimic real-world spring behavior. These animations are perfect for creating organic, responsive user interfaces.

## Core Classes

### SpringAnimation

The main class for creating spring animations.

```swift
public struct SpringAnimation {
    public let damping: Double
    public let response: Double
    public let mass: Double
    public let velocity: Double
    public let duration: TimeInterval
    
    public init(
        damping: Double = 0.7,
        response: Double = 0.5,
        mass: Double = 1.0,
        velocity: Double = 0.0,
        duration: TimeInterval = 0.5
    )
}
```

### SpringAnimationManager

Manager class for handling spring animations.

```swift
public class SpringAnimationManager {
    public static let shared = SpringAnimationManager()
    
    private var configuration: SpringAnimationConfiguration
    private var activeSprings: [UUID: SpringAnimation]
    
    public init()
    public func configure(_ configuration: SpringAnimationConfiguration)
    public func animate(_ view: UIView, with animation: SpringAnimation) -> Result<Void, AnimationError>
    public func stopAllSprings()
}
```

## Key Methods

### Creating Spring Animations

```swift
// Natural spring
let naturalSpring = SpringAnimation(
    damping: 0.7,
    response: 0.5,
    mass: 1.0
)

// Bouncy spring
let bouncySpring = SpringAnimation(
    damping: 0.3,
    response: 0.8,
    mass: 1.0
)

// Stiff spring
let stiffSpring = SpringAnimation(
    damping: 0.9,
    response: 0.2,
    mass: 1.0
)
```

### Applying Spring Animations

```swift
// Apply spring animation
let manager = SpringAnimationManager.shared
let spring = SpringAnimation(damping: 0.7, response: 0.5)

manager.animate(view, with: spring) { result in
    switch result {
    case .success:
        print("Spring animation completed")
    case .failure(let error):
        print("Spring animation failed: \(error)")
    }
}
```

## Spring Parameters

### Damping

Controls how quickly the spring settles. Lower values create more bouncy animations.

```swift
// Low damping (bouncy)
let bouncy = SpringAnimation(damping: 0.3, response: 0.5)

// High damping (smooth)
let smooth = SpringAnimation(damping: 0.9, response: 0.5)
```

### Response

Controls how quickly the spring responds to changes. Lower values create slower animations.

```swift
// Fast response
let fast = SpringAnimation(damping: 0.7, response: 0.2)

// Slow response
let slow = SpringAnimation(damping: 0.7, response: 0.8)
```

### Mass

Controls the "weight" of the spring. Higher values create more sluggish animations.

```swift
// Light mass
let light = SpringAnimation(damping: 0.7, response: 0.5, mass: 0.5)

// Heavy mass
let heavy = SpringAnimation(damping: 0.7, response: 0.5, mass: 2.0)
```

## Predefined Spring Types

```swift
public enum SpringType {
    case natural
    case bouncy
    case smooth
    case stiff
    case custom(damping: Double, response: Double, mass: Double)
}

// Usage
let naturalSpring = SpringAnimation(type: .natural)
let bouncySpring = SpringAnimation(type: .bouncy)
let smoothSpring = SpringAnimation(type: .smooth)
let stiffSpring = SpringAnimation(type: .stiff)
```

## Configuration

### SpringAnimationConfiguration

```swift
public struct SpringAnimationConfiguration {
    public var enableNaturalSprings: Bool
    public var enableCustomDamping: Bool
    public var enableVelocityControl: Bool
    public var enableMassControl: Bool
    public var maxConcurrentSprings: Int
    public var defaultDamping: Double
    public var defaultResponse: Double
    public var defaultMass: Double
    
    public init()
}
```

## Error Handling

```swift
public enum SpringAnimationError: Error {
    case invalidDamping(Double)
    case invalidResponse(Double)
    case invalidMass(Double)
    case invalidVelocity(Double)
    case springInProgress
    case configurationError(String)
}
```

## Best Practices

1. **Use natural springs** for most UI interactions
2. **Keep damping between 0.3-0.9** for good results
3. **Adjust response based on interaction speed**
4. **Test on different devices** for consistent behavior
5. **Consider accessibility** and reduced motion
6. **Use appropriate mass values** for different elements
7. **Avoid excessive bouncing** in professional apps

## Integration Examples

### SwiftUI Integration

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

struct SpringAnimatedView: View {
    @State private var isExpanded = false
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: isExpanded ? 200 : 100, height: 100)
            .animation(.spring(damping: 0.7, response: 0.5), value: isExpanded)
            .onTapGesture {
                isExpanded.toggle()
            }
    }
}
```

### UIKit Integration

```swift
import UIKit
import SwiftUIAnimationMasterclass

class SpringViewController: UIViewController {
    @IBOutlet weak var springView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpringAnimations()
    }
    
    private func setupSpringAnimations() {
        let manager = SpringAnimationManager.shared
        
        let spring = SpringAnimation(
            damping: 0.7,
            response: 0.5,
            mass: 1.0
        )
        
        // Animate on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        springView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        let spring = SpringAnimation(damping: 0.3, response: 0.8)
        
        springView.animate(.scale, from: 1.0, to: 1.2, with: spring) { _ in
            // Animate back
            let reverseSpring = SpringAnimation(damping: 0.7, response: 0.5)
            self.springView.animate(.scale, from: 1.2, to: 1.0, with: reverseSpring)
        }
    }
}
```

## API Reference

For related APIs, see:

- [Basic Animation API](BasicAnimationAPI.md)
- [Keyframe Animation API](KeyframeAnimationAPI.md)
- [Transition API](TransitionAPI.md)
- [Gesture Animation API](GestureAnimationAPI.md)
