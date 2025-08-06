import Foundation
import SwiftUI

/// Animation Utilities for SwiftUI Animation Masterclass
public struct AnimationUtilities {
    public static let version = "1.0.0"
    
    public init() {}
}

/// Animation Timing Utilities
public struct AnimationTiming {
    public static let fast = 0.2
    public static let normal = 0.5
    public static let slow = 1.0
    
    public static func custom(duration: Double) -> Double {
        return max(0.1, min(3.0, duration))
    }
}

/// Animation Easing Utilities
public struct AnimationEasing {
    public static let linear = Animation.linear
    public static let easeIn = Animation.easeIn
    public static let easeOut = Animation.easeOut
    public static let easeInOut = Animation.easeInOut
    
    public static func spring(response: Double = 0.5, dampingFraction: Double = 0.6) -> Animation {
        return .spring(response: response, dampingFraction: dampingFraction)
    }
}

/// Animation Performance Utilities
public struct AnimationPerformance {
    public static func optimizeForDevice() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return UIDevice.current.isMultitaskingSupported
        #endif
    }
    
    public static func shouldReduceMotion() -> Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
}

/// Animation Debug Utilities
public struct AnimationDebug {
    public static var isEnabled = false
    
    public static func log(_ message: String) {
        if isEnabled {
            print("[AnimationDebug] \(message)")
        }
    }
    
    public static func measurePerformance<T>(_ operation: () -> T) -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = operation()
        let end = CFAbsoluteTimeGetCurrent()
        
        if isEnabled {
            print("[AnimationDebug] Performance: \(end - start)s")
        }
        
        return result
    }
}
