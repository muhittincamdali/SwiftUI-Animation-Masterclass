import SwiftUI

public extension ParticleEmitter {
    /// Paper strips and shapes that shoot up, tumble and fall. Made for
    /// ``SwiftUICore/View/particleBurst(_:trigger:)``.
    static let confetti = ParticleEmitter(
        burstCount: 120,
        lifetime: 2.4...3.4,
        speed: 420...880,
        direction: .degrees(-90),
        spread: .degrees(75),
        size: 7...12,
        spin: -7...7,
        tumble: 6...16,
        drag: 1.4,
        forces: [.gravity(820), .turbulence(strength: 90, scale: 90)],
        colors: [.blue, .cyan, .yellow, .pink, .orange, .green, .purple],
        shapes: [.rectangle(aspectRatio: 0.45), .rectangle(aspectRatio: 0.45), .circle, .triangle],
        fadeOutStart: 0.8,
        reach: 340
    )

    /// A ring of glowing sparks that bursts outward, slows down and drifts downward.
    static let fireworks = ParticleEmitter(
        burstCount: 140,
        lifetime: 1.2...2.0,
        speed: 140...420,
        spread: .degrees(360),
        size: 3...5,
        endScale: 0.3,
        drag: 1.8,
        forces: [.gravity(200)],
        colors: [.yellow, .orange, .pink, .cyan, .white],
        fadeOutStart: 0.55,
        blending: .additive,
        reach: 260
    )

    /// Flakes that drift down from the top edge and sway. Made for
    /// ``SwiftUICore/View/particleEffect(_:isActive:)``.
    static let snow = ParticleEmitter(
        source: .edge(.top),
        birthRate: 24,
        maxParticles: 400,
        lifetime: 9...13,
        speed: 25...60,
        direction: .degrees(90),
        spread: .degrees(30),
        size: 3...7,
        forces: [.gravity(6), .turbulence(strength: 28, scale: 110)],
        colors: [.white, Color(white: 0.92)],
        fadeIn: 0.03,
        fadeOutStart: 0.85
    )

    /// Fast, slanted streaks that fall from the top edge.
    static let rain = ParticleEmitter(
        source: .edge(.top),
        birthRate: 110,
        lifetime: 0.9...1.3,
        speed: 650...850,
        direction: .degrees(100),
        spread: .degrees(4),
        size: 1.5...2,
        alignsWithMotion: true,
        forces: [.gravity(500)],
        colors: [Color(red: 0.55, green: 0.72, blue: 0.95).opacity(0.75)],
        shapes: [.rectangle(aspectRatio: 9)],
        fadeOutStart: 0.9
    )

    /// Stars that appear anywhere in the view, twinkle and shrink away.
    static let sparkles = ParticleEmitter(
        source: .area,
        birthRate: 16,
        maxParticles: 80,
        lifetime: 0.8...1.4,
        speed: 0...12,
        size: 9...18,
        endScale: 0.2,
        spin: -1.5...1.5,
        colors: [.yellow, .white, Color(red: 1, green: 0.85, blue: 0.4)],
        shapes: [.star],
        fadeIn: 0.25,
        fadeOutStart: 0.5,
        blending: .additive
    )

    /// Bubbles that rise from the bottom edge and wobble.
    static let bubbles = ParticleEmitter(
        source: .edge(.bottom),
        birthRate: 5,
        maxParticles: 60,
        lifetime: 4...7,
        speed: 30...70,
        direction: .degrees(-90),
        spread: .degrees(20),
        size: 10...26,
        forces: [.gravity(-12), .turbulence(strength: 30, scale: 70)],
        colors: [.cyan.opacity(0.8), .blue.opacity(0.6), .white.opacity(0.7)],
        shapes: [.ring],
        fadeIn: 0.05,
        fadeOutStart: 0.8
    )

    /// Hearts that float up and away, like a like button reaction.
    static let hearts = ParticleEmitter(
        burstCount: 18,
        lifetime: 1.1...1.7,
        speed: 140...300,
        direction: .degrees(-90),
        spread: .degrees(70),
        size: 12...22,
        endScale: 0.6,
        spin: -1...1,
        drag: 1.6,
        forces: [.gravity(-60)],
        colors: [.pink, .red, Color(red: 1, green: 0.45, blue: 0.6)],
        shapes: [.symbol("heart.fill")],
        fadeOutStart: 0.6,
        reach: 200
    )

    /// Glowing embers that rise from the bottom edge and swirl, like a campfire.
    static let embers = ParticleEmitter(
        source: .edge(.bottom),
        birthRate: 36,
        maxParticles: 200,
        lifetime: 1.6...3.0,
        speed: 50...130,
        direction: .degrees(-90),
        spread: .degrees(30),
        size: 2...4.5,
        endScale: 0.2,
        forces: [.gravity(-35), .turbulence(strength: 70, scale: 80)],
        colors: [.orange, .yellow, .red],
        fadeIn: 0.1,
        fadeOutStart: 0.5,
        blending: .additive
    )

    /// Every preset with its name, in the order they are documented.
    static let presets: [(name: String, emitter: ParticleEmitter)] = [
        ("confetti", .confetti),
        ("fireworks", .fireworks),
        ("snow", .snow),
        ("rain", .rain),
        ("sparkles", .sparkles),
        ("bubbles", .bubbles),
        ("hearts", .hearts),
        ("embers", .embers),
    ]
}
