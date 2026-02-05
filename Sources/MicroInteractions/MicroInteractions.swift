//
//  MicroInteractions.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Micro-Interaction Types (15+)

/// 15+ Production-ready micro-interactions for delightful UX
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum MicroInteractionType: String, CaseIterable, Sendable {
    case tapScale         // Scale on tap
    case tapBounce        // Bounce on tap
    case longPressGlow    // Glow on long press
    case hoverLift        // Lift on hover (macOS/iPadOS)
    case swipeReveal      // Reveal on swipe
    case pullToRefresh    // Pull to refresh
    case successCheck     // Checkmark success
    case errorShake       // Shake on error
    case likeHeart        // Heart like animation
    case addToCart        // Add to cart animation
    case toggleSwitch     // Toggle switch
    case sliderSnap       // Slider with snap
    case deleteSwipe      // Swipe to delete
    case expandCollapse   // Expand/collapse
    case rippleFeedback   // Ripple touch feedback
}

// MARK: - Tap Scale Modifier

/// Scales view on tap with spring animation
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct TapScaleModifier: ViewModifier {
    
    let scale: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    public init(scale: CGFloat = 0.95, action: @escaping () -> Void) {
        self.scale = scale
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

// MARK: - Tap Bounce Modifier

/// Bounces view on tap
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct TapBounceModifier: ViewModifier {
    
    let action: () -> Void
    
    @State private var isBouncing = false
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isBouncing ? 1.2 : 1)
            .animation(.interpolatingSpring(stiffness: 300, damping: 10), value: isBouncing)
            .onTapGesture {
                isBouncing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isBouncing = false
                    action()
                }
            }
    }
}

// MARK: - Long Press Glow Modifier

/// Adds glow effect on long press
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct LongPressGlowModifier: ViewModifier {
    
    let color: Color
    let action: () -> Void
    
    @State private var isGlowing = false
    
    public init(color: Color = .blue, action: @escaping () -> Void) {
        self.color = color
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        content
            .shadow(color: isGlowing ? color.opacity(0.8) : .clear, radius: isGlowing ? 15 : 0)
            .animation(.easeInOut(duration: 0.3), value: isGlowing)
            .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
                isGlowing = pressing
            }) {
                action()
            }
    }
}

// MARK: - Hover Lift Modifier

/// Lifts view on hover (macOS/iPadOS with pointer)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct HoverLiftModifier: ViewModifier {
    
    @State private var isHovered = false
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.05 : 1)
            .shadow(
                color: .black.opacity(isHovered ? 0.2 : 0.1),
                radius: isHovered ? 10 : 5,
                y: isHovered ? 5 : 2
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Success Check Animation

/// Animated success checkmark
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SuccessCheckView: View {
    
    @Binding var isShowing: Bool
    let color: Color
    let size: CGFloat
    
    @State private var checkProgress: CGFloat = 0
    @State private var circleProgress: CGFloat = 0
    
    public init(isShowing: Binding<Bool>, color: Color = .green, size: CGFloat = 60) {
        self._isShowing = isShowing
        self.color = color
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            CheckmarkShape()
                .trim(from: 0, to: checkProgress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.5, height: size * 0.5)
        }
        .opacity(isShowing ? 1 : 0)
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                animateIn()
            } else {
                reset()
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.easeOut(duration: 0.3)) {
            circleProgress = 1
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
            checkProgress = 1
        }
    }
    
    private func reset() {
        checkProgress = 0
        circleProgress = 0
    }
}

private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.1, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.8))
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.2))
        
        return path
    }
}

// MARK: - Error Shake Modifier

/// Shakes view on error
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct ErrorShakeModifier: ViewModifier {
    
    @Binding var shake: Bool
    
    @State private var shakeOffset: CGFloat = 0
    
    public init(shake: Binding<Bool>) {
        self._shake = shake
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: shake) { _, newValue in
                if newValue {
                    performShake()
                }
            }
    }
    
    private func performShake() {
        let shakeSequence: [(CGFloat, Double)] = [
            (10, 0.05),
            (-10, 0.05),
            (8, 0.05),
            (-8, 0.05),
            (5, 0.05),
            (-5, 0.05),
            (0, 0.05)
        ]
        
        var delay: Double = 0
        for (offset, duration) in shakeSequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration)) {
                    shakeOffset = offset
                }
            }
            delay += duration
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            shake = false
        }
    }
}

// MARK: - Like Heart Animation

