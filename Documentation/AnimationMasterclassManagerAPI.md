# Animation Masterclass Manager API

## Overview

The `AnimationMasterclassManager` is the core component of the SwiftUI Animation Masterclass framework. It provides centralized control over all animation operations, configuration, and performance optimization.

## Core Classes

### AnimationMasterclassManager

The main manager class that orchestrates all animation operations.

```swift
public class AnimationMasterclassManager {
    public static let shared = AnimationMasterclassManager()
    
    private var configuration: AnimationMasterclassConfiguration
    private var performanceManager: PerformanceManager
    private var animationQueue: AnimationQueue
    
    public init()
    public func start(with configuration: AnimationMasterclassConfiguration)
    public func configure(_ configuration: AnimationMasterclassConfiguration)
    public func configurePerformance(_ handler: (PerformanceConfiguration) -> Void)
    public func stop()
}
```

### AnimationMasterclassConfiguration

Configuration class for the animation masterclass manager.

```swift
public struct AnimationMasterclassConfiguration {
    public var enableBasicAnimations: Bool
    public var enableSpringAnimations: Bool
    public var enableKeyframeAnimations: Bool
    public var enableTransitions: Bool
    public var enableGestureAnimations: Bool
    public var enablePerformanceOptimization: Bool
    public var enableAccessibility: Bool
    public var enableReducedMotion: Bool
    
    public init()
}
```

## Key Methods

### Initialization

```swift
// Initialize the manager
let manager = AnimationMasterclassManager.shared

// Configure the manager
let config = AnimationMasterclassConfiguration()
config.enableBasicAnimations = true
config.enableSpringAnimations = true
config.enableKeyframeAnimations = true
config.enableTransitions = true

// Start the manager
manager.start(with: config)
```

### Performance Configuration

```swift
// Configure performance settings
manager.configurePerformance { config in
    config.enable60FPS = true
    config.enableReducedMotion = true
    config.enableAccessibility = true
    config.maxConcurrentAnimations = 10
    config.memoryLimit = 100 * 1024 * 1024 // 100MB
}
```

### Animation Management

```swift
// Create and manage animations
let animation = BasicAnimation(duration: 0.5, curve: .easeInOut)
manager.addAnimation(animation, to: view)

// Batch animations
manager.addBatchAnimations([
    BasicAnimation(duration: 0.3, curve: .easeIn),
    SpringAnimation(damping: 0.7, response: 0.5)
], to: view)
```

## Error Handling

The manager provides comprehensive error handling:

```swift
public enum AnimationMasterclassError: Error {
    case configurationError(String)
    case performanceError(String)
    case animationError(String)
    case memoryError(String)
    case accessibilityError(String)
}
```

## Performance Monitoring

```swift
// Monitor performance
manager.monitorPerformance { metrics in
    print("FPS: \(metrics.fps)")
    print("Memory Usage: \(metrics.memoryUsage)")
    print("Active Animations: \(metrics.activeAnimations)")
}
```

## Accessibility Support

```swift
// Configure accessibility
manager.configureAccessibility { config in
    config.enableReducedMotion = true
    config.enableVoiceOver = true
    config.enableSwitchControl = true
}
```

## Best Practices

1. **Always initialize the manager** before using any animations
2. **Configure performance settings** based on your app's requirements
3. **Monitor memory usage** to prevent performance issues
4. **Handle errors appropriately** to provide good user experience
5. **Test with accessibility features** enabled
6. **Use batch animations** for better performance
7. **Clean up resources** when animations are complete

## Integration Examples

### Basic Integration

```swift
import SwiftUIAnimationMasterclass

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize animation manager
        let manager = AnimationMasterclassManager.shared
        
        // Configure manager
        let config = AnimationMasterclassConfiguration()
        config.enableBasicAnimations = true
        config.enableSpringAnimations = true
        config.enableTransitions = true
        
        // Start manager
        manager.start(with: config)
        
        return true
    }
}
```

### Advanced Integration

```swift
import SwiftUIAnimationMasterclass

class AnimationCoordinator {
    private let manager = AnimationMasterclassManager.shared
    
    func setupAnimations() {
        // Configure performance
        manager.configurePerformance { config in
            config.enable60FPS = true
            config.enableReducedMotion = true
            config.maxConcurrentAnimations = 15
        }
        
        // Configure accessibility
        manager.configureAccessibility { config in
            config.enableReducedMotion = true
            config.enableVoiceOver = true
        }
        
        // Monitor performance
        manager.monitorPerformance { metrics in
            if metrics.fps < 50 {
                print("Warning: Low FPS detected")
            }
        }
    }
}
```

## API Reference

For complete API reference, see the individual documentation files:

- [Basic Animation API](BasicAnimationAPI.md)
- [Spring Animation API](SpringAnimationAPI.md)
- [Keyframe Animation API](KeyframeAnimationAPI.md)
- [Transition API](TransitionAPI.md)
- [Gesture Animation API](GestureAnimationAPI.md)
- [Configuration API](ConfigurationAPI.md)
- [Performance API](PerformanceAPI.md)
