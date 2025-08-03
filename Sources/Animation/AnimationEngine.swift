//
//  AnimationEngine.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali on 2023-06-15.
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI
import Metal
import CoreGraphics
import Combine

// MARK: - Animation Engine Core

/// High-performance animation engine for SwiftUI with 60fps+ performance
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public final class AnimationEngine: ObservableObject {
    
    // MARK: - Properties
    
    /// Shared instance for global animation management
    public static let shared = AnimationEngine()
    
    /// Current animation performance metrics
    @Published public private(set) var performanceMetrics = AnimationPerformanceMetrics()
    
    /// Active animations registry
    private var activeAnimations: [UUID: AnimationInstance] = [:]
    
    /// Animation cache for optimized performance
    private var animationCache: [String: CachedAnimation] = [:]
    
    /// Metal device for GPU acceleration
    private let metalDevice: MTLDevice?
    
    /// Display link for 60fps rendering
    private var displayLink: CADisplayLink?
    
    /// Animation queue for batch processing
    private let animationQueue = DispatchQueue(label: "com.animation.engine", qos: .userInteractive)
    
    /// Performance monitoring
    private var frameTimeHistory: [CFTimeInterval] = []
    private let maxFrameHistory = 60
    
    // MARK: - Initialization
    
    private init() {
        self.metalDevice = MTLCreateSystemDefaultDevice()
        setupDisplayLink()
        setupPerformanceMonitoring()
    }
    
    // MARK: - Public API
    
    /// Creates and starts a new animation instance
    /// - Parameters:
    ///   - configuration: Animation configuration
    ///   - completion: Completion handler called when animation finishes
    /// - Returns: Animation instance ID
    @discardableResult
    public func startAnimation(
        configuration: AnimationConfiguration,
        completion: @escaping (AnimationResult) -> Void = { _ in }
    ) -> UUID {
        
        let animationId = UUID()
        let instance = AnimationInstance(
            id: animationId,
            configuration: configuration,
            completion: completion
        )
        
        activeAnimations[animationId] = instance
        instance.start()
        
        return animationId
    }
    
    /// Stops an active animation
    /// - Parameter animationId: The animation ID to stop
    public func stopAnimation(_ animationId: UUID) {
        guard let instance = activeAnimations[animationId] else { return }
        instance.stop()
        activeAnimations.removeValue(forKey: animationId)
    }
    
    /// Pauses an active animation
    /// - Parameter animationId: The animation ID to pause
    public func pauseAnimation(_ animationId: UUID) {
        activeAnimations[animationId]?.pause()
    }
    
    /// Resumes a paused animation
    /// - Parameter animationId: The animation ID to resume
    public func resumeAnimation(_ animationId: UUID) {
        activeAnimations[animationId]?.resume()
    }
    
    /// Updates animation performance metrics
    public func updatePerformanceMetrics() {
        let currentTime = CACurrentMediaTime()
        
        // Calculate frame rate
        if frameTimeHistory.count >= 2 {
            let frameRate = 1.0 / (currentTime - frameTimeHistory.last!)
            performanceMetrics.currentFrameRate = frameRate
        }
        
        // Update average frame rate
        if frameTimeHistory.count >= maxFrameHistory {
            frameTimeHistory.removeFirst()
        }
        frameTimeHistory.append(currentTime)
        
        // Calculate average frame rate
        if frameTimeHistory.count >= 2 {
            let totalTime = frameTimeHistory.last! - frameTimeHistory.first!
            let averageFrameRate = Double(frameTimeHistory.count - 1) / totalTime
            performanceMetrics.averageFrameRate = averageFrameRate
        }
        
        // Update memory usage
        performanceMetrics.memoryUsage = getCurrentMemoryUsage()
        
        // Update active animation count
        performanceMetrics.activeAnimationCount = activeAnimations.count
    }
    
    /// Clears animation cache
    public func clearCache() {
        animationCache.removeAll()
    }
    
    /// Gets cached animation or creates new one
    /// - Parameter key: Cache key
    /// - Parameter createAnimation: Animation creation closure
    /// - Returns: Cached animation
    public func getCachedAnimation<T>(
        key: String,
        createAnimation: () -> T
    ) -> T {
        if let cached = animationCache[key]?.value as? T {
            return cached
        }
        
        let animation = createAnimation()
        animationCache[key] = CachedAnimation(value: animation, timestamp: CACurrentMediaTime())
        return animation
    }
    
    // MARK: - Private Methods
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 60)
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func displayLinkFired() {
        updatePerformanceMetrics()
        updateActiveAnimations()
    }
    
    private func updateActiveAnimations() {
        let currentTime = CACurrentMediaTime()
        
        for (id, instance) in activeAnimations {
            if instance.isFinished {
                activeAnimations.removeValue(forKey: id)
                instance.completion(.success)
            } else {
                instance.update(currentTime: currentTime)
            }
        }
    }
    
    private func setupPerformanceMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePerformanceMetrics()
        }
    }
    
    private func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }
}

