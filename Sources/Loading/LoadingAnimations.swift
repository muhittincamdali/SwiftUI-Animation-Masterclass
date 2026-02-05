//
//  LoadingAnimations.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Loading Animation Type

/// 15+ Production-ready loading animations
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum LoadingAnimationType: String, CaseIterable, Sendable {
    case spinner
    case dots
    case pulse
    case bars
    case circular
    case wave
    case bounce
    case gradient
    case orbit
    case ripple
    case morphing
    case typing
    case skeleton
    case shimmer
    case heartbeat
}

// MARK: - Loading View

/// Customizable loading animation view
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct LoadingView: View {
    
    // MARK: - Properties
    
    let type: LoadingAnimationType
    let color: Color
    let size: CGFloat
    let speed: Double
    
    @State private var isAnimating = false
    @State private var phase: CGFloat = 0
    
    // MARK: - Initialization
    
    public init(
        type: LoadingAnimationType = .spinner,
        color: Color = .primary,
        size: CGFloat = 40,
        speed: Double = 1.0
    ) {
        self.type = type
        self.color = color
        self.size = size
        self.speed = speed
    }
    
    // MARK: - Body
    
    public var body: some View {
        content
            .frame(width: size, height: size)
            .onAppear { isAnimating = true }
    }
    
    @ViewBuilder
    private var content: some View {
        switch type {
        case .spinner:
            SpinnerLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .dots:
            DotsLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .pulse:
            PulseLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .bars:
            BarsLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .circular:
            CircularLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .wave:
            WaveLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .bounce:
            BounceLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .gradient:
            GradientLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .orbit:
            OrbitLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .ripple:
            RippleLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .morphing:
            MorphingLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .typing:
            TypingLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .skeleton:
            SkeletonLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .shimmer:
            ShimmerLoading(color: color, isAnimating: isAnimating, speed: speed)
            
        case .heartbeat:
            HeartbeatLoading(color: color, isAnimating: isAnimating, speed: speed)
        }
    }
}

// MARK: - Spinner Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct SpinnerLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1 / speed).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Dots Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct DotsLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var scales: [CGFloat] = [1, 1, 1]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .scaleEffect(scales[index])
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.6 / speed)
                    .repeatForever()
                    .delay(Double(i) * 0.2 / speed)
                ) {
                    scales[i] = 0.5
                }
            }
        }
    }
}

// MARK: - Pulse Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct PulseLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .scaleEffect(scale)
                .opacity(opacity)
            
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1 / speed).repeatForever(autoreverses: false)) {
                scale = 2
                opacity = 0
            }
        }
    }
}

// MARK: - Bars Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct BarsLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var heights: [CGFloat] = Array(repeating: 10, count: 5)
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 4, height: heights[index])
            }
        }
        .onAppear {
            for i in 0..<5 {
                withAnimation(
                    .easeInOut(duration: 0.5 / speed)
                    .repeatForever()
                    .delay(Double(i) * 0.1 / speed)
                ) {
                    heights[i] = 30
                }
            }
        }
    }
}

// MARK: - Circular Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct CircularLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var trim: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: trim)
            .stroke(
                AngularGradient(
                    colors: [color.opacity(0), color],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 2 / speed).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 1 / speed).repeatForever()) {
                    trim = 0.8
                }
            }
    }
}

// MARK: - Wave Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct WaveLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        WaveShape(phase: phase)
            .stroke(color, lineWidth: 3)
            .onAppear {
                withAnimation(.linear(duration: 1 / speed).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
    }
}

private struct WaveShape: Shape {
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        let amplitude: CGFloat = rect.height / 4
        
        path.move(to: CGPoint(x: 0, y: midY))
        
        for x in stride(from: 0, to: rect.width, by: 1) {
            let relativeX = x / rect.width
            let y = midY + sin(relativeX * .pi * 4 + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

// MARK: - Bounce Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct BounceLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var offsets: [CGFloat] = [0, 0, 0]
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                    .offset(y: offsets[index])
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.5 / speed)
                    .repeatForever()
                    .delay(Double(i) * 0.15 / speed)
                ) {
                    offsets[i] = -15
                }
            }
        }
    }
}

// MARK: - Gradient Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct GradientLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    colors: [color, color.opacity(0.5), color.opacity(0.2), color.opacity(0.5), color],
                    center: .center
                ),
                lineWidth: 4
            )
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1.5 / speed).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Orbit Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct OrbitLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 2)
            
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .offset(x: 16)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 1 / speed).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Ripple Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct RippleLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var scales: [CGFloat] = [0, 0, 0]
    @State private var opacities: [Double] = [1, 1, 1]
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(color, lineWidth: 2)
                    .scaleEffect(scales[index])
                    .opacity(opacities[index])
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeOut(duration: 1.5 / speed)
                    .repeatForever(autoreverses: false)
                    .delay(Double(i) * 0.5 / speed)
                ) {
                    scales[i] = 1
                    opacities[i] = 0
                }
            }
        }
    }
}

// MARK: - Morphing Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct MorphingLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var cornerRadius: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .frame(width: 30, height: 30)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8 / speed).repeatForever()) {
                    cornerRadius = 15
                }
            }
    }
}

// MARK: - Typing Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct TypingLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var opacities: [Double] = [0.3, 0.3, 0.3]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .opacity(opacities[index])
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.4 / speed)
                    .repeatForever()
                    .delay(Double(i) * 0.2 / speed)
                ) {
                    opacities[i] = 1
                }
            }
        }
    }
}

// MARK: - Skeleton Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct SkeletonLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var phase: CGFloat = -1
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.clear, color.opacity(0.3), .clear],
                            startPoint: UnitPoint(x: phase, y: 0.5),
                            endPoint: UnitPoint(x: phase + 1, y: 0.5)
                        )
                    )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5 / speed).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}

// MARK: - Shimmer Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct ShimmerLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.opacity(0.2))
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, color.opacity(0.4), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.4)
                        .offset(x: -geometry.size.width * 0.4 + phase * geometry.size.width * 1.8)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onAppear {
                withAnimation(.linear(duration: 1.5 / speed).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Heartbeat Loading

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct HeartbeatLoading: View {
    let color: Color
    let isAnimating: Bool
    let speed: Double
    
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 30))
            .foregroundStyle(color)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.15 / speed)
                    .repeatForever()
                ) {
                    scale = 1.2
                }
            }
    }
}

// MARK: - Loading Button

/// Button with integrated loading state
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct LoadingButton<Label: View>: View {
    
    let isLoading: Bool
    let loadingType: LoadingAnimationType
    let action: () -> Void
    let label: () -> Label
    
    public init(
        isLoading: Bool,
        loadingType: LoadingAnimationType = .spinner,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.isLoading = isLoading
        self.loadingType = loadingType
        self.action = action
        self.label = label
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack {
                label()
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    LoadingView(type: loadingType, size: 20)
                }
            }
        }
        .disabled(isLoading)
    }
}
