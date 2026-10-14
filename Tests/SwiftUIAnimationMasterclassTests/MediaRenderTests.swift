import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import SwiftUIAnimationMasterclass

/// Renders the README animations frame by frame from the package's own simulation and effect
/// code. Runs only when SCREENSHOT_DIR is set; see scripts/render-readme-media.sh.
@MainActor
@Suite("README media", .enabled(if: ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] != nil))
struct MediaRenderTests {
    private static let size = CGSize(width: 720, height: 420)
    private static let framesPerSecond = 25.0

    private var outputDirectory: URL {
        URL(fileURLWithPath: ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] ?? ".")
    }

    @Test(arguments: MediaTheme.allCases)
    func particles(theme: MediaTheme) throws {
        let size = CGSize(width: Self.size.width, height: 520)
        let tileSize = CGSize(width: size.width / 2 - 18, height: size.height / 2 - 18)
        var confetti = ParticleEmitter.confetti
        confetti.position = .bottom // launched from the bottom so the whole arc fits in the tile
        var tiles = [
            ParticleTile(name: "Confetti burst", emitter: confetti, theme: theme, seed: 1, canvas: tileSize),
            ParticleTile(name: "Fireworks", emitter: .fireworks, theme: theme, seed: 2, canvas: tileSize),
            ParticleTile(name: "Snow", emitter: .snow, theme: theme, seed: 3, canvas: tileSize),
            ParticleTile(name: "Embers", emitter: .embers, theme: theme, seed: 4, canvas: tileSize),
        ]
        let frameCount = 75
        var frames: [CGImage] = []
        for frame in 0..<frameCount {
            if frame == 0 || frame == 40 {
                tiles[0].system.burst()
                tiles[1].system.burst()
            }
            for index in tiles.indices {
                tiles[index].system.update(by: 1 / Self.framesPerSecond, in: tileSize)
            }
            let grid = Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow { tiles[0].view(size: tileSize); tiles[1].view(size: tileSize) }
                GridRow { tiles[2].view(size: tileSize); tiles[3].view(size: tileSize) }
            }
            frames.append(try render(grid, theme: theme, size: size))
        }
        try writeGIF(frames, name: "particles-\(theme.rawValue)")
    }

    @Test(arguments: MediaTheme.allCases)
    func changeEffects(theme: MediaTheme) throws {
        let effects: [(String, String, ChangeEffect)] = [
            ("shake", "lock.fill", .shake()), ("jump", "bell.fill", .jump()),
            ("spin", "arrow.triangle.2.circlepath", .spin()), ("pulse", "heart.fill", .pulse()),
            ("ping", "dot.radiowaves.left.and.right", .ping()), ("shine", "star.fill", .shine),
        ]
        let cycle = 1.6
        var frames: [CGImage] = []
        for frame in 0..<Int(cycle * Self.framesPerSecond) {
            let time = Double(frame) / Self.framesPerSecond - 0.2
            let grid = LazyVGrid(columns: Array(repeating: GridItem(.fixed(200)), count: 3), spacing: 36) {
                ForEach(effects, id: \.0) { name, symbol, effect in
                    VStack(spacing: 14) {
                        Image(systemName: symbol)
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                            .frame(width: 84, height: 84)
                            .background(theme.accent.gradient, in: .rect(cornerRadius: 20))
                            .modifier(ChangeEffectFrame(state: effect.state(at: time / effect.duration)))
                        Text(".\(name)").font(.system(size: 17, design: .monospaced)).foregroundStyle(theme.text)
                    }
                    .frame(height: 150)
                }
            }
            frames.append(try render(grid, theme: theme))
        }
        try writeGIF(frames, name: "effects-\(theme.rawValue)")
    }

    @Test(arguments: MediaTheme.allCases)
    func physics(theme: MediaTheme) throws {
        let bounce = GravityBounceAnimation(fallDuration: 0.45, restitution: 0.55)
        let spring = DampedSpring.bouncy
        let decay = Decay.normal
        let flick = 900.0
        let travel = decay.projectedDistance(initialVelocity: flick)
        let duration = 2.2
        var frames: [CGImage] = []
        for frame in 0..<Int(duration * Self.framesPerSecond) {
            let time = max(0, Double(frame) / Self.framesPerSecond - 0.2)
            let panels = HStack(spacing: 12) {
                PhysicsPanel(title: ".gravityBounce()", theme: theme) { size in
                    CGPoint(x: size.width / 2, y: 30 + (size.height - 80) * bounce.progress(at: time))
                }
                PhysicsPanel(title: "DampedSpring.bouncy", theme: theme) { size in
                    CGPoint(x: size.width / 2, y: size.height / 2 + spring.displacement(at: time, initialDisplacement: -120, initialVelocity: 0))
                }
                PhysicsPanel(title: "Decay.normal", theme: theme) { size in
                    let distance = decay.distance(at: time, initialVelocity: flick)
                    return CGPoint(x: 30 + (size.width - 60) * distance / travel, y: size.height / 2)
                }
            }
            frames.append(try render(panels, theme: theme))
        }
        try writeGIF(frames, name: "physics-\(theme.rawValue)")
    }

    // MARK: Rendering

    private func render(_ content: some View, theme: MediaTheme, size: CGSize = MediaRenderTests.size) throws -> CGImage {
        let view = content
            .frame(width: size.width, height: size.height)
            .background(theme.background)
            .environment(\.colorScheme, theme.colorScheme)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        return try #require(renderer.cgImage)
    }

    private func writeGIF(_ frames: [CGImage], name: String) throws {
        let url = outputDirectory.appendingPathComponent("\(name).gif")
        let destination = try #require(CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, frames.count, nil))
        let fileProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary
        CGImageDestinationSetProperties(destination, fileProperties)
        let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1 / Self.framesPerSecond]] as CFDictionary
        for frame in frames {
            CGImageDestinationAddImage(destination, frame, frameProperties)
        }
        #expect(CGImageDestinationFinalize(destination))
    }
}

