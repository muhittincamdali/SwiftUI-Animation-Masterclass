//
//  ComplexAnimations.swift
//  SwiftUI-Animation-Masterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Particle System

/// A particle emitter for creating visual effects like confetti, snow, or fire.
///
/// `ParticleSystem` provides a flexible foundation for creating
/// various particle-based animations with customizable behavior.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct ParticleSystem: View {
    /// The particle configuration.
    private let configuration: ParticleConfiguration
    
    /// Timer for particle updates.
    @State private var particles: [Particle] = []
    
    /// Timer for spawning new particles.
    @State private var timer: Timer?
    
    /// Unique particle identifier.
    private struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var rotation: Double
        var opacity: Double
        var velocityX: CGFloat
        var velocityY: CGFloat
        var color: Color
        var lifetime: TimeInterval
        var age: TimeInterval = 0
    }
    
    /// Particle configuration options.
    public struct ParticleConfiguration {
        /// Maximum number of particles.
        public var maxParticles: Int
        
        /// Particle spawn rate per second.
        public var spawnRate: Double
        
        /// Particle lifetime range in seconds.
        public var lifetimeRange: ClosedRange<Double>
        
        /// Initial scale range.
        public var scaleRange: ClosedRange<CGFloat>
        
        /// Horizontal velocity range.
        public var velocityXRange: ClosedRange<CGFloat>
        
        /// Vertical velocity range.
        public var velocityYRange: ClosedRange<CGFloat>
        
        /// Available particle colors.
        public var colors: [Color]
        
        /// Gravity effect on particles.
        public var gravity: CGFloat
        
        /// Spawn area width.
        public var emitterWidth: CGFloat
        
        /// Spawn area height.
        public var emitterHeight: CGFloat
        
        /// Particle shape.
        public var shape: ParticleShape
        
        /// Particle shape options.
        public enum ParticleShape {
            case circle
            case square
            case star
            case custom(AnyView)
        }
        
        /// Creates a particle configuration.
        public init(
            maxParticles: Int = 50,
            spawnRate: Double = 10,
            lifetimeRange: ClosedRange<Double> = 2...4,
            scaleRange: ClosedRange<CGFloat> = 0.5...1.5,
            velocityXRange: ClosedRange<CGFloat> = -50...50,
            velocityYRange: ClosedRange<CGFloat> = -100...(-50),
            colors: [Color] = [.red, .blue, .green, .yellow, .purple],
            gravity: CGFloat = 98,
            emitterWidth: CGFloat = 300,
            emitterHeight: CGFloat = 10,
            shape: ParticleShape = .circle
        ) {
            self.maxParticles = maxParticles
            self.spawnRate = spawnRate
            self.lifetimeRange = lifetimeRange
            self.scaleRange = scaleRange
            self.velocityXRange = velocityXRange
            self.velocityYRange = velocityYRange
            self.colors = colors
            self.gravity = gravity
            self.emitterWidth = emitterWidth
            self.emitterHeight = emitterHeight
            self.shape = shape
        }
        
        /// Confetti preset.
        public static let confetti = ParticleConfiguration(
            maxParticles: 100,
            spawnRate: 30,
            lifetimeRange: 3...5,
            scaleRange: 0.3...0.8,
            velocityXRange: -100...100,
            velocityYRange: -300...(-200),
            colors: [.red, .blue, .green, .yellow, .purple, .orange, .pink],
            gravity: 150,
            shape: .square
        )
        
        /// Snow preset.
        public static let snow = ParticleConfiguration(
            maxParticles: 80,
            spawnRate: 15,
            lifetimeRange: 5...8,
            scaleRange: 0.2...0.6,
            velocityXRange: -20...20,
            velocityYRange: 30...60,
            colors: [.white, Color(white: 0.9)],
            gravity: 0,
            shape: .circle
        )
        
        /// Fire preset.
        public static let fire = ParticleConfiguration(
            maxParticles: 60,
            spawnRate: 25,
            lifetimeRange: 1...2,
            scaleRange: 0.5...1.2,
            velocityXRange: -30...30,
            velocityYRange: -150...(-100),
            colors: [.red, .orange, .yellow],
            gravity: -50,
            shape: .circle
        )
    }
    
    /// Creates a particle system.
    /// - Parameter configuration: The particle configuration.
    public init(configuration: ParticleConfiguration = .confetti) {
        self.configuration = configuration
    }
    
    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x - 5 * particle.scale,
                        y: particle.y - 5 * particle.scale,
                        width: 10 * particle.scale,
                        height: 10 * particle.scale
                    )
                    
                    context.opacity = particle.opacity
                    
                    switch configuration.shape {
                    case .circle:
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(particle.color)
                        )
                    case .square:
                        context.fill(
                            Rectangle().path(in: rect),
                            with: .color(particle.color)
                        )
                    case .star:
                        let starPath = starPath(in: rect)
                        context.fill(starPath, with: .color(particle.color))
                    case .custom:
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(particle.color)
                        )
                    }
                }
            }
            .onChange(of: timeline.date) { _, _ in
                updateParticles()
            }
        }
        .onAppear {
            startEmitting()
        }
        .onDisappear {
            stopEmitting()
        }
    }
    
    private func starPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * 0.4
        
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5 - .pi / 2
            let r = i % 2 == 0 ? radius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * r
            let y = center.y + CGFloat(sin(angle)) * r
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
    
    private func startEmitting() {
        let interval = 1.0 / configuration.spawnRate
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            spawnParticle()
        }
    }
    
    private func stopEmitting() {
        timer?.invalidate()
        timer = nil
    }
    
    private func spawnParticle() {
        guard particles.count < configuration.maxParticles else { return }
        
        let particle = Particle(
            x: CGFloat.random(in: 0...configuration.emitterWidth),
            y: CGFloat.random(in: 0...configuration.emitterHeight),
            scale: CGFloat.random(in: configuration.scaleRange),
            rotation: Double.random(in: 0...360),
            opacity: 1.0,
            velocityX: CGFloat.random(in: configuration.velocityXRange),
            velocityY: CGFloat.random(in: configuration.velocityYRange),
            color: configuration.colors.randomElement() ?? .white,
            lifetime: Double.random(in: configuration.lifetimeRange)
        )
        
        particles.append(particle)
    }
    
    private func updateParticles() {
        let deltaTime: TimeInterval = 1.0 / 60.0
        
        particles = particles.compactMap { particle in
            var p = particle
            p.age += deltaTime
            
            guard p.age < p.lifetime else { return nil }
            
            p.velocityY += configuration.gravity * CGFloat(deltaTime)
            p.x += p.velocityX * CGFloat(deltaTime)
            p.y += p.velocityY * CGFloat(deltaTime)
            p.rotation += 90 * deltaTime
            p.opacity = 1.0 - (p.age / p.lifetime)
            
            return p
        }
    }
}

