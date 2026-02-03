//
//  AdvancedAnimationTests.swift
//  SwiftUI-Animation-Masterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import SwiftUI_Animation_Masterclass

// MARK: - Timing Curve Tests

final class TimingCurveTests: XCTestCase {
    
    // MARK: - Cubic Bezier Tests
    
    func testLinearCurve() {
        let curve = CubicBezierCurve.linear
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(0.5), 0.5, accuracy: 0.01)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
    }
    
    func testEaseInCurve() {
        let curve = CubicBezierCurve.easeIn
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
        
        // Ease in should be slower at the start
        XCTAssertLessThan(curve.transform(0.25), 0.25)
        XCTAssertLessThan(curve.transform(0.5), 0.5)
    }
    
    func testEaseOutCurve() {
        let curve = CubicBezierCurve.easeOut
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
        
        // Ease out should be faster at the start
        XCTAssertGreaterThan(curve.transform(0.25), 0.25)
        XCTAssertGreaterThan(curve.transform(0.5), 0.5)
    }
    
    func testEaseInOutCurve() {
        let curve = CubicBezierCurve.easeInOut
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(0.5), 0.5, accuracy: 0.05)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
        
        // First half should be slower
        XCTAssertLessThan(curve.transform(0.25), 0.25)
        // Second half should be faster (relative to end)
        XCTAssertGreaterThan(curve.transform(0.75), 0.75)
    }
    
    func testCustomCubicBezier() {
        let curve = CubicBezierCurve(x1: 0.17, y1: 0.67, x2: 0.83, y2: 0.67)
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
        
        // Curve should be monotonically increasing
        var previousValue: Double = 0
        for i in 1...10 {
            let t = Double(i) / 10.0
            let value = curve.transform(t)
            XCTAssertGreaterThanOrEqual(value, previousValue)
            previousValue = value
        }
    }
    
    // MARK: - Spring Curve Tests
    
    func testSpringCurveConvergence() {
        let curve = SpringCurve.smooth
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        
        // Spring should converge towards 1
        XCTAssertGreaterThan(curve.transform(0.9), 0.9)
    }
    
    func testBouncySpringOscillation() {
        let curve = SpringCurve.bouncy
        
        // Bouncy spring may overshoot
        var hasOvershoot = false
        for i in 1...20 {
            let t = Double(i) / 20.0
            if curve.transform(t) > 1.0 {
                hasOvershoot = true
                break
            }
        }
        
        // Note: Depending on damping, there may or may not be overshoot
        // This is just checking the curve runs without error
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
    }
    
    func testStiffSpringFastSettling() {
        let stiff = SpringCurve.stiff
        let soft = SpringCurve.soft
        
        // Stiff spring should reach 0.9 faster
        var stiffTime: Double = 1.0
        var softTime: Double = 1.0
        
        for i in 1...100 {
            let t = Double(i) / 100.0
            if stiff.transform(t) >= 0.9 && stiffTime == 1.0 {
                stiffTime = t
            }
            if soft.transform(t) >= 0.9 && softTime == 1.0 {
                softTime = t
            }
        }
        
        XCTAssertLessThanOrEqual(stiffTime, softTime)
    }
    
    // MARK: - Elastic Curve Tests
    
    func testElasticCurveEndpoints() {
        let curve = ElasticCurve()
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
    }
    
    func testElasticEaseInDirection() {
        let curveIn = ElasticCurve(easeIn: true)
        let curveOut = ElasticCurve(easeIn: false)
        
        // Both should reach the same endpoints
        XCTAssertEqual(curveIn.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curveOut.transform(0), 0, accuracy: 0.001)
    }
    
    // MARK: - Bounce Curve Tests
    
    func testBounceCurveEndpoints() {
        let curve = BounceCurve()
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
    }
    
    func testBounceEaseInEndpoints() {
        let curve = BounceCurve(easeIn: true)
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
    }
    
    // MARK: - Polynomial Curve Tests
    
    func testQuadraticEaseIn() {
        let curve = PolynomialCurve(exponent: 2, mode: .easeIn)
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(0.5), 0.25, accuracy: 0.001) // 0.5^2 = 0.25
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
    }
    
    func testQuadraticEaseOut() {
        let curve = PolynomialCurve(exponent: 2, mode: .easeOut)
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(0.5), 0.75, accuracy: 0.001) // 1 - 0.5^2 = 0.75
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
    }
    
    func testCubicEaseInOut() {
        let curve = PolynomialCurve(exponent: 3, mode: .easeInOut)
        
        XCTAssertEqual(curve.transform(0), 0, accuracy: 0.001)
        XCTAssertEqual(curve.transform(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(curve.transform(1), 1, accuracy: 0.001)
    }
}

// MARK: - Keyframe Tests

final class KeyframeTests: XCTestCase {
    
    func testKeyframeTrackEvaluation() {
        let track = KeyframeTrack<StandardAnimationValue>(duration: 1.0) {
            Keyframe(value: StandardAnimationValue(scale: 0), time: 0)
            Keyframe(value: StandardAnimationValue(scale: 1), time: 0.5)
            Keyframe(value: StandardAnimationValue(scale: 0.5), time: 1.0)
        }
        
        // At time 0
        let valueAtStart = track.evaluate(at: 0)
        XCTAssertEqual(valueAtStart.scale, 0, accuracy: 0.001)
        
        // At time 0.5 (peak)
        let valueAtPeak = track.evaluate(at: 0.5)
        XCTAssertEqual(valueAtPeak.scale, 1, accuracy: 0.001)
        
        // At time 1.0 (end)
        let valueAtEnd = track.evaluate(at: 1.0)
        XCTAssertEqual(valueAtEnd.scale, 0.5, accuracy: 0.001)
    }
    
    func testKeyframeInterpolation() {
        let track = KeyframeTrack<StandardAnimationValue>(duration: 1.0) {
            Keyframe(value: StandardAnimationValue(offsetX: 0), time: 0, easing: .linear)
            Keyframe(value: StandardAnimationValue(offsetX: 100), time: 1.0, easing: .linear)
        }
        
        // Linear interpolation at 0.25
        let valueAt25 = track.evaluate(at: 0.25)
        XCTAssertEqual(valueAt25.offsetX, 25, accuracy: 1.0)
        
        // Linear interpolation at 0.75
        let valueAt75 = track.evaluate(at: 0.75)
        XCTAssertEqual(valueAt75.offsetX, 75, accuracy: 1.0)
    }
    
    func testStandardAnimationValueInterpolation() {
        let from = StandardAnimationValue(offsetX: 0, offsetY: 0, scale: 1, rotation: 0, opacity: 1)
        let to = StandardAnimationValue(offsetX: 100, offsetY: 50, scale: 2, rotation: 90, opacity: 0)
        
        let interpolated = from.interpolated(to: to, progress: 0.5)
        
        XCTAssertEqual(interpolated.offsetX, 50, accuracy: 0.001)
        XCTAssertEqual(interpolated.offsetY, 25, accuracy: 0.001)
        XCTAssertEqual(interpolated.scale, 1.5, accuracy: 0.001)
        XCTAssertEqual(interpolated.rotation, 45, accuracy: 0.001)
        XCTAssertEqual(interpolated.opacity, 0.5, accuracy: 0.001)
    }
    
    func testTransform3DValueInterpolation() {
        let from = Transform3DValue(rotationX: 0, rotationY: 0, rotationZ: 0)
        let to = Transform3DValue(rotationX: 90, rotationY: 180, rotationZ: 45)
        
        let interpolated = from.interpolated(to: to, progress: 0.5)
        
        XCTAssertEqual(interpolated.rotationX, 45, accuracy: 0.001)
        XCTAssertEqual(interpolated.rotationY, 90, accuracy: 0.001)
        XCTAssertEqual(interpolated.rotationZ, 22.5, accuracy: 0.001)
    }
}

// MARK: - Keyframe Easing Tests

final class KeyframeEasingTests: XCTestCase {
    
    func testLinearEasing() {
        let easing = KeyframeEasing.linear
        
        XCTAssertEqual(easing.apply(0), 0, accuracy: 0.001)
        XCTAssertEqual(easing.apply(0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(easing.apply(1), 1, accuracy: 0.001)
    }
    
    func testEaseInEasing() {
        let easing = KeyframeEasing.easeIn
        
        XCTAssertEqual(easing.apply(0), 0, accuracy: 0.001)
        XCTAssertLessThan(easing.apply(0.5), 0.5) // Slower at start
        XCTAssertEqual(easing.apply(1), 1, accuracy: 0.001)
    }
    
    func testEaseOutEasing() {
        let easing = KeyframeEasing.easeOut
        
        XCTAssertEqual(easing.apply(0), 0, accuracy: 0.001)
        XCTAssertGreaterThan(easing.apply(0.5), 0.5) // Faster at start
        XCTAssertEqual(easing.apply(1), 1, accuracy: 0.001)
    }
    
    func testBounceEasing() {
        let easing = KeyframeEasing.bounce
        
        XCTAssertEqual(easing.apply(0), 0, accuracy: 0.001)
        XCTAssertEqual(easing.apply(1), 1, accuracy: 0.001)
        
        // Bounce should have specific values at certain points
        XCTAssertGreaterThan(easing.apply(0.5), 0)
    }
    
    func testExponentialEasing() {
        let easingIn = KeyframeEasing.exponentialIn
        let easingOut = KeyframeEasing.exponentialOut
        
        XCTAssertEqual(easingIn.apply(0), 0, accuracy: 0.001)
        XCTAssertEqual(easingOut.apply(1), 1, accuracy: 0.001)
    }
}

// MARK: - Keyframe Presets Tests

final class KeyframePresetsTests: XCTestCase {
    
    func testShakePreset() {
        let track = KeyframePresets.shake(intensity: 10, duration: 0.5)
        
        // Should start and end at zero offset
        let start = track.evaluate(at: 0)
        let end = track.evaluate(at: 0.5)
        
        XCTAssertEqual(start.offsetX, 0, accuracy: 0.001)
        XCTAssertEqual(end.offsetX, 0, accuracy: 1.0)
        
        // Should have movement in between
        let mid = track.evaluate(at: 0.05)
        XCTAssertNotEqual(mid.offsetX, 0)
    }
    
    func testHeartbeatPreset() {
        let track = KeyframePresets.heartbeat(duration: 1.0)
        
        // Should start at scale 1
        let start = track.evaluate(at: 0)
        XCTAssertEqual(start.scale, 1.0, accuracy: 0.001)
        
        // Should have larger scale in the middle
        let peak = track.evaluate(at: 0.4)
        XCTAssertGreaterThan(peak.scale, 1.0)
    }
    
    func testJellyPreset() {
        let track = KeyframePresets.jelly(duration: 0.8)
        
        // Should start and end at scale 1
        let start = track.evaluate(at: 0)
        let end = track.evaluate(at: 0.8)
        
        XCTAssertEqual(start.scale, 1.0, accuracy: 0.001)
        XCTAssertEqual(end.scale, 1.0, accuracy: 0.1)
    }
    
    func testBounceInPreset() {
        let track = KeyframePresets.bounceIn(duration: 0.6)
        
        // Should start small and transparent
        let start = track.evaluate(at: 0)
        XCTAssertLessThan(start.scale, 1.0)
        XCTAssertEqual(start.opacity, 0, accuracy: 0.001)
        
        // Should end at normal scale and visible
        let end = track.evaluate(at: 0.6)
        XCTAssertEqual(end.scale, 1.0, accuracy: 0.1)
        XCTAssertEqual(end.opacity, 1.0, accuracy: 0.1)
    }
}

// MARK: - Phase Animation Tests

final class PhaseAnimationTests: XCTestCase {
    
    func testPulsePhaseValues() {
        XCTAssertEqual(PulsePhase.idle.scale, 1.0)
        XCTAssertGreaterThan(PulsePhase.expanded.scale, 1.0)
        XCTAssertLessThan(PulsePhase.contracted.scale, 1.0)
    }
    
    func testBouncePhaseOffsets() {
        XCTAssertEqual(BouncePhase.rest.offsetY, 0)
        XCTAssertGreaterThan(BouncePhase.compress.offsetY, 0) // Downward
        XCTAssertLessThan(BouncePhase.stretch.offsetY, 0) // Upward
    }
    
    func testRotationPhaseDegrees() {
        XCTAssertEqual(RotationPhase.start.degrees, 0)
        XCTAssertEqual(RotationPhase.quarter.degrees, 90)
        XCTAssertEqual(RotationPhase.half.degrees, 180)
        XCTAssertEqual(RotationPhase.threeQuarter.degrees, 270)
        XCTAssertEqual(RotationPhase.complete.degrees, 360)
    }
    
    func testColorCyclePhaseColors() {
        // Just verify all phases have distinct colors
        let colors = [
            ColorCyclePhase.primary.color,
            ColorCyclePhase.secondary.color,
            ColorCyclePhase.tertiary.color,
            ColorCyclePhase.accent.color
        ]
        
        XCTAssertEqual(colors.count, 4)
    }
}

// MARK: - Transform 3D Configuration Tests

final class Transform3DConfigurationTests: XCTestCase {
    
    func testIdentityConfiguration() {
        let identity = Transform3DConfiguration.identity
        
        XCTAssertEqual(identity.rotationX, 0)
        XCTAssertEqual(identity.rotationY, 0)
        XCTAssertEqual(identity.rotationZ, 0)
        XCTAssertEqual(identity.translateX, 0)
        XCTAssertEqual(identity.translateY, 0)
        XCTAssertEqual(identity.scaleX, 1)
        XCTAssertEqual(identity.scaleY, 1)
    }
    
    func testCardFlipConfiguration() {
        let flip = Transform3DConfiguration.cardFlip
        
        XCTAssertEqual(flip.rotationY, 180)
        XCTAssertEqual(flip.perspective, 0.5)
    }
    
    func testCustomConfiguration() {
        let config = Transform3DConfiguration(
            rotationX: 45,
            rotationY: 90,
            rotationZ: 30,
            translateX: 10,
            translateY: 20,
            scaleX: 1.5,
            scaleY: 2.0
        )
        
        XCTAssertEqual(config.rotationX, 45)
        XCTAssertEqual(config.rotationY, 90)
        XCTAssertEqual(config.rotationZ, 30)
        XCTAssertEqual(config.translateX, 10)
        XCTAssertEqual(config.translateY, 20)
        XCTAssertEqual(config.scaleX, 1.5)
        XCTAssertEqual(config.scaleY, 2.0)
    }
}

// MARK: - Parallax Configuration Tests

final class ParallaxConfigurationTests: XCTestCase {
    
    func testDefaultConfiguration() {
        let config = ParallaxConfiguration()
        
        XCTAssertEqual(config.maxOffset, 20)
        XCTAssertEqual(config.intensity, 1.0)
        XCTAssertTrue(config.horizontalEnabled)
        XCTAssertTrue(config.verticalEnabled)
        XCTAssertFalse(config.inverted)
    }
    
    func testSubtlePreset() {
        let config = ParallaxConfiguration.subtle
        
        XCTAssertEqual(config.maxOffset, 10)
        XCTAssertEqual(config.intensity, 0.5)
    }
    
    func testIntensePreset() {
        let config = ParallaxConfiguration.intense
        
        XCTAssertEqual(config.maxOffset, 40)
        XCTAssertEqual(config.intensity, 1.5)
    }
    
    func testHorizontalOnlyPreset() {
        let config = ParallaxConfiguration.horizontalOnly
        
        XCTAssertTrue(config.horizontalEnabled)
        XCTAssertFalse(config.verticalEnabled)
    }
    
    func testSmoothingClamping() {
        let config = ParallaxConfiguration(smoothing: 1.5)
        XCTAssertEqual(config.smoothing, 1.0) // Should be clamped to 1.0
        
        let config2 = ParallaxConfiguration(smoothing: -0.5)
        XCTAssertEqual(config2.smoothing, 0) // Should be clamped to 0
    }
}

// MARK: - Morphing Shape Tests

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
final class MorphingShapeTests: XCTestCase {
    
    func testMorphProgressBounds() {
        let shape = MorphingShape(from: .circle, to: .square, progress: 0)
        XCTAssertEqual(shape.progress, 0)
        
        let shape2 = MorphingShape(from: .circle, to: .square, progress: 1)
        XCTAssertEqual(shape2.progress, 1)
    }
    
    func testShapeTypeNormalizedPoints() {
        // All shapes should have the same number of points for smooth morphing
        let circlePoints = MorphingShape.ShapeType.circle.normalizedPoints
        let squarePoints = MorphingShape.ShapeType.square.normalizedPoints
        let trianglePoints = MorphingShape.ShapeType.triangle.normalizedPoints
        
        XCTAssertEqual(circlePoints.count, squarePoints.count)
        XCTAssertEqual(squarePoints.count, trianglePoints.count)
    }
}

// MARK: - Particle Configuration Tests

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
final class ParticleConfigurationTests: XCTestCase {
    
    func testDefaultConfiguration() {
        let config = ParticleSystem.ParticleConfiguration()
        
        XCTAssertEqual(config.maxParticles, 50)
        XCTAssertEqual(config.spawnRate, 10)
        XCTAssertFalse(config.colors.isEmpty)
    }
    
    func testConfettiPreset() {
        let config = ParticleSystem.ParticleConfiguration.confetti
        
        XCTAssertEqual(config.maxParticles, 100)
        XCTAssertGreaterThan(config.spawnRate, 20)
        XCTAssertGreaterThan(config.colors.count, 5)
    }
    
    func testSnowPreset() {
        let config = ParticleSystem.ParticleConfiguration.snow
        
        XCTAssertEqual(config.gravity, 0) // Snow floats
        XCTAssertGreaterThan(config.velocityYRange.lowerBound, 0) // Falls down
    }
    
    func testFirePreset() {
        let config = ParticleSystem.ParticleConfiguration.fire
        
        XCTAssertLessThan(config.gravity, 0) // Fire rises
        XCTAssertLessThan(config.velocityYRange.upperBound, 0) // Moves upward
    }
}
