//
//  PhaseAnimator.swift
//  SwiftUI-Animation-Masterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Phase Animation Protocol

/// A protocol that defines the requirements for phase-based animations.
///
/// Conform to this protocol to create custom phase animations that cycle through
/// distinct visual states with configurable timing and easing.
///
/// ## Overview
/// Phase animations are powerful tools for creating multi-step animated sequences.
/// Each phase represents a distinct visual state, and the animator smoothly transitions
/// between phases based on configured timing curves.
///
/// ## Example
/// ```swift
/// enum PulsePhase: PhaseAnimatable {
///     case initial, expanded, contracted
///
///     var scale: Double {
///         switch self {
///         case .initial: return 1.0
///         case .expanded: return 1.3
///         case .contracted: return 0.9
///         }
///     }
/// }
/// ```
public protocol PhaseAnimatable: CaseIterable, Equatable {
    /// The animation to use when transitioning to this phase.
    var animation: Animation? { get }
}

// MARK: - Default Implementation

public extension PhaseAnimatable {
    /// Default spring animation for phase transitions.
    var animation: Animation? {
        .spring(response: 0.4, dampingFraction: 0.8)
    }
}

// MARK: - Phase Animation State

/// Manages the internal state of a phase animation sequence.
///
/// This class handles the timing, phase progression, and lifecycle
/// of phase-based animations within SwiftUI views.
@MainActor
public final class PhaseAnimationState<Phase: PhaseAnimatable>: ObservableObject {
    /// The current active phase in the animation sequence.
    @Published public private(set) var currentPhase: Phase
    
    /// Indicates whether the animation is currently running.
    @Published public private(set) var isAnimating: Bool = false
    
    /// The total number of completed animation cycles.
    @Published public private(set) var cycleCount: Int = 0
    
    /// All available phases in the animation sequence.
    public let phases: [Phase]
    
    /// The index of the current phase within the phases array.
    private var currentIndex: Int = 0
    
    /// Timer for automatic phase progression.
    private var animationTimer: Timer?
    
    /// Duration for each phase in seconds.
    public var phaseDuration: TimeInterval
    
    /// Whether the animation should loop continuously.
    public var shouldLoop: Bool
    
    /// Callback executed when a phase transition completes.
    public var onPhaseChange: ((Phase) -> Void)?
    
    /// Creates a new phase animation state manager.
    /// - Parameters:
    ///   - initialPhase: The starting phase of the animation.
    ///   - phaseDuration: Duration for each phase in seconds. Defaults to 0.5.
    ///   - shouldLoop: Whether to loop continuously. Defaults to true.
    public init(
        initialPhase: Phase,
        phaseDuration: TimeInterval = 0.5,
        shouldLoop: Bool = true
    ) {
        self.currentPhase = initialPhase
        self.phases = Array(Phase.allCases)
        self.phaseDuration = phaseDuration
        self.shouldLoop = shouldLoop
        
        if let index = phases.firstIndex(of: initialPhase) {
            self.currentIndex = index
        }
    }
    
    /// Starts the phase animation sequence.
    public func start() {
        guard !isAnimating else { return }
        isAnimating = true
        scheduleNextPhase()
    }
    
    /// Stops the phase animation sequence.
    public func stop() {
        isAnimating = false
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    /// Resets the animation to the initial phase.
    public func reset() {
        stop()
        currentIndex = 0
        cycleCount = 0
        if let firstPhase = phases.first {
            currentPhase = firstPhase
        }
    }
    
    /// Advances to the next phase manually.
    public func nextPhase() {
        advancePhase()
    }
    
    /// Moves to the previous phase.
    public func previousPhase() {
        currentIndex = (currentIndex - 1 + phases.count) % phases.count
        currentPhase = phases[currentIndex]
        onPhaseChange?(currentPhase)
    }
    
    /// Jumps to a specific phase.
    /// - Parameter phase: The target phase to transition to.
    public func jumpTo(phase: Phase) {
        if let index = phases.firstIndex(of: phase) {
            currentIndex = index
            currentPhase = phase
            onPhaseChange?(currentPhase)
        }
    }
    
    /// Schedules the next phase transition.
    private func scheduleNextPhase() {
        animationTimer = Timer.scheduledTimer(
            withTimeInterval: phaseDuration,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                self?.advancePhase()
                if self?.isAnimating == true {
                    self?.scheduleNextPhase()
                }
            }
        }
    }
    
    /// Advances to the next phase in the sequence.
    private func advancePhase() {
        let nextIndex = currentIndex + 1
        
        if nextIndex >= phases.count {
            cycleCount += 1
            if shouldLoop {
                currentIndex = 0
            } else {
                stop()
                return
            }
        } else {
            currentIndex = nextIndex
        }
        
        withAnimation(currentPhase.animation) {
            currentPhase = phases[currentIndex]
        }
        onPhaseChange?(currentPhase)
    }
}

