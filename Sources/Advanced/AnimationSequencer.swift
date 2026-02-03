//
//  AnimationSequencer.swift
//  SwiftUI-Animation-Masterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Animation Step Protocol

/// A protocol that defines a single step in an animation sequence.
///
/// Implement this protocol to create custom animation steps that can
/// be chained together to form complex animation sequences.
public protocol AnimationStep {
    /// The duration of this animation step in seconds.
    var duration: TimeInterval { get }
    
    /// The delay before this step begins, relative to the previous step.
    var delay: TimeInterval { get }
    
    /// Executes the animation step.
    /// - Parameter completion: Called when the animation completes.
    func execute(completion: @escaping () -> Void)
}

// MARK: - Basic Animation Step

/// A concrete implementation of AnimationStep for basic property animations.
public struct BasicAnimationStep<Value: Equatable>: AnimationStep {
    /// The binding to animate.
    private let binding: Binding<Value>
    
    /// The target value.
    private let targetValue: Value
    
    /// The animation to use.
    private let animation: Animation
    
    public let duration: TimeInterval
    public let delay: TimeInterval
    
    /// Creates a basic animation step.
    /// - Parameters:
    ///   - binding: The binding to animate.
    ///   - to: The target value.
    ///   - duration: Animation duration.
    ///   - delay: Delay before animation starts.
    ///   - animation: The animation to use.
    public init(
        _ binding: Binding<Value>,
        to targetValue: Value,
        duration: TimeInterval = 0.3,
        delay: TimeInterval = 0,
        animation: Animation = .easeInOut
    ) {
        self.binding = binding
        self.targetValue = targetValue
        self.duration = duration
        self.delay = delay
        self.animation = animation
    }
    
    public func execute(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(animation) {
                binding.wrappedValue = targetValue
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                completion()
            }
        }
    }
}

// MARK: - Animation Sequencer

/// A coordinator that manages sequential and parallel animation execution.
///
/// `AnimationSequencer` provides a powerful way to orchestrate complex
/// animations by chaining multiple animation steps together.
///
/// ## Overview
/// The sequencer supports both sequential and parallel execution modes,
/// allowing you to create sophisticated animation choreography.
///
/// ## Example
/// ```swift
/// let sequencer = AnimationSequencer()
/// sequencer.addStep(BasicAnimationStep($opacity, to: 1.0, duration: 0.3))
/// sequencer.addStep(BasicAnimationStep($scale, to: 1.2, duration: 0.2))
/// sequencer.start()
/// ```
@MainActor
public final class AnimationSequencer: ObservableObject {
    /// The execution mode for the sequencer.
    public enum ExecutionMode {
        /// Execute steps one after another.
        case sequential
        /// Execute all steps simultaneously.
        case parallel
    }
    
    /// The current execution state.
    public enum State {
        case idle
        case running
        case paused
        case completed
    }
    
    /// The animation steps to execute.
    @Published public private(set) var steps: [any AnimationStep] = []
    
    /// The current execution state.
    @Published public private(set) var state: State = .idle
    
    /// The current step index (for sequential mode).
    @Published public private(set) var currentStepIndex: Int = 0
    
    /// The total progress (0.0 to 1.0).
    @Published public private(set) var progress: Double = 0
    
    /// The execution mode.
    public var executionMode: ExecutionMode = .sequential
    
    /// Whether to loop the animation.
    public var shouldLoop: Bool = false
    
    /// Number of completed loops.
    @Published public private(set) var completedLoops: Int = 0
    
    /// Callback when the sequence completes.
    public var onComplete: (() -> Void)?
    
    /// Callback when a step completes.
    public var onStepComplete: ((Int) -> Void)?
    
    /// Creates a new animation sequencer.
    public init() {}
    
    /// Adds a step to the sequence.
    /// - Parameter step: The animation step to add.
    public func addStep(_ step: any AnimationStep) {
        steps.append(step)
    }
    
    /// Adds multiple steps to the sequence.
    /// - Parameter newSteps: The animation steps to add.
    public func addSteps(_ newSteps: [any AnimationStep]) {
        steps.append(contentsOf: newSteps)
    }
    
    /// Removes all steps from the sequence.
    public func clearSteps() {
        steps.removeAll()
        reset()
    }
    
    /// Starts the animation sequence.
    public func start() {
        guard state != .running else { return }
        guard !steps.isEmpty else {
            state = .completed
            onComplete?()
            return
        }
        
        state = .running
        currentStepIndex = 0
        progress = 0
        
        switch executionMode {
        case .sequential:
            executeSequentially()
        case .parallel:
            executeInParallel()
        }
    }
    
    /// Pauses the animation sequence.
    public func pause() {
        guard state == .running else { return }
        state = .paused
    }
    
    /// Resumes a paused animation sequence.
    public func resume() {
        guard state == .paused else { return }
        state = .running
        executeSequentially()
    }
    
    /// Stops and resets the animation sequence.
    public func stop() {
        state = .idle
        reset()
    }
    
    /// Resets the sequencer to the beginning.
    public func reset() {
        currentStepIndex = 0
        progress = 0
        completedLoops = 0
    }
    
    /// Executes steps sequentially.
    private func executeSequentially() {
        guard state == .running else { return }
        guard currentStepIndex < steps.count else {
            handleSequenceComplete()
            return
        }
        
        let step = steps[currentStepIndex]
        step.execute { [weak self] in
            guard let self = self, self.state == .running else { return }
            
            self.onStepComplete?(self.currentStepIndex)
            self.currentStepIndex += 1
            self.progress = Double(self.currentStepIndex) / Double(self.steps.count)
            
            self.executeSequentially()
        }
    }
    
    /// Executes all steps in parallel.
    private func executeInParallel() {
        var completedCount = 0
        let totalSteps = steps.count
        
        for (index, step) in steps.enumerated() {
            step.execute { [weak self] in
                guard let self = self, self.state == .running else { return }
                
                completedCount += 1
                self.onStepComplete?(index)
                self.progress = Double(completedCount) / Double(totalSteps)
                
                if completedCount == totalSteps {
                    self.handleSequenceComplete()
                }
            }
        }
    }
    
    /// Handles sequence completion.
    private func handleSequenceComplete() {
        completedLoops += 1
        
        if shouldLoop {
            reset()
            start()
        } else {
            state = .completed
            onComplete?()
        }
    }
}

// MARK: - Animation Group

/// A group of animations that can be executed together.
///
/// `AnimationGroup` allows you to combine multiple animation steps
/// into a single logical unit with shared timing.
public struct AnimationGroup: AnimationStep {
    /// The steps in this group.
    public let steps: [any AnimationStep]
    
    /// The execution mode for the group.
    public let mode: AnimationSequencer.ExecutionMode
    
    public var duration: TimeInterval {
        switch mode {
        case .sequential:
            return steps.reduce(0) { $0 + $1.duration + $1.delay }
        case .parallel:
            return steps.map { $0.duration + $0.delay }.max() ?? 0
        }
    }
    
    public let delay: TimeInterval
    
    /// Creates an animation group.
    /// - Parameters:
    ///   - steps: The animation steps to group.
    ///   - mode: The execution mode.
    ///   - delay: Delay before the group starts.
    public init(
        steps: [any AnimationStep],
        mode: AnimationSequencer.ExecutionMode = .parallel,
        delay: TimeInterval = 0
    ) {
        self.steps = steps
        self.mode = mode
        self.delay = delay
    }
    
    public func execute(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            switch mode {
            case .sequential:
                executeSequentially(index: 0, completion: completion)
            case .parallel:
                executeInParallel(completion: completion)
            }
        }
    }
    
    private func executeSequentially(index: Int, completion: @escaping () -> Void) {
        guard index < steps.count else {
            completion()
            return
        }
        
        steps[index].execute { [self] in
            executeSequentially(index: index + 1, completion: completion)
        }
    }
    
    private func executeInParallel(completion: @escaping () -> Void) {
        var completedCount = 0
        let totalSteps = steps.count
        
        guard totalSteps > 0 else {
            completion()
            return
        }
        
        for step in steps {
            step.execute {
                completedCount += 1
                if completedCount == totalSteps {
                    completion()
                }
            }
        }
    }
}

// MARK: - Delay Step

/// An animation step that simply waits for a specified duration.
///
/// Use `DelayStep` to add pauses between animations in a sequence.
public struct DelayStep: AnimationStep {
    public let duration: TimeInterval
    public let delay: TimeInterval = 0
    
    /// Creates a delay step.
    /// - Parameter duration: The duration to wait.
    public init(duration: TimeInterval) {
        self.duration = duration
    }
    
    public func execute(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }
}

// MARK: - Callback Step

/// An animation step that executes a callback.
///
/// Use `CallbackStep` to perform side effects during an animation sequence.
public struct CallbackStep: AnimationStep {
    /// The callback to execute.
    private let callback: () -> Void
    
    public let duration: TimeInterval = 0
    public let delay: TimeInterval
    
    /// Creates a callback step.
    /// - Parameters:
    ///   - delay: Delay before executing.
    ///   - callback: The callback to execute.
    public init(delay: TimeInterval = 0, callback: @escaping () -> Void) {
        self.delay = delay
        self.callback = callback
    }
    
    public func execute(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            callback()
            completion()
        }
    }
}

// MARK: - Repeat Step

/// An animation step that repeats another step multiple times.
public struct RepeatStep: AnimationStep {
    /// The step to repeat.
    private let step: any AnimationStep
    
    /// The number of repetitions.
    private let count: Int
    
    public var duration: TimeInterval {
        step.duration * Double(count)
    }
    
    public let delay: TimeInterval
    
    /// Creates a repeat step.
    /// - Parameters:
    ///   - step: The step to repeat.
    ///   - count: Number of times to repeat.
    ///   - delay: Initial delay.
    public init(_ step: any AnimationStep, count: Int, delay: TimeInterval = 0) {
        self.step = step
        self.count = max(1, count)
        self.delay = delay
    }
    
    public func execute(completion: @escaping () -> Void) {
        executeRepetition(remaining: count, completion: completion)
    }
    
    private func executeRepetition(remaining: Int, completion: @escaping () -> Void) {
        guard remaining > 0 else {
            completion()
            return
        }
        
        step.execute { [self] in
            executeRepetition(remaining: remaining - 1, completion: completion)
        }
    }
}

// MARK: - Animation Timeline

/// A timeline-based animation controller.
///
/// `AnimationTimeline` provides frame-accurate control over animations
/// with support for seeking, reversing, and speed adjustments.
@MainActor
public final class AnimationTimeline: ObservableObject {
    /// The timeline events.
    public struct Event: Identifiable {
        public let id = UUID()
        /// The time at which this event occurs.
        public let time: TimeInterval
        /// The duration of this event.
        public let duration: TimeInterval
        /// The event handler.
        public let handler: (Double) -> Void
        
        public init(time: TimeInterval, duration: TimeInterval, handler: @escaping (Double) -> Void) {
            self.time = time
            self.duration = duration
            self.handler = handler
        }
    }
    
    /// The timeline events.
    @Published public private(set) var events: [Event] = []
    
    /// The current playhead position in seconds.
    @Published public private(set) var currentTime: TimeInterval = 0
    
    /// Whether the timeline is currently playing.
    @Published public private(set) var isPlaying: Bool = false
    
    /// The playback speed multiplier.
    public var playbackSpeed: Double = 1.0
    
    /// The total duration of the timeline.
    public var totalDuration: TimeInterval {
        events.map { $0.time + $0.duration }.max() ?? 0
    }
    
    /// Display link for animation updates.
    private var displayLink: CADisplayLink?
    
    /// Last frame timestamp.
    private var lastTimestamp: CFTimeInterval?
    
    /// Creates a new animation timeline.
    public init() {}
    
    /// Adds an event to the timeline.
    /// - Parameter event: The event to add.
    public func addEvent(_ event: Event) {
        events.append(event)
    }
    
    /// Removes all events from the timeline.
    public func clearEvents() {
        events.removeAll()
        stop()
    }
    
    /// Starts playback.
    public func play() {
        guard !isPlaying else { return }
        isPlaying = true
        
        displayLink = CADisplayLink(target: DisplayLinkHandler { [weak self] link in
            self?.update(link)
        }, selector: #selector(DisplayLinkHandler.handleDisplayLink(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Pauses playback.
    public func pause() {
        isPlaying = false
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = nil
    }
    
    /// Stops playback and resets to the beginning.
    public func stop() {
        pause()
        currentTime = 0
    }
    
    /// Seeks to a specific time.
    /// - Parameter time: The target time in seconds.
    public func seek(to time: TimeInterval) {
        currentTime = max(0, min(totalDuration, time))
        updateEvents()
    }
    
    /// Updates the timeline.
    private func update(_ link: CADisplayLink) {
        guard let lastTimestamp = lastTimestamp else {
            self.lastTimestamp = link.timestamp
            return
        }
        
        let deltaTime = (link.timestamp - lastTimestamp) * playbackSpeed
        self.lastTimestamp = link.timestamp
        
        currentTime += deltaTime
        
        if currentTime >= totalDuration {
            currentTime = totalDuration
            pause()
        }
        
        updateEvents()
    }
    
    /// Updates all events based on current time.
    private func updateEvents() {
        for event in events {
            if currentTime >= event.time && currentTime <= event.time + event.duration {
                let localProgress = (currentTime - event.time) / event.duration
                event.handler(localProgress)
            }
        }
    }
}

/// Helper class for CADisplayLink callback.
private class DisplayLinkHandler {
    let handler: (CADisplayLink) -> Void
    
    init(handler: @escaping (CADisplayLink) -> Void) {
        self.handler = handler
    }
    
    @objc func handleDisplayLink(_ link: CADisplayLink) {
        handler(link)
    }
}

// MARK: - Animation State Machine

/// A state machine for managing animation states and transitions.
///
/// `AnimationStateMachine` provides a structured way to manage complex
/// animation state with defined transitions between states.
@MainActor
public final class AnimationStateMachine<State: Hashable>: ObservableObject {
    /// A transition between two states.
    public struct Transition {
        /// The source state.
        public let from: State
        /// The destination state.
        public let to: State
        /// The animation for this transition.
        public let animation: Animation
        /// Optional guard condition.
        public let guard: (() -> Bool)?
        
        public init(from: State, to: State, animation: Animation = .default, guard: (() -> Bool)? = nil) {
            self.from = from
            self.to = to
            self.animation = animation
            self.guard = `guard`
        }
    }
    
    /// The current state.
    @Published public private(set) var currentState: State
    
    /// The previous state.
    @Published public private(set) var previousState: State?
    
    /// Whether a transition is in progress.
    @Published public private(set) var isTransitioning: Bool = false
    
    /// The registered transitions.
    private var transitions: [Transition] = []
    
    /// State entry handlers.
    private var entryHandlers: [State: () -> Void] = [:]
    
    /// State exit handlers.
    private var exitHandlers: [State: () -> Void] = [:]
    
    /// Creates a new state machine.
    /// - Parameter initialState: The starting state.
    public init(initialState: State) {
        self.currentState = initialState
    }
    
    /// Registers a transition.
    /// - Parameter transition: The transition to register.
    public func addTransition(_ transition: Transition) {
        transitions.append(transition)
    }
    
    /// Sets the entry handler for a state.
    /// - Parameters:
    ///   - state: The state.
    ///   - handler: The handler to call when entering the state.
    public func onEntry(_ state: State, handler: @escaping () -> Void) {
        entryHandlers[state] = handler
    }
    
    /// Sets the exit handler for a state.
    /// - Parameters:
    ///   - state: The state.
    ///   - handler: The handler to call when exiting the state.
    public func onExit(_ state: State, handler: @escaping () -> Void) {
        exitHandlers[state] = handler
    }
    
    /// Attempts to transition to a new state.
    /// - Parameter newState: The target state.
    /// - Returns: Whether the transition was successful.
    @discardableResult
    public func transition(to newState: State) -> Bool {
        guard currentState != newState else { return false }
        
        let matchingTransition = transitions.first {
            $0.from == currentState && $0.to == newState
        }
        
        if let transition = matchingTransition {
            if let guardCondition = transition.guard, !guardCondition() {
                return false
            }
            
            performTransition(to: newState, animation: transition.animation)
            return true
        }
        
        return false
    }
    
    /// Performs the state transition.
    private func performTransition(to newState: State, animation: Animation) {
        isTransitioning = true
        
        exitHandlers[currentState]?()
        previousState = currentState
        
        withAnimation(animation) {
            currentState = newState
        }
        
        entryHandlers[newState]?()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isTransitioning = false
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct AnimationSequencerPreview: View {
    @StateObject private var sequencer = AnimationSequencer()
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Circle()
                .fill(.blue)
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .opacity(opacity)
                .rotationEffect(.degrees(rotation))
            
            Text("Progress: \(Int(sequencer.progress * 100))%")
            
            HStack(spacing: 20) {
                Button("Start") {
                    setupAndStart()
                }
                
                Button("Reset") {
                    withAnimation {
                        scale = 1.0
                        opacity = 1.0
                        rotation = 0
                    }
                    sequencer.stop()
                }
            }
        }
        .padding()
    }
    
    private func setupAndStart() {
        sequencer.clearSteps()
        
        sequencer.addStep(BasicAnimationStep($scale, to: 1.5, duration: 0.3))
        sequencer.addStep(BasicAnimationStep($rotation, to: 180, duration: 0.3))
        sequencer.addStep(BasicAnimationStep($opacity, to: 0.5, duration: 0.2))
        sequencer.addStep(BasicAnimationStep($scale, to: 1.0, duration: 0.3))
        sequencer.addStep(BasicAnimationStep($rotation, to: 360, duration: 0.3))
        sequencer.addStep(BasicAnimationStep($opacity, to: 1.0, duration: 0.2))
        
        sequencer.start()
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Animation Sequencer") {
    AnimationSequencerPreview()
}
#endif
