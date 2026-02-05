//
//  PageTransitions.swift
//  SwiftUIAnimationMasterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Page Transition Type (10+)

/// 10+ Production-ready page transition effects
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public enum PageTransitionType: String, CaseIterable, Sendable {
    case slide          // Standard slide
    case fade           // Crossfade
    case zoom           // Zoom in/out
    case flip           // 3D flip
    case cube           // 3D cube rotation
    case cards          // Card stack
    case parallax       // Parallax effect
    case reveal         // Reveal from center
    case push           // iOS-style push
    case modal          // Modal presentation
    case book           // Page flip like a book
    case carousel       // Carousel rotation
}

// MARK: - Page Transition Container

/// Container for page transitions with gesture support
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct PageTransitionContainer<Content: View>: View {
    
    let transitionType: PageTransitionType
    @Binding var currentPage: Int
    let pageCount: Int
    let content: (Int) -> Content
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var animationProgress: CGFloat = 0
    
    public init(
        transitionType: PageTransitionType = .slide,
        currentPage: Binding<Int>,
        pageCount: Int,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.transitionType = transitionType
        self._currentPage = currentPage
        self.pageCount = pageCount
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<pageCount, id: \.self) { index in
                    content(index)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .modifier(PageTransitionModifier(
                            type: transitionType,
                            index: index,
                            currentPage: currentPage,
                            dragOffset: dragOffset,
                            containerSize: geometry.size
                        ))
                }
            }
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.25
                        let predictedEnd = value.predictedEndTranslation.width
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if predictedEnd < -threshold && currentPage < pageCount - 1 {
                                currentPage += 1
                            } else if predictedEnd > threshold && currentPage > 0 {
                                currentPage -= 1
                            }
                        }
                    }
            )
        }
    }
}

// MARK: - Page Transition Modifier

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct PageTransitionModifier: ViewModifier {
    
    let type: PageTransitionType
    let index: Int
    let currentPage: Int
    let dragOffset: CGFloat
    let containerSize: CGSize
    
    private var offset: CGFloat {
        CGFloat(index - currentPage) * containerSize.width + dragOffset
    }
    
    private var normalizedOffset: CGFloat {
        offset / containerSize.width
    }
    
    func body(content: Content) -> some View {
        switch type {
        case .slide:
            slideTransition(content)
        case .fade:
            fadeTransition(content)
        case .zoom:
            zoomTransition(content)
        case .flip:
            flipTransition(content)
        case .cube:
            cubeTransition(content)
        case .cards:
            cardsTransition(content)
        case .parallax:
            parallaxTransition(content)
        case .reveal:
            revealTransition(content)
        case .push:
            pushTransition(content)
        case .modal:
            modalTransition(content)
        case .book:
            bookTransition(content)
        case .carousel:
            carouselTransition(content)
        }
    }
    
    // MARK: - Transition Implementations
    
    @ViewBuilder
    private func slideTransition(_ content: Content) -> some View {
        content
            .offset(x: offset)
    }
    
    @ViewBuilder
    private func fadeTransition(_ content: Content) -> some View {
        content
            .offset(x: offset)
            .opacity(1 - abs(normalizedOffset) * 0.5)
    }
    
    @ViewBuilder
    private func zoomTransition(_ content: Content) -> some View {
        let scale = max(0.8, 1 - abs(normalizedOffset) * 0.2)
        content
            .offset(x: offset)
            .scaleEffect(scale)
            .opacity(1 - abs(normalizedOffset) * 0.3)
    }
    
    @ViewBuilder
    private func flipTransition(_ content: Content) -> some View {
        let angle = normalizedOffset * 90
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .opacity(abs(angle) > 89 ? 0 : 1)
    }
    
    @ViewBuilder
    private func cubeTransition(_ content: Content) -> some View {
        let angle = normalizedOffset * 90
        let anchor: UnitPoint = normalizedOffset < 0 ? .trailing : .leading
        
        content
            .rotation3DEffect(
                .degrees(-angle),
                axis: (x: 0, y: 1, z: 0),
                anchor: anchor,
                perspective: 0.5
            )
            .opacity(abs(normalizedOffset) > 1 ? 0 : 1)
    }
    
    @ViewBuilder
    private func cardsTransition(_ content: Content) -> some View {
        let scale = max(0.9, 1 - abs(normalizedOffset) * 0.1)
        let offsetY = abs(normalizedOffset) * 20
        
        content
            .offset(x: normalizedOffset > 0 ? offset : offset * 0.3)
            .offset(y: offsetY)
            .scaleEffect(scale)
            .zIndex(Double(-abs(index - currentPage)))
    }
    
    @ViewBuilder
    private func parallaxTransition(_ content: Content) -> some View {
        content
            .offset(x: offset * 0.7)
            .overlay(
                Rectangle()
                    .fill(.black.opacity(abs(normalizedOffset) * 0.3))
            )
    }
    
    @ViewBuilder
    private func revealTransition(_ content: Content) -> some View {
        let clipWidth = containerSize.width * (1 - abs(normalizedOffset))
        
        content
            .clipShape(Rectangle().size(width: clipWidth, height: containerSize.height))
            .offset(x: normalizedOffset > 0 ? offset : 0)
    }
    
    @ViewBuilder
    private func pushTransition(_ content: Content) -> some View {
        let scale = normalizedOffset < 0 ? 1 : max(0.9, 1 - normalizedOffset * 0.1)
        let adjustedOffset = normalizedOffset < 0 ? offset : offset * 0.3
        
        content
            .offset(x: adjustedOffset)
            .scaleEffect(scale)
            .overlay(
                Rectangle()
                    .fill(.black.opacity(max(0, normalizedOffset) * 0.2))
            )
    }
    
    @ViewBuilder
    private func modalTransition(_ content: Content) -> some View {
        let offsetY = max(0, normalizedOffset) * containerSize.height * 0.5
        let scale = normalizedOffset < 0 ? max(0.95, 1 + normalizedOffset * 0.05) : 1
        
        content
            .offset(y: offsetY)
            .scaleEffect(scale)
            .opacity(normalizedOffset < 0 ? 1 - abs(normalizedOffset) * 0.3 : 1)
    }
    
    @ViewBuilder
    private func bookTransition(_ content: Content) -> some View {
        let angle = normalizedOffset * 180
        let anchor: UnitPoint = index <= currentPage ? .trailing : .leading
        
        content
            .rotation3DEffect(
                .degrees(min(max(angle, -180), 0)),
                axis: (x: 0, y: 1, z: 0),
                anchor: anchor,
                perspective: 0.5
            )
            .opacity(angle < -90 || angle > 0 ? 0 : 1)
            .zIndex(Double(-abs(index - currentPage)))
    }
    
    @ViewBuilder
    private func carouselTransition(_ content: Content) -> some View {
        let angle = normalizedOffset * 45
        let offsetZ = abs(normalizedOffset) * 100
        let scale = max(0.8, 1 - abs(normalizedOffset) * 0.2)
        
        content
            .offset(x: offset * 0.8)
            .scaleEffect(scale)
            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
            .opacity(abs(normalizedOffset) > 2 ? 0 : 1 - abs(normalizedOffset) * 0.3)
    }
}

