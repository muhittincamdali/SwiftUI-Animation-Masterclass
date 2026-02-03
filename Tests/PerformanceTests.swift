// PerformanceTests.swift
// SwiftUI-Animation-Masterclass
//
// Created by Muhittin Çamdalı
// Performance testing suite for animation framework

import XCTest
@testable import SwiftUI_Animation_Masterclass

/// Performance test suite for animation framework components
///
/// These tests measure execution time and memory usage of critical
/// animation operations to ensure optimal performance.
final class PerformanceTests: XCTestCase {
    
    // MARK: - Properties
    
    private var animationEngine: AnimationEngine!
    private var measurementOptions: XCTMeasureOptions!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        animationEngine = AnimationEngine()
        measurementOptions = XCTMeasureOptions()
        measurementOptions.iterationCount = 10
    }
    
    override func tearDown() {
        animationEngine = nil
        measurementOptions = nil
        super.tearDown()
    }
    
    // MARK: - Timing Curve Performance Tests
    
    /// Tests performance of linear interpolation calculations
    func testLinearInterpolationPerformance() {
        measure(options: measurementOptions) {
            for progress in stride(from: 0.0, through: 1.0, by: 0.001) {
                _ = linearInterpolation(progress)
            }
        }
    }
    
    /// Tests performance of ease-in curve calculations
    func testEaseInCurvePerformance() {
        measure(options: measurementOptions) {
            for progress in stride(from: 0.0, through: 1.0, by: 0.001) {
                _ = easeInCurve(progress, power: 3.0)
            }
        }
    }
    
    /// Tests performance of ease-out curve calculations
    func testEaseOutCurvePerformance() {
        measure(options: measurementOptions) {
            for progress in stride(from: 0.0, through: 1.0, by: 0.001) {
                _ = easeOutCurve(progress, power: 3.0)
            }
        }
    }
    
    /// Tests performance of ease-in-out curve calculations
    func testEaseInOutCurvePerformance() {
        measure(options: measurementOptions) {
            for progress in stride(from: 0.0, through: 1.0, by: 0.001) {
                _ = easeInOutCurve(progress, power: 3.0)
            }
        }
    }
    
    /// Tests cubic bezier curve performance with various control points
    func testCubicBezierPerformance() {
        let controlPoints: [(Double, Double, Double, Double)] = [
            (0.25, 0.1, 0.25, 1.0),    // Ease
            (0.42, 0.0, 1.0, 1.0),     // Ease-in
            (0.0, 0.0, 0.58, 1.0),     // Ease-out
            (0.42, 0.0, 0.58, 1.0),    // Ease-in-out
            (0.68, -0.55, 0.27, 1.55)  // Back
        ]
        
        measure(options: measurementOptions) {
            for (x1, y1, x2, y2) in controlPoints {
                for progress in stride(from: 0.0, through: 1.0, by: 0.01) {
                    _ = cubicBezier(progress, x1: x1, y1: y1, x2: x2, y2: y2)
                }
            }
        }
    }
    
    // MARK: - Spring Animation Performance Tests
    
    /// Tests performance of spring physics calculations
    func testSpringPhysicsPerformance() {
        let springConfig = SpringConfiguration(
            mass: 1.0,
            stiffness: 100.0,
            damping: 10.0
        )
        
        measure(options: measurementOptions) {
            for time in stride(from: 0.0, through: 2.0, by: 0.001) {
                _ = calculateSpringPosition(
                    time: time,
                    config: springConfig,
                    initialVelocity: 0.0
                )
            }
        }
    }
    
    /// Tests performance with varying spring parameters
    func testSpringParameterVariationsPerformance() {
        let configurations = [
            SpringConfiguration(mass: 0.5, stiffness: 50.0, damping: 5.0),
            SpringConfiguration(mass: 1.0, stiffness: 100.0, damping: 10.0),
            SpringConfiguration(mass: 2.0, stiffness: 200.0, damping: 20.0),
            SpringConfiguration(mass: 1.0, stiffness: 300.0, damping: 15.0),
            SpringConfiguration(mass: 0.8, stiffness: 150.0, damping: 8.0)
        ]
        
        measure(options: measurementOptions) {
            for config in configurations {
                for time in stride(from: 0.0, through: 1.0, by: 0.01) {
                    _ = calculateSpringPosition(
                        time: time,
                        config: config,
                        initialVelocity: 0.0
                    )
                }
            }
        }
    }
    
    // MARK: - Keyframe Animation Performance Tests
    
    /// Tests keyframe interpolation performance with linear keyframes
    func testKeyframeInterpolationPerformance() {
        let keyframes = createTestKeyframes(count: 20)
        
        measure(options: measurementOptions) {
            for progress in stride(from: 0.0, through: 1.0, by: 0.001) {
                _ = interpolateKeyframes(keyframes, at: progress)
            }
        }
    }
    
    /// Tests keyframe search performance with large keyframe sets
    func testLargeKeyframeSetPerformance() {
        let keyframes = createTestKeyframes(count: 100)
        
        measure(options: measurementOptions) {
            for progress in stride(from: 0.0, through: 1.0, by: 0.001) {
                _ = findKeyframePair(keyframes, at: progress)
            }
        }
    }
    
    // MARK: - Matrix Transformation Performance Tests
    
    /// Tests 3D transformation matrix multiplication performance
    func testMatrixMultiplicationPerformance() {
        let matrices = createTestMatrices(count: 10)
        
        measure(options: measurementOptions) {
            var result = matrices[0]
            for i in 1..<matrices.count {
                result = multiplyMatrices(result, matrices[i])
            }
        }
    }
    
    /// Tests perspective transformation calculation performance
    func testPerspectiveTransformPerformance() {
        measure(options: measurementOptions) {
            for angle in stride(from: 0.0, through: 360.0, by: 1.0) {
                let radians = angle * .pi / 180.0
                _ = createPerspectiveMatrix(
                    rotationX: radians,
                    rotationY: radians * 0.5,
                    rotationZ: radians * 0.25,
                    perspective: 1000.0
                )
            }
        }
    }
    
    // MARK: - Parallax Effect Performance Tests
    
    /// Tests parallax offset calculation performance
    func testParallaxOffsetPerformance() {
        let layers = createTestLayers(count: 10)
        
        measure(options: measurementOptions) {
            for scrollOffset in stride(from: 0.0, through: 1000.0, by: 1.0) {
                for layer in layers {
                    _ = calculateParallaxOffset(
                        scrollOffset: scrollOffset,
                        layer: layer
                    )
                }
            }
        }
    }
    
    /// Tests depth-based parallax performance with multiple layers
    func testMultiLayerParallaxPerformance() {
        let layerCount = 20
        let depthFactors = (0..<layerCount).map { Double($0) / Double(layerCount) }
        
        measure(options: measurementOptions) {
            for scrollOffset in stride(from: 0.0, through: 500.0, by: 1.0) {
                for depth in depthFactors {
                    _ = calculateDepthParallax(
                        scrollOffset: scrollOffset,
                        depthFactor: depth
                    )
                }
            }
        }
    }
    
    // MARK: - Animation Sequencer Performance Tests
    
    /// Tests animation sequence building performance
    func testSequenceBuilderPerformance() {
        measure(options: measurementOptions) {
            for _ in 0..<100 {
                _ = buildAnimationSequence(stepCount: 50)
            }
        }
    }
    
    /// Tests concurrent animation calculation performance
    func testConcurrentAnimationPerformance() {
        let animations = createTestAnimations(count: 20)
        
        measure(options: measurementOptions) {
            for progress in stride(from: 0.0, through: 1.0, by: 0.01) {
                for animation in animations {
                    _ = calculateAnimationValue(animation, at: progress)
                }
            }
        }
    }
    
    // MARK: - Memory Performance Tests
    
    /// Tests memory allocation during animation creation
    func testAnimationCreationMemory() {
        measure(metrics: [XCTMemoryMetric()]) {
            var animations: [TestAnimation] = []
            for i in 0..<1000 {
                animations.append(TestAnimation(id: i))
            }
            _ = animations.count
        }
    }
    
    /// Tests memory usage with large keyframe sets
    func testKeyframeMemoryUsage() {
        measure(metrics: [XCTMemoryMetric()]) {
            var keyframeSets: [[TestKeyframe]] = []
            for _ in 0..<100 {
                keyframeSets.append(createTestKeyframes(count: 100))
            }
            _ = keyframeSets.count
        }
    }
    
    // MARK: - Helper Functions
    
    private func linearInterpolation(_ t: Double) -> Double {
        return t
    }
    
    private func easeInCurve(_ t: Double, power: Double) -> Double {
        return pow(t, power)
    }
    
    private func easeOutCurve(_ t: Double, power: Double) -> Double {
        return 1.0 - pow(1.0 - t, power)
    }
    
    private func easeInOutCurve(_ t: Double, power: Double) -> Double {
        if t < 0.5 {
            return pow(2.0 * t, power) / 2.0
        } else {
            return 1.0 - pow(2.0 * (1.0 - t), power) / 2.0
        }
    }
    
    private func cubicBezier(
        _ t: Double,
        x1: Double,
        y1: Double,
        x2: Double,
        y2: Double
    ) -> Double {
        let cx = 3.0 * x1
        let bx = 3.0 * (x2 - x1) - cx
        let ax = 1.0 - cx - bx
        
        let cy = 3.0 * y1
        let by = 3.0 * (y2 - y1) - cy
        let ay = 1.0 - cy - by
        
        return ((ay * t + by) * t + cy) * t
    }
    
    private func calculateSpringPosition(
        time: Double,
        config: SpringConfiguration,
        initialVelocity: Double
    ) -> Double {
        let omega0 = sqrt(config.stiffness / config.mass)
        let zeta = config.damping / (2.0 * sqrt(config.stiffness * config.mass))
        
        if zeta < 1.0 {
            let omegaD = omega0 * sqrt(1.0 - zeta * zeta)
            let envelope = exp(-zeta * omega0 * time)
            return 1.0 - envelope * (
                cos(omegaD * time) +
                (zeta * omega0 / omegaD) * sin(omegaD * time)
            )
        } else if zeta == 1.0 {
            return 1.0 - (1.0 + omega0 * time) * exp(-omega0 * time)
        } else {
            let s1 = -omega0 * (zeta - sqrt(zeta * zeta - 1.0))
            let s2 = -omega0 * (zeta + sqrt(zeta * zeta - 1.0))
            return 1.0 - (s2 * exp(s1 * time) - s1 * exp(s2 * time)) / (s2 - s1)
        }
    }
    
    private func createTestKeyframes(count: Int) -> [TestKeyframe] {
        return (0..<count).map { i in
            TestKeyframe(
                time: Double(i) / Double(count - 1),
                value: Double.random(in: 0...100)
            )
        }
    }
    
    private func interpolateKeyframes(
        _ keyframes: [TestKeyframe],
        at progress: Double
    ) -> Double {
        guard !keyframes.isEmpty else { return 0.0 }
        guard keyframes.count > 1 else { return keyframes[0].value }
        
        let (start, end) = findKeyframePair(keyframes, at: progress)
        
        guard let startKeyframe = start, let endKeyframe = end else {
            return keyframes.last?.value ?? 0.0
        }
        
        let localProgress = (progress - startKeyframe.time) /
            (endKeyframe.time - startKeyframe.time)
        
        return startKeyframe.value +
            (endKeyframe.value - startKeyframe.value) * localProgress
    }
    
    private func findKeyframePair(
        _ keyframes: [TestKeyframe],
        at progress: Double
    ) -> (TestKeyframe?, TestKeyframe?) {
        var startKeyframe: TestKeyframe?
        var endKeyframe: TestKeyframe?
        
        for (index, keyframe) in keyframes.enumerated() {
            if keyframe.time <= progress {
                startKeyframe = keyframe
                if index + 1 < keyframes.count {
                    endKeyframe = keyframes[index + 1]
                }
            }
        }
        
        return (startKeyframe, endKeyframe)
    }
    
    private func createTestMatrices(count: Int) -> [[Double]] {
        return (0..<count).map { i in
            let angle = Double(i) * .pi / Double(count)
            return [
                cos(angle), -sin(angle), 0, 0,
                sin(angle), cos(angle), 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
            ]
        }
    }
    
    private func multiplyMatrices(
        _ a: [Double],
        _ b: [Double]
    ) -> [Double] {
        var result = [Double](repeating: 0, count: 16)
        for row in 0..<4 {
            for col in 0..<4 {
                for k in 0..<4 {
                    result[row * 4 + col] += a[row * 4 + k] * b[k * 4 + col]
                }
            }
        }
        return result
    }
    
    private func createPerspectiveMatrix(
        rotationX: Double,
        rotationY: Double,
        rotationZ: Double,
        perspective: Double
    ) -> [Double] {
        let cosX = cos(rotationX)
        let sinX = sin(rotationX)
        let cosY = cos(rotationY)
        let sinY = sin(rotationY)
        let cosZ = cos(rotationZ)
        let sinZ = sin(rotationZ)
        
        return [
            cosY * cosZ,
            cosY * sinZ,
            -sinY,
            0,
            sinX * sinY * cosZ - cosX * sinZ,
            sinX * sinY * sinZ + cosX * cosZ,
            sinX * cosY,
            0,
            cosX * sinY * cosZ + sinX * sinZ,
            cosX * sinY * sinZ - sinX * cosZ,
            cosX * cosY,
            -1.0 / perspective,
            0,
            0,
            0,
            1
        ]
    }
    
    private func createTestLayers(count: Int) -> [ParallaxLayer] {
        return (0..<count).map { i in
            ParallaxLayer(
                id: i,
                depthFactor: Double(i) / Double(count),
                speedMultiplier: 1.0 + Double(i) * 0.1
            )
        }
    }
    
    private func calculateParallaxOffset(
        scrollOffset: Double,
        layer: ParallaxLayer
    ) -> Double {
        return scrollOffset * layer.depthFactor * layer.speedMultiplier
    }
    
    private func calculateDepthParallax(
        scrollOffset: Double,
        depthFactor: Double
    ) -> Double {
        return scrollOffset * (1.0 - depthFactor)
    }
    
    private func buildAnimationSequence(stepCount: Int) -> [AnimationStep] {
        return (0..<stepCount).map { i in
            AnimationStep(
                startTime: Double(i) / Double(stepCount),
                duration: 1.0 / Double(stepCount),
                easing: .easeInOut
            )
        }
    }
    
    private func createTestAnimations(count: Int) -> [TestAnimation] {
        return (0..<count).map { TestAnimation(id: $0) }
    }
    
    private func calculateAnimationValue(
        _ animation: TestAnimation,
        at progress: Double
    ) -> Double {
        return progress * Double(animation.id + 1)
    }
}

// MARK: - Test Support Types

struct SpringConfiguration {
    let mass: Double
    let stiffness: Double
    let damping: Double
}

struct TestKeyframe {
    let time: Double
    let value: Double
}

struct ParallaxLayer {
    let id: Int
    let depthFactor: Double
    let speedMultiplier: Double
}

struct AnimationStep {
    let startTime: Double
    let duration: Double
    let easing: TestEasing
}

enum TestEasing {
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

struct TestAnimation {
    let id: Int
}