// MARK: - Built-in Phase Types

/// A phase type for simple pulsing animations.
///
/// Use this phase type to create breathing or pulsing effects
/// that smoothly scale and fade between states.
public enum PulsePhase: String, PhaseAnimatable, CaseIterable {
    /// The initial resting state.
    case idle
    /// The expanded state with increased scale.
    case expanded
    /// The contracted state with decreased scale.
    case contracted
    
    /// The scale factor for each phase.
    public var scale: Double {
        switch self {
        case .idle: return 1.0
        case .expanded: return 1.15
        case .contracted: return 0.92
        }
    }
    
    /// The opacity value for each phase.
    public var opacity: Double {
        switch self {
        case .idle: return 1.0
        case .expanded: return 0.85
        case .contracted: return 0.95
        }
    }
    
    public var animation: Animation? {
        switch self {
        case .idle:
            return .easeInOut(duration: 0.3)
        case .expanded:
            return .spring(response: 0.35, dampingFraction: 0.65)
        case .contracted:
            return .spring(response: 0.25, dampingFraction: 0.75)
        }
    }
}

/// A phase type for attention-grabbing bounce animations.
///
/// This phase creates a playful bouncing effect suitable for
/// buttons, notifications, or interactive elements.
public enum BouncePhase: String, PhaseAnimatable, CaseIterable {
    /// The resting state at normal position.
    case rest
    /// The compressed state before bouncing.
    case compress
    /// The stretched state during bounce.
    case stretch
    /// The overshoot state at peak height.
    case overshoot
    /// The settle state returning to rest.
    case settle
    
    /// The vertical offset for each phase.
    public var offsetY: Double {
        switch self {
        case .rest: return 0
        case .compress: return 8
        case .stretch: return -20
        case .overshoot: return -28
        case .settle: return -5
        }
    }
    
    /// The scale factors for squash and stretch.
    public var scaleX: Double {
        switch self {
        case .rest: return 1.0
        case .compress: return 1.15
        case .stretch: return 0.88
        case .overshoot: return 0.92
        case .settle: return 1.02
        }
    }
    
    public var scaleY: Double {
        switch self {
        case .rest: return 1.0
        case .compress: return 0.85
        case .stretch: return 1.18
        case .overshoot: return 1.1
        case .settle: return 0.98
        }
    }
    
    public var animation: Animation? {
        switch self {
        case .rest:
            return .spring(response: 0.3, dampingFraction: 0.8)
        case .compress:
            return .easeIn(duration: 0.1)
        case .stretch:
            return .spring(response: 0.2, dampingFraction: 0.5)
        case .overshoot:
            return .easeOut(duration: 0.15)
        case .settle:
            return .spring(response: 0.25, dampingFraction: 0.7)
        }
    }
}

/// A phase type for smooth rotation animations.
///
/// Use this for loading indicators, refresh icons, or any
/// element that should rotate through distinct angles.
public enum RotationPhase: String, PhaseAnimatable, CaseIterable {
    /// The starting position at 0 degrees.
    case start
    /// First quarter rotation at 90 degrees.
    case quarter
    /// Half rotation at 180 degrees.
    case half
    /// Three quarter rotation at 270 degrees.
    case threeQuarter
    /// Full rotation returning to start.
    case complete
    
    /// The rotation angle in degrees.
    public var degrees: Double {
        switch self {
        case .start: return 0
        case .quarter: return 90
        case .half: return 180
        case .threeQuarter: return 270
        case .complete: return 360
        }
    }
    
    public var animation: Animation? {
        .easeInOut(duration: 0.25)
    }
}

/// A phase type for color cycling animations.
///
/// Perfect for status indicators, mood lighting effects,
/// or decorative color transitions.
public enum ColorCyclePhase: String, PhaseAnimatable, CaseIterable {
    /// Primary color state.
    case primary
    /// Secondary color state.
    case secondary
    /// Tertiary color state.
    case tertiary
    /// Accent color state.
    case accent
    
    /// The color associated with each phase.
    public var color: Color {
        switch self {
        case .primary: return .blue
        case .secondary: return .purple
        case .tertiary: return .pink
        case .accent: return .orange
        }
    }
    
    public var animation: Animation? {
        .easeInOut(duration: 0.6)
    }
}

// MARK: - Phase Animator View

