import SwiftUI

/// The simulation behind the particle views: births, forces, motion and deaths.
///
/// `ParticleSystem` is a value type with no timer of its own. Call ``update(by:in:)`` with
/// the time that passed, then draw ``particles``. ``ParticleView`` does this on every frame;
/// use the system directly to drive your own drawing or to test an emitter.
///
/// ```swift
/// var system = ParticleSystem(emitter: .confetti, seed: 1)
/// system.burst()
/// system.update(by: 1 / 60, in: CGSize(width: 400, height: 400))
/// print(system.particles.count) // 120
/// ```
///
/// The same seed and the same sequence of calls always give the same particles.
public struct ParticleSystem: Sendable {
    /// The emitter that describes births and motion. Changes apply to particles born afterwards,
    /// and forces and drag apply to all particles immediately.
    public var emitter: ParticleEmitter
    /// Whether particles are born continuously at the emitter's ``ParticleEmitter/birthRate``.
    public var isEmitting: Bool
    /// The living particles, oldest first.
    public private(set) var particles: [Particle] = []
    /// Seconds simulated so far.
    public private(set) var time: Double = 0

    private var generator: SplitMix64
    private var pendingBursts: [Int] = []
    private var birthDebt: Double = 0

    /// Longest step simulated at once; longer updates are split so fast particles stay stable.
    static let maximumStep = 1.0 / 60
    /// Longest update simulated; a longer pause (for example, the app in the background)
    /// continues as if this much time had passed.
    static let maximumUpdate = 0.25

    /// Creates a particle system.
    ///
    /// - Parameters:
    ///   - emitter: How particles are born and move.
    ///   - isEmitting: Whether to start emitting continuously.
    ///   - seed: Seed for the random numbers; pass a fixed value for repeatable results.
    public init(emitter: ParticleEmitter, isEmitting: Bool = false, seed: UInt64 = .random(in: .min ... .max)) {
        self.emitter = emitter
        self.isEmitting = isEmitting
        self.generator = SplitMix64(seed: seed)
    }

    /// Whether nothing is left to simulate: no living particles, no pending burst and no
    /// continuous emission.
    public var isIdle: Bool {
        particles.isEmpty && pendingBursts.isEmpty && !(isEmitting && emitter.birthRate > 0)
    }

    /// Queues a burst; the particles are born on the next ``update(by:in:)``.
    ///
    /// - Parameter count: Number of particles; `nil` uses the emitter's ``ParticleEmitter/burstCount``.
    public mutating func burst(count: Int? = nil) {
        pendingBursts.append(max(0, count ?? emitter.burstCount))
    }

    /// Removes every particle and pending burst.
    public mutating func reset() {
        particles.removeAll()
        pendingBursts.removeAll()
        birthDebt = 0
    }

    /// Advances the simulation.
    ///
    /// - Parameters:
    ///   - duration: Seconds that passed since the last update. Values above 0.25 s are
    ///     treated as 0.25 s.
    ///   - canvas: Size of the area the particles live in, in points.
    public mutating func update(by duration: Double, in canvas: CGSize) {
        for count in pendingBursts {
            spawn(count, in: canvas)
        }
        pendingBursts.removeAll()

        var remaining = min(max(duration, 0), Self.maximumUpdate)
        while remaining > 0 {
            let step = min(remaining, Self.maximumStep)
            advance(by: step, in: canvas)
            emitContinuously(during: step, in: canvas)
            remaining -= step
        }
    }

    // MARK: Births

    private mutating func emitContinuously(during step: Double, in canvas: CGSize) {
        guard isEmitting, emitter.birthRate > 0 else {
            birthDebt = 0
            return
        }
        birthDebt += emitter.birthRate * step
        let births = Int(birthDebt)
        birthDebt -= Double(births)
        for _ in 0..<births {
            guard particles.count < emitter.maxParticles else { break }
            var particle = makeParticle(in: canvas)
            // Each birth happened somewhere during the step that just ended; moving it by the
            // time since then keeps particles from leaving in visible rows.
            let sinceBirth = Double.random(in: 0..<step, using: &generator)
            move(&particle, by: sinceBirth, in: canvas)
            particles.append(particle)
        }
    }

