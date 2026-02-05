//
//  PhysicsAnimations.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Physics Animation Types

/// Physics-based animation configurations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum PhysicsAnimationType: Sendable {
    case spring(response: Double, dampingFraction: Double, blendDuration: Double)
    case gravity(acceleration: Double)
    case friction(coefficient: Double)
    case bounce(restitution: Double)
    case elastic(stiffness: Double, damping: Double)
    case pendulum(length: Double, gravity: Double)
    case magnetic(strength: Double)
    case fluid(viscosity: Double)
}

// MARK: - Spring Presets

/// Pre-configured spring animations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SpringPresets {
    
    /// Gentle spring - slow and smooth
    public static var gentle: Animation {
        .spring(response: 0.8, dampingFraction: 0.9, blendDuration: 0)
    }
    
    /// Wobbly spring - bouncy with overshoot
    public static var wobbly: Animation {
        .spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)
    }
    
    /// Stiff spring - quick and snappy
    public static var stiff: Animation {
        .spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0)
    }
    
    /// Bouncy spring - very bouncy
    public static var bouncy: Animation {
        .spring(response: 0.4, dampingFraction: 0.3, blendDuration: 0)
    }
    
    /// Slow spring - elegant movement
    public static var slow: Animation {
        .spring(response: 1.0, dampingFraction: 0.85, blendDuration: 0)
    }
    
    /// Snappy spring - iOS default feel
    public static var snappy: Animation {
        .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }
    
    /// Interactive spring - for gestures
    public static var interactive: Animation {
        .interactiveSpring(response: 0.15, dampingFraction: 0.86, blendDuration: 0.25)
    }
    
    /// Custom spring with parameters
    public static func custom(
        response: Double = 0.5,
        damping: Double = 0.7,
        blend: Double = 0
    ) -> Animation {
        .spring(response: response, dampingFraction: damping, blendDuration: blend)
    }
}

// MARK: - Gravity Animation

/// Simulates gravity effect on a view
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct GravityModifier: ViewModifier {
    
    @Binding var isActive: Bool
    let acceleration: Double
    let groundY: CGFloat
    let bounciness: Double
    
    @State private var offsetY: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var timer: Timer?
    
    public init(
        isActive: Binding<Bool>,
        acceleration: Double = 9.8,
        groundY: CGFloat = 300,
        bounciness: Double = 0.6
    ) {
        self._isActive = isActive
        self.acceleration = acceleration
        self.groundY = groundY
        self.bounciness = bounciness
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(y: offsetY)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    startSimulation()
                } else {
                    stopSimulation()
                }
            }
    }
    
    private func startSimulation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            let dt: CGFloat = 1/60
            
            // Apply gravity
            velocity += CGFloat(acceleration) * dt * 60
            offsetY += velocity * dt
            
            // Ground collision
            if offsetY >= groundY {
                offsetY = groundY
                velocity = -velocity * CGFloat(bounciness)
                
                // Stop if velocity is very small
                if abs(velocity) < 1 {
                    velocity = 0
                    stopSimulation()
                }
            }
        }
    }
    
    private func stopSimulation() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Pendulum Animation

/// Simulates pendulum motion
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct PendulumView: View {
    
    @State private var angle: Double = 45
    @State private var velocity: Double = 0
    
    let length: Double
    let gravity: Double
    let damping: Double
    
    public init(length: Double = 150, gravity: Double = 9.8, damping: Double = 0.995) {
        self.length = length
        self.gravity = gravity
        self.damping = damping
    }
    
    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let pivot = CGPoint(x: size.width / 2, y: 50)
                let angleRad = angle * .pi / 180
                let bobX = pivot.x + sin(angleRad) * length
                let bobY = pivot.y + cos(angleRad) * length
                let bob = CGPoint(x: bobX, y: bobY)
                
                // Draw rope
                var ropePath = Path()
                ropePath.move(to: pivot)
                ropePath.addLine(to: bob)
                context.stroke(ropePath, with: .color(.gray), lineWidth: 2)
                
                // Draw pivot
                let pivotRect = CGRect(x: pivot.x - 5, y: pivot.y - 5, width: 10, height: 10)
                context.fill(Circle().path(in: pivotRect), with: .color(.gray))
                
                // Draw bob
                let bobRect = CGRect(x: bob.x - 15, y: bob.y - 15, width: 30, height: 30)
                context.fill(Circle().path(in: bobRect), with: .color(.blue))
            }
        }
        .onAppear {
            startPendulum()
        }
    }
    
    private func startPendulum() {
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            let dt = 1.0 / 60.0
            let acceleration = -(gravity / length) * sin(angle * .pi / 180)
            velocity += acceleration * dt * 60
            velocity *= damping
            angle += velocity * dt * 60
        }
    }
}