/// A view that automatically animates through a sequence of phases.
///
/// `PhaseAnimatorView` provides a declarative way to create multi-step
/// animations that cycle through distinct visual states.
///
/// ## Overview
/// Phase animators are ideal for creating complex, choreographed animations
/// that would be difficult to achieve with simple state-based animations.
///
/// ## Example
/// ```swift
/// PhaseAnimatorView(PulsePhase.self) { phase in
///     Circle()
///         .fill(.blue)
///         .scaleEffect(phase.scale)
///         .opacity(phase.opacity)
/// }
/// ```
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct PhaseAnimatorView<Phase: PhaseAnimatable, Content: View>: View {
    /// The state object managing the animation.
    @StateObject private var state: PhaseAnimationState<Phase>
    
    /// The content builder that receives the current phase.
    private let content: (Phase) -> Content
    
    /// Whether to automatically start animating when the view appears.
    private let autoStart: Bool
    
    /// Creates a phase animator with the specified phase type.
    /// - Parameters:
    ///   - phaseType: The type of phases to animate through.
    ///   - phaseDuration: Duration for each phase. Defaults to 0.5 seconds.
    ///   - autoStart: Whether to start automatically. Defaults to true.
    ///   - content: A closure that builds the view for each phase.
    public init(
        _ phaseType: Phase.Type,
        phaseDuration: TimeInterval = 0.5,
        autoStart: Bool = true,
        @ViewBuilder content: @escaping (Phase) -> Content
    ) {
        let initialPhase = Array(Phase.allCases).first!
        _state = StateObject(wrappedValue: PhaseAnimationState(
            initialPhase: initialPhase,
            phaseDuration: phaseDuration
        ))
        self.content = content
        self.autoStart = autoStart
    }
    
    public var body: some View {
        content(state.currentPhase)
            .onAppear {
                if autoStart {
                    state.start()
                }
            }
            .onDisappear {
                state.stop()
            }
    }
}

// MARK: - Phase Animator Modifier

/// A view modifier that applies phase-based animations to any view.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct PhaseAnimatorModifier<Phase: PhaseAnimatable>: ViewModifier {
    /// The animation state manager.
    @StateObject private var state: PhaseAnimationState<Phase>
    
    /// Transform to apply based on current phase.
    private let transform: (Phase, AnyView) -> AnyView
    
    /// Whether to auto-start the animation.
    private let autoStart: Bool
    
    /// Creates a phase animator modifier.
    /// - Parameters:
    ///   - initialPhase: The starting phase.
    ///   - phaseDuration: Duration for each phase.
    ///   - autoStart: Whether to start automatically.
    ///   - transform: A closure that applies phase-specific transformations.
    public init(
        initialPhase: Phase,
        phaseDuration: TimeInterval = 0.5,
        autoStart: Bool = true,
        transform: @escaping (Phase, AnyView) -> AnyView
    ) {
        _state = StateObject(wrappedValue: PhaseAnimationState(
            initialPhase: initialPhase,
            phaseDuration: phaseDuration
        ))
        self.transform = transform
        self.autoStart = autoStart
    }
    
    public func body(content: Content) -> some View {
        transform(state.currentPhase, AnyView(content))
            .onAppear {
                if autoStart {
                    state.start()
                }
            }
            .onDisappear {
                state.stop()
            }
    }
}

// MARK: - View Extensions

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension View {
    /// Applies a pulsing phase animation to the view.
    /// - Parameter phaseDuration: Duration for each pulse phase.
    /// - Returns: A view with pulsing animation applied.
    func pulsingAnimation(phaseDuration: TimeInterval = 0.5) -> some View {
        modifier(PhaseAnimatorModifier(
            initialPhase: PulsePhase.idle,
            phaseDuration: phaseDuration
        ) { phase, view in
            AnyView(
                view
                    .scaleEffect(phase.scale)
                    .opacity(phase.opacity)
            )
        })
    }
    
    /// Applies a bouncing phase animation to the view.
    /// - Parameter phaseDuration: Duration for each bounce phase.
    /// - Returns: A view with bouncing animation applied.
    func bouncingAnimation(phaseDuration: TimeInterval = 0.15) -> some View {
        modifier(PhaseAnimatorModifier(
            initialPhase: BouncePhase.rest,
            phaseDuration: phaseDuration
        ) { phase, view in
            AnyView(
                view
                    .scaleEffect(x: phase.scaleX, y: phase.scaleY)
                    .offset(y: phase.offsetY)
            )
        })
    }
    
    /// Applies a rotating phase animation to the view.
    /// - Parameter phaseDuration: Duration for each rotation phase.
    /// - Returns: A view with rotation animation applied.
    func rotatingAnimation(phaseDuration: TimeInterval = 0.25) -> some View {
        modifier(PhaseAnimatorModifier(
            initialPhase: RotationPhase.start,
            phaseDuration: phaseDuration
        ) { phase, view in
            AnyView(
                view
                    .rotationEffect(.degrees(phase.degrees))
            )
        })
    }
}

