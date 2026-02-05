//
//  ParticleEffects.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Particle Types

/// Types of particle effects
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum ParticleEffectType: String, CaseIterable, Sendable {
    case confetti
    case snow
    case rain
    case stars
    case hearts
    case bubbles
    case sparks
    case fireflies
    case explosion
    case smoke
}

// MARK: - Particle

/// Individual particle data
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct Particle: Identifiable {
    public let id = UUID()
    public var x: CGFloat
    public var y: CGFloat
    public var scale: CGFloat
    public var opacity: Double
    public var rotation: Double
    public var velocity: CGPoint
    public var color: Color
    public var lifetime: Double
    public var age: Double = 0
    
    public init(
        x: CGFloat = 0,
        y: CGFloat = 0,
        scale: CGFloat = 1,
        opacity: Double = 1,
        rotation: Double = 0,
        velocity: CGPoint = .zero,
        color: Color = .white,
        lifetime: Double = 1
    ) {
        self.x = x
        self.y = y
        self.scale = scale
        self.opacity = opacity
        self.rotation = rotation
        self.velocity = velocity
        self.color = color
        self.lifetime = lifetime
    }
}

// MARK: - Particle Emitter

/// High-performance particle emitter
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public class ParticleEmitter: ObservableObject {
    
    @Published public var particles: [Particle] = []
    
    public var emissionRate: Double = 10
    public var particleLifetime: Double = 2
    public var gravity: CGPoint = CGPoint(x: 0, y: 100)
    public var spread: CGFloat = 360
    public var speed: ClosedRange<CGFloat> = 50...150
    public var scale: ClosedRange<CGFloat> = 0.5...1.5
    public var colors: [Color] = [.red, .blue, .green, .yellow, .purple]
    
    private var timer: Timer?
    private var displayLink: CADisplayLink?
    
    public init() {}
    
    public func start() {
        // Emit particles at rate
        timer = Timer.scheduledTimer(withTimeInterval: 1 / emissionRate, repeats: true) { [weak self] _ in
            self?.emitParticle()
        }
        
        // Update particles every frame
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
        displayLink?.invalidate()
        displayLink = nil
    }
    
    public func burst(count: Int, at position: CGPoint) {
        for _ in 0..<count {
            emitParticle(at: position)
        }
    }
    
    private func emitParticle(at position: CGPoint? = nil) {
        let angle = CGFloat.random(in: 0...spread) * .pi / 180
        let velocity = CGFloat.random(in: speed)
        
        let particle = Particle(
            x: position?.x ?? CGFloat.random(in: 0...300),
            y: position?.y ?? 0,
            scale: CGFloat.random(in: scale),
            opacity: 1,
            rotation: Double.random(in: 0...360),
            velocity: CGPoint(
                x: cos(angle) * velocity,
                y: sin(angle) * velocity
            ),
            color: colors.randomElement() ?? .white,
            lifetime: particleLifetime
        )
        
        particles.append(particle)
    }
    
    @objc private func update() {
        let dt: CGFloat = 1 / 60
        
        particles = particles.compactMap { particle in
            var p = particle
            p.age += Double(dt)
            
            // Remove dead particles
            if p.age >= p.lifetime {
                return nil
            }
            
            // Apply velocity
            p.x += p.velocity.x * dt
            p.y += p.velocity.y * dt
            
            // Apply gravity
            p.velocity.x += gravity.x * dt
            p.velocity.y += gravity.y * dt
            
            // Fade out
            p.opacity = 1 - (p.age / p.lifetime)
            
            // Rotate
            p.rotation += Double(dt * 100)
            
            return p
        }
    }
}

// MARK: - Confetti View

