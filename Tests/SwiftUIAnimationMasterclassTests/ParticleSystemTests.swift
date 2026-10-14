import Foundation
import SwiftUI
import Testing
@testable import SwiftUIAnimationMasterclass

private let canvas = CGSize(width: 400, height: 300)

/// Advances `system` in display-sized steps.
private func run(_ system: inout ParticleSystem, for seconds: Double, step: Double = 1.0 / 60) {
    var elapsed = 0.0
    while elapsed < seconds - 1e-9 {
        system.update(by: step, in: canvas)
        elapsed += step
    }
}

@Suite("ParticleSystem")
struct ParticleSystemTests {
    @Test func sameSeedGivesTheSameParticles() {
        var first = ParticleSystem(emitter: .confetti, seed: 42)
        var second = ParticleSystem(emitter: .confetti, seed: 42)
        var other = ParticleSystem(emitter: .confetti, seed: 43)
        first.burst()
        second.burst()
        other.burst()
        run(&first, for: 0.5)
        run(&second, for: 0.5)
        run(&other, for: 0.5)
        #expect(first.particles == second.particles)
        #expect(first.particles != other.particles)
    }

    @Test func burstBornOnTheNextUpdateAndCappedByMaxParticles() {
        var emitter = ParticleEmitter(burstCount: 30, maxParticles: 50, lifetime: 5...5)
        var system = ParticleSystem(emitter: emitter, seed: 1)
        system.burst()
        #expect(system.particles.isEmpty)
        #expect(!system.isIdle)
        system.update(by: 0, in: canvas)
        #expect(system.particles.count == 30)
        system.burst()
        system.burst(count: 5)
        system.update(by: 0, in: canvas)
        #expect(system.particles.count == 50)

        emitter.burstCount = 0
        system.emitter = emitter
        system.reset()
        system.burst()
        system.update(by: 0, in: canvas)
        #expect(system.isIdle)
    }

    @Test func continuousEmissionFollowsTheBirthRate() {
        let emitter = ParticleEmitter(birthRate: 50, lifetime: 10...10)
        var system = ParticleSystem(emitter: emitter, isEmitting: true, seed: 3)
        run(&system, for: 2)
        #expect(abs(system.particles.count - 100) <= 1)

        system.isEmitting = false
        run(&system, for: 1)
        #expect(abs(system.particles.count - 100) <= 1)
    }

    @Test func particlesDieAtTheEndOfTheirLifetime() {
        var system = ParticleSystem(emitter: ParticleEmitter(burstCount: 10, lifetime: 0.5...1.0), seed: 9)
        system.burst()
        run(&system, for: 0.45)
        #expect(system.particles.count == 10)
        run(&system, for: 0.6)
        #expect(system.particles.isEmpty)
        #expect(system.isIdle)
    }

    @Test func gravityAndLaunchVelocityFollowProjectileMotion() throws {
        // One particle launched straight right at 100 pt/s under 400 pt/s² gravity.
        let emitter = ParticleEmitter(
            burstCount: 1, lifetime: 5...5, speed: 100...100, direction: .zero, spread: .zero,
            forces: [.gravity(400)]
        )
        var system = ParticleSystem(emitter: emitter, seed: 5)
        system.burst()
        run(&system, for: 1, step: 1.0 / 120)
        let particle = try #require(system.particles.first)
        #expect(abs(particle.x - (200 + 100)) < 1e-6)
        #expect(abs(particle.y - (150 + 200)) < 2) // ½·400·1² = 200, Euler error below 2 pt
        #expect(abs(particle.velocityY - 400) < 1e-6)
    }

    @Test func dragRemovesTheSameShareOfSpeedEverySecond() throws {
        let emitter = ParticleEmitter(burstCount: 1, lifetime: 5...5, speed: 300...300, spread: .zero, drag: 2)
        var system = ParticleSystem(emitter: emitter, seed: 5)
        system.burst()
        run(&system, for: 1)
        let speed = try #require(system.particles.first).speed
        #expect(abs(speed - 300 * exp(-2)) < 1e-6)
    }

    @Test func spreadKeepsLaunchDirectionsInsideTheCone() {
        let emitter = ParticleEmitter(burstCount: 200, lifetime: 5...5, speed: 100...200, direction: .degrees(-90), spread: .degrees(60))
        var system = ParticleSystem(emitter: emitter, seed: 11)
        system.burst()
        system.update(by: 1.0 / 60, in: canvas)
        for particle in system.particles {
            let degrees = atan2(particle.velocityY, particle.velocityX) * 180 / .pi
            #expect(degrees >= -120 - 1e-9 && degrees <= -60 + 1e-9)
        }
    }

    @Test("sources place births where they promise", arguments: [
        ParticleEmitter.Source.edge(.top), .edge(.bottom), .edge(.leading), .edge(.trailing), .area, .circle(radius: 40),
    ])
    func sourcesPlaceBirths(source: ParticleEmitter.Source) {
        let emitter = ParticleEmitter(source: source, position: .center, burstCount: 100, speed: 0...0)
        var system = ParticleSystem(emitter: emitter, seed: 2)
        system.burst()
        system.update(by: 0, in: canvas)
        for particle in system.particles {
            switch source {
            case .edge(.top): #expect(particle.y == 0)
            case .edge(.bottom): #expect(particle.y == Double(canvas.height))
            case .edge(.leading): #expect(particle.x == 0)
            case .edge(.trailing): #expect(particle.x == Double(canvas.width))
            case .circle: #expect(abs(hypot(particle.x - 200, particle.y - 150) - 40) < 1e-9)
            default: break
            }
            #expect((0...canvas.width).contains(particle.x) && (0...canvas.height).contains(particle.y))
        }
    }

