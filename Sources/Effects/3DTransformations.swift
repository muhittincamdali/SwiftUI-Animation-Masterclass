//
//  3DTransformations.swift
//  SwiftUI-Animation-Masterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - 3D Transform Configuration

/// Configuration for 3D transformation effects.
///
/// Use this struct to define how elements should transform
/// in three-dimensional space.
public struct Transform3DConfiguration {
    /// Rotation angle around the X-axis in degrees.
    public var rotationX: Double
    
    /// Rotation angle around the Y-axis in degrees.
    public var rotationY: Double
    
    /// Rotation angle around the Z-axis in degrees.
    public var rotationZ: Double
    
    /// Translation along the X-axis.
    public var translateX: CGFloat
    
    /// Translation along the Y-axis.
    public var translateY: CGFloat
    
    /// Translation along the Z-axis (affects perceived depth).
    public var translateZ: CGFloat
    
    /// Scale factor along the X-axis.
    public var scaleX: CGFloat
    
    /// Scale factor along the Y-axis.
    public var scaleY: CGFloat
    
    /// Scale factor along the Z-axis.
    public var scaleZ: CGFloat
    
    /// Perspective value for 3D depth effect.
    public var perspective: CGFloat
    
    /// The anchor point for transformations.
    public var anchor: UnitPoint
    
    /// Creates a 3D transform configuration.
    /// - Parameters:
    ///   - rotationX: X-axis rotation in degrees. Defaults to 0.
    ///   - rotationY: Y-axis rotation in degrees. Defaults to 0.
    ///   - rotationZ: Z-axis rotation in degrees. Defaults to 0.
    ///   - translateX: X translation. Defaults to 0.
    ///   - translateY: Y translation. Defaults to 0.
    ///   - translateZ: Z translation. Defaults to 0.
    ///   - scaleX: X scale factor. Defaults to 1.
    ///   - scaleY: Y scale factor. Defaults to 1.
    ///   - scaleZ: Z scale factor. Defaults to 1.
    ///   - perspective: Perspective depth. Defaults to 1.
    ///   - anchor: Transform anchor point. Defaults to center.
    public init(
        rotationX: Double = 0,
        rotationY: Double = 0,
        rotationZ: Double = 0,
        translateX: CGFloat = 0,
        translateY: CGFloat = 0,
        translateZ: CGFloat = 0,
        scaleX: CGFloat = 1,
        scaleY: CGFloat = 1,
        scaleZ: CGFloat = 1,
        perspective: CGFloat = 1,
        anchor: UnitPoint = .center
    ) {
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.rotationZ = rotationZ
        self.translateX = translateX
        self.translateY = translateY
        self.translateZ = translateZ
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.scaleZ = scaleZ
        self.perspective = perspective
        self.anchor = anchor
    }
    
    /// Identity transform with no modifications.
    public static let identity = Transform3DConfiguration()
    
    /// A subtle tilt transform.
    public static let subtleTilt = Transform3DConfiguration(rotationX: 5, rotationY: 5)
    
    /// A card flip transform (Y-axis).
    public static let cardFlip = Transform3DConfiguration(rotationY: 180, perspective: 0.5)
    
    /// A page turn transform.
    public static let pageTurn = Transform3DConfiguration(rotationY: -90, perspective: 0.3, anchor: .leading)
}

// MARK: - 3D Transform Modifier

/// A view modifier that applies 3D transformations.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct Transform3DModifier: ViewModifier {
    /// The transformation configuration.
    public let configuration: Transform3DConfiguration
    
    /// Creates a 3D transform modifier.
    /// - Parameter configuration: The transform configuration.
    public init(configuration: Transform3DConfiguration) {
        self.configuration = configuration
    }
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(
                x: configuration.scaleX,
                y: configuration.scaleY,
                anchor: configuration.anchor
            )
            .rotation3DEffect(
                .degrees(configuration.rotationX),
                axis: (x: 1, y: 0, z: 0),
                anchor: configuration.anchor,
                perspective: configuration.perspective
            )
            .rotation3DEffect(
                .degrees(configuration.rotationY),
                axis: (x: 0, y: 1, z: 0),
                anchor: configuration.anchor,
                perspective: configuration.perspective
            )
            .rotation3DEffect(
                .degrees(configuration.rotationZ),
                axis: (x: 0, y: 0, z: 1),
                anchor: configuration.anchor
            )
            .offset(x: configuration.translateX, y: configuration.translateY)
    }
}

