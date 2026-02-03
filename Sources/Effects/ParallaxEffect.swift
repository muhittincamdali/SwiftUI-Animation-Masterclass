//
//  ParallaxEffect.swift
//  SwiftUI-Animation-Masterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import SwiftUI
import CoreMotion

// MARK: - Parallax Configuration

/// Configuration options for parallax effects.
///
/// Use this struct to customize the behavior and intensity
/// of parallax animations in your views.
public struct ParallaxConfiguration {
    /// The maximum offset in points for the parallax effect.
    public var maxOffset: CGFloat
    
    /// The intensity multiplier for the effect.
    public var intensity: CGFloat
    
    /// Whether to enable horizontal parallax movement.
    public var horizontalEnabled: Bool
    
    /// Whether to enable vertical parallax movement.
    public var verticalEnabled: Bool
    
    /// The smoothing factor for motion updates (0 to 1).
    public var smoothing: CGFloat
    
    /// Whether to invert the parallax direction.
    public var inverted: Bool
    
    /// Creates a parallax configuration.
    /// - Parameters:
    ///   - maxOffset: Maximum offset in points. Defaults to 20.
    ///   - intensity: Effect intensity. Defaults to 1.0.
    ///   - horizontalEnabled: Enable horizontal movement. Defaults to true.
    ///   - verticalEnabled: Enable vertical movement. Defaults to true.
    ///   - smoothing: Motion smoothing factor. Defaults to 0.1.
    ///   - inverted: Invert direction. Defaults to false.
    public init(
        maxOffset: CGFloat = 20,
        intensity: CGFloat = 1.0,
        horizontalEnabled: Bool = true,
        verticalEnabled: Bool = true,
        smoothing: CGFloat = 0.1,
        inverted: Bool = false
    ) {
        self.maxOffset = maxOffset
        self.intensity = intensity
        self.horizontalEnabled = horizontalEnabled
        self.verticalEnabled = verticalEnabled
        self.smoothing = max(0, min(1, smoothing))
        self.inverted = inverted
    }
    
    /// A subtle parallax configuration.
    public static let subtle = ParallaxConfiguration(maxOffset: 10, intensity: 0.5)
    
    /// A moderate parallax configuration.
    public static let moderate = ParallaxConfiguration(maxOffset: 20, intensity: 1.0)
    
    /// An intense parallax configuration.
    public static let intense = ParallaxConfiguration(maxOffset: 40, intensity: 1.5)
    
    /// Horizontal-only parallax configuration.
    public static let horizontalOnly = ParallaxConfiguration(verticalEnabled: false)
    
    /// Vertical-only parallax configuration.
    public static let verticalOnly = ParallaxConfiguration(horizontalEnabled: false)
}

// MARK: - Motion Manager

/// A manager that handles device motion updates for parallax effects.
///
/// `MotionManager` uses Core Motion to track device orientation
/// and provides smoothed motion data for parallax animations.
@MainActor
public final class MotionManager: ObservableObject {
    /// The current horizontal offset based on device motion.
    @Published public private(set) var xOffset: CGFloat = 0
    
    /// The current vertical offset based on device motion.
    @Published public private(set) var yOffset: CGFloat = 0
    
    /// The raw pitch value from the gyroscope.
    @Published public private(set) var pitch: Double = 0
    
    /// The raw roll value from the gyroscope.
    @Published public private(set) var roll: Double = 0
    
    /// Whether device motion is currently being tracked.
    @Published public private(set) var isTracking: Bool = false
    
    /// The Core Motion manager instance.
    private let motionManager = CMMotionManager()
    
    /// The update interval for motion data.
    private let updateInterval: TimeInterval = 1.0 / 60.0
    
    /// The current parallax configuration.
    public var configuration: ParallaxConfiguration
    
    /// Smoothed offset values.
    private var smoothedX: CGFloat = 0
    private var smoothedY: CGFloat = 0
    
    /// Creates a new motion manager.
    /// - Parameter configuration: The parallax configuration. Defaults to moderate.
    public init(configuration: ParallaxConfiguration = .moderate) {
        self.configuration = configuration
    }
    
