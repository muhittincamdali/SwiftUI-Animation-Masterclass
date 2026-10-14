import SwiftUI
import Testing
@testable import SwiftUIAnimationMasterclass

/// Values that reach the package from outside (emitter settings changed at run time, frame
/// times, canvas sizes, gesture velocities) must neither crash nor grow memory without limit.
@Suite("Input bounds")
struct InputBoundsTests {
    private let canvas = CGSize(width: 300, height: 300)

    private func allFinite(_ particles: [Particle]) -> Bool {
        particles.allSatisfy {
            $0.x.isFinite && $0.y.isFinite && $0.velocityX.isFinite && $0.velocityY.isFinite && $0.size.isFinite
        }
    }

    @Test("a huge or infinite birth rate fills the system without trapping", arguments: [1e300, .greatestFiniteMagnitude, .infinity])
    func hugeBirthRate(rate: Double) {
        var emitter = ParticleEmitter(maxParticles: 50, lifetime: 5...5)
        emitter.birthRate = rate
        var system = ParticleSystem(emitter: emitter, isEmitting: true, seed: 3)
        for _ in 0..<30 {
            system.update(by: 1.0 / 60, in: canvas)
        }
        // An infinite rate is not a rate: nothing is born. A finite one stops at the cap.
        #expect(system.particles.count == (rate.isFinite ? 50 : 0))
    }

    @Test func particleCountNeverPassesTheHardLimit() {
        var emitter = ParticleEmitter(lifetime: 5...5)
        emitter.maxParticles = .max
        emitter.burstCount = .max
        var system = ParticleSystem(emitter: emitter, seed: 4)
        #expect(system.capacity == ParticleSystem.particleLimit)

        // Bursts queued before an update add up, but the queue is a single bounded number.
        for _ in 0..<1000 {
            system.burst()
        }
        system.burst(count: .max)
        system.update(by: 1.0 / 60, in: canvas)
        #expect(system.particles.count == ParticleSystem.particleLimit)

        system.burst()
        system.update(by: 1.0 / 60, in: canvas)
        #expect(system.particles.count == ParticleSystem.particleLimit)
    }

    @Test func negativeLimitsBirthNothing() {
        var emitter = ParticleEmitter()
        emitter.maxParticles = -5
        emitter.burstCount = -5
        var system = ParticleSystem(emitter: emitter, seed: 5)
        system.burst()
        system.burst(count: .min)
        system.update(by: 1.0 / 60, in: canvas)
        #expect(system.particles.isEmpty)
        #expect(system.isIdle)
    }

    @Test func infiniteRangesUseTheirFiniteEnd() throws {
        var emitter = ParticleEmitter(burstCount: 20)
        emitter.speed = 50...Double.infinity
        emitter.lifetime = 2...Double.infinity
        emitter.size = -Double.greatestFiniteMagnitude...Double.greatestFiniteMagnitude // infinite width
        emitter.spin = -Double.infinity...0
        emitter.spread = .radians(.infinity)
        emitter.direction = .radians(.nan)
        var system = ParticleSystem(emitter: emitter, seed: 6)
        system.burst()
        system.update(by: 1.0 / 60, in: canvas)

        #expect(system.particles.count == 20)
        let particle = try #require(system.particles.first)
        #expect(particle.lifetime == 2)
        #expect(particle.size == 0)
        #expect(particle.spin == 0)
        // A NaN direction and an infinite spread count as 0: every particle leaves to the right.
        #expect(system.particles.allSatisfy { abs($0.velocityX - 50) < 1e-9 && $0.velocityY == 0 })
        #expect(abs(particle.speed - 50) < 1e-9)
        #expect(allFinite(system.particles))
    }

    @Test func nonFiniteDurationsAndCanvasSizesAreSafe() {
        var system = ParticleSystem(emitter: .snow, isEmitting: true, seed: 7)
        system.update(by: .nan, in: canvas)
        #expect(system.time == 0)
        system.update(by: -1, in: canvas)
        #expect(system.time == 0)
        system.update(by: .infinity, in: canvas)
        #expect(abs(system.time - ParticleSystem.maximumUpdate) < 1e-9)

        system.update(by: 0.1, in: CGSize(width: CGFloat.nan, height: .infinity))
        system.update(by: 0.1, in: CGSize(width: -200, height: -200))
        #expect(!system.particles.isEmpty)
        #expect(allFinite(system.particles))
    }