/// The repository kit's blue palette in light and dark.
enum MediaTheme: String, CaseIterable, Sendable {
    case light, dark

    var colorScheme: ColorScheme { self == .light ? .light : .dark }
    var background: Color { self == .light ? Color(hex: 0xFFFFFF) : Color(hex: 0x0D1117) }
    var surface: Color { self == .light ? Color(hex: 0xEAF4FF) : Color(hex: 0x0B1626) }
    var text: Color { self == .light ? Color(hex: 0x0B1F33) : Color(hex: 0xE6EDF3) }
    var muted: Color { self == .light ? Color(hex: 0x5A6B80) : Color(hex: 0x8FA3BC) }
    var accent: Color { self == .light ? Color(hex: 0x0071E3) : Color(hex: 0x0A84FF) }
    var sky: Color { self == .light ? Color(hex: 0x5AC8FA) : Color(hex: 0x64D2FF) }
    var deep: Color { Color(hex: 0x003A85) }
}

private extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}

/// One particle preset in a tile, recolored with the palette (the README shows how).
@MainActor
private struct ParticleTile {
    let name: String
    var system: ParticleSystem
    let theme: MediaTheme

    init(name: String, emitter: ParticleEmitter, theme: MediaTheme, seed: UInt64, canvas: CGSize) {
        var emitter = emitter
        emitter.colors = [theme.accent, theme.sky, .white, Color(hex: 0x8CC4FF)]
        self.name = name
        self.theme = theme
        system = ParticleSystem(emitter: emitter, isEmitting: true, seed: seed)
        // Continuous effects start already running instead of filling up on camera.
        if emitter.birthRate > 0 {
            for _ in 0..<Int(emitter.lifetime.upperBound * 25) {
                system.update(by: 1.0 / 25, in: canvas)
            }
        }
    }

    func view(size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: [theme.deep, Color(hex: 0x04111F)], startPoint: .top, endPoint: .bottom)
            ParticleSnapshot(particles: system.particles, emitter: system.emitter)
            Text(name).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white.opacity(0.85)).padding(12)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(.rect(cornerRadius: 16))
    }
}

/// A dot moved by a physics model, with its title.
private struct PhysicsPanel: View {
    let title: String
    let theme: MediaTheme
    let position: (CGSize) -> CGPoint

    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { proxy in
                Circle()
                    .fill(theme.accent.gradient)
                    .frame(width: 40, height: 40)
                    .position(position(proxy.size))
            }
            .background(theme.surface, in: .rect(cornerRadius: 16))
            Text(title).font(.system(size: 15, design: .monospaced)).foregroundStyle(theme.text)
        }
        .padding(.vertical, 16)
        .frame(width: 228)
    }
}