// MARK: - Flip Card View

/// A view that can flip between front and back content.
///
/// `FlipCardView` creates a card that can be flipped with a
/// realistic 3D animation to reveal different content on each side.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct FlipCardView<Front: View, Back: View>: View {
    /// The front content of the card.
    private let front: Front
    
    /// The back content of the card.
    private let back: Back
    
    /// Whether the card is flipped.
    @Binding private var isFlipped: Bool
    
    /// The flip animation duration.
    private let duration: Double
    
    /// The flip axis.
    private let axis: FlipAxis
    
    /// The perspective for 3D effect.
    private let perspective: Double
    
    /// Defines the axis for card flip.
    public enum FlipAxis {
        case horizontal
        case vertical
        
        var rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat) {
            switch self {
            case .horizontal:
                return (0, 1, 0)
            case .vertical:
                return (1, 0, 0)
            }
        }
    }
    
    /// Creates a flip card view.
    /// - Parameters:
    ///   - isFlipped: Binding to the flip state.
    ///   - axis: The flip axis. Defaults to horizontal.
    ///   - duration: Flip animation duration. Defaults to 0.6.
    ///   - perspective: 3D perspective. Defaults to 0.5.
    ///   - front: Front content builder.
    ///   - back: Back content builder.
    public init(
        isFlipped: Binding<Bool>,
        axis: FlipAxis = .horizontal,
        duration: Double = 0.6,
        perspective: Double = 0.5,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._isFlipped = isFlipped
        self.axis = axis
        self.duration = duration
        self.perspective = perspective
        self.front = front()
        self.back = back()
    }
    
    public var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: axis.rotationAxis,
                    perspective: perspective
                )
            
            back
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: axis.rotationAxis,
                    perspective: perspective
                )
        }
        .animation(.easeInOut(duration: duration), value: isFlipped)
    }
}

// MARK: - Cube Transition

/// A cube-like transition effect for view changes.
///
/// `CubeTransition` creates the illusion of rotating a 3D cube
/// to reveal different faces containing different content.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct CubeTransition<Content: View>: View {
    /// The current face index.
    @Binding private var currentFace: Int
    
    /// The content views for each face.
    private let faces: [Content]
    
    /// The transition direction.
    private let direction: TransitionDirection
    
    /// The animation duration.
    private let duration: Double
    
    /// Cube transition direction.
    public enum TransitionDirection {
        case horizontal
        case vertical
    }
    
    /// Creates a cube transition view.
    /// - Parameters:
    ///   - currentFace: Binding to current face index.
    ///   - direction: Transition direction. Defaults to horizontal.
    ///   - duration: Animation duration. Defaults to 0.5.
    ///   - faces: Array of content views for each face.
    public init(
        currentFace: Binding<Int>,
        direction: TransitionDirection = .horizontal,
        duration: Double = 0.5,
        faces: [Content]
    ) {
        self._currentFace = currentFace
        self.direction = direction
        self.duration = duration
        self.faces = faces
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<faces.count, id: \.self) { index in
                    faces[index]
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .rotation3DEffect(
                            rotationAngle(for: index),
                            axis: rotationAxis,
                            anchor: anchor(for: index),
                            perspective: 0.5
                        )
                        .opacity(opacity(for: index))
                }
            }
            .animation(.easeInOut(duration: duration), value: currentFace)
        }
    }
    
    private var rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch direction {
        case .horizontal:
            return (0, 1, 0)
        case .vertical:
            return (1, 0, 0)
        }
    }
    
    private func rotationAngle(for index: Int) -> Angle {
        let diff = index - currentFace
        return .degrees(Double(diff) * 90)
    }
    
    private func anchor(for index: Int) -> UnitPoint {
        let diff = index - currentFace
        switch direction {
        case .horizontal:
            return diff > 0 ? .trailing : (diff < 0 ? .leading : .center)
        case .vertical:
            return diff > 0 ? .bottom : (diff < 0 ? .top : .center)
        }
    }
    
    private func opacity(for index: Int) -> Double {
        let diff = abs(index - currentFace)
        return diff <= 1 ? 1 : 0
    }
}