// MARK: - Chained Phase Animator

/// A phase animator that supports chaining multiple phase sequences.
///
/// Use `ChainedPhaseAnimator` when you need to run different phase
/// sequences in order, such as an intro animation followed by a loop.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@MainActor
public final class ChainedPhaseAnimator: ObservableObject {
    /// Represents a single animation sequence in the chain.
    public struct AnimationSequence {
        /// A unique identifier for this sequence.
        public let id: String
        /// The phases in this sequence as an array of any equatable values.
        public let phases: [AnyHashable]
        /// Duration for each phase.
        public let phaseDuration: TimeInterval
        /// Number of times to repeat this sequence.
        public let repeatCount: Int
        /// Callback when sequence completes.
        public let onComplete: (() -> Void)?
        
        public init(
            id: String,
            phases: [AnyHashable],
            phaseDuration: TimeInterval = 0.5,
            repeatCount: Int = 1,
            onComplete: (() -> Void)? = nil
        ) {
            self.id = id
            self.phases = phases
            self.phaseDuration = phaseDuration
            self.repeatCount = repeatCount
            self.onComplete = onComplete
        }
    }
    
    /// The queue of animation sequences to execute.
    @Published public private(set) var sequences: [AnimationSequence] = []
    
    /// The currently executing sequence index.
    @Published public private(set) var currentSequenceIndex: Int = 0
    
    /// The current phase index within the active sequence.
    @Published public private(set) var currentPhaseIndex: Int = 0
    
    /// Whether the animator is currently running.
    @Published public private(set) var isRunning: Bool = false
    
    /// Timer for phase progression.
    private var timer: Timer?
    
    /// Number of completed repetitions for current sequence.
    private var currentRepetition: Int = 0
    
    /// Creates an empty chained phase animator.
    public init() {}
    
    /// Adds a sequence to the animation chain.
    /// - Parameter sequence: The sequence to add.
    public func addSequence(_ sequence: AnimationSequence) {
        sequences.append(sequence)
    }
    
    /// Removes all sequences from the chain.
    public func clearSequences() {
        stop()
        sequences.removeAll()
        currentSequenceIndex = 0
        currentPhaseIndex = 0
        currentRepetition = 0
    }
    
    /// Starts the chained animation.
    public func start() {
        guard !sequences.isEmpty, !isRunning else { return }
        isRunning = true
        scheduleNextPhase()
    }
    
    /// Stops the chained animation.
    public func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    /// Schedules the next phase transition.
    private func scheduleNextPhase() {
        guard currentSequenceIndex < sequences.count else {
            stop()
            return
        }
        
        let currentSequence = sequences[currentSequenceIndex]
        
        timer = Timer.scheduledTimer(
            withTimeInterval: currentSequence.phaseDuration,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                self?.advancePhase()
            }
        }
    }
    
    /// Advances to the next phase.
    private func advancePhase() {
        guard currentSequenceIndex < sequences.count else {
            stop()
            return
        }
        
        let currentSequence = sequences[currentSequenceIndex]
        let nextPhaseIndex = currentPhaseIndex + 1
        
        if nextPhaseIndex >= currentSequence.phases.count {
            currentRepetition += 1
            
            if currentRepetition >= currentSequence.repeatCount {
                currentSequence.onComplete?()
                currentSequenceIndex += 1
                currentPhaseIndex = 0
                currentRepetition = 0
            } else {
                currentPhaseIndex = 0
            }
        } else {
            currentPhaseIndex = nextPhaseIndex
        }
        
        if isRunning {
            scheduleNextPhase()
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct PhaseAnimatorPreview: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("Pulse Animation")
                .font(.headline)
            
            PhaseAnimatorView(PulsePhase.self, phaseDuration: 0.4) { phase in
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .scaleEffect(phase.scale)
                    .opacity(phase.opacity)
                    .shadow(color: .blue.opacity(0.4), radius: 10)
            }
            
            Text("Bounce Animation")
                .font(.headline)
            
            PhaseAnimatorView(BouncePhase.self, phaseDuration: 0.12) { phase in
                RoundedRectangle(cornerRadius: 12)
                    .fill(.orange)
                    .frame(width: 60, height: 60)
                    .scaleEffect(x: phase.scaleX, y: phase.scaleY)
                    .offset(y: phase.offsetY)
            }
            
            Text("Rotation Animation")
                .font(.headline)
            
            PhaseAnimatorView(RotationPhase.self, phaseDuration: 0.2) { phase in
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                    .rotationEffect(.degrees(phase.degrees))
            }
        }
        .padding()
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Phase Animator") {
    PhaseAnimatorPreview()
}
#endif
