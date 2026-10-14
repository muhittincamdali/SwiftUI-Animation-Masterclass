import Foundation
import SwiftUI
import Testing
@testable import SwiftUIAnimationMasterclass

/// Integrates m·x″ = −k·x − c·x′ with tiny semi-implicit Euler steps, independently of the
/// closed-form solution under test.
private func integrate(_ spring: DampedSpring, displacement: Double, velocity: Double, until time: Double) -> (x: Double, v: Double) {
    let step = 1e-5
    var x = displacement
    var v = velocity
    for _ in 0..<Int((time / step).rounded()) {
        let acceleration = (-spring.stiffness * x - spring.damping * v) / spring.mass
        v += acceleration * step
        x += v * step
    }
    return (x, v)
}

@Suite("DampedSpring")
struct DampedSpringTests {
    @Test("closed form matches numeric integration", arguments: [0.3, 1.0, 2.5])
    func matchesIntegration(dampingRatio: Double) {
        let spring = DampedSpring(response: 0.5, dampingRatio: dampingRatio)
        for time in [0.05, 0.2, 0.45, 1.0] {
            let numeric = integrate(spring, displacement: 100, velocity: -400, until: time)
            #expect(abs(spring.displacement(at: time, initialDisplacement: 100, initialVelocity: -400) - numeric.x) < 0.05)
            #expect(abs(spring.velocity(at: time, initialDisplacement: 100, initialVelocity: -400) - numeric.v) < 0.5)
        }
    }

    @Test func responseAndDampingRatioRoundTrip() {
        let spring = DampedSpring(response: 0.42, dampingRatio: 0.65, mass: 2)
        #expect(abs(spring.response - 0.42) < 1e-12)
        #expect(abs(spring.dampingRatio - 0.65) < 1e-12)
        #expect(spring.mass == 2)
    }

    @Test func underdampedSpringOvershootsAndCriticalDoesNot() {
        let samples = stride(from: 0.0, through: 3, by: 0.005)
        let bouncy = samples.map { DampedSpring.bouncy.displacement(at: $0, initialDisplacement: 1, initialVelocity: 0) }
        let smooth = samples.map { DampedSpring.smooth.displacement(at: $0, initialDisplacement: 1, initialVelocity: 0) }
        #expect(bouncy.contains { $0 < -0.05 })
        #expect(smooth.allSatisfy { $0 >= 0 })
    }

    @Test func startsAtTheInitialState() {
        let spring = DampedSpring.snappy
        #expect(spring.displacement(at: 0, initialDisplacement: 42, initialVelocity: 7) == 42)
        #expect(spring.velocity(at: 0, initialDisplacement: 42, initialVelocity: 7) == 7)
        #expect(spring.value(from: 10, to: 50, at: 0) == 10)
    }

    @Test("settling duration is the last moment outside the tolerance", arguments: [0.2, 1.0, 3.0])
    func settlingDuration(dampingRatio: Double) {
        let spring = DampedSpring(response: 0.4, dampingRatio: dampingRatio)
        let tolerance = 0.01
        let settle = spring.settlingDuration(initialDisplacement: 50, initialVelocity: 0, tolerance: tolerance)
        #expect(settle > 0)
        let before = settle - 0.001
        let isOutsideBefore = abs(spring.displacement(at: before, initialDisplacement: 50, initialVelocity: 0)) >= tolerance
            || abs(spring.velocity(at: before, initialDisplacement: 50, initialVelocity: 0)) >= tolerance
        #expect(isOutsideBefore)
        for time in stride(from: settle, through: settle + 5, by: 0.001) {
            #expect(abs(spring.displacement(at: time, initialDisplacement: 50, initialVelocity: 0)) < tolerance)
        }
    }

    @Test func springAtRestSettlesImmediatelyAndUndampedNever() {
        #expect(DampedSpring.snappy.settlingDuration(initialDisplacement: 0, initialVelocity: 0) == 0)
        let undamped = DampedSpring(stiffness: 100, damping: 0)
        #expect(undamped.settlingDuration(initialDisplacement: 1, initialVelocity: 0) == .infinity)
    }

    @Test func relativeVelocityDividesByTheChange() {
        #expect(DampedSpring.relativeVelocity(300, from: 100, to: 0) == -3)
        #expect(DampedSpring.relativeVelocity(300, from: 0, to: 150) == 2)
        #expect(DampedSpring.relativeVelocity(300, from: 20, to: 20) == 0)
    }
}

@Suite("Decay")
struct DecayTests {
    @Test func distanceMatchesStepwiseDeceleration() {
        // Apply the rate once per millisecond, the way a scroll view decelerates.
        var velocity = 2000.0
        var distance = 0.0
        for _ in 0..<800 {
            distance += velocity * 0.001
            velocity *= Decay.normal.decelerationRate
        }
        #expect(abs(Decay.normal.distance(at: 0.8, initialVelocity: 2000) - distance) / distance < 0.002)
        #expect(abs(Decay.normal.velocity(at: 0.8, initialVelocity: 2000) - velocity) < 1e-6)
    }