// MARK: - Carousel 3D

/// A 3D carousel view that displays items in a rotating cylinder.
///
/// `Carousel3D` arranges items in a circle and allows rotation
/// through gestures or programmatic control.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct Carousel3D<Item: Identifiable, Content: View>: View {
    /// The items to display.
    private let items: [Item]
    
    /// The content builder for each item.
    private let content: (Item) -> Content
    
    /// The currently selected item index.
    @Binding private var selectedIndex: Int
    
    /// The radius of the carousel.
    private let radius: CGFloat
    
    /// The item spacing angle in degrees.
    private let itemAngle: Double
    
    /// The perspective depth.
    private let perspective: Double
    
    /// Current drag rotation.
    @State private var dragRotation: Double = 0
    
    /// Whether the carousel is being dragged.
    @State private var isDragging: Bool = false
    
    /// Creates a 3D carousel.
    /// - Parameters:
    ///   - items: Items to display.
    ///   - selectedIndex: Binding to selected item index.
    ///   - radius: Carousel radius. Defaults to 200.
    ///   - perspective: 3D perspective. Defaults to 0.3.
    ///   - content: Content builder for each item.
    public init(
        items: [Item],
        selectedIndex: Binding<Int>,
        radius: CGFloat = 200,
        perspective: Double = 0.3,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self._selectedIndex = selectedIndex
        self.radius = radius
        self.perspective = perspective
        self.content = content
        self.itemAngle = 360.0 / Double(max(items.count, 1))
    }
    
    public var body: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .rotation3DEffect(
                        .degrees(itemAngle * Double(index) - currentRotation),
                        axis: (0, 1, 0),
                        perspective: perspective
                    )
                    .offset(x: xOffset(for: index), y: 0)
                    .zIndex(zIndex(for: index))
                    .opacity(opacity(for: index))
                    .scaleEffect(scale(for: index))
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    isDragging = true
                    dragRotation = Double(value.translation.width) * 0.5
                }
                .onEnded { value in
                    isDragging = false
                    let velocity = Double(value.predictedEndTranslation.width - value.translation.width)
                    let totalRotation = dragRotation + velocity * 0.3
                    let indexChange = Int(round(totalRotation / itemAngle))
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedIndex = (selectedIndex - indexChange + items.count) % items.count
                        dragRotation = 0
                    }
                }
        )
    }
    
    private var currentRotation: Double {
        Double(selectedIndex) * itemAngle + dragRotation
    }
    
    private func xOffset(for index: Int) -> CGFloat {
        let angle = (itemAngle * Double(index) - currentRotation) * .pi / 180
        return sin(angle) * radius
    }
    
    private func zIndex(for index: Int) -> Double {
        let angle = (itemAngle * Double(index) - currentRotation) * .pi / 180
        return cos(angle) * 100
    }
    
    private func opacity(for index: Int) -> Double {
        let angle = abs((itemAngle * Double(index) - currentRotation).truncatingRemainder(dividingBy: 360))
        let normalizedAngle = min(angle, 360 - angle)
        return max(0.3, 1 - normalizedAngle / 180)
    }
    
    private func scale(for index: Int) -> Double {
        let angle = (itemAngle * Double(index) - currentRotation) * .pi / 180
        let z = cos(angle)
        return 0.6 + z * 0.4
    }
}

// MARK: - Fold Animation

