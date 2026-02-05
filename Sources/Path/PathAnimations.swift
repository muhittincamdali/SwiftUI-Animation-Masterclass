//
//  PathAnimations.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Path Animation Types

/// Types of path-based animations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum PathAnimationType: Sendable {
    case draw           // Drawing path animation
    case followPath     // Object following path
    case morphPath      // Morphing between paths
    case dashOffset     // Animated dash pattern
    case trimPath       // Trim animation
}

// MARK: - Animated Path Shape

/// Shape with drawing animation
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct AnimatedPathShape: Shape {
    
    var progress: CGFloat
    let path: Path
    
    public init(progress: CGFloat, path: Path) {
        self.progress = progress
        self.path = path
    }
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    public func path(in rect: CGRect) -> Path {
        path.trimmedPath(from: 0, to: progress)
    }
}

// MARK: - Drawing Animation View

/// Animates drawing of a path
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct DrawingPathView: View {
    
    let path: Path
    let strokeColor: Color
    let lineWidth: CGFloat
    let duration: Double
    
    @State private var progress: CGFloat = 0
    @Binding var trigger: Bool
    
    public init(
        path: Path,
        strokeColor: Color = .primary,
        lineWidth: CGFloat = 2,
        duration: Double = 1.0,
        trigger: Binding<Bool>
    ) {
        self.path = path
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.duration = duration
        self._trigger = trigger
    }
    
    public var body: some View {
        AnimatedPathShape(progress: progress, path: path)
            .stroke(strokeColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    progress = 0
                    withAnimation(.easeInOut(duration: duration)) {
                        progress = 1
                    }
                }
            }
    }
}

// MARK: - Path Following Animation

/// Animates an element following a path
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct PathFollowingView<Content: View>: View {
    
    let path: Path
    let duration: Double
    let autoStart: Bool
    let repeatForever: Bool
    let content: () -> Content
    
    @State private var progress: CGFloat = 0
    
    public init(
        path: Path,
        duration: Double = 2.0,
        autoStart: Bool = true,
        repeatForever: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.path = path
        self.duration = duration
        self.autoStart = autoStart
        self.repeatForever = repeatForever
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            // Path visualization (optional)
            path
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            
            // Animated content
            content()
                .position(positionOnPath(at: progress))
        }
        .onAppear {
            if autoStart {
                startAnimation()
            }
        }
    }
    
    private func positionOnPath(at progress: CGFloat) -> CGPoint {
        let trimmedPath = path.trimmedPath(from: 0, to: max(0.001, progress))
        return trimmedPath.currentPoint ?? .zero
    }
    
    private func startAnimation() {
        if repeatForever {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                progress = 1
            }
        } else {
            withAnimation(.linear(duration: duration)) {
                progress = 1
            }
        }
    }
}

// MARK: - Morphing Path

/// Morphs between two paths
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct MorphingPathView: View {
    
    let startPath: Path
    let endPath: Path
    let fillColor: Color
    let duration: Double
    
    @Binding var isMorphed: Bool
    
    public init(
        startPath: Path,
        endPath: Path,
        fillColor: Color = .blue,
        duration: Double = 0.5,
        isMorphed: Binding<Bool>
    ) {
        self.startPath = startPath
        self.endPath = endPath
        self.fillColor = fillColor
        self.duration = duration
        self._isMorphed = isMorphed
    }
    
    public var body: some View {
        MorphingShape(fromPath: startPath, toPath: endPath, progress: isMorphed ? 1 : 0)
            .fill(fillColor)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isMorphed)
    }
}

private struct MorphingShape: Shape {
    let fromPath: Path
    let toPath: Path
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        // Simple interpolation - for complex morphing, consider using matched control points
        if progress < 0.5 {
            return fromPath
        } else {
            return toPath
        }
    }
}

// MARK: - Dash Offset Animation

/// Animated dashed stroke
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct DashOffsetAnimationView: View {
    
    let path: Path
    let strokeColor: Color
    let lineWidth: CGFloat
    let dashPattern: [CGFloat]
    let duration: Double
    
    @State private var dashOffset: CGFloat = 0
    
    public init(
        path: Path,
        strokeColor: Color = .primary,
        lineWidth: CGFloat = 2,
        dashPattern: [CGFloat] = [10, 5],
        duration: Double = 1.0
    ) {
        self.path = path
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.dashPattern = dashPattern
        self.duration = duration
    }
    
    public var body: some View {
        path
            .stroke(
                strokeColor,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    dash: dashPattern,
                    dashPhase: dashOffset
                )
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    dashOffset = dashPattern.reduce(0, +)
                }
            }
    }
}

