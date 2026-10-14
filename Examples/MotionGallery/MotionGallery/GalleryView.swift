import SwiftUI
import SwiftUIAnimationMasterclass

/// Lists every sample. Launching the app with `-sample <case name>` opens one directly, which
/// is how scripts/capture-example-screens.sh takes its screenshots.
struct GalleryView: View {
    enum Sample: String, CaseIterable, Identifiable {
        case showcase = "Showcase"
        case physics = "Physics lab"
        case particles = "Particles"
        case effects = "Change effects"
        case transitions = "Transitions"
        case gestures = "Gestures"
        case quickStart = "Quick start"
        case dropBadge = "Gravity bounce"
        case orderButton = "Confetti burst"
        case winter = "Snow"
        case password = "Shake on error"
        case photo = "Iris transition"
        case panel = "Pull-up panel"
        case parallax = "Parallax"
        case stardust = "Custom emitter"

        var id: Self { self }

        /// The sample whose case name is `name`, such as `"particles"`.
        static func named(_ name: String) -> Sample? {
            allCases.first { String(describing: $0) == name }
        }

        var systemImage: String {
            switch self {
            case .showcase: "sparkles.rectangle.stack"
            case .physics: "function"
            case .particles: "sparkles"
            case .effects: "bell.badge"
            case .transitions: "rectangle.on.rectangle.angled"
            case .gestures: "hand.draw"
            case .quickStart: "heart"
            case .dropBadge: "arrow.down.to.line"
            case .orderButton: "party.popper"
            case .winter: "snowflake"
            case .password: "lock"
            case .photo: "circle.dashed"
            case .panel: "rectangle.bottomhalf.filled"
            case .parallax: "mountain.2"
            case .stardust: "star"
            }
        }

        @MainActor @ViewBuilder
        var screen: some View {
            switch self {
            case .showcase: AnimationShowcase()
            case .physics: PhysicsLab()
            case .particles: ParticlePlayground()
            case .effects: EffectsBoard()
            case .transitions: TransitionsBoard()
            case .gestures: GestureBoard()
            case .quickStart: LikeButton().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .dropBadge: DropBadge().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .orderButton: OrderButton().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .winter: WinterScene()
            case .password: PasswordField().padding()
            case .photo: PhotoReveal().padding()
            case .panel: PullUpPanel().padding().frame(maxHeight: .infinity, alignment: .top)
            case .parallax: ParallaxArticle()
            case .stardust: StardustView()
            }
        }
    }

    @State private var path: [Sample] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(Sample.allCases) { sample in
                NavigationLink(value: sample) {
                    Label(sample.rawValue, systemImage: sample.systemImage)
                }
            }
            .navigationTitle("Motion Gallery")
            .navigationDestination(for: Sample.self) { sample in
                sample.screen
                    .navigationTitle(sample.rawValue)
            }
        }
        .tint(.blue)
        .onAppear(perform: openRequestedSample)
    }

    private func openRequestedSample() {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flag = arguments.firstIndex(of: "-sample"), flag + 1 < arguments.count,
              let sample = Sample.named(arguments[flag + 1]) else { return }
        path = [sample]
    }
}
