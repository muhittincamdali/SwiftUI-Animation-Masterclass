import SwiftUI
import SwiftUIAnimationMasterclass

/// Plots a spring with adjustable response and damping, and drops a ball with adjustable
/// restitution, so the parameters can be compared with the curves they produce.
struct PhysicsLab: View {
    @State private var response = 0.45
    @State private var dampingRatio = 0.5
    @State private var restitution = 0.5
    @State private var isDropped = false

    private var spring: DampedSpring { DampedSpring(response: response, dampingRatio: dampingRatio) }

    var body: some View {
        Form {
            Section("Spring") {
                SpringCurve(spring: spring)
                    .frame(height: 140)
                LabeledContent("Response", value: response, format: .number.precision(.fractionLength(2)))
                Slider(value: $response, in: 0.15...1.2)
                LabeledContent("Damping ratio", value: dampingRatio, format: .number.precision(.fractionLength(2)))
                Slider(value: $dampingRatio, in: 0.1...1.5)
                LabeledContent(
                    "Settles after",
                    value: spring.settlingDuration(initialDisplacement: 1, initialVelocity: 0, tolerance: 0.005),
                    format: .number.precision(.fractionLength(2))
                )
            }
            Section("Gravity bounce") {
                HStack {
                    Circle()
                        .fill(.blue.gradient)
                        .frame(width: 36, height: 36)
                        .offset(y: isDropped ? 70 : -70)
                        .animation(.gravityBounce(restitution: restitution), value: isDropped)
                    Spacer()
                    Button(isDropped ? "Lift" : "Drop") { isDropped.toggle() }
                        .buttonStyle(.borderedProminent)
                }
                .frame(height: 180)
                LabeledContent("Restitution", value: restitution, format: .number.precision(.fractionLength(2)))
                Slider(value: $restitution, in: 0...0.9)
            }
        }
    }
}

/// The displacement of `spring` from 1 to its target over 1.5 seconds.
struct SpringCurve: View {
    let spring: DampedSpring

    var body: some View {
        Canvas { context, size in
            let duration = 1.5
            var curve = Path()
            for step in 0...120 {
                let time = duration * Double(step) / 120
                let value = spring.value(from: 0, to: 1, at: time)
                let point = CGPoint(x: size.width * time / duration, y: size.height * (0.85 - 0.6 * value))
                step == 0 ? curve.move(to: point) : curve.addLine(to: point)
            }
            let target = size.height * 0.25
            context.stroke(Path { $0.move(to: CGPoint(x: 0, y: target)); $0.addLine(to: CGPoint(x: size.width, y: target)) },
                           with: .color(.secondary), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            context.stroke(curve, with: .color(.blue), lineWidth: 2.5)
        }
        .accessibilityLabel("Spring curve")
    }
}

/// Every particle preset, continuous ones running and burst ones on a button.
struct ParticlePlayground: View {
    @State private var preset = "confetti"
    @State private var bursts = 0

    private var emitter: ParticleEmitter {
        ParticleEmitter.presets.first { $0.name == preset }?.emitter ?? .confetti
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Preset", selection: $preset) {
                ForEach(ParticleEmitter.presets, id: \.name) { Text($0.name.capitalized).tag($0.name) }
            }
            .pickerStyle(.menu)
            .padding()

            ZStack {
                LinearGradient(colors: [Color(red: 0.04, green: 0.1, blue: 0.3), .blue], startPoint: .top, endPoint: .bottom)
                if emitter.birthRate > 0 {
                    ParticleView(emitter)
                        .id(preset)
                } else {
                    ParticleView(emitter, isEmitting: false, bursts: bursts)
                        .id(preset)
                    Button("Burst") { bursts += 1 }
                        .buttonStyle(.borderedProminent)
                        .tint(.white.opacity(0.25))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 32)
                }
            }
            .clipShape(.rect(cornerRadius: 20))
            .padding()
        }
    }
}

/// One tile per change effect; tapping a tile plays its effect.
struct EffectsBoard: View {
    private let effects: [(name: String, symbol: String, effect: ChangeEffect)] = [
        ("Shake", "lock.fill", .shake()),
        ("Jump", "bell.fill", .jump()),
        ("Spin", "arrow.triangle.2.circlepath", .spin()),
        ("Pulse", "heart.fill", .pulse()),
        ("Ping", "dot.radiowaves.left.and.right", .ping()),
        ("Shine", "star.fill", .shine),
    ]
    @State private var taps = [Int](repeating: 0, count: 6)

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 20)], spacing: 28) {
            ForEach(effects.indices, id: \.self) { index in
                Button { taps[index] += 1 } label: {
                    VStack(spacing: 10) {
                        Image(systemName: effects[index].symbol)
                            .font(.system(size: 34))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(.blue.gradient, in: .rect(cornerRadius: 18))
                            .changeEffect(effects[index].effect, value: taps[index])
                        Text(effects[index].name).font(.callout)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

/// Shows and hides a card with the transition of your choice.
struct TransitionsBoard: View {
    private enum Kind: String, CaseIterable, Identifiable {
        case iris = "Iris", wipe = "Wipe", flip = "Flip", pop = "Pop"
        var id: Self { self }
    }

    @State private var kind = Kind.iris
    @State private var isShown = true

    var body: some View {
        VStack(spacing: 24) {
            Picker("Transition", selection: $kind) {
                ForEach(Kind.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            ZStack {
                if isShown {
                    card.transition(transition)
                }
            }
            .frame(height: 220)

            Button(isShown ? "Hide" : "Show") {
                withAnimation(kind == .pop ? .bouncy : .smooth(duration: 0.6)) { isShown.toggle() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.blue.gradient)
            .frame(width: 220, height: 200)
            .overlay { Image(systemName: "photo.fill").font(.system(size: 64)).foregroundStyle(.white) }
    }

    private var transition: AnyTransition {
        switch kind {
        case .iris: AnyTransition(.iris())
        case .wipe: AnyTransition(.wipe(from: .leading))
        case .flip: AnyTransition(.flip())
        case .pop: AnyTransition(.pop)
        }
    }
}

/// An elastic card and a horizontal carousel that snaps between pages.
struct GestureBoard: View {
    @State private var page = 0

    var body: some View {
        VStack(spacing: 40) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.blue.gradient)
                .frame(width: 180, height: 120)
                .overlay { Text("Pull me").font(.headline).foregroundStyle(.white) }
                .elasticDrag()

            GeometryReader { proxy in
                let width = proxy.size.width
                HStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.blue.opacity(0.25 + 0.25 * Double(index)))
                            .overlay { Text("Page \(index + 1)").font(.title2.bold()) }
                            .padding(.horizontal, 12)
                            .frame(width: width)
                    }
                }
                .snapDrag(.horizontal, offsets: [0, -width, -2 * width], selection: $page)
            }
            .frame(height: 160)
            .clipped()

            Text("Page \(page + 1) of 3").foregroundStyle(.secondary)
        }
        .padding(.vertical, 32)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
