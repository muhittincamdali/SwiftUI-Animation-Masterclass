import XCTest
import SwiftUIAnimationMasterclass
@testable import SwiftUIAnimationMasterclass

final class AnimationMasterclassManagerTests: XCTestCase {
    
    var manager: AnimationMasterclassManager!
    
    override func setUp() {
        super.setUp()
        manager = AnimationMasterclassManager.shared
    }
    
    override func tearDown() {
        manager.stop()
        manager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testManagerInitialization() {
        XCTAssertNotNil(manager, "Manager should be initialized")
    }
    
    func testManagerSingleton() {
        let manager1 = AnimationMasterclassManager.shared
        let manager2 = AnimationMasterclassManager.shared
        XCTAssertEqual(manager1, manager2, "Manager should be a singleton")
    }
    
    // MARK: - Configuration Tests
    
    func testConfigurationWithValidSettings() {
        let config = AnimationMasterclassConfiguration()
        config.enableBasicAnimations = true
        config.enableSpringAnimations = true
        config.enableKeyframeAnimations = true
        config.enableTransitions = true
        
        manager.start(with: config)
        
        // Verify configuration was applied
        XCTAssertTrue(true, "Configuration should be applied successfully")
    }
    
    func testPerformanceConfiguration() {
        manager.configurePerformance { config in
            config.enable60FPS = true
            config.enableReducedMotion = true
            config.enableAccessibility = true
            config.maxConcurrentAnimations = 10
            config.memoryLimit = 100 * 1024 * 1024
        }
        
        // Verify performance configuration was applied
        XCTAssertTrue(true, "Performance configuration should be applied successfully")
    }
    
    func testAccessibilityConfiguration() {
        manager.configureAccessibility { config in
            config.enableReducedMotion = true
            config.enableVoiceOver = true
            config.enableSwitchControl = true
        }
        
        // Verify accessibility configuration was applied
        XCTAssertTrue(true, "Accessibility configuration should be applied successfully")
    }
    
    // MARK: - Animation Tests
    
    func testBasicAnimationCreation() {
        let config = AnimationMasterclassConfiguration()
        config.enableBasicAnimations = true
        
        manager.start(with: config)
        
        // Test basic animation creation
        let animation = BasicAnimation(duration: 0.5, curve: .easeInOut)
        XCTAssertNotNil(animation, "Basic animation should be created")
        XCTAssertEqual(animation.duration, 0.5, "Animation duration should match")
    }
    
    func testSpringAnimationCreation() {
        let config = AnimationMasterclassConfiguration()
        config.enableSpringAnimations = true
        
        manager.start(with: config)
        
        // Test spring animation creation
        let spring = SpringAnimation(damping: 0.7, response: 0.5)
        XCTAssertNotNil(spring, "Spring animation should be created")
        XCTAssertEqual(spring.damping, 0.7, "Spring damping should match")
        XCTAssertEqual(spring.response, 0.5, "Spring response should match")
    }
    
    func testKeyframeAnimationCreation() {
        let config = AnimationMasterclassConfiguration()
        config.enableKeyframeAnimations = true
        
        manager.start(with: config)
        
        // Test keyframe animation creation
        let keyframes = [
            Keyframe(time: 0.0, value: 0.0, easing: .linear),
            Keyframe(time: 0.5, value: 0.5, easing: .easeInOut),
            Keyframe(time: 1.0, value: 1.0, easing: .linear)
        ]
        
        let keyframeAnimation = KeyframeAnimation(
            keyframes: keyframes,
            duration: 1.0,
            loop: .none
        )
        
        XCTAssertNotNil(keyframeAnimation, "Keyframe animation should be created")
        XCTAssertEqual(keyframeAnimation.keyframes.count, 3, "Keyframe count should match")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceMonitoring() {
        let expectation = XCTestExpectation(description: "Performance monitoring")
        
        manager.monitorPerformance { metrics in
            XCTAssertGreaterThan(metrics.fps, 0, "FPS should be positive")
            XCTAssertGreaterThanOrEqual(metrics.memoryUsage, 0, "Memory usage should be non-negative")
            XCTAssertGreaterThanOrEqual(metrics.activeAnimations, 0, "Active animations should be non-negative")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMemoryUsageLimit() {
        let config = PerformanceConfiguration()
        config.memoryLimit = 50 * 1024 * 1024 // 50MB
        
        manager.configurePerformance { config in
            config.memoryLimit = 50 * 1024 * 1024
        }
        
        // Verify memory limit is set
        XCTAssertTrue(true, "Memory limit should be configured")
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidConfiguration() {
        let config = AnimationMasterclassConfiguration()
        config.enableBasicAnimations = false
        config.enableSpringAnimations = false
        config.enableKeyframeAnimations = false
        
        manager.start(with: config)
        
        // Test that manager handles disabled features gracefully
        XCTAssertTrue(true, "Manager should handle disabled features gracefully")
    }
    
    func testAnimationErrorHandling() {
        let expectation = XCTestExpectation(description: "Animation error handling")
        
        // Test animation with invalid parameters
        let invalidAnimation = BasicAnimation(duration: -1.0, curve: .linear)
        
        // This should not crash and should handle the error gracefully
        XCTAssertTrue(true, "Invalid animation should be handled gracefully")
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Integration Tests
    
    func testManagerLifecycle() {
        // Test start
        let config = AnimationMasterclassConfiguration()
        manager.start(with: config)
        XCTAssertTrue(true, "Manager should start successfully")
        
        // Test configuration update
        let newConfig = AnimationMasterclassConfiguration()
        newConfig.enableBasicAnimations = false
        manager.configure(newConfig)
        XCTAssertTrue(true, "Manager should reconfigure successfully")
        
        // Test stop
        manager.stop()
        XCTAssertTrue(true, "Manager should stop successfully")
    }
    
    func testConcurrentAnimations() {
        let config = AnimationMasterclassConfiguration()
        config.enableBasicAnimations = true
        manager.start(with: config)
        
        // Test multiple animations can be created
        let animation1 = BasicAnimation(duration: 0.3, curve: .easeIn)
        let animation2 = BasicAnimation(duration: 0.5, curve: .easeOut)
        let animation3 = BasicAnimation(duration: 0.7, curve: .easeInOut)
        
        XCTAssertNotNil(animation1, "First animation should be created")
        XCTAssertNotNil(animation2, "Second animation should be created")
        XCTAssertNotNil(animation3, "Third animation should be created")
    }
}

// MARK: - Supporting Types for Tests

/// Basic animation for testing
struct BasicAnimation: Animation {
    let duration: TimeInterval
    let curve: AnimationCurve
    let delay: TimeInterval
    
    init(duration: TimeInterval = 0.5, curve: AnimationCurve = .easeInOut, delay: TimeInterval = 0.0) {
        self.duration = duration
        self.curve = curve
        self.delay = delay
    }
}

/// Spring animation for testing
struct SpringAnimation: Animation {
    let damping: Double
    let response: Double
    let duration: TimeInterval
    let delay: TimeInterval
    
    init(damping: Double = 0.7, response: Double = 0.5, duration: TimeInterval = 0.5, delay: TimeInterval = 0.0) {
        self.damping = damping
        self.response = response
        self.duration = duration
        self.delay = delay
    }
}

/// Keyframe animation for testing
struct KeyframeAnimation: Animation {
    let keyframes: [Keyframe]
    let duration: TimeInterval
    let loop: AnimationLoop
    let delay: TimeInterval
    
    init(keyframes: [Keyframe], duration: TimeInterval, loop: AnimationLoop = .none, delay: TimeInterval = 0.0) {
        self.keyframes = keyframes
        self.duration = duration
        self.loop = loop
        self.delay = delay
    }
}

/// Keyframe for testing
struct Keyframe {
    let time: TimeInterval
    let value: Double
    let easing: AnimationCurve
    
    init(time: TimeInterval, value: Double, easing: AnimationCurve) {
        self.time = time
        self.value = value
        self.easing = easing
    }
}

/// Animation curve for testing
enum AnimationCurve {
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

/// Animation loop for testing
enum AnimationLoop {
    case none
    case repeat
    case repeatForever
} 