// MARK: - Morphing Shape

/// A shape that can morph between different forms.
///
/// `MorphingShape` smoothly transitions between predefined shapes
/// creating fluid, organic-looking animations.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct MorphingShape: Shape {
    /// The current morph progress (0 to 1).
    public var progress: Double
    
    /// The starting shape points.
    private let fromPoints: [CGPoint]
    
    /// The ending shape points.
    private let toPoints: [CGPoint]
    
    public var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    /// Creates a morphing shape.
    /// - Parameters:
    ///   - from: Starting shape type.
    ///   - to: Ending shape type.
    ///   - progress: Morph progress from 0 to 1.
    public init(from: ShapeType, to: ShapeType, progress: Double) {
        self.progress = progress
        self.fromPoints = from.normalizedPoints
        self.toPoints = to.normalizedPoints
    }
    
    /// Predefined shape types.
    public enum ShapeType {
        case circle
        case square
        case triangle
        case star
        case hexagon
        case heart
        
        var normalizedPoints: [CGPoint] {
            let segments = 60
            switch self {
            case .circle:
                return (0..<segments).map { i in
                    let angle = Double(i) * 2 * .pi / Double(segments)
                    return CGPoint(
                        x: 0.5 + 0.4 * cos(angle),
                        y: 0.5 + 0.4 * sin(angle)
                    )
                }
                
            case .square:
                return (0..<segments).map { i in
                    let t = Double(i) / Double(segments) * 4
                    let segment = Int(t)
                    let localT = t - Double(segment)
                    
                    switch segment {
                    case 0: return CGPoint(x: 0.1 + localT * 0.8, y: 0.1)
                    case 1: return CGPoint(x: 0.9, y: 0.1 + localT * 0.8)
                    case 2: return CGPoint(x: 0.9 - localT * 0.8, y: 0.9)
                    default: return CGPoint(x: 0.1, y: 0.9 - localT * 0.8)
                    }
                }
                
            case .triangle:
                return (0..<segments).map { i in
                    let t = Double(i) / Double(segments) * 3
                    let segment = Int(t)
                    let localT = t - Double(segment)
                    
                    let p1 = CGPoint(x: 0.5, y: 0.1)
                    let p2 = CGPoint(x: 0.9, y: 0.9)
                    let p3 = CGPoint(x: 0.1, y: 0.9)
                    
                    switch segment {
                    case 0: return CGPoint(x: p1.x + (p2.x - p1.x) * localT, y: p1.y + (p2.y - p1.y) * localT)
                    case 1: return CGPoint(x: p2.x + (p3.x - p2.x) * localT, y: p2.y + (p3.y - p2.y) * localT)
                    default: return CGPoint(x: p3.x + (p1.x - p3.x) * localT, y: p3.y + (p1.y - p3.y) * localT)
                    }
                }
                
            case .star:
                return (0..<segments).map { i in
                    let angle = Double(i) * 2 * .pi / Double(segments) - .pi / 2
                    let pointIndex = Int(Double(i) / Double(segments) * 10)
                    let isOuter = pointIndex % 2 == 0
                    let radius = isOuter ? 0.4 : 0.2
                    return CGPoint(
                        x: 0.5 + radius * cos(angle),
                        y: 0.5 + radius * sin(angle)
                    )
                }
                
            case .hexagon:
                return (0..<segments).map { i in
                    let angle = Double(i) * 2 * .pi / Double(segments)
                    return CGPoint(
                        x: 0.5 + 0.4 * cos(angle),
                        y: 0.5 + 0.4 * sin(angle)
                    )
                }
                
            case .heart:
                return (0..<segments).map { i in
                    let t = Double(i) / Double(segments) * 2 * .pi
                    let x = 16 * pow(sin(t), 3)
                    let y = 13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t)
                    return CGPoint(
                        x: 0.5 + x / 40,
                        y: 0.55 - y / 40
                    )
                }
            }
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard fromPoints.count == toPoints.count else { return path }
        
        let interpolatedPoints = zip(fromPoints, toPoints).map { from, to in
            CGPoint(
                x: rect.width * (from.x + (to.x - from.x) * progress),
                y: rect.height * (from.y + (to.y - from.y) * progress)
            )
        }
        
        guard let first = interpolatedPoints.first else { return path }
        path.move(to: first)
        
        for point in interpolatedPoints.dropFirst() {
            path.addLine(to: point)
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Wave Animation

/// A wave animation effect for creating ripple or ocean-like motion.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct WaveAnimation: Shape {
    /// The animation phase.
    public var phase: Double
    
    /// The wave amplitude.
    public let amplitude: CGFloat
    
    /// The wave frequency.
    public let frequency: CGFloat
    
    public var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    /// Creates a wave animation.
    /// - Parameters:
    ///   - phase: Animation phase.
    ///   - amplitude: Wave height. Defaults to 20.
    ///   - frequency: Wave frequency. Defaults to 1.
    public init(phase: Double, amplitude: CGFloat = 20, frequency: CGFloat = 1) {
        self.phase = phase
        self.amplitude = amplitude
        self.frequency = frequency
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midHeight = rect.height / 2
        let wavelength = rect.width / frequency
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / wavelength
            let sine = sin(relativeX * 2 * .pi + phase)
            let y = midHeight + amplitude * sine
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Loading Animations

/// A collection of loading animation views.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct LoadingAnimations {
    
    /// A pulsing dots loading indicator.
    public struct PulsingDots: View {
        private let dotCount: Int
        private let dotSize: CGFloat
        private let spacing: CGFloat
        private let color: Color
        
        @State private var animatingDot: Int = 0
        
        /// Creates a pulsing dots loader.
        /// - Parameters:
        ///   - dotCount: Number of dots. Defaults to 3.
        ///   - dotSize: Size of each dot. Defaults to 10.
        ///   - spacing: Space between dots. Defaults to 8.
        ///   - color: Dot color. Defaults to blue.
        public init(dotCount: Int = 3, dotSize: CGFloat = 10, spacing: CGFloat = 8, color: Color = .blue) {
            self.dotCount = dotCount
            self.dotSize = dotSize
            self.spacing = spacing
            self.color = color
        }
        
        public var body: some View {
            HStack(spacing: spacing) {
                ForEach(0..<dotCount, id: \.self) { index in
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .scaleEffect(animatingDot == index ? 1.3 : 1.0)
                        .opacity(animatingDot == index ? 1.0 : 0.5)
                }
            }
            .onAppear {
                animateDots()
            }
        }
        
        private func animateDots() {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    animatingDot = (animatingDot + 1) % dotCount
                }
            }
        }
    }
    
    /// A rotating arc loading indicator.
    public struct RotatingArc: View {
        private let lineWidth: CGFloat
        private let color: Color
        
        @State private var rotation: Double = 0
        
        /// Creates a rotating arc loader.
        /// - Parameters:
        ///   - lineWidth: Arc line width. Defaults to 4.
        ///   - color: Arc color. Defaults to blue.
        public init(lineWidth: CGFloat = 4, color: Color = .blue) {
            self.lineWidth = lineWidth
            self.color = color
        }
        
        public var body: some View {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
        }
    }
    
    /// A morphing shape loading indicator.
    public struct MorphingLoader: View {
        private let color: Color
        private let size: CGFloat
        
        @State private var morphProgress: Double = 0
        @State private var currentShapeIndex: Int = 0
        
        private let shapes: [MorphingShape.ShapeType] = [.circle, .square, .triangle, .star, .hexagon]
        
        /// Creates a morphing loader.
        /// - Parameters:
        ///   - size: Loader size. Defaults to 50.
        ///   - color: Shape color. Defaults to blue.
        public init(size: CGFloat = 50, color: Color = .blue) {
            self.size = size
            self.color = color
        }
        
        public var body: some View {
            MorphingShape(
                from: shapes[currentShapeIndex],
                to: shapes[(currentShapeIndex + 1) % shapes.count],
                progress: morphProgress
            )
            .fill(color)
            .frame(width: size, height: size)
            .onAppear {
                animate()
            }
        }
        
        private func animate() {
            withAnimation(.easeInOut(duration: 1)) {
                morphProgress = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                morphProgress = 0
                currentShapeIndex = (currentShapeIndex + 1) % shapes.count
                animate()
            }
        }
    }
    
    /// A wave loading indicator.
    public struct WaveLoader: View {
        private let barCount: Int
        private let barWidth: CGFloat
        private let spacing: CGFloat
        private let color: Color
        
        @State private var animating: Bool = false
        
        /// Creates a wave loader.
        /// - Parameters:
        ///   - barCount: Number of bars. Defaults to 5.
        ///   - barWidth: Width of each bar. Defaults to 4.
        ///   - spacing: Space between bars. Defaults to 3.
        ///   - color: Bar color. Defaults to blue.
        public init(barCount: Int = 5, barWidth: CGFloat = 4, spacing: CGFloat = 3, color: Color = .blue) {
            self.barCount = barCount
            self.barWidth = barWidth
            self.spacing = spacing
            self.color = color
        }
        
        public var body: some View {
            HStack(spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: barWidth / 2)
                        .fill(color)
                        .frame(width: barWidth, height: animating ? 30 : 10)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.1),
                            value: animating
                        )
                }
            }
            .onAppear {
                animating = true
            }
        }
    }
}

