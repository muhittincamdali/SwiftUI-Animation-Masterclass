import SwiftUI

/// A view that runs a ``ParticleSystem`` and draws it every frame.
///
/// All particles are drawn into one `Canvas`, so hundreds of particles cost one view. The
/// animation clock only runs while there is something to draw.
///
/// ```swift
/// ZStack {
///     Color.indigo
///     ParticleView(.snow)
/// }
/// ```
///
/// Most of the time the modifiers are simpler: ``SwiftUICore/View/particleEffect(_:isActive:)``
/// for continuous effects and ``SwiftUICore/View/particleBurst(_:trigger:)`` for one-off bursts.
///
/// With Reduce Motion on, the view draws nothing.
public struct ParticleView: View {
    private let emitter: ParticleEmitter
    private let isEmitting: Bool
    private let bursts: Int

    @State private var model = ParticleModel()
    @State private var isRunning = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates a particle view.
    ///
    /// - Parameters:
    ///   - emitter: How particles are born, move and look.
    ///   - isEmitting: Whether particles are born continuously at the emitter's
    ///     ``ParticleEmitter/birthRate``. Particles already alive finish their lives when this
    ///     turns off.
    ///   - bursts: A counter; each time it changes, the view emits one burst of
    ///     ``ParticleEmitter/burstCount`` particles.
    public init(_ emitter: ParticleEmitter, isEmitting: Bool = true, bursts: Int = 0) {
        self.emitter = emitter
        self.isEmitting = isEmitting
        self.bursts = bursts
    }

    private var emits: Bool { isEmitting && !reduceMotion }

    public var body: some View {
        TimelineView(.animation(paused: !isRunning)) { timeline in
            Canvas { context, size in
                model.advance(to: timeline.date, canvas: size)
                ParticleRenderer.draw(model.system.particles, emitter: emitter, in: &context)
                if model.system.isIdle && isRunning {
                    Task { @MainActor in
                        if model.system.isIdle { isRunning = false }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            model.system.emitter = emitter
            setEmitting(emits)
        }
        .onChange(of: emitter) {
            model.system.emitter = emitter
        }
        .onChange(of: emits) {
            setEmitting(emits)
        }
        .onChange(of: bursts) {
            guard !reduceMotion else { return }
            model.system.burst()
            start()
        }
        .onChange(of: reduceMotion) {
            if reduceMotion { model.system.reset() }
        }
    }

    private func setEmitting(_ on: Bool) {
        model.system.isEmitting = on
        if on { start() }
    }

    private func start() {
        if !isRunning {
            model.lastDate = nil
            isRunning = true
        }
    }
}

/// Holds the simulation between frames. It is a class so the `Canvas` closure can advance it
/// without causing another view update.
@MainActor
final class ParticleModel {
    var system = ParticleSystem(emitter: ParticleEmitter())
    var lastDate: Date?

    func advance(to date: Date, canvas: CGSize) {
        let elapsed = lastDate.map { date.timeIntervalSince($0) } ?? 0
        lastDate = date
        system.update(by: elapsed, in: canvas)
    }
}

public extension View {
    /// Draws a continuous particle effect, such as snow or embers, over the view.
    ///
    /// ```swift
    /// Image("cabin")
    ///     .particleEffect(.snow)
    /// ```
    ///
    /// The particles fill the view's frame and do not take touches. With Reduce Motion on,
    /// nothing is drawn.
    ///
    /// - Parameters:
    ///   - emitter: The effect; see the presets on ``ParticleEmitter``.
    ///   - isActive: Whether new particles are born. Turning it off lets the living ones finish.
    func particleEffect(_ emitter: ParticleEmitter, isActive: Bool = true) -> some View {
        overlay {
            ParticleView(emitter, isEmitting: isActive)
        }
    }

    /// Emits a burst of particles from the view every time `trigger` changes.
    ///
    /// ```swift
    /// Button("Like", systemImage: "heart.fill") { likes += 1 }
    ///     .particleBurst(.hearts, trigger: likes)
    /// ```
    ///
    /// The particles are drawn in a square of twice the emitter's ``ParticleEmitter/reach``
    /// centered on the view, so they can fly past its edges; place the view above its
    /// neighbours (for example with `zIndex`) if they would cover the particles. With Reduce
    /// Motion on, nothing is drawn.
    ///
    /// - Parameters:
    ///   - emitter: The burst; see the presets on ``ParticleEmitter``.
    ///   - trigger: Any value; each change starts a burst.
    func particleBurst(_ emitter: ParticleEmitter, trigger: some Equatable) -> some View {
        modifier(ParticleBurstModifier(emitter: emitter, trigger: trigger))
    }
}

struct ParticleBurstModifier<Trigger: Equatable>: ViewModifier {
    let emitter: ParticleEmitter
    let trigger: Trigger
    @State private var bursts = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                ParticleView(emitter, isEmitting: false, bursts: bursts)
                    .frame(width: emitter.reach * 2, height: emitter.reach * 2)
            }
            .onChange(of: trigger) {
                bursts &+= 1
            }
    }
}