// MARK: - Animation Instance

/// Represents a single animation instance
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private final class AnimationInstance {
    
    // MARK: - Properties
    
    let id: UUID
    let configuration: AnimationConfiguration
    let completion: (AnimationResult) -> Void
    
    private var startTime: CFTimeInterval = 0
    private var currentTime: CFTimeInterval = 0
    private var isPaused: Bool = false
    private var pauseTime: CFTimeInterval = 0
    
    var isFinished: Bool {
        currentTime >= configuration.duration
    }
    
    // MARK: - Initialization
    
    init(id: UUID, configuration: AnimationConfiguration, completion: @escaping (AnimationResult) -> Void) {
        self.id = id
        self.configuration = configuration
        self.completion = completion
    }
    
    // MARK: - Public Methods
    
    func start() {
        startTime = CACurrentMediaTime()
        currentTime = 0
        isPaused = false
    }
    
    func stop() {
        currentTime = configuration.duration
    }
    
    func pause() {
        if !isPaused {
            isPaused = true
            pauseTime = CACurrentMediaTime()
        }
    }
    
    func resume() {
        if isPaused {
            isPaused = false
            let pauseDuration = CACurrentMediaTime() - pauseTime
            startTime += pauseDuration
        }
    }
    
    func update(currentTime: CFTimeInterval) {
        guard !isPaused else { return }
        
        self.currentTime = currentTime - startTime
        
        let progress = min(self.currentTime / configuration.duration, 1.0)
        let easedProgress = configuration.easing.ease(progress)
        
        // Update animated properties based on configuration
        updateAnimatedProperties(progress: easedProgress)
    }
    
    // MARK: - Private Methods
    
    private func updateAnimatedProperties(progress: Double) {
        // Implementation for updating view properties
        // This would integrate with SwiftUI's animation system
    }
}

// MARK: - Animation Configuration

/// Configuration for animation instances
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnimationConfiguration {
    
    /// Animation duration in seconds
    public let duration: CFTimeInterval
    
    /// Easing function for the animation
    public let easing: AnimationEasing
    
    /// Animation curve for custom timing
    public let curve: AnimationCurve?
    
    /// Whether animation should repeat
    public let repeats: Bool
    
    /// Number of repeat cycles (nil for infinite)
    public let repeatCount: Int?
    
    /// Whether animation should auto-reverse
    public let autoReverses: Bool
    
    /// Delay before animation starts
    public let delay: CFTimeInterval
    
    /// Animation speed multiplier
    public let speed: Double
    
    /// Performance priority
    public let priority: AnimationPriority
    
    public init(
        duration: CFTimeInterval = 0.3,
        easing: AnimationEasing = .easeInOut,
        curve: AnimationCurve? = nil,
        repeats: Bool = false,
        repeatCount: Int? = nil,
        autoReverses: Bool = false,
        delay: CFTimeInterval = 0,
        speed: Double = 1.0,
        priority: AnimationPriority = .normal
    ) {
        self.duration = duration
        self.easing = easing
        self.curve = curve
        self.repeats = repeats
        self.repeatCount = repeatCount
        self.autoReverses = autoReverses
        self.delay = delay
        self.speed = speed
        self.priority = priority
    }
}