/// Confetti celebration effect
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct ConfettiView: View {
    
    @Binding var isActive: Bool
    let colors: [Color]
    let particleCount: Int
    let duration: Double
    
    @State private var particles: [ConfettiParticle] = []
    
    public init(
        isActive: Binding<Bool>,
        colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink],
        particleCount: Int = 100,
        duration: Double = 3
    ) {
        self._isActive = isActive
        self.colors = colors
        self.particleCount = particleCount
        self.duration = duration
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiShape(type: particle.shape)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .rotationEffect(.degrees(particle.rotation))
                        .rotation3DEffect(.degrees(particle.rotation3D), axis: (1, 1, 0))
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                createConfetti()
            }
        }
    }
    
    private func createConfetti() {
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: -20,
                size: CGFloat.random(in: 8...15),
                color: colors.randomElement() ?? .red,
                shape: ConfettiShapeType.allCases.randomElement() ?? .rectangle,
                rotation: 0,
                rotation3D: 0,
                opacity: 1,
                velocityX: CGFloat.random(in: -50...50),
                velocityY: CGFloat.random(in: 200...400),
                rotationSpeed: Double.random(in: 100...300)
            )
        }
        
        // Animate particles
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { timer in
            let dt: CGFloat = 1/60
            
            for i in particles.indices {
                particles[i].x += particles[i].velocityX * dt
                particles[i].y += particles[i].velocityY * dt
                particles[i].rotation += particles[i].rotationSpeed * Double(dt)
                particles[i].rotation3D += particles[i].rotationSpeed * 0.5 * Double(dt)
                particles[i].velocityY += 100 * dt // gravity
                particles[i].velocityX *= 0.99 // air resistance
                
                // Fade out near bottom
                if particles[i].y > UIScreen.main.bounds.height - 100 {
                    particles[i].opacity -= Double(dt) * 2
                }
            }
            
            // Remove off-screen particles
            particles.removeAll { $0.y > UIScreen.main.bounds.height + 50 || $0.opacity <= 0 }
            
            if particles.isEmpty {
                timer.invalidate()
                isActive = false
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var shape: ConfettiShapeType
    var rotation: Double
    var rotation3D: Double
    var opacity: Double
    var velocityX: CGFloat
    var velocityY: CGFloat
    var rotationSpeed: Double
}

private enum ConfettiShapeType: CaseIterable {
    case rectangle
    case circle
    case triangle
}

private struct ConfettiShape: Shape {
    let type: ConfettiShapeType
    
    func path(in rect: CGRect) -> Path {
        switch type {
        case .rectangle:
            return Path(rect)
        case .circle:
            return Path(ellipseIn: rect)
        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}

// MARK: - Snow Effect

/// Falling snow particles
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SnowView: View {
    
    let particleCount: Int
    let speed: ClosedRange<Double>
    
    @State private var snowflakes: [Snowflake] = []
    
    public init(particleCount: Int = 50, speed: ClosedRange<Double> = 2...5) {
        self.particleCount = particleCount
        self.speed = speed
    }
    
    public var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    for snowflake in snowflakes {
                        let y = (CGFloat(time * snowflake.speed) * 50).truncatingRemainder(dividingBy: size.height + 50) - 25
                        let x = snowflake.x + sin(CGFloat(time) * snowflake.wobbleSpeed) * 20
                        
                        let circle = Path(ellipseIn: CGRect(
                            x: x - snowflake.size / 2,
                            y: y - snowflake.size / 2,
                            width: snowflake.size,
                            height: snowflake.size
                        ))
                        
                        context.fill(circle, with: .color(.white.opacity(snowflake.opacity)))
                    }
                }
            }
            .onAppear {
                snowflakes = (0..<particleCount).map { _ in
                    Snowflake(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        size: CGFloat.random(in: 3...8),
                        speed: Double.random(in: speed),
                        wobbleSpeed: Double.random(in: 0.5...2),
                        opacity: Double.random(in: 0.5...1)
                    )
                }
            }
        }
    }
}

private struct Snowflake {
    let x: CGFloat
    let size: CGFloat
    let speed: Double
    let wobbleSpeed: Double
    let opacity: Double
}

// MARK: - Sparkle Effect