/// A fold animation effect that collapses or expands a view.
///
/// `FoldAnimation` creates a paper-folding effect useful for
/// revealing or hiding content in a unique way.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct FoldAnimationModifier: ViewModifier {
    /// Whether the view is folded.
    private let isFolded: Bool
    
    /// The number of fold segments.
    private let segments: Int
    
    /// The fold direction.
    private let direction: FoldDirection
    
    /// Fold direction options.
    public enum FoldDirection {
        case horizontal
        case vertical
    }
    
    /// Creates a fold animation modifier.
    /// - Parameters:
    ///   - isFolded: Whether the view is in folded state.
    ///   - segments: Number of fold segments. Defaults to 4.
    ///   - direction: Fold direction. Defaults to vertical.
    public init(isFolded: Bool, segments: Int = 4, direction: FoldDirection = .vertical) {
        self.isFolded = isFolded
        self.segments = max(2, segments)
        self.direction = direction
    }
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            let segmentSize = direction == .vertical
                ? geometry.size.height / CGFloat(segments)
                : geometry.size.width / CGFloat(segments)
            
            VStack(spacing: 0) {
                ForEach(0..<segments, id: \.self) { index in
                    content
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(y: -segmentSize * CGFloat(index))
                        .frame(height: segmentSize)
                        .clipped()
                        .rotation3DEffect(
                            .degrees(isFolded ? foldAngle(for: index) : 0),
                            axis: (direction == .vertical ? 1 : 0, direction == .horizontal ? 1 : 0, 0),
                            anchor: index % 2 == 0 ? .bottom : .top,
                            perspective: 0.3
                        )
                        .offset(y: isFolded ? foldOffset(for: index, segmentSize: segmentSize) : 0)
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isFolded)
    }
    
    private func foldAngle(for index: Int) -> Double {
        return index % 2 == 0 ? -90 : 90
    }
    
    private func foldOffset(for index: Int, segmentSize: CGFloat) -> CGFloat {
        return -segmentSize * CGFloat(index) * 0.9
    }
}

// MARK: - Stack Cards 3D