    /// Starts tracking device motion.
    public func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            
            Task { @MainActor in
                self.processMotion(motion)
            }
        }
        
        isTracking = true
    }
    
    /// Stops tracking device motion.
    public func stopTracking() {
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
    }
    
    /// Processes motion data and updates offset values.
    private func processMotion(_ motion: CMDeviceMotion) {
        let attitude = motion.attitude
        
        pitch = attitude.pitch
        roll = attitude.roll
        
        let maxOffset = configuration.maxOffset * configuration.intensity
        let direction: CGFloat = configuration.inverted ? -1 : 1
        
        var targetX: CGFloat = 0
        var targetY: CGFloat = 0
        
        if configuration.horizontalEnabled {
            targetX = CGFloat(roll) * maxOffset * direction
            targetX = max(-maxOffset, min(maxOffset, targetX))
        }
        
        if configuration.verticalEnabled {
            targetY = CGFloat(pitch) * maxOffset * direction
            targetY = max(-maxOffset, min(maxOffset, targetY))
        }
        
        smoothedX += (targetX - smoothedX) * configuration.smoothing
        smoothedY += (targetY - smoothedY) * configuration.smoothing
        
        xOffset = smoothedX
        yOffset = smoothedY
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Parallax Layer

/// Represents a single layer in a parallax scene.
///
/// Each layer can have its own depth factor, which determines
/// how much it moves relative to other layers.
public struct ParallaxLayer<Content: View>: View {
    /// The depth factor for this layer (1.0 = normal, >1 = faster, <1 = slower).
    public let depth: CGFloat
    
    /// The content view for this layer.
    public let content: Content
    
    /// The motion manager providing offset values.
    @ObservedObject private var motionManager: MotionManager
    
    /// Creates a parallax layer.
    /// - Parameters:
    ///   - depth: The depth factor for movement.
    ///   - motionManager: The motion manager to use.
    ///   - content: The content view builder.
    public init(
        depth: CGFloat,
        motionManager: MotionManager,
        @ViewBuilder content: () -> Content
    ) {
        self.depth = depth
        self.motionManager = motionManager
        self.content = content()
    }
    
    public var body: some View {
        content
            .offset(
                x: motionManager.xOffset * depth,
                y: motionManager.yOffset * depth
            )
    }
}

// MARK: - Parallax Container

/// A container view that manages multiple parallax layers.
///
/// `ParallaxContainer` creates a 3D-like depth effect by moving
/// multiple layers at different rates based on device motion.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct ParallaxContainer<Content: View>: View {
    /// The motion manager for this container.
    @StateObject private var motionManager: MotionManager
    
    /// The content view builder.
    private let content: (MotionManager) -> Content
    
    /// Creates a parallax container.
    /// - Parameters:
    ///   - configuration: The parallax configuration. Defaults to moderate.
    ///   - content: A view builder that receives the motion manager.
    public init(
        configuration: ParallaxConfiguration = .moderate,
        @ViewBuilder content: @escaping (MotionManager) -> Content
    ) {
        _motionManager = StateObject(wrappedValue: MotionManager(configuration: configuration))
        self.content = content
    }
    
    public var body: some View {
        content(motionManager)
            .onAppear {
                motionManager.startTracking()
            }
            .onDisappear {
                motionManager.stopTracking()
            }
    }
}

// MARK: - Scroll Parallax

/// A parallax effect that responds to scroll position.
///
/// Use this modifier to create parallax effects based on
/// scroll position rather than device motion.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct ScrollParallaxModifier: ViewModifier {
    /// The scroll offset value.
    private let scrollOffset: CGFloat
    
    /// The parallax speed multiplier.
    private let speed: CGFloat
    
    /// The direction of the parallax effect.
    private let direction: ParallaxDirection
    
    /// The maximum offset limit.
    private let maxOffset: CGFloat
    
    /// Parallax movement direction.
    public enum ParallaxDirection {
        case horizontal
        case vertical
        case both
    }
    
    /// Creates a scroll parallax modifier.
    /// - Parameters:
    ///   - scrollOffset: Current scroll position.
    ///   - speed: Parallax speed multiplier. Defaults to 0.5.
    ///   - direction: Movement direction. Defaults to vertical.
    ///   - maxOffset: Maximum offset limit. Defaults to infinity.
    public init(
        scrollOffset: CGFloat,
        speed: CGFloat = 0.5,
        direction: ParallaxDirection = .vertical,
        maxOffset: CGFloat = .infinity
    ) {
        self.scrollOffset = scrollOffset
        self.speed = speed
        self.direction = direction
        self.maxOffset = maxOffset
    }
    
    public func body(content: Content) -> some View {
        let offset = min(abs(scrollOffset * speed), maxOffset) * (scrollOffset < 0 ? -1 : 1)
        
        switch direction {
        case .horizontal:
            content.offset(x: offset)
        case .vertical:
            content.offset(y: offset)
        case .both:
            content.offset(x: offset, y: offset)
        }
    }
}

// MARK: - Parallax Card

