//
//  Transform3D.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - 3D Transform Types

/// Types of 3D transformations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum Transform3DType: Sendable {
    case rotateX(degrees: Double)
    case rotateY(degrees: Double)
    case rotateZ(degrees: Double)
    case flip(axis: Axis3D)
    case cube
    case carousel
    case fold
    case perspective(depth: CGFloat)
}

/// 3D Axis definition
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum Axis3D: Sendable {
    case x
    case y
    case z
    case custom(x: CGFloat, y: CGFloat, z: CGFloat)
    
    public var values: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch self {
        case .x: return (1, 0, 0)
        case .y: return (0, 1, 0)
        case .z: return (0, 0, 1)
        case .custom(let x, let y, let z): return (x, y, z)
        }
    }
}

// MARK: - 3D Flip Card

/// Flippable card with 3D effect
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct FlipCard<Front: View, Back: View>: View {
    
    @Binding var isFlipped: Bool
    let axis: Axis3D
    let perspective: Double
    let duration: Double
    let front: () -> Front
    let back: () -> Back
    
    public init(
        isFlipped: Binding<Bool>,
        axis: Axis3D = .y,
        perspective: Double = 0.5,
        duration: Double = 0.6,
        @ViewBuilder front: @escaping () -> Front,
        @ViewBuilder back: @escaping () -> Back
    ) {
        self._isFlipped = isFlipped
        self.axis = axis
        self.perspective = perspective
        self.duration = duration
        self.front = front
        self.back = back
    }
    
    public var body: some View {
        ZStack {
            front()
                .rotation3DEffect(
                    .degrees(isFlipped ? -180 : 0),
                    axis: axis.values,
                    perspective: perspective
                )
                .opacity(isFlipped ? 0 : 1)
            
            back()
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : 180),
                    axis: axis.values,
                    perspective: perspective
                )
                .opacity(isFlipped ? 1 : 0)
        }
        .animation(.spring(response: duration, dampingFraction: 0.8), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }
}

// MARK: - 3D Cube Rotation

/// Rotating 3D cube with content on each face
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct Cube3D<Content: View>: View {
    
    @Binding var currentFace: Int
    let size: CGFloat
    let content: (Int) -> Content
    
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    
    public init(
        currentFace: Binding<Int>,
        size: CGFloat = 200,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self._currentFace = currentFace
        self.size = size
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            // Front (0)
            content(0)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial)
                .rotation3DEffect(.degrees(rotationY), axis: (0, 1, 0), perspective: 0.5)
                .offset(z: size / 2)
            
            // Back (1)
            content(1)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial)
                .rotation3DEffect(.degrees(180 + rotationY), axis: (0, 1, 0), perspective: 0.5)
                .offset(z: -size / 2)
            
            // Left (2)
            content(2)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial)
                .rotation3DEffect(.degrees(-90 + rotationY), axis: (0, 1, 0), perspective: 0.5)
                .offset(z: 0)
            
            // Right (3)
            content(3)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial)
                .rotation3DEffect(.degrees(90 + rotationY), axis: (0, 1, 0), perspective: 0.5)
                .offset(z: 0)
            
            // Top (4)
            content(4)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial)
                .rotation3DEffect(.degrees(-90 + rotationX), axis: (1, 0, 0), perspective: 0.5)
                .offset(z: 0)
            
            // Bottom (5)
            content(5)
                .frame(width: size, height: size)
                .background(.ultraThinMaterial)
                .rotation3DEffect(.degrees(90 + rotationX), axis: (1, 0, 0), perspective: 0.5)
                .offset(z: 0)
        }
        .onChange(of: currentFace) { _, newFace in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                switch newFace {
                case 0: rotationY = 0; rotationX = 0
                case 1: rotationY = 180; rotationX = 0
                case 2: rotationY = -90; rotationX = 0
                case 3: rotationY = 90; rotationX = 0
                case 4: rotationY = 0; rotationX = -90
                case 5: rotationY = 0; rotationX = 90
                default: break
                }
            }
        }
    }
}

// MARK: - 3D Carousel

/// 3D carousel with perspective
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct Carousel3D<Content: View>: View {
    
    @Binding var currentIndex: Int
    let itemCount: Int
    let radius: CGFloat
    let itemWidth: CGFloat
    let content: (Int) -> Content
    
    @GestureState private var dragOffset: CGFloat = 0
    
    public init(
        currentIndex: Binding<Int>,
        itemCount: Int,
        radius: CGFloat = 200,
        itemWidth: CGFloat = 150,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self._currentIndex = currentIndex
        self.itemCount = itemCount
        self.radius = radius
        self.itemWidth = itemWidth
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<itemCount, id: \.self) { index in
                let angle = angleForIndex(index)
                let offset = offsetForAngle(angle)
                let scale = scaleForAngle(angle)
                let opacity = opacityForAngle(angle)
                
                content(index)
                    .frame(width: itemWidth)
                    .scaleEffect(scale)
                    .offset(x: offset.x, y: offset.y)
                    .zIndex(Double(itemCount) - abs(angleNormalized(angle)))
                    .opacity(opacity)
                    .rotation3DEffect(
                        .degrees(angle),
                        axis: (0, 1, 0),
                        perspective: 0.5
                    )
            }
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        withAnimation(.spring()) {
                            currentIndex = (currentIndex + 1) % itemCount
                        }
                    } else if value.translation.width > threshold {
                        withAnimation(.spring()) {
                            currentIndex = (currentIndex - 1 + itemCount) % itemCount
                        }
                    }
                }
        )
        .animation(.spring(), value: currentIndex)
    }
    
    private func angleForIndex(_ index: Int) -> Double {
        let baseAngle = 360.0 / Double(itemCount)
        let offsetAngle = Double(currentIndex) * baseAngle
        let dragAngle = Double(dragOffset) * 0.5
        return Double(index) * baseAngle - offsetAngle + dragAngle
    }
    
    private func angleNormalized(_ angle: Double) -> Double {
        var normalized = angle.truncatingRemainder(dividingBy: 360)
        if normalized > 180 { normalized -= 360 }
        if normalized < -180 { normalized += 360 }
        return normalized
    }
    
    private func offsetForAngle(_ angle: Double) -> CGPoint {
        let rad = angle * .pi / 180
        return CGPoint(
            x: sin(rad) * radius,
            y: 0
        )
    }
    
    private func scaleForAngle(_ angle: Double) -> CGFloat {
        let normalized = abs(angleNormalized(angle))
        return 1.0 - (normalized / 180.0) * 0.3
    }
    
    private func opacityForAngle(_ angle: Double) -> Double {
        let normalized = abs(angleNormalized(angle))
        return 1.0 - (normalized / 180.0) * 0.5
    }
}

// MARK: - Perspective Scroll

/// Scroll view with 3D perspective effect
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct PerspectiveScroll<Content: View>: View {
    
    let angle: Double
    let axis: Axis3D
    let perspective: Double
    let content: () -> Content
    
    public init(
        angle: Double = 30,
        axis: Axis3D = .x,
        perspective: Double = 0.5,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.angle = angle
        self.axis = axis
        self.perspective = perspective
        self.content = content
    }
    
    public var body: some View {
        ScrollView {
            content()
        }
        .rotation3DEffect(
            .degrees(angle),
            axis: axis.values,
            perspective: perspective
        )
    }
}

// MARK: - 3D Fold Effect

/// Folding paper effect
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct FoldEffect<Content: View>: View {
    
    @Binding var foldProgress: CGFloat
    let folds: Int
    let content: () -> Content
    
    public init(
        foldProgress: Binding<CGFloat>,
        folds: Int = 3,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._foldProgress = foldProgress
        self.folds = folds
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let foldHeight = geometry.size.height / CGFloat(folds)
            
            VStack(spacing: 0) {
                ForEach(0..<folds, id: \.self) { index in
                    let angle = foldProgress * 90 * (index % 2 == 0 ? 1 : -1)
                    let anchor: UnitPoint = index % 2 == 0 ? .bottom : .top
                    
                    content()
                        .frame(height: foldHeight)
                        .clipped()
                        .rotation3DEffect(
                            .degrees(angle),
                            axis: (1, 0, 0),
                            anchor: anchor,
                            perspective: 0.5
                        )
                        .offset(y: -CGFloat(index) * foldHeight * foldProgress * 0.1)
                }
            }
        }
    }
}

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension View {
    
    /// Applies 3D rotation on tap
    func rotate3DOnTap(
        degrees: Double = 360,
        axis: Axis3D = .y,
        duration: Double = 0.6
    ) -> some View {
        modifier(Rotate3DOnTapModifier(degrees: degrees, axis: axis, duration: duration))
    }
    
    /// Applies continuous 3D rotation
    func rotate3DContinuous(
        axis: Axis3D = .y,
        duration: Double = 3.0
    ) -> some View {
        modifier(Rotate3DContinuousModifier(axis: axis, duration: duration))
    }
    
    /// Applies parallax 3D effect based on device motion
    func parallax3D(intensity: Double = 20) -> some View {
        modifier(Parallax3DModifier(intensity: intensity))
    }
}

// MARK: - Supporting Modifiers

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct Rotate3DOnTapModifier: ViewModifier {
    let degrees: Double
    let axis: Axis3D
    let duration: Double
    
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(rotation), axis: axis.values, perspective: 0.5)
            .onTapGesture {
                withAnimation(.spring(response: duration, dampingFraction: 0.7)) {
                    rotation += degrees
                }
            }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct Rotate3DContinuousModifier: ViewModifier {
    let axis: Axis3D
    let duration: Double
    
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(rotation), axis: axis.values, perspective: 0.5)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct Parallax3DModifier: ViewModifier {
    let intensity: Double
    
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(rotationX), axis: (1, 0, 0), perspective: 0.5)
            .rotation3DEffect(.degrees(rotationY), axis: (0, 1, 0), perspective: 0.5)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = value.location.x
                        let y = value.location.y
                        rotationY = (x - 150) / 150 * intensity
                        rotationX = -(y - 150) / 150 * intensity
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            rotationX = 0
                            rotationY = 0
                        }
                    }
            )
    }
}