/// Twinkling sparkle effect
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SparkleView: View {
    
    let particleCount: Int
    let colors: [Color]
    
    @State private var sparkles: [Sparkle] = []
    
    public init(
        particleCount: Int = 30,
        colors: [Color] = [.yellow, .white, .orange]
    ) {
        self.particleCount = particleCount
        self.colors = colors
    }
    
    public var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    for sparkle in sparkles {
                        let twinkle = sin(time * sparkle.twinkleSpeed + sparkle.phase)
                        let scale = CGFloat(0.5 + twinkle * 0.5) * sparkle.size
                        let opacity = 0.3 + twinkle * 0.7
                        
                        // Draw star shape
                        let starPath = starPath(
                            center: CGPoint(x: sparkle.x, y: sparkle.y),
                            radius: scale,
                            points: 4
                        )
                        
                        context.fill(starPath, with: .color(sparkle.color.opacity(opacity)))
                    }
                }
            }
            .onAppear {
                sparkles = (0..<particleCount).map { _ in
                    Sparkle(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height),
                        size: CGFloat.random(in: 4...12),
                        color: colors.randomElement() ?? .white,
                        twinkleSpeed: Double.random(in: 2...6),
                        phase: Double.random(in: 0...(.pi * 2))
                    )
                }
            }
        }
    }
    
    private func starPath(center: CGPoint, radius: CGFloat, points: Int) -> Path {
        var path = Path()
        let angleIncrement = .pi * 2 / CGFloat(points * 2)
        
        for i in 0..<(points * 2) {
            let r = i % 2 == 0 ? radius : radius * 0.4
            let angle = CGFloat(i) * angleIncrement - .pi / 2
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

private struct Sparkle {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
    let twinkleSpeed: Double
    let phase: Double
}

// MARK: - Bubble Effect

/// Rising bubbles effect
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct BubblesView: View {
    
    let particleCount: Int
    
    @State private var bubbles: [Bubble] = []
    
    public init(particleCount: Int = 20) {
        self.particleCount = particleCount
    }
    
    public var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    for bubble in bubbles {
                        let y = size.height - (CGFloat(time * bubble.speed) * 30).truncatingRemainder(dividingBy: size.height + 100) + 50
                        let x = bubble.x + sin(CGFloat(time) * bubble.wobbleSpeed + bubble.phase) * 30
                        
                        let circle = Path(ellipseIn: CGRect(
                            x: x - bubble.size / 2,
                            y: y - bubble.size / 2,
                            width: bubble.size,
                            height: bubble.size
                        ))
                        
                        // Gradient for bubble effect
                        context.stroke(
                            circle,
                            with: .color(.white.opacity(0.6)),
                            lineWidth: 1.5
                        )
                        
                        // Highlight
                        let highlight = Path(ellipseIn: CGRect(
                            x: x - bubble.size * 0.3,
                            y: y - bubble.size * 0.3,
                            width: bubble.size * 0.2,
                            height: bubble.size * 0.2
                        ))
                        context.fill(highlight, with: .color(.white.opacity(0.8)))
                    }
                }
            }
            .onAppear {
                bubbles = (0..<particleCount).map { _ in
                    Bubble(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        size: CGFloat.random(in: 10...40),
                        speed: Double.random(in: 1...3),
                        wobbleSpeed: Double.random(in: 0.5...2),
                        phase: Double.random(in: 0...(.pi * 2))
                    )
                }
            }
        }
    }
}

private struct Bubble {
    let x: CGFloat
    let size: CGFloat
    let speed: Double
    let wobbleSpeed: Double
    let phase: Double
}

// MARK: - View Extension

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension View {
    
    /// Adds confetti celebration overlay
    func confetti(isActive: Binding<Bool>) -> some View {
        overlay(ConfettiView(isActive: isActive))
    }
    
    /// Adds snow effect overlay
    func snowEffect(particleCount: Int = 50) -> some View {
        overlay(SnowView(particleCount: particleCount))
    }
    
    /// Adds sparkle effect overlay
    func sparkleEffect(particleCount: Int = 30) -> some View {
        overlay(SparkleView(particleCount: particleCount))
    }
    
    /// Adds bubbles effect overlay
    func bubblesEffect(particleCount: Int = 20) -> some View {
        overlay(BubblesView(particleCount: particleCount))
    }
}