// MARK: - Animated Text

/// A text view with character-by-character animation.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct AnimatedText: View {
    private let text: String
    private let animation: TextAnimationType
    private let characterDelay: Double
    
    @State private var visibleCharacters: Int = 0
    @State private var characterAnimations: [Bool] = []
    
    /// Text animation types.
    public enum TextAnimationType {
        case typewriter
        case fadeIn
        case bounce
        case wave
    }
    
    /// Creates an animated text view.
    /// - Parameters:
    ///   - text: The text to animate.
    ///   - animation: Animation type. Defaults to typewriter.
    ///   - characterDelay: Delay between characters. Defaults to 0.05.
    public init(_ text: String, animation: TextAnimationType = .typewriter, characterDelay: Double = 0.05) {
        self.text = text
        self.animation = animation
        self.characterDelay = characterDelay
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .modifier(characterModifier(for: index))
            }
        }
        .onAppear {
            characterAnimations = Array(repeating: false, count: text.count)
            animateCharacters()
        }
    }
    
    @ViewBuilder
    private func characterModifier(for index: Int) -> some ViewModifier {
        CharacterAnimationModifier(
            isVisible: index < visibleCharacters,
            isAnimating: index < characterAnimations.count ? characterAnimations[index] : false,
            animationType: animation,
            index: index
        )
    }
    
    private func animateCharacters() {
        for i in 0..<text.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(i)) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    visibleCharacters = i + 1
                    if i < characterAnimations.count {
                        characterAnimations[i] = true
                    }
                }
            }
        }
    }
}