// MARK: - Elastic Drag

/// Elastic drag effect with rubber band feel
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct ElasticDragModifier: ViewModifier {
    
    let maxStretch: CGFloat
    let stiffness: Double
    
    @State private var dragOffset: CGSize = .zero
    @GestureState private var isDragging = false
    
    public init(maxStretch: CGFloat = 100, stiffness: Double = 0.5) {
        self.maxStretch = maxStretch
        self.stiffness = stiffness
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        // Apply rubber band effect
                        let translation = value.translation
                        dragOffset = CGSize(
                            width: rubberBand(translation.width),
                            height: rubberBand(translation.height)
                        )
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            dragOffset = .zero
                        }
                    }
            )
    }
    
    private func rubberBand(_ offset: CGFloat) -> CGFloat {
        let sign: CGFloat = offset < 0 ? -1 : 1
        let absOffset = abs(offset)
        
        // Logarithmic damping for rubber band effect
        if absOffset > maxStretch {
            let extra = absOffset - maxStretch
            let dampedExtra = log10(extra + 1) * maxStretch * CGFloat(stiffness)
            return sign * (maxStretch + dampedExtra)
        }
        return offset
    }
}

// MARK: - Inertial Scroll

/// Inertial scrolling with momentum
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct InertialScrollModifier: ViewModifier {
    
    let friction: Double
    let bounds: ClosedRange<CGFloat>
    
    @State private var offset: CGFloat = 0
    @State private var velocity: CGFloat = 0
    @State private var timer: Timer?
    
    public init(friction: Double = 0.95, bounds: ClosedRange<CGFloat> = -1000...0) {
        self.friction = friction
        self.bounds = bounds
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        timer?.invalidate()
                        offset = (offset + value.translation.height).clamped(to: bounds)
                        velocity = value.velocity.height
                    }
                    .onEnded { _ in
                        applyInertia()
                    }
            )
    }
    
    private func applyInertia() {
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { t in
            velocity *= CGFloat(friction)
            offset = (offset + velocity / 60).clamped(to: bounds)
            
            if abs(velocity) < 0.5 {
                t.invalidate()
            }
        }
    }
}

// MARK: - Magnetic Snap

/// Snaps to predefined points with magnetic feel
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct MagneticSnapModifier: ViewModifier {
    
    let snapPoints: [CGFloat]
    let threshold: CGFloat
    
    @State private var currentPosition: CGFloat = 0
    
    public init(snapPoints: [CGFloat], threshold: CGFloat = 50) {
        self.snapPoints = snapPoints
        self.threshold = threshold
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(y: currentPosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        currentPosition = value.translation.height
                    }
                    .onEnded { value in
                        let targetPosition = currentPosition + value.predictedEndTranslation.height
                        let nearest = findNearestSnapPoint(to: targetPosition)
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPosition = nearest
                        }
                    }
            )
    }
    
    private func findNearestSnapPoint(to position: CGFloat) -> CGFloat {
        snapPoints.min(by: { abs($0 - position) < abs($1 - position) }) ?? 0
    }
}

// MARK: - View Extension

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension View {
    
    /// Applies gravity animation
    func gravity(
        isActive: Binding<Bool>,
        acceleration: Double = 9.8,
        groundY: CGFloat = 300,
        bounciness: Double = 0.6
    ) -> some View {
        modifier(GravityModifier(
            isActive: isActive,
            acceleration: acceleration,
            groundY: groundY,
            bounciness: bounciness
        ))
    }
    
    /// Applies elastic drag
    func elasticDrag(maxStretch: CGFloat = 100, stiffness: Double = 0.5) -> some View {
        modifier(ElasticDragModifier(maxStretch: maxStretch, stiffness: stiffness))
    }
    
    /// Applies magnetic snap behavior
    func magneticSnap(to points: [CGFloat], threshold: CGFloat = 50) -> some View {
        modifier(MagneticSnapModifier(snapPoints: points, threshold: threshold))
    }
}

// MARK: - Helper Extensions

extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