// MARK: - Animation Easing

/// Easing functions for smooth animations
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum AnimationEasing {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case easeInBack
    case easeOutBack
    case easeInElastic
    case easeOutElastic
    case custom((Double) -> Double)
    
    public func ease(_ progress: Double) -> Double {
        switch self {
        case .linear:
            return progress
        case .easeIn:
            return progress * progress
        case .easeOut:
            return 1 - (1 - progress) * (1 - progress)
        case .easeInOut:
            return progress < 0.5 ? 2 * progress * progress : 1 - 2 * (1 - progress) * (1 - progress)
        case .easeInBack:
            return progress * progress * (2.70158 * progress - 1.70158)
        case .easeOutBack:
            let t = progress - 1
            return t * t * (2.70158 * t + 1.70158) + 1
        case .easeInElastic:
            return sin(13 * .pi/2 * progress) * pow(2, 10 * (progress - 1))
        case .easeOutElastic:
            return sin(-13 * .pi/2 * (progress + 1)) * pow(2, -10 * progress) + 1
        case .custom(let function):
            return function(progress)
        }
    }
}

// MARK: - Animation Curve

/// Custom animation curve with control points
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnimationCurve {
    
    /// Control points for the curve
    public let controlPoints: [CGPoint]
    
    public init(controlPoints: [CGPoint]) {
        self.controlPoints = controlPoints
    }
    
    /// Evaluates the curve at a given progress
    /// - Parameter progress: Progress value between 0 and 1
    /// - Returns: Evaluated curve value
    public func evaluate(at progress: Double) -> Double {
        guard controlPoints.count >= 2 else { return progress }
        
        // Implement cubic bezier curve evaluation
        let t = progress
        let n = controlPoints.count - 1
        
        var result: Double = 0
        for i in 0...n {
            let coefficient = binomialCoefficient(n: n, k: i)
            let term = coefficient * pow(1 - t, Double(n - i)) * pow(t, Double(i))
            result += term * controlPoints[i].y
        }
        
        return result
    }
    
    private func binomialCoefficient(n: Int, k: Int) -> Double {
        guard k <= n else { return 0 }
        return factorial(n) / (factorial(k) * factorial(n - k))
    }
    
    private func factorial(_ n: Int) -> Double {
        guard n >= 0 else { return 1 }
        var result: Double = 1
        for i in 1...n {
            result *= Double(i)
        }
        return result
    }
}

// MARK: - Animation Priority

/// Priority levels for animation performance
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum AnimationPriority {
    case low
    case normal
    case high
    case critical
}

// MARK: - Animation Result

/// Result of animation completion
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum AnimationResult {
    case success
    case cancelled
    case failed(Error)
}

// MARK: - Animation Performance Metrics

/// Performance metrics for animation engine
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnimationPerformanceMetrics {
    /// Current frame rate
    public var currentFrameRate: Double = 0
    
    /// Average frame rate over time
    public var averageFrameRate: Double = 0
    
    /// Memory usage in bytes
    public var memoryUsage: UInt64 = 0
    
    /// Number of active animations
    public var activeAnimationCount: Int = 0
    
    /// Peak memory usage
    public var peakMemoryUsage: UInt64 = 0
    
    /// Minimum frame rate observed
    public var minimumFrameRate: Double = Double.infinity
    
    /// Maximum frame rate observed
    public var maximumFrameRate: Double = 0
    
    public init() {}
}

// MARK: - Cached Animation

/// Cached animation for performance optimization
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct CachedAnimation {
    let value: Any
    let timestamp: CFTimeInterval
    
    var age: CFTimeInterval {
        CACurrentMediaTime() - timestamp
    }
} 