// MARK: - Preset Paths

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct PathPresets {
    
    /// Circle path
    public static func circle(in rect: CGRect) -> Path {
        Path(ellipseIn: rect)
    }
    
    /// Star path
    public static func star(in rect: CGRect, points: Int = 5) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        
        for i in 0..<(points * 2) {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
    
    /// Heart path
    public static func heart(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width / 2, y: height * 0.25))
        
        path.addCurve(
            to: CGPoint(x: 0, y: height * 0.4),
            control1: CGPoint(x: width / 2, y: 0),
            control2: CGPoint(x: 0, y: 0)
        )
        
        path.addCurve(
            to: CGPoint(x: width / 2, y: height),
            control1: CGPoint(x: 0, y: height * 0.7),
            control2: CGPoint(x: width / 2, y: height * 0.7)
        )
        
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.4),
            control1: CGPoint(x: width / 2, y: height * 0.7),
            control2: CGPoint(x: width, y: height * 0.7)
        )
        
        path.addCurve(
            to: CGPoint(x: width / 2, y: height * 0.25),
            control1: CGPoint(x: width, y: 0),
            control2: CGPoint(x: width / 2, y: 0)
        )
        
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }
    
    /// Wave path
    public static func wave(in rect: CGRect, frequency: Int = 3, amplitude: CGFloat = 20) -> Path {
        var path = Path()
        let midY = rect.midY
        let step: CGFloat = 1
        
        path.move(to: CGPoint(x: 0, y: midY))
        
        for x in stride(from: 0, to: rect.width, by: step) {
            let relativeX = x / rect.width
            let y = midY + sin(relativeX * .pi * 2 * CGFloat(frequency)) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
    
    /// Spiral path
    public static func spiral(in rect: CGRect, turns: Double = 3) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let maxRadius = min(rect.width, rect.height) / 2
        
        let steps = Int(turns * 360)
        for i in 0...steps {
            let angle = Double(i) * .pi / 180
            let radius = maxRadius * (Double(i) / Double(steps))
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
    
    /// Checkmark path
    public static func checkmark(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.1, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.8))
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.2))
        
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }
    
    /// Arrow path
    public static func arrow(in rect: CGRect, direction: Edge = .trailing) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        switch direction {
        case .trailing:
            path.move(to: CGPoint(x: 0, y: height * 0.5))
            path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.5))
            path.move(to: CGPoint(x: width * 0.6, y: height * 0.2))
            path.addLine(to: CGPoint(x: width, y: height * 0.5))
            path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.8))
        case .leading:
            path.move(to: CGPoint(x: width, y: height * 0.5))
            path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.5))
            path.move(to: CGPoint(x: width * 0.4, y: height * 0.2))
            path.addLine(to: CGPoint(x: 0, y: height * 0.5))
            path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.8))
        case .top:
            path.move(to: CGPoint(x: width * 0.5, y: height))
            path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.2))
            path.move(to: CGPoint(x: width * 0.2, y: height * 0.4))
            path.addLine(to: CGPoint(x: width * 0.5, y: 0))
            path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.4))
        case .bottom:
            path.move(to: CGPoint(x: width * 0.5, y: 0))
            path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.8))
            path.move(to: CGPoint(x: width * 0.2, y: height * 0.6))
            path.addLine(to: CGPoint(x: width * 0.5, y: height))
            path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.6))
        }
        
        return path.offsetBy(dx: rect.minX, dy: rect.minY)
    }
}

// MARK: - Signature Animation

/// Animated signature drawing effect
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SignatureView: View {
    
    let text: String
    let font: Font
    let strokeColor: Color
    let duration: Double
    
    @State private var progress: CGFloat = 0
    @Binding var trigger: Bool
    
    public init(
        text: String,
        font: Font = .largeTitle,
        strokeColor: Color = .primary,
        duration: Double = 2.0,
        trigger: Binding<Bool>
    ) {
        self.text = text
        self.font = font
        self.strokeColor = strokeColor
        self.duration = duration
        self._trigger = trigger
    }
    
    public var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(.clear)
            .overlay(
                GeometryReader { geometry in
                    Text(text)
                        .font(font)
                        .foregroundStyle(strokeColor)
                        .mask(
                            Rectangle()
                                .size(
                                    width: geometry.size.width * progress,
                                    height: geometry.size.height
                                )
                        )
                }
            )
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    progress = 0
                    withAnimation(.easeInOut(duration: duration)) {
                        progress = 1
                    }
                }
            }
    }
}