    @Test("forces with degenerate parameters do not produce NaN", arguments: [
        ParticleForce.turbulence(strength: 50, scale: 0),
        .turbulence(strength: 50, scale: -10),
        .turbulence(strength: 50, scale: .nan),
        .gravity(.infinity),
        .wind(x: .nan, y: 10),
        .attractor(center: UnitPoint(x: CGFloat.nan, y: 0.5), strength: 100),
    ])
    func degenerateForces(force: ParticleForce) {
        var emitter = ParticleEmitter(burstCount: 10)
        emitter.forces = [force]
        var system = ParticleSystem(emitter: emitter, seed: 8)
        system.burst()
        for _ in 0..<20 {
            system.update(by: 1.0 / 60, in: canvas)
        }
        #expect(system.particles.count == 10)
        #expect(allFinite(system.particles))
    }

    @MainActor
    @Test func emptiedColorsAndShapesDrawNothingInsteadOfTrapping() throws {
        var emitter = ParticleEmitter(burstCount: 10)
        var system = ParticleSystem(emitter: emitter, seed: 9)
        emitter.colors = []
        emitter.shapes = []
        system.emitter = emitter
        system.burst()
        system.update(by: 1.0 / 60, in: canvas)
        #expect(system.particles.count == 10)

        let renderer = ImageRenderer(content: ParticleSnapshot(particles: system.particles, emitter: emitter).frame(width: 100, height: 100))
        #expect(renderer.cgImage != nil)
    }

    @Test func gravityBounceStopsAtTheBounceLimitWhateverTheRestitution() {
        for restitution in [0.999_999, 1, 2] {
            var drop = GravityBounce(gravity: 1000, restitution: 0.5, minimumBounceSpeed: 0)
            drop.restitution = restitution
            drop.maximumBounces = .max
            #expect(drop.bounceCount(height: 100) == GravityBounce.bounceLimit)
        }
        var still = GravityBounce(gravity: 1000, restitution: 0.5)
        still.restitution = .nan
        #expect(still.bounceCount(height: 100) == 0)
    }

    @Test("the most extreme accepted fall durations animate with finite values", arguments: [1e-150, 1e150])
    func extremeFallDurations(fallDuration: Double) {
        let animation = GravityBounceAnimation(fallDuration: fallDuration, restitution: 0.5)
        #expect(animation.duration.isFinite && animation.duration >= fallDuration)
        #expect(animation.progress(at: fallDuration / 2).isFinite)
        #expect(animation.progress(at: animation.duration) == 1)
    }