/// A card view with built-in parallax tilt effect.
///
/// `ParallaxCard` responds to touch or drag gestures to create
/// a 3D tilt effect that follows the user's finger.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct ParallaxCard<Content: View>: View {
    /// The card content.
    private let content: Content
    
    /// The maximum rotation angle in degrees.
    private let maxRotation: Double
    
    /// The perspective depth.
    private let perspective: Double
    
    /// Current drag location.
    @State private var dragLocation: CGPoint = .zero
    
    /// Whether the card is being pressed.
    @State private var isPressed: Bool = false
    
    /// Card size for calculations.
    @State private var cardSize: CGSize = .zero
    
    /// Creates a parallax card.
    /// - Parameters:
    ///   - maxRotation: Maximum tilt angle in degrees. Defaults to 15.
    ///   - perspective: 3D perspective depth. Defaults to 0.5.
    ///   - content: The card content view.
    public init(
        maxRotation: Double = 15,
        perspective: Double = 0.5,
        @ViewBuilder content: () -> Content
    ) {
        self.maxRotation = maxRotation
        self.perspective = perspective
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            cardSize = proxy.size
                        }
                    }
                )
                .rotation3DEffect(
                    .degrees(isPressed ? rotationX : 0),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: perspective
                )
                .rotation3DEffect(
                    .degrees(isPressed ? rotationY : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: perspective
                )
                .scaleEffect(isPressed ? 1.02 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: dragLocation)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isPressed = true
                            dragLocation = value.location
                        }
                        .onEnded { _ in
                            isPressed = false
                            dragLocation = CGPoint(x: cardSize.width / 2, y: cardSize.height / 2)
                        }
                )
        }
    }
    
    /// Calculates rotation around X axis based on drag position.
    private var rotationX: Double {
        guard cardSize.height > 0 else { return 0 }
        let normalizedY = (dragLocation.y / cardSize.height) - 0.5
        return normalizedY * maxRotation * -1
    }
    
    /// Calculates rotation around Y axis based on drag position.
    private var rotationY: Double {
        guard cardSize.width > 0 else { return 0 }
        let normalizedX = (dragLocation.x / cardSize.width) - 0.5
        return normalizedX * maxRotation
    }
}

// MARK: - Mouse Parallax (macOS)

#if os(macOS)
/// A parallax effect that follows mouse position on macOS.
@available(macOS 14.0, *)
public struct MouseParallaxModifier: ViewModifier {
    /// The intensity of the parallax effect.
    private let intensity: CGFloat
    
    /// The maximum offset.
    private let maxOffset: CGFloat
    
    /// Current mouse position.
    @State private var mousePosition: CGPoint = .zero
    
    /// View bounds.
    @State private var bounds: CGRect = .zero
    
    /// Creates a mouse parallax modifier.
    /// - Parameters:
    ///   - intensity: Effect intensity. Defaults to 1.0.
    ///   - maxOffset: Maximum offset. Defaults to 20.
    public init(intensity: CGFloat = 1.0, maxOffset: CGFloat = 20) {
        self.intensity = intensity
        self.maxOffset = maxOffset
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(x: calculateOffset().x, y: calculateOffset().y)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            bounds = geometry.frame(in: .global)
                        }
                }
            )
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    mousePosition = location
                case .ended:
                    mousePosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
                }
            }
            .animation(.spring(response: 0.2), value: mousePosition)
    }
    
    private func calculateOffset() -> CGPoint {
        guard bounds.width > 0 && bounds.height > 0 else { return .zero }
        
        let normalizedX = (mousePosition.x / bounds.width) - 0.5
        let normalizedY = (mousePosition.y / bounds.height) - 0.5
        
        let offsetX = normalizedX * maxOffset * intensity * 2
        let offsetY = normalizedY * maxOffset * intensity * 2
        
        return CGPoint(x: offsetX, y: offsetY)
    }
}
#endif

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    /// Applies a scroll-based parallax effect.
    /// - Parameters:
    ///   - scrollOffset: Current scroll position.
    ///   - speed: Parallax speed multiplier.
    ///   - direction: Movement direction.
    /// - Returns: A view with scroll parallax applied.
    func scrollParallax(
        scrollOffset: CGFloat,
        speed: CGFloat = 0.5,
        direction: ScrollParallaxModifier.ParallaxDirection = .vertical
    ) -> some View {
        modifier(ScrollParallaxModifier(
            scrollOffset: scrollOffset,
            speed: speed,
            direction: direction
        ))
    }
    
    /// Wraps the view in a parallax card with tilt effect.
    /// - Parameters:
    ///   - maxRotation: Maximum tilt angle.
    ///   - perspective: 3D perspective depth.
    /// - Returns: A parallax card containing the view.
    func parallaxCard(maxRotation: Double = 15, perspective: Double = 0.5) -> some View {
        ParallaxCard(maxRotation: maxRotation, perspective: perspective) {
            self
        }
    }
    
    #if os(macOS)
    /// Applies a mouse-following parallax effect on macOS.
    /// - Parameters:
    ///   - intensity: Effect intensity.
    ///   - maxOffset: Maximum offset.
    /// - Returns: A view with mouse parallax applied.
    @available(macOS 14.0, *)
    func mouseParallax(intensity: CGFloat = 1.0, maxOffset: CGFloat = 20) -> some View {
        modifier(MouseParallaxModifier(intensity: intensity, maxOffset: maxOffset))
    }
    #endif
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct ParallaxEffectPreview: View {
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Parallax Card")
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 120)
                .overlay(
                    VStack {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 30))
                        Text("Drag me")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                .parallaxCard()
            
            Text("Scroll Parallax Demo")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<10) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.3 + Double(index) * 0.07))
                            .frame(height: 80)
                            .overlay(Text("Layer \(index)"))
                            .scrollParallax(scrollOffset: scrollOffset, speed: 0.1 * CGFloat(index))
                    }
                }
                .padding()
            }
            .frame(height: 300)
        }
        .padding()
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Parallax Effect") {
    ParallaxEffectPreview()
}
#endif