    @Test func longPausesAreClampedAndAlignedParticlesFaceTheirMotion() throws {
        let emitter = ParticleEmitter(
            burstCount: 1, lifetime: 5...5, speed: 100...100, direction: .zero, spread: .zero,
            alignsWithMotion: true, forces: [.gravity(400)]
        )
        var system = ParticleSystem(emitter: emitter, seed: 4)
        system.burst()
        system.update(by: 30, in: canvas)
        #expect(abs(system.time - ParticleSystem.maximumUpdate) < 1e-9)
        let particle = try #require(system.particles.first)
        #expect(abs(particle.rotation - atan2(particle.velocityY, particle.velocityX)) < 1e-12)
    }
}

@Suite("Particle forces and appearance")
struct ParticleForceTests {
    private func particle(atX x: Double, y: Double) -> Particle {
        Particle(x: x, y: y, velocityX: 0, velocityY: 0, age: 0, lifetime: 1, size: 4, rotation: 0, spin: 0, tumble: 0, colorIndex: 0, shapeIndex: 0)
    }

    @Test func attractorPullsAndNegativeStrengthPushes() {
        let size = CGSize(width: 200, height: 200)
        let pull = ParticleForce.attractor(center: .center, strength: 50).acceleration(for: particle(atX: 180, y: 100), time: 0, canvas: size)
        #expect(abs(pull.x + 50) < 1e-9 && abs(pull.y) < 1e-9)
        let push = ParticleForce.attractor(center: .center, strength: -50).acceleration(for: particle(atX: 100, y: 20), time: 0, canvas: size)
        #expect(abs(push.y + 50) < 1e-9)
        let atCenter = ParticleForce.attractor(center: .center, strength: 50).acceleration(for: particle(atX: 100, y: 100), time: 0, canvas: size)
        #expect(atCenter.x == 0 && atCenter.y == 0)
        let nearCenter = ParticleForce.attractor(center: .center, strength: 50).acceleration(for: particle(atX: 104, y: 100), time: 0, canvas: size)
        #expect(abs(nearCenter.x + 25) < 1e-9) // half strength at half the core radius
    }

    @Test func vortexTurnsClockwiseOnScreen() {
        let size = CGSize(width: 200, height: 200)
        // Right of the center: pushed down. Below the center: pushed left.
        let right = ParticleForce.vortex(center: .center, strength: 30).acceleration(for: particle(atX: 160, y: 100), time: 0, canvas: size)
        #expect(abs(right.x) < 1e-9 && abs(right.y - 30) < 1e-9)
        let below = ParticleForce.vortex(center: .center, strength: 30).acceleration(for: particle(atX: 100, y: 160), time: 0, canvas: size)
        #expect(abs(below.x + 30) < 1e-9 && abs(below.y) < 1e-9)
    }

    @Test func turbulenceHasTheGivenStrengthAndChangesSmoothly() {
        let force = ParticleForce.turbulence(strength: 40, scale: 100)
        let here = force.acceleration(for: particle(atX: 120, y: 80), time: 1, canvas: canvas)
        let nearby = force.acceleration(for: particle(atX: 121, y: 80), time: 1, canvas: canvas)
        #expect(abs(hypot(here.x, here.y) - 40) < 1e-9)
        #expect(hypot(here.x - nearby.x, here.y - nearby.y) < 3)
    }

    @Test func opacityFadesInAndOut() {
        let emitter = ParticleEmitter(fadeIn: 0.2, fadeOutStart: 0.6)
        #expect(emitter.opacity(at: 0) == 0)
        #expect(abs(emitter.opacity(at: 0.1) - 0.5) < 1e-12)
        #expect(emitter.opacity(at: 0.5) == 1)
        #expect(abs(emitter.opacity(at: 0.8) - 0.5) < 1e-12)
        #expect(emitter.opacity(at: 1) == 0)
        #expect(ParticleEmitter(fadeOutStart: 1).opacity(at: 1) == 1)
    }

    @Test func scaleMovesTowardTheEndScale() {
        let emitter = ParticleEmitter(endScale: 0.2)
        #expect(emitter.scale(at: 0) == 1)
        #expect(abs(emitter.scale(at: 0.5) - 0.6) < 1e-12)
        #expect(abs(emitter.scale(at: 1) - 0.2) < 1e-12)
    }

    @Test("every preset produces particles inside the canvas", arguments: ParticleEmitter.presets.map(\.name))
    func presetsProduceVisibleParticles(name: String) throws {
        let emitter = try #require(ParticleEmitter.presets.first { $0.name == name }).emitter
        var system = ParticleSystem(emitter: emitter, isEmitting: true, seed: 8)
        system.burst()
        let area = CGSize(width: emitter.reach * 2, height: emitter.reach * 2)
        for _ in 0..<30 {
            system.update(by: 1.0 / 60, in: area)
        }
        #expect(!system.particles.isEmpty)
        let inside = system.particles.filter { (0...area.width).contains($0.x) && (0...area.height).contains($0.y) }
        #expect(inside.count * 2 >= system.particles.count)
        for particle in system.particles {
            #expect(particle.x.isFinite && particle.y.isFinite)
        }
    }
}