    @Test func projectedDistanceIsTheLimitAndKeepsTheSign() {
        let projected = Decay.normal.projectedDistance(initialVelocity: 1500)
        #expect(abs(Decay.normal.distance(at: 30, initialVelocity: 1500) - projected) < 1e-6)
        #expect(Decay.normal.projectedDistance(initialVelocity: -1500) == -projected)
        #expect(Decay.fast.projectedDistance(initialVelocity: 1500) < projected)
        #expect(Decay.normal.projectedDistance(initialVelocity: 0) == 0)
    }

    @Test func durationEndsAtTheThreshold() {
        let duration = Decay.normal.duration(initialVelocity: -1000, threshold: 1)
        #expect(abs(abs(Decay.normal.velocity(at: duration, initialVelocity: -1000)) - 1) < 1e-9)
        #expect(Decay.normal.duration(initialVelocity: 0.2, threshold: 0.5) == 0)
    }
}

@Suite("GravityBounce")
struct GravityBounceTests {
    let drop = GravityBounce(gravity: 1000, restitution: 0.5, minimumBounceSpeed: 20)

    @Test func firstLandingFollowsFreeFall() {
        let first = drop.impactTimes(height: 500)[0]
        #expect(abs(first - 1) < 1e-12) // 500 = ½·1000·t²
        #expect(abs(drop.position(at: 0.5, height: 500) - 125) < 1e-9)
        #expect(abs(drop.position(at: first, height: 500) - 500) < 1e-9)
    }

    @Test func eachBounceIsRestitutionSquaredAsHigh() {
        let impacts = drop.impactTimes(height: 500)
        #expect(impacts.count >= 3)
        var apexes: [Double] = []
        for (start, end) in zip(impacts, impacts.dropFirst()) {
            let apexTime = (start + end) / 2
            apexes.append(500 - drop.position(at: apexTime, height: 500))
        }
        #expect(abs(apexes[0] - 125) < 1e-9) // 500 · 0.5²
        for (higher, lower) in zip(apexes, apexes.dropFirst()) {
            #expect(abs(lower / higher - 0.25) < 1e-9)
        }
    }

    @Test func neverPassesTheFloorAndEndsOnIt() {
        let duration = drop.duration(height: 300, initialVelocity: 100)
        for time in stride(from: 0.0, through: duration + 1, by: 0.001) {
            let position = drop.position(at: time, height: 300, initialVelocity: 100)
            #expect(position <= 300 + 1e-9)
            #expect(position >= 0)
        }
        #expect(drop.position(at: duration, height: 300, initialVelocity: 100) == 300)
    }

    @Test func stopsWhenBouncesGetTooSlowOrTooMany() {
        // Impact speed 1000; bounces at 500, 250, 125, 62.5, 31.25, then 15.6 < 20 stops.
        #expect(drop.bounceCount(height: 500) == 5)
        let limited = GravityBounce(gravity: 1000, restitution: 0.9, minimumBounceSpeed: 0, maximumBounces: 3)
        #expect(limited.bounceCount(height: 500) == 3)
        let dead = GravityBounce(gravity: 1000, restitution: 0)
        #expect(dead.bounceCount(height: 500) == 0)
        #expect(abs(dead.duration(height: 500) - 1) < 1e-12)
    }

    @Test func animationProgressStartsAtZeroAndRestsAtOne() {
        let animation = GravityBounceAnimation(fallDuration: 0.4, restitution: 0.5)
        #expect(animation.progress(at: 0) == 0)
        #expect(abs(animation.progress(at: 0.4) - 1) < 1e-9)
        #expect(animation.progress(at: 0.5) < 1) // in the air after the first bounce
        #expect(animation.progress(at: animation.duration) == 1)
        #expect(animation.duration > 0.4)
    }
}

@Suite("RubberBand and SnapPoints")
struct RubberBandTests {
    @Test func rubberBandResistsAndNeverReachesTheDimension() {
        #expect(RubberBand.offset(0, dimension: 300) == 0)
        let small = RubberBand.offset(10, dimension: 300)
        #expect(small > 0 && small < 10)
        #expect(RubberBand.offset(1_000_000, dimension: 300) < 300)
        #expect(RubberBand.offset(-80, dimension: 300) == -RubberBand.offset(80, dimension: 300))
        #expect(RubberBand.offset(200, dimension: 300) > RubberBand.offset(100, dimension: 300))
    }

    @Test func clampFollowsInsideTheRangeAndStretchesOutside() {
        #expect(RubberBand.clamp(50, to: 0...100, dimension: 300) == 50)
        let above = RubberBand.clamp(160, to: 0...100, dimension: 300)
        #expect(above > 100 && above < 160)
        let below = RubberBand.clamp(-60, to: 0...100, dimension: 300)
        #expect(below < 0 && below > -60)
    }

    @Test func snapPointsUseTheProjectedPosition() {
        let detents = SnapPoints([600, 0, 300])
        #expect(detents.positions == [0, 300, 600])
        #expect(detents.index(nearest: 140) == 0)
        #expect(detents.index(nearest: 150) == 0) // tie goes to the lower position
        #expect(detents.index(nearest: 460) == 2)
        // A slow release near 0 stays; a flick at 600 pt/s carries about 300 pt further and moves on.
        #expect(detents.index(forRelease: 40, velocity: 50) == 0)
        #expect(detents.index(forRelease: 40, velocity: 600) == 1)
        #expect(detents.index(forRelease: 40, velocity: -600) == 0)
    }
}