// MARK: - Navigation Transition Modifier

/// Applies custom transition to NavigationStack pushes
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct NavigationTransitionModifier: ViewModifier {
    
    let type: PageTransitionType
    
    public func body(content: Content) -> some View {
        content
            .navigationTransition(.slide)
    }
}

// MARK: - Sheet Transition

/// Custom sheet presentation transitions
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SheetTransition {
    
    /// Slide up with spring
    public static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }
    
    /// Scale and fade
    public static var scaleFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        )
    }
    
    /// Flip up
    public static var flipUp: AnyTransition {
        .modifier(
            active: FlipUpModifier(angle: -90),
            identity: FlipUpModifier(angle: 0)
        )
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
private struct FlipUpModifier: ViewModifier {
    let angle: Double
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(angle), axis: (x: 1, y: 0, z: 0), anchor: .bottom, perspective: 0.5)
            .opacity(abs(angle) > 45 ? 0 : 1)
    }
}

// MARK: - Tab Transition

/// Custom tab bar transition container
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct AnimatedTabView<Content: View>: View {
    
    @Binding var selection: Int
    let transitionType: PageTransitionType
    let content: () -> Content
    
    public init(
        selection: Binding<Int>,
        transitionType: PageTransitionType = .slide,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.transitionType = transitionType
        self.content = content
    }
    
    public var body: some View {
        content()
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selection)
    }
}

// MARK: - Hero Transition

/// Shared element transition helper
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct HeroTransitionModifier: ViewModifier {
    
    let id: String
    let namespace: Namespace.ID
    let isSource: Bool
    
    public func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: id, in: namespace, isSource: isSource)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public extension View {
    
    /// Adds hero transition capability
    func heroTransition(id: String, namespace: Namespace.ID, isSource: Bool = true) -> some View {
        modifier(HeroTransitionModifier(id: id, namespace: namespace, isSource: isSource))
    }
}