    #if os(macOS)
    // Exit tests run the closure in a child process; they are available on macOS, not on iOS.
    @Test func fallDurationsThatGiveNoUsableGravityAreRejected() async {
        await #expect(processExitsWith: .failure) {
            _ = GravityBounceAnimation(fallDuration: .infinity, restitution: 0.5)
        }
        await #expect(processExitsWith: .failure) {
            _ = GravityBounceAnimation(fallDuration: 1e200, restitution: 0.5) // 2 / T² is 0
        }
        await #expect(processExitsWith: .failure) {
            _ = GravityBounceAnimation(fallDuration: 1e-200, restitution: 0.5) // 2 / T² is infinite
        }
        await #expect(processExitsWith: .failure) {
            _ = GravityBounceAnimation(fallDuration: .nan, restitution: 0.5)
        }
    }

    @Test func dragModifiersRejectValuesThatWouldBreakTheFirstDrag() async {
        // Without these checks the modifiers were created and the process trapped, or the view
        // got NaN offsets, only once the user started dragging.
        await #expect(processExitsWith: .failure) {
            _ = SnapDragModifier(axis: .vertical, offsets: [.nan, 0], selection: .constant(0), decay: .normal, spring: .snappy)
        }
        await #expect(processExitsWith: .failure) {
            _ = SnapDragModifier(axis: .horizontal, offsets: [0, .infinity], selection: .constant(0), decay: .normal, spring: .snappy)
        }
        await #expect(processExitsWith: .failure) {
            _ = ElasticDragModifier(axes: .vertical, resistance: 0, spring: .bouncy)
        }
        await #expect(processExitsWith: .failure) {
            _ = ElasticDragModifier(axes: .vertical, resistance: -240, spring: .bouncy)
        }
        await #expect(processExitsWith: .failure) {
            _ = ElasticDragModifier(axes: .vertical, resistance: .nan, spring: .bouncy)
        }
        await #expect(processExitsWith: .failure) {
            _ = ElasticDragModifier(axes: .vertical, resistance: .infinity, spring: .bouncy)
        }
    }

    @Test func physicsConstantsSetAfterCreationFollowTheInitializerRules() async {
        await #expect(processExitsWith: .failure) {
            var spring = DampedSpring.bouncy
            spring.mass = 0
        }
        await #expect(processExitsWith: .failure) {
            var spring = DampedSpring.bouncy
            spring.stiffness = .nan
        }
        await #expect(processExitsWith: .failure) {
            var spring = DampedSpring.bouncy
            spring.damping = -1
        }
        await #expect(processExitsWith: .failure) {
            var decay = Decay.normal
            decay.decelerationRate = 1
        }
        await #expect(processExitsWith: .failure) {
            var drop = GravityBounce(gravity: 1000, restitution: 0.5)
            drop.gravity = 0
        }
    }

    @Test func infiniteConstantsAreRejected() async {
        // `> 0` alone accepts infinity, which turns spring and bounce results into NaN.
        await #expect(processExitsWith: .failure) {
            _ = DampedSpring(mass: .infinity, stiffness: 100, damping: 10)
        }
        await #expect(processExitsWith: .failure) {
            _ = DampedSpring(stiffness: .infinity, damping: 10)
        }
        await #expect(processExitsWith: .failure) {
            _ = DampedSpring(stiffness: 100, damping: .infinity)
        }
        await #expect(processExitsWith: .failure) {
            _ = DampedSpring(response: 0.4, dampingRatio: .infinity)
        }
        await #expect(processExitsWith: .failure) {
            var spring = DampedSpring.bouncy
            spring.mass = .infinity
        }
        await #expect(processExitsWith: .failure) {
            var spring = DampedSpring.bouncy
            spring.stiffness = .infinity
        }
        await #expect(processExitsWith: .failure) {
            var spring = DampedSpring.bouncy
            spring.damping = .infinity
        }
        await #expect(processExitsWith: .failure) {
            _ = GravityBounce(gravity: .infinity, restitution: 0.5)
        }
        await #expect(processExitsWith: .failure) {
            var drop = GravityBounce(gravity: 1000, restitution: 0.5)
            drop.gravity = .infinity
        }
        await #expect(processExitsWith: .failure) {
            _ = RubberBand.offset(10, dimension: .infinity)
        }
        await #expect(processExitsWith: .failure) {
            _ = RubberBand.offset(0, dimension: 200, coefficient: .infinity)
        }
    }
    #endif

    @Test func validPhysicsConstantsCanBeSetAfterCreation() {
        // The didSet checks must let valid values through (a trap would end this test), and the
        // motion must then use the new value, as if it had been passed to the initializer.
        var spring = DampedSpring.bouncy
        spring.mass = 2
        spring.stiffness = 300
        spring.damping = 0 // the lowest damping allowed
        #expect(spring == DampedSpring(mass: 2, stiffness: 300, damping: 0))

        var decay = Decay.normal
        decay.decelerationRate = 0.99
        #expect(decay == .fast)

        var drop = GravityBounce(gravity: 1000, restitution: 0.5)
        drop.gravity = 2000
        // A fall of 100 units under 2000 units/s² lands after √(2·100 / 2000) = √0.1 s.
        let firstImpact = drop.impactTimes(height: 100).first ?? 0
        #expect(abs(firstImpact - 0.1.squareRoot()) < 1e-12)
    }

    @Test func springsIgnoreNonFiniteStartsAndVelocities() {
        let spring = DampedSpring.bouncy
        #expect(spring.settlingDuration(initialDisplacement: .nan, initialVelocity: 0) == .infinity)
        #expect(spring.settlingDuration(initialDisplacement: 0, initialVelocity: .infinity) == .infinity)
        #expect(DampedSpring.relativeVelocity(.nan, from: 0, to: 100) == 0)
        #expect(DampedSpring.relativeVelocity(100, from: 0, to: .infinity) == 0)
        #expect(DampedSpring.relativeVelocity(-200, from: 0, to: 100) == -2)
    }

    @Test func gestureVelocitiesThatAreNotFiniteStartTheSpringAtRest() {
        #expect(ElasticDrag.returnVelocity(offset: CGSize(width: 50, height: 0), velocity: CGSize(width: CGFloat.nan, height: 0)) == 0)
        #expect(ElasticDrag.returnVelocity(offset: CGSize(width: 50, height: 0), velocity: CGSize(width: CGFloat.infinity, height: 0)) == 0)
        #expect(ElasticDrag.returnVelocity(offset: CGSize(width: CGFloat.infinity, height: 0), velocity: CGSize(width: 10, height: 0)) == 0)
        #expect(SnapDrag.finiteVelocity(.nan) == 0)
        #expect(SnapDrag.finiteVelocity(-.infinity) == 0)
        #expect(SnapDrag.finiteVelocity(-320) == -320)
    }
}