    private mutating func spawn(_ count: Int, in canvas: CGSize) {
        let room = max(0, emitter.maxParticles - particles.count)
        for _ in 0..<min(count, room) {
            particles.append(makeParticle(in: canvas))
        }
    }

    private mutating func makeParticle(in canvas: CGSize) -> Particle {
        let origin = birthPoint(in: canvas)
        let halfSpread = emitter.spread.radians / 2
        let angle = emitter.direction.radians + (halfSpread > 0 ? Double.random(in: -halfSpread...halfSpread, using: &generator) : 0)
        let speed = sample(emitter.speed)
        let colorIndex = Int.random(in: 0..<emitter.colors.count, using: &generator)
        let shapeIndex = Int.random(in: 0..<emitter.shapes.count, using: &generator)
        return Particle(
            x: origin.x,
            y: origin.y,
            velocityX: speed * cos(angle),
            velocityY: speed * sin(angle),
            age: 0,
            lifetime: sample(emitter.lifetime),
            size: sample(emitter.size),
            rotation: emitter.alignsWithMotion ? angle : Double.random(in: 0..<(2 * .pi), using: &generator),
            spin: sample(emitter.spin),
            tumble: sample(emitter.tumble),
            colorIndex: colorIndex,
            shapeIndex: shapeIndex
        )
    }

    private mutating func birthPoint(in canvas: CGSize) -> CGPoint {
        let anchor = CGPoint(x: emitter.position.x * canvas.width, y: emitter.position.y * canvas.height)
        switch emitter.source {
        case .point:
            return anchor
        case let .circle(radius):
            let angle = Double.random(in: 0..<(2 * .pi), using: &generator)
            return CGPoint(x: anchor.x + radius * cos(angle), y: anchor.y + radius * sin(angle))
        case let .edge(edge):
            let alongWidth = Double.random(in: 0...1, using: &generator) * canvas.width
            let alongHeight = Double.random(in: 0...1, using: &generator) * canvas.height
            switch edge {
            case .top: return CGPoint(x: alongWidth, y: 0)
            case .bottom: return CGPoint(x: alongWidth, y: canvas.height)
            case .leading: return CGPoint(x: 0, y: alongHeight)
            case .trailing: return CGPoint(x: canvas.width, y: alongHeight)
            }
        case .area:
            return CGPoint(
                x: Double.random(in: 0...1, using: &generator) * canvas.width,
                y: Double.random(in: 0...1, using: &generator) * canvas.height
            )
        }
    }

    private mutating func sample(_ range: ClosedRange<Double>) -> Double {
        range.lowerBound == range.upperBound ? range.lowerBound : Double.random(in: range, using: &generator)
    }

    // MARK: Motion

    private mutating func advance(by step: Double, in canvas: CGSize) {
        time += step
        for index in particles.indices {
            move(&particles[index], by: step, in: canvas)
        }
        particles.removeAll(where: \.isExpired)
    }

    /// Semi-implicit Euler: velocity first, then position with the new velocity.
    private func move(_ particle: inout Particle, by step: Double, in canvas: CGSize) {
        var accelerationX = 0.0
        var accelerationY = 0.0
        for force in emitter.forces {
            let acceleration = force.acceleration(for: particle, time: time, canvas: canvas)
            accelerationX += acceleration.x
            accelerationY += acceleration.y
        }
        particle.velocityX += accelerationX * step
        particle.velocityY += accelerationY * step
        if emitter.drag > 0 {
            let kept = exp(-emitter.drag * step)
            particle.velocityX *= kept
            particle.velocityY *= kept
        }
        particle.x += particle.velocityX * step
        particle.y += particle.velocityY * step
        if emitter.alignsWithMotion {
            particle.rotation = atan2(particle.velocityY, particle.velocityX)
        } else {
            particle.rotation += particle.spin * step
        }
        particle.age += step
    }
}

/// SplitMix64: a small, fast generator with a 64-bit state, so a seed fully determines the
/// sequence on every platform.
struct SplitMix64: RandomNumberGenerator, Sendable {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var mixed = state
        mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
        mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
        return mixed ^ (mixed >> 31)
    }
}