/// Animated heart like button
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct LikeHeartButton: View {
    
    @Binding var isLiked: Bool
    let size: CGFloat
    
    @State private var scale: CGFloat = 1
    @State private var particles: [HeartParticle] = []
    
    public init(isLiked: Binding<Bool>, size: CGFloat = 30) {
        self._isLiked = isLiked
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            // Particles
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.red.opacity(particle.opacity))
                    .frame(width: 6, height: 6)
                    .offset(x: particle.x, y: particle.y)
            }
            
            // Heart
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: size))
                .foregroundStyle(isLiked ? .red : .gray)
                .scaleEffect(scale)
        }
        .onTapGesture {
            if !isLiked {
                triggerLike()
            } else {
                isLiked = false
            }
        }
    }
    
    private func triggerLike() {
        isLiked = true
        
        // Scale animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            scale = 1.3
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
            scale = 1
        }
        
        // Particle animation
        createParticles()
    }
    
    private func createParticles() {
        particles = (0..<8).map { i in
            HeartParticle(
                id: UUID(),
                x: 0,
                y: 0,
                opacity: 1
            )
        }
        
        for (index, _) in particles.enumerated() {
            let angle = Double(index) * (.pi * 2 / 8)
            let distance: CGFloat = 30
            
            withAnimation(.easeOut(duration: 0.5)) {
                particles[index].x = cos(angle) * distance
                particles[index].y = sin(angle) * distance
                particles[index].opacity = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particles.removeAll()
        }
    }
}

private struct HeartParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
}

// MARK: - Add to Cart Animation

/// Animated add to cart button
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct AddToCartButton: View {
    
    @Binding var isAdded: Bool
    let action: () -> Void
    
    @State private var iconOffset: CGFloat = 0
    @State private var iconScale: CGFloat = 1
    @State private var showCheck = false
    
    public init(isAdded: Binding<Bool>, action: @escaping () -> Void) {
        self._isAdded = isAdded
        self.action = action
    }
    
    public var body: some View {
        Button(action: performAction) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isAdded ? Color.green : Color.blue)
                    .frame(width: 150, height: 44)
                
                HStack {
                    if showCheck {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 18))
                            .foregroundStyle(.white)
                            .scaleEffect(iconScale)
                            .offset(y: iconOffset)
                        
                        Text("Add to Cart")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private func performAction() {
        guard !isAdded else { return }
        
        // Bounce animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            iconScale = 1.3
            iconOffset = -5
        }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.1)) {
            iconScale = 1
            iconOffset = 0
        }
        
        // Show check after bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) {
                isAdded = true
                showCheck = true
            }
            action()
        }
    }
}

// MARK: - Toggle Switch

/// Custom animated toggle switch
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct AnimatedToggle: View {
    
    @Binding var isOn: Bool
    let onColor: Color
    let offColor: Color
    
    public init(isOn: Binding<Bool>, onColor: Color = .green, offColor: Color = .gray) {
        self._isOn = isOn
        self.onColor = onColor
        self.offColor = offColor
    }
    
    public var body: some View {
        ZStack {
            Capsule()
                .fill(isOn ? onColor : offColor)
                .frame(width: 51, height: 31)
            
            Circle()
                .fill(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                .frame(width: 27, height: 27)
                .offset(x: isOn ? 10 : -10)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        .onTapGesture {
            isOn.toggle()
        }
    }
}

// MARK: - Ripple Feedback

/// Material design-like ripple effect
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct RippleFeedbackModifier: ViewModifier {
    
    let color: Color
    
    @State private var ripplePosition: CGPoint = .zero
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    
    public init(color: Color = .gray) {
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Circle()
                        .fill(color.opacity(0.3))
                        .scaleEffect(rippleScale)
                        .opacity(rippleOpacity)
                        .position(ripplePosition)
                }
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        ripplePosition = value.location
                        withAnimation(.easeOut(duration: 0.3)) {
                            rippleScale = 2
                            rippleOpacity = 0.5
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            rippleOpacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            rippleScale = 0
                        }
                    }
            )
    }
}

// MARK: - Expand Collapse View

/// Animated expandable/collapsible view
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct ExpandableView<Header: View, Content: View>: View {
    
    @Binding var isExpanded: Bool
    let header: () -> Header
    let content: () -> Content
    
    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isExpanded = isExpanded
        self.header = header
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    header()
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                content()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
    }
}

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension View {
    
    /// Adds tap scale interaction
    func tapScale(scale: CGFloat = 0.95, action: @escaping () -> Void) -> some View {
        modifier(TapScaleModifier(scale: scale, action: action))
    }
    
    /// Adds tap bounce interaction
    func tapBounce(action: @escaping () -> Void) -> some View {
        modifier(TapBounceModifier(action: action))
    }
    
    /// Adds long press glow effect
    func longPressGlow(color: Color = .blue, action: @escaping () -> Void) -> some View {
        modifier(LongPressGlowModifier(color: color, action: action))
    }
    
    /// Adds hover lift effect
    func hoverLift() -> some View {
        modifier(HoverLiftModifier())
    }
    
    /// Adds error shake animation
    func errorShake(shake: Binding<Bool>) -> some View {
        modifier(ErrorShakeModifier(shake: shake))
    }
    
    /// Adds ripple feedback effect
    func rippleFeedback(color: Color = .gray) -> some View {
        modifier(RippleFeedbackModifier(color: color))
    }
}
