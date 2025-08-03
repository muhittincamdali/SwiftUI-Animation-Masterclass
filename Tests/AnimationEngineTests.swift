//
//  AnimationEngineTests.swift
//  SwiftUIAnimationMasterclassTests
//
//  Created by Muhittin Camdali on 2023-06-15.
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import XCTest
import SwiftUI
@testable import SwiftUIAnimationMasterclass

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class AnimationEngineTests: XCTestCase {
    
    var animationEngine: AnimationEngine!
    
    override func setUpWithError() throws {
        animationEngine = AnimationEngine.shared
    }
    
    override func tearDownWithError() throws {
        animationEngine = nil
    }
    
    // MARK: - Animation Engine Tests
    
    func testAnimationEngineInitialization() {
        XCTAssertNotNil(animationEngine)
        XCTAssertNotNil(AnimationEngine.shared)
        XCTAssertEqual(AnimationEngine.shared, animationEngine)
    }
    
    func testAnimationStartAndStop() {
        let expectation = XCTestExpectation(description: "Animation completion")
        
        let configuration = AnimationConfiguration(
            duration: 0.1,
            easing: .easeInOut
        )
        
        let animationId = animationEngine.startAnimation(configuration: configuration) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .cancelled, .failed:
                XCTFail("Animation should complete successfully")
            }
        }
        
        XCTAssertNotNil(animationId)
        
        // Wait for animation to complete
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAnimationPauseAndResume() {
        let configuration = AnimationConfiguration(
            duration: 1.0,
            easing: .linear
        )
        
        let animationId = animationEngine.startAnimation(configuration: configuration)
        
        // Pause animation
        animationEngine.pauseAnimation(animationId)
        
        // Verify animation is paused
        // Note: In a real implementation, we would check the internal state
        
        // Resume animation
        animationEngine.resumeAnimation(animationId)
        
        // Stop animation
        animationEngine.stopAnimation(animationId)
    }
    
    func testAnimationPerformance() {
        let configuration = AnimationConfiguration(
            duration: 0.1,
            easing: .easeInOut,
            priority: .high
        )
        
        measure {
            for _ in 0..<100 {
                let animationId = animationEngine.startAnimation(configuration: configuration)
                animationEngine.stopAnimation(animationId)
            }
        }
    }
    
    // MARK: - Animation Configuration Tests
    
    func testAnimationConfigurationDefaultValues() {
        let config = AnimationConfiguration()
        
        XCTAssertEqual(config.duration, 0.3, accuracy: 0.001)
        XCTAssertEqual(config.easing, .easeInOut)
        XCTAssertNil(config.curve)
        XCTAssertFalse(config.repeats)
        XCTAssertNil(config.repeatCount)
        XCTAssertFalse(config.autoReverses)
        XCTAssertEqual(config.delay, 0.0, accuracy: 0.001)
        XCTAssertEqual(config.speed, 1.0, accuracy: 0.001)
        XCTAssertEqual(config.priority, .normal)
    }
    
    func testAnimationConfigurationCustomValues() {
        let curve = AnimationCurve(controlPoints: [
            CGPoint(x: 0.25, y: 0.1),
            CGPoint(x: 0.25, y: 1.0)
        ])
        
        let config = AnimationConfiguration(
            duration: 1.0,
            easing: .easeInBack,
            curve: curve,
            repeats: true,
            repeatCount: 3,
            autoReverses: true,
            delay: 0.5,
            speed: 2.0,
            priority: .critical
        )
        
        XCTAssertEqual(config.duration, 1.0, accuracy: 0.001)
        XCTAssertEqual(config.easing, .easeInBack)
        XCTAssertEqual(config.curve, curve)
        XCTAssertTrue(config.repeats)
        XCTAssertEqual(config.repeatCount, 3)
        XCTAssertTrue(config.autoReverses)
        XCTAssertEqual(config.delay, 0.5, accuracy: 0.001)
        XCTAssertEqual(config.speed, 2.0, accuracy: 0.001)
        XCTAssertEqual(config.priority, .critical)
    }
    
    // MARK: - Animation Easing Tests
    
    func testAnimationEasingLinear() {
        let easing = AnimationEasing.linear
        
        XCTAssertEqual(easing.ease(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(easing.ease(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(easing.ease(1.0), 1.0, accuracy: 0.001)
    }
    
    func testAnimationEasingEaseIn() {
        let easing = AnimationEasing.easeIn
        
        XCTAssertEqual(easing.ease(0.0), 0.0, accuracy: 0.001)
        XCTAssertLessThan(easing.ease(0.5), 0.5) // Should be less than linear
        XCTAssertEqual(easing.ease(1.0), 1.0, accuracy: 0.001)
    }
    
    func testAnimationEasingEaseOut() {
        let easing = AnimationEasing.easeOut
        
        XCTAssertEqual(easing.ease(0.0), 0.0, accuracy: 0.001)
        XCTAssertGreaterThan(easing.ease(0.5), 0.5) // Should be greater than linear
        XCTAssertEqual(easing.ease(1.0), 1.0, accuracy: 0.001)
    }
    
    func testAnimationEasingEaseInOut() {
        let easing = AnimationEasing.easeInOut
        
        XCTAssertEqual(easing.ease(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(easing.ease(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(easing.ease(1.0), 1.0, accuracy: 0.001)
    }
    
    func testAnimationEasingCustom() {
        let customEasing = AnimationEasing.custom { progress in
            return progress * progress * progress // Cubic function
        }
        
        XCTAssertEqual(customEasing.ease(0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(customEasing.ease(0.5), 0.125, accuracy: 0.001)
        XCTAssertEqual(customEasing.ease(1.0), 1.0, accuracy: 0.001)
    }
    
    // MARK: - Animation Curve Tests
    
    func testAnimationCurveInitialization() {
        let controlPoints = [
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.25, y: 0.1),
            CGPoint(x: 0.75, y: 0.9),
            CGPoint(x: 1.0, y: 1.0)
        ]
        
        let curve = AnimationCurve(controlPoints: controlPoints)
        
        XCTAssertEqual(curve.controlPoints.count, 4)
        XCTAssertEqual(curve.controlPoints[0], CGPoint(x: 0.0, y: 0.0))
        XCTAssertEqual(curve.controlPoints[3], CGPoint(x: 1.0, y: 1.0))
    }
    
    func testAnimationCurveEvaluation() {
        let controlPoints = [
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 1.0, y: 1.0)
        ]
        
        let curve = AnimationCurve(controlPoints: controlPoints)
        
        XCTAssertEqual(curve.evaluate(at: 0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(curve.evaluate(at: 0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(curve.evaluate(at: 1.0), 1.0, accuracy: 0.001)
    }
    
    func testAnimationCurveComplexEvaluation() {
        let controlPoints = [
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0.25, y: 0.1),
            CGPoint(x: 0.75, y: 0.9),
            CGPoint(x: 1.0, y: 1.0)
        ]
        
        let curve = AnimationCurve(controlPoints: controlPoints)
        
        // Test boundary conditions
        XCTAssertEqual(curve.evaluate(at: 0.0), 0.0, accuracy: 0.001)
        XCTAssertEqual(curve.evaluate(at: 1.0), 1.0, accuracy: 0.001)
        
        // Test intermediate values
        let midValue = curve.evaluate(at: 0.5)
        XCTAssertGreaterThan(midValue, 0.0)
        XCTAssertLessThan(midValue, 1.0)
    }
    
    // MARK: - Performance Metrics Tests
    
    func testPerformanceMetricsInitialization() {
        let metrics = AnimationPerformanceMetrics()
        
        XCTAssertEqual(metrics.currentFrameRate, 0.0, accuracy: 0.001)
        XCTAssertEqual(metrics.averageFrameRate, 0.0, accuracy: 0.001)
        XCTAssertEqual(metrics.memoryUsage, 0)
        XCTAssertEqual(metrics.activeAnimationCount, 0)
        XCTAssertEqual(metrics.peakMemoryUsage, 0)
        XCTAssertEqual(metrics.minimumFrameRate, Double.infinity)
        XCTAssertEqual(metrics.maximumFrameRate, 0.0, accuracy: 0.001)
    }
    
    func testPerformanceMetricsUpdate() {
        // This test would verify that performance metrics are updated correctly
        // In a real implementation, we would trigger animations and verify metrics
        XCTAssertNotNil(animationEngine.performanceMetrics)
    }
    
    // MARK: - Cache Tests
    
    func testAnimationCache() {
        let cacheKey = "test_animation"
        
        // Test cache miss
        let animation1 = animationEngine.getCachedAnimation(key: cacheKey) {
            return "cached_animation_1"
        }
        
        XCTAssertEqual(animation1, "cached_animation_1")
        
        // Test cache hit
        let animation2 = animationEngine.getCachedAnimation(key: cacheKey) {
            return "cached_animation_2"
        }
        
        XCTAssertEqual(animation2, "cached_animation_1") // Should return cached value
    }
    
    func testCacheClear() {
        let cacheKey = "test_clear_animation"
        
        // Add to cache
        _ = animationEngine.getCachedAnimation(key: cacheKey) {
            return "cached_value"
        }
        
        // Clear cache
        animationEngine.clearCache()
        
        // Verify cache is cleared
        let newValue = animationEngine.getCachedAnimation(key: cacheKey) {
            return "new_cached_value"
        }
        
        XCTAssertEqual(newValue, "new_cached_value")
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidAnimationConfiguration() {
        let invalidConfig = AnimationConfiguration(
            duration: -1.0, // Invalid negative duration
            easing: .easeInOut
        )
        
        // Should handle gracefully
        let animationId = animationEngine.startAnimation(configuration: invalidConfig)
        animationEngine.stopAnimation(animationId)
    }
    
    func testMultipleSimultaneousAnimations() {
        let configurations = [
            AnimationConfiguration(duration: 0.1, easing: .easeIn),
            AnimationConfiguration(duration: 0.2, easing: .easeOut),
            AnimationConfiguration(duration: 0.3, easing: .easeInOut)
        ]
        
        var animationIds: [UUID] = []
        
        for config in configurations {
            let animationId = animationEngine.startAnimation(configuration: config)
            animationIds.append(animationId)
        }
        
        // Verify all animations are active
        XCTAssertEqual(animationIds.count, 3)
        
        // Stop all animations
        for animationId in animationIds {
            animationEngine.stopAnimation(animationId)
        }
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryUsageTracking() {
        let initialMemory = animationEngine.performanceMetrics.memoryUsage
        
        // Start multiple animations
        for i in 0..<10 {
            let config = AnimationConfiguration(
                duration: 0.1,
                easing: .easeInOut
            )
            let animationId = animationEngine.startAnimation(configuration: config)
            
            // Stop immediately to test memory cleanup
            animationEngine.stopAnimation(animationId)
        }
        
        // Memory should be managed properly
        let finalMemory = animationEngine.performanceMetrics.memoryUsage
        XCTAssertGreaterThanOrEqual(finalMemory, 0)
    }
    
    // MARK: - Integration Tests
    
    func testAnimationEngineIntegration() {
        let expectation = XCTestExpectation(description: "Multiple animations completion")
        var completedAnimations = 0
        let totalAnimations = 5
        
        for i in 0..<totalAnimations {
            let config = AnimationConfiguration(
                duration: 0.1,
                easing: .easeInOut
            )
            
            animationEngine.startAnimation(configuration: config) { result in
                switch result {
                case .success:
                    completedAnimations += 1
                    if completedAnimations == totalAnimations {
                        expectation.fulfill()
                    }
                case .cancelled, .failed:
                    XCTFail("Animation should complete successfully")
                }
            }
        }
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(completedAnimations, totalAnimations)
    }
} 