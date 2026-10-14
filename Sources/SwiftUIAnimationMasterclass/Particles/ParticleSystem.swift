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
    /// Particles queued by ``burst(count:)``, never more than ``capacity``.
    private var pendingBirths = 0
    private var birthDebt: Double = 0

    /// Most particles a system keeps alive, whatever ``ParticleEmitter/maxParticles`` says.
    /// It bounds memory and the work per frame.
    public static let particleLimit = 10_000

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
        particles.isEmpty && pendingBirths == 0 && !(isEmitting && emitter.birthRate > 0)
    }

    /// Most particles alive at once: ``ParticleEmitter/maxParticles``, at most ``particleLimit``.
    public var capacity: Int { min(max(0, emitter.maxParticles), Self.particleLimit) }

    /// Queues a burst; the particles are born on the next ``update(by:in:)``.
    ///
    /// Bursts queued before the next update add up, but never beyond ``capacity``.
    ///
    /// - Parameter count: Number of particles; `nil` uses the emitter's ``ParticleEmitter/burstCount``.
    public mutating func burst(count: Int? = nil) {
        let requested = min(max(0, count ?? emitter.burstCount), capacity)
        pendingBirths = min(pendingBirths + requested, capacity)
    }

    /// Removes every particle and pending burst.
    public mutating func reset() {
        particles.removeAll()
        pendingBirths = 0
        birthDebt = 0
    }

    /// Advances the simulation.
    ///
    /// - Parameters:
    ///   - duration: Seconds that passed since the last update. Values above 0.25 s, infinity
    ///     included, are treated as 0.25 s; negative values and NaN as 0.
    ///   - canvas: Size of the area the particles live in, in points. A negative or
    ///     non-finite dimension counts as 0.
    public mutating func update(by duration: Double, in canvas: CGSize) {
        let canvas = CGSize(
            width: max(0, Self.finiteOrZero(canvas.width)),
            height: max(0, Self.finiteOrZero(canvas.height))
        )
        spawn(pendingBirths, in: canvas)
        pendingBirths = 0

        // `max(0, .nan)` is 0, so a NaN duration simulates nothing.
        var remaining = min(max(0, duration), Self.maximumUpdate)
        while remaining > 0 {
            let step = min(remaining, Self.maximumStep)
            advance(by: step, in: canvas)
            emitContinuously(during: step, in: canvas)
            remaining -= step
        }
    }

    // MARK: Births

    private mutating func emitContinuously(during step: Double, in canvas: CGSize) {
        let rate = emitter.birthRate
        guard isEmitting, rate.isFinite, rate > 0 else {
            birthDebt = 0
            return
        }
        birthDebt += rate * step
        let room = max(0, capacity - particles.count)
        // Bounded by `room` before the conversion, so a huge rate cannot overflow `Int`.
        let births = Int(min(birthDebt, Double(room)))
        // A full system skips births instead of owing them, so no flood follows when room frees up.
        birthDebt = min(birthDebt - Double(births), 1)
        for _ in 0..<births {
            var particle = makeParticle(in: canvas)
            // Each birth happened somewhere during the step that just ended; moving it by the
            // time since then keeps particles from leaving in visible rows.
            let sinceBirth = Double.random(in: 0..<step, using: &generator)
            move(&particle, by: sinceBirth, in: canvas)
            particles.append(particle)
        }
    }

    private mutating func spawn(_ count: Int, in canvas: CGSize) {
        let room = max(0, capacity - particles.count)
        for _ in 0..<min(count, room) {
            particles.append(makeParticle(in: canvas))
        }
    }

    private mutating func makeParticle(in canvas: CGSize) -> Particle {
        let origin = birthPoint(in: canvas)
        let halfSpread = min(Self.finiteOrZero(emitter.spread.radians / 2), .pi)
        let angle = Self.finiteOrZero(emitter.direction.radians)
            + (halfSpread > 0 ? Double.random(in: -halfSpread...halfSpread, using: &generator) : 0)
        let speed = sample(emitter.speed)
        let colorIndex = index(below: emitter.colors.count)
        let shapeIndex = index(below: emitter.shapes.count)
        let lifetime = sample(emitter.lifetime)
        return Particle(
            x: origin.x,
            y: origin.y,
            velocityX: speed * cos(angle),
            velocityY: speed * sin(angle),
            age: 0,
            // A zero or negative lifetime ends the particle on the next step.
            lifetime: max(0, lifetime),
            size: sample(emitter.size),
            rotation: emitter.alignsWithMotion ? angle : Double.random(in: 0..<(2 * .pi), using: &generator),
            spin: sample(emitter.spin),
            tumble: sample(emitter.tumble),
            colorIndex: colorIndex,
            shapeIndex: shapeIndex
        )
    }

    private mutating func birthPoint(in canvas: CGSize) -> CGPoint {
        let anchor = CGPoint(
            x: Self.finiteOrZero(emitter.position.x) * canvas.width,
            y: Self.finiteOrZero(emitter.position.y) * canvas.height
        )
        switch emitter.source {
        case .point:
            return anchor
        case let .circle(radius):
            let radius = Self.finiteOrZero(radius)
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

    /// A uniform sample of `range`. `Double.random(in:)` traps on infinite bounds or an
    /// infinite width, so a range with one infinite bound gives its finite end, a range too wide
    /// to measure gives its midpoint, and a range with no finite bound gives 0.
    private mutating func sample(_ range: ClosedRange<Double>) -> Double {
        let lower = range.lowerBound
        let upper = range.upperBound
        guard lower.isFinite, upper.isFinite else {
            return lower.isFinite ? lower : Self.finiteOrZero(upper)
        }
        guard (upper - lower).isFinite else { return lower / 2 + upper / 2 }
        return lower == upper ? lower : Double.random(in: range, using: &generator)
    }

    /// A random index below `count`, or 0 when `count` is 0 (the renderer then skips the particle).
    private mutating func index(below count: Int) -> Int {
        count > 0 ? Int.random(in: 0..<count, using: &generator) : 0
    }

    static func finiteOrZero(_ value: Double) -> Double {
        value.isFinite ? value : 0
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
        // A force with extreme parameters must not turn the particle's state into NaN.
        if !accelerationX.isFinite { accelerationX = 0 }
        if !accelerationY.isFinite { accelerationY = 0 }
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