/// A 3D stack of cards that can be swiped through.
///
/// `StackCards3D` displays cards in a stacked arrangement with
/// depth perspective and swipe-to-dismiss functionality.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct StackCards3D<Item: Identifiable, Content: View>: View {
    /// The items to display as cards.
    private let items: [Item]
    
    /// The content builder for each card.
    private let content: (Item) -> Content
    
    /// The maximum number of visible cards.
    private let maxVisibleCards: Int
    
    /// The offset between cards.
    private let cardOffset: CGFloat
    
    /// Scale reduction per card.
    private let scaleReduction: CGFloat
    
    /// Callback when a card is swiped away.
    private let onSwipe: ((Item, SwipeDirection) -> Void)?
    
    /// Current card offset from dragging.
    @State private var dragOffset: CGSize = .zero
    
    /// Current card index.
    @State private var currentIndex: Int = 0
    
    /// Swipe direction.
    public enum SwipeDirection {
        case left
        case right
        case up
        case down
    }
    
    /// Creates a 3D card stack.
    /// - Parameters:
    ///   - items: Items to display.
    ///   - maxVisibleCards: Max visible cards. Defaults to 3.
    ///   - cardOffset: Offset between cards. Defaults to 10.
    ///   - scaleReduction: Scale reduction per card. Defaults to 0.05.
    ///   - onSwipe: Callback when card is swiped.
    ///   - content: Content builder for each card.
    public init(
        items: [Item],
        maxVisibleCards: Int = 3,
        cardOffset: CGFloat = 10,
        scaleReduction: CGFloat = 0.05,
        onSwipe: ((Item, SwipeDirection) -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.maxVisibleCards = maxVisibleCards
        self.cardOffset = cardOffset
        self.scaleReduction = scaleReduction
        self.onSwipe = onSwipe
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            ForEach(visibleItems.reversed()) { item in
                let index = items.firstIndex(where: { $0.id == item.id }) ?? 0
                let relativeIndex = index - currentIndex
                
                content(item)
                    .offset(y: CGFloat(relativeIndex) * cardOffset)
                    .scaleEffect(1 - CGFloat(relativeIndex) * scaleReduction)
                    .zIndex(Double(items.count - relativeIndex))
                    .offset(relativeIndex == 0 ? dragOffset : .zero)
                    .rotationEffect(relativeIndex == 0 ? .degrees(Double(dragOffset.width) / 20) : .zero)
                    .gesture(relativeIndex == 0 ? dragGesture : nil)
            }
        }
    }
    
    private var visibleItems: [Item] {
        let endIndex = min(currentIndex + maxVisibleCards, items.count)
        return Array(items[currentIndex..<endIndex])
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                let width = value.translation.width
                let height = value.translation.height
                
                if abs(width) > threshold || abs(height) > threshold {
                    let direction: SwipeDirection
                    if abs(width) > abs(height) {
                        direction = width > 0 ? .right : .left
                    } else {
                        direction = height > 0 ? .down : .up
                    }
                    
                    withAnimation(.spring(response: 0.3)) {
                        dragOffset = CGSize(
                            width: width > 0 ? 500 : -500,
                            height: height > 0 ? 500 : -500
                        )
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if currentIndex < items.count {
                            onSwipe?(items[currentIndex], direction)
                            currentIndex += 1
                            dragOffset = .zero
                        }
                    }
                } else {
                    withAnimation(.spring(response: 0.3)) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    /// Applies a 3D transformation to the view.
    /// - Parameter configuration: The transform configuration.
    /// - Returns: A view with 3D transformations applied.
    func transform3D(_ configuration: Transform3DConfiguration) -> some View {
        modifier(Transform3DModifier(configuration: configuration))
    }
    
    /// Applies a fold animation to the view.
    /// - Parameters:
    ///   - isFolded: Whether the view is folded.
    ///   - segments: Number of fold segments.
    ///   - direction: Fold direction.
    /// - Returns: A view with fold animation.
    func foldAnimation(
        isFolded: Bool,
        segments: Int = 4,
        direction: FoldAnimationModifier.FoldDirection = .vertical
    ) -> some View {
        modifier(FoldAnimationModifier(isFolded: isFolded, segments: segments, direction: direction))
    }
    
    /// Applies a perspective tilt effect based on drag gestures.
    /// - Parameters:
    ///   - maxAngle: Maximum tilt angle.
    ///   - perspective: 3D perspective depth.
    /// - Returns: A view with perspective tilt effect.
    func perspectiveTilt(maxAngle: Double = 15, perspective: Double = 0.5) -> some View {
        PerspectiveTiltWrapper(maxAngle: maxAngle, perspective: perspective) {
            self
        }
    }
}

// MARK: - Perspective Tilt Wrapper

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct PerspectiveTiltWrapper<Content: View>: View {
    let maxAngle: Double
    let perspective: Double
    let content: Content
    
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var isInteracting: Bool = false
    
    init(maxAngle: Double, perspective: Double, @ViewBuilder content: () -> Content) {
        self.maxAngle = maxAngle
        self.perspective = perspective
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .rotation3DEffect(.degrees(rotationX), axis: (1, 0, 0), perspective: perspective)
                .rotation3DEffect(.degrees(rotationY), axis: (0, 1, 0), perspective: perspective)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isInteracting = true
                            let centerX = geometry.size.width / 2
                            let centerY = geometry.size.height / 2
                            let normalizedX = (value.location.x - centerX) / centerX
                            let normalizedY = (value.location.y - centerY) / centerY
                            
                            withAnimation(.interactiveSpring()) {
                                rotationY = normalizedX * maxAngle
                                rotationX = -normalizedY * maxAngle
                            }
                        }
                        .onEnded { _ in
                            isInteracting = false
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                rotationX = 0
                                rotationY = 0
                            }
                        }
                )
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct Transform3DPreview: View {
    @State private var isFlipped = false
    @State private var cubeFace = 0
    @State private var isFolded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                Text("Flip Card")
                    .font(.headline)
                
                FlipCardView(isFlipped: $isFlipped) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.blue)
                        .frame(width: 150, height: 100)
                        .overlay(Text("Front").foregroundColor(.white))
                } back: {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.purple)
                        .frame(width: 150, height: 100)
                        .overlay(Text("Back").foregroundColor(.white))
                }
                .onTapGesture { isFlipped.toggle() }
                
                Text("Perspective Tilt")
                    .font(.headline)
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 100)
                    .overlay(Text("Drag Me").foregroundColor(.white))
                    .shadow(radius: 10)
                    .perspectiveTilt()
                
                Text("Fold Animation")
                    .font(.headline)
                
                VStack {
                    Rectangle()
                        .fill(Color.green.gradient)
                        .frame(width: 150, height: 150)
                        .overlay(Text("Tap to Fold").foregroundColor(.white))
                        .foldAnimation(isFolded: isFolded)
                        .onTapGesture { isFolded.toggle() }
                }
                .frame(height: 200)
            }
            .padding()
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("3D Transformations") {
    Transform3DPreview()
}
#endif
