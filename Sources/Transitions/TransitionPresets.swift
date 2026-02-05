//
//  TransitionPresets.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Transition Presets (20+)

/// Production-ready transition presets for SwiftUI
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct TransitionPresets {
    
    // MARK: - Fade Transitions (4)
    
    /// Simple fade transition
    public static var fade: AnyTransition {
        .opacity
    }
    
    /// Fade with scale
    public static var fadeScale: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.8))
    }
    
    /// Fade with blur
    public static var fadeBlur: AnyTransition {
        .modifier(
            active: FadeBlurModifier(opacity: 0, blur: 10),
            identity: FadeBlurModifier(opacity: 1, blur: 0)
        )
    }
    
    /// Crossfade with custom duration
    public static func crossfade(duration: Double = 0.3) -> AnyTransition {
        .opacity.animation(.easeInOut(duration: duration))
    }
    
    // MARK: - Slide Transitions (4)
    
    /// Slide from leading edge
    public static var slideLeading: AnyTransition {
        .move(edge: .leading)
    }
    
    /// Slide from trailing edge
    public static var slideTrailing: AnyTransition {
        .move(edge: .trailing)
    }
    
    /// Slide from top
    public static var slideTop: AnyTransition {
        .move(edge: .top)
    }
    
    /// Slide from bottom
    public static var slideBottom: AnyTransition {
        .move(edge: .bottom)
    }
    
    // MARK: - Zoom Transitions (3)
    
    /// Zoom in from center
    public static var zoomIn: AnyTransition {
        .scale(scale: 0).combined(with: .opacity)
    }
    
    /// Zoom out to center
    public static var zoomOut: AnyTransition {
        .scale(scale: 2).combined(with: .opacity)
    }
    
    /// Zoom with rotation
    public static var zoomRotate: AnyTransition {
        .modifier(
            active: ZoomRotateModifier(scale: 0, rotation: -180, opacity: 0),
            identity: ZoomRotateModifier(scale: 1, rotation: 0, opacity: 1)
        )
    }
    
    // MARK: - Flip Transitions (3)
    
    /// Horizontal flip
    public static var flipHorizontal: AnyTransition {
        .modifier(
            active: FlipModifier(angle: 90, axis: (x: 0, y: 1, z: 0)),
            identity: FlipModifier(angle: 0, axis: (x: 0, y: 1, z: 0))
        )
    }
    
    /// Vertical flip
    public static var flipVertical: AnyTransition {
        .modifier(
            active: FlipModifier(angle: 90, axis: (x: 1, y: 0, z: 0)),
            identity: FlipModifier(angle: 0, axis: (x: 1, y: 0, z: 0))
        )
    }
    
    /// Diagonal flip
    public static var flipDiagonal: AnyTransition {
        .modifier(
            active: FlipModifier(angle: 90, axis: (x: 1, y: 1, z: 0)),
            identity: FlipModifier(angle: 0, axis: (x: 1, y: 1, z: 0))
        )
    }
    
    // MARK: - Creative Transitions (6)
    
    /// Iris wipe transition
    public static var iris: AnyTransition {
        .modifier(
            active: IrisModifier(progress: 0),
            identity: IrisModifier(progress: 1)
        )
    }
    
    /// Curtain reveal
    public static var curtain: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: CurtainModifier(progress: 0, direction: .horizontal),
                identity: CurtainModifier(progress: 1, direction: .horizontal)
            ),
            removal: .modifier(
                active: CurtainModifier(progress: 1, direction: .horizontal),
                identity: CurtainModifier(progress: 0, direction: .horizontal)
            )
        )
    }
    
    /// Pixelate transition
    public static var pixelate: AnyTransition {
        .modifier(
            active: PixelateModifier(pixelSize: 20, opacity: 0),
            identity: PixelateModifier(pixelSize: 1, opacity: 1)
        )
    }
    
    /// Swirl transition
    public static var swirl: AnyTransition {
        .modifier(
            active: SwirlModifier(rotation: 720, scale: 0, opacity: 0),
            identity: SwirlModifier(rotation: 0, scale: 1, opacity: 1)
        )
    }
    
    /// Fold transition
    public static var fold: AnyTransition {
        .modifier(
            active: FoldModifier(angle: 90, anchor: .leading),
            identity: FoldModifier(angle: 0, anchor: .leading)
        )
    }
    
    /// Cube rotation
    public static var cube: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: CubeModifier(angle: -90, direction: .leading),
                identity: CubeModifier(angle: 0, direction: .leading)
            ),
            removal: .modifier(
                active: CubeModifier(angle: 90, direction: .trailing),
                identity: CubeModifier(angle: 0, direction: .trailing)
            )
        )
    }
}

// MARK: - Supporting Modifiers

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct FadeBlurModifier: ViewModifier {
    let opacity: Double
    let blur: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .blur(radius: blur)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct ZoomRotateModifier: ViewModifier {
    let scale: Double
    let rotation: Double
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct FlipModifier: ViewModifier {
    let angle: Double
    let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(angle), axis: axis, perspective: 0.5)
            .opacity(abs(angle) > 89 ? 0 : 1)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct IrisModifier: ViewModifier {
    var progress: Double
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(Circle().scale(progress))
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct CurtainModifier: ViewModifier {
    var progress: Double
    let direction: Axis
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .mask(
                Rectangle()
                    .scaleEffect(
                        x: direction == .horizontal ? progress : 1,
                        y: direction == .vertical ? progress : 1
                    )
            )
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct PixelateModifier: ViewModifier {
    let pixelSize: Double
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct SwirlModifier: ViewModifier {
    let rotation: Double
    let scale: Double
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct FoldModifier: ViewModifier {
    let angle: Double
    let anchor: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0),
                anchor: anchor,
                perspective: 0.5
            )
            .opacity(angle > 85 ? 0 : 1)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct CubeModifier: ViewModifier {
    let angle: Double
    let direction: HorizontalEdge
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0),
                anchor: direction == .leading ? .leading : .trailing,
                perspective: 0.5
            )
    }
}

// MARK: - View Extension for Transitions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension View {
    
    /// Applies a preset transition with animation
    func transition(_ preset: AnyTransition, animation: Animation = .spring()) -> some View {
        self.transition(preset).animation(animation, value: UUID())
    }
}

// MARK: - Transition Builders

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension AnyTransition {
    
    /// Creates a slide transition from specified edge with offset
    static func slide(edge: Edge, offset: CGFloat = 100) -> AnyTransition {
        .modifier(
            active: SlideOffsetModifier(edge: edge, offset: offset, opacity: 0),
            identity: SlideOffsetModifier(edge: edge, offset: 0, opacity: 1)
        )
    }
    
    /// Creates a bounce transition
    static var bounce: AnyTransition {
        .modifier(
            active: BounceTransitionModifier(scale: 0.3, offsetY: 20),
            identity: BounceTransitionModifier(scale: 1, offsetY: 0)
        )
    }
    
    /// Creates a pop transition
    static var pop: AnyTransition {
        .scale(scale: 1.2).combined(with: .opacity)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct SlideOffsetModifier: ViewModifier {
    let edge: Edge
    let offset: CGFloat
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading ? -offset : (edge == .trailing ? offset : 0),
                y: edge == .top ? -offset : (edge == .bottom ? offset : 0)
            )
            .opacity(opacity)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct BounceTransitionModifier: ViewModifier {
    let scale: Double
    let offsetY: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .offset(y: offsetY)
    }
}