/// Modifier for animating individual characters.
private struct CharacterAnimationModifier: ViewModifier {
    let isVisible: Bool
    let isAnimating: Bool
    let animationType: AnimatedText.TextAnimationType
    let index: Int
    
    func body(content: Content) -> some View {
        switch animationType {
        case .typewriter:
            content
                .opacity(isVisible ? 1 : 0)
                
        case .fadeIn:
            content
                .opacity(isVisible ? 1 : 0)
                .blur(radius: isVisible ? 0 : 5)
                
        case .bounce:
            content
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -20)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                
        case .wave:
            content
                .opacity(isVisible ? 1 : 0)
                .offset(y: isAnimating ? -10 * sin(Double(index) * 0.5) : 0)
        }
    }
}

// MARK: - Ripple Effect

/// A ripple effect that emanates from a touch point.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct RippleEffect: ViewModifier {
    /// The ripple origin point.
    @Binding var origin: CGPoint?
    
    /// The ripple color.
    let color: Color
    
    /// The maximum ripple radius.
    let maxRadius: CGFloat
    
    /// Current ripple state.
    @State private var ripples: [Ripple] = []
    
    private struct Ripple: Identifiable {
        let id = UUID()
        let center: CGPoint
        var radius: CGFloat = 0
        var opacity: Double = 0.6
    }
    
    /// Creates a ripple effect modifier.
    /// - Parameters:
    ///   - origin: Binding to ripple origin point.
    ///   - color: Ripple color. Defaults to blue.
    ///   - maxRadius: Maximum radius. Defaults to 150.
    public init(origin: Binding<CGPoint?>, color: Color = .blue, maxRadius: CGFloat = 150) {
        self._origin = origin
        self.color = color
        self.maxRadius = maxRadius
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    ForEach(ripples) { ripple in
                        Circle()
                            .stroke(color, lineWidth: 2)
                            .frame(width: ripple.radius * 2, height: ripple.radius * 2)
                            .position(ripple.center)
                            .opacity(ripple.opacity)
                    }
                }
            )
            .onChange(of: origin) { oldValue, newValue in
                if let point = newValue {
                    createRipple(at: point)
                    origin = nil
                }
            }
    }
    
    private func createRipple(at point: CGPoint) {
        let ripple = Ripple(center: point)
        ripples.append(ripple)
        
        guard let index = ripples.firstIndex(where: { $0.id == ripple.id }) else { return }
        
        withAnimation(.easeOut(duration: 0.6)) {
            ripples[index].radius = maxRadius
            ripples[index].opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    /// Adds a ripple effect to the view.
    /// - Parameters:
    ///   - origin: Binding to ripple origin point.
    ///   - color: Ripple color.
    ///   - maxRadius: Maximum ripple radius.
    /// - Returns: A view with ripple effect.
    func rippleEffect(origin: Binding<CGPoint?>, color: Color = .blue, maxRadius: CGFloat = 150) -> some View {
        modifier(RippleEffect(origin: origin, color: color, maxRadius: maxRadius))
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct ComplexAnimationsPreview: View {
    @State private var morphProgress: Double = 0
    @State private var wavePhase: Double = 0
    @State private var rippleOrigin: CGPoint? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("Particle System")
                    .font(.headline)
                ParticleSystem(configuration: .confetti)
                    .frame(height: 200)
                
                Text("Loading Animations")
                    .font(.headline)
                HStack(spacing: 40) {
                    LoadingAnimations.PulsingDots()
                    LoadingAnimations.RotatingArc()
                        .frame(width: 40, height: 40)
                    LoadingAnimations.WaveLoader()
                }
                
                Text("Animated Text")
                    .font(.headline)
                AnimatedText("Hello, SwiftUI!", animation: .bounce)
                    .font(.title)
                
                Text("Wave Animation")
                    .font(.headline)
                WaveAnimation(phase: wavePhase, amplitude: 15, frequency: 2)
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
                    .frame(height: 100)
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            wavePhase = .pi * 2
                        }
                    }
                
                Text("Morphing Shape")
                    .font(.headline)
                MorphingShape(from: .circle, to: .star, progress: morphProgress)
                    .fill(.purple)
                    .frame(width: 100, height: 100)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            morphProgress = 1
                        }
                    }
                
                Text("Ripple Effect - Tap Below")
                    .font(.headline)
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                    .rippleEffect(origin: $rippleOrigin)
                    .onTapGesture { location in
                        rippleOrigin = location
                    }
            }
            .padding()
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Complex Animations") {
    ComplexAnimationsPreview()
}
#endif
