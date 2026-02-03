//
//  CustomTimingCurves.swift
//  SwiftUI-Animation-Masterclass
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import SwiftUI

// MARK: - Timing Curve Protocol

/// A protocol that defines a custom timing curve for animations.
///
/// Implement this protocol to create your own easing functions
/// that control the rate of change during an animation.
///
/// ## Overview
/// Timing curves determine how an animation progresses over time.
/// A linear curve moves at constant speed, while custom curves can
/// create effects like ease-in, ease-out, or bouncing.
///
/// ## Example
/// ```swift
/// struct MyCustomCurve: TimingCurve {
///     func transform(_ t: Double) -> Double {
///         // Quadratic ease in
///         return t * t
///     }
/// }
/// ```
public protocol TimingCurve {
    /// Transforms a linear progress value to a curved value.
    /// - Parameter t: Linear progress from 0.0 to 1.0.
    /// - Returns: Transformed progress value.
    func transform(_ t: Double) -> Double
}

// MARK: - Cubic Bezier Curve

/// A cubic bezier timing curve with configurable control points.
///
/// Cubic bezier curves are the industry standard for defining
/// smooth animation timing. The curve is defined by two control
/// points (x1, y1) and (x2, y2).
///
/// ## Common Presets
/// - Ease: (0.25, 0.1, 0.25, 1.0)
/// - EaseIn: (0.42, 0, 1.0, 1.0)
/// - EaseOut: (0, 0, 0.58, 1.0)
/// - EaseInOut: (0.42, 0, 0.58, 1.0)
public struct CubicBezierCurve: TimingCurve {
    /// X coordinate of the first control point.
    public let x1: Double
    
    /// Y coordinate of the first control point.
    public let y1: Double
    
    /// X coordinate of the second control point.
    public let x2: Double
    
    /// Y coordinate of the second control point.
    public let y2: Double
    
    /// The epsilon value for Newton-Raphson iteration.
    private let epsilon: Double = 1e-6
    
    /// Creates a cubic bezier curve with the specified control points.
    /// - Parameters:
    ///   - x1: X coordinate of first control point (0.0 to 1.0).
    ///   - y1: Y coordinate of first control point.
    ///   - x2: X coordinate of second control point (0.0 to 1.0).
    ///   - y2: Y coordinate of second control point.
    public init(x1: Double, y1: Double, x2: Double, y2: Double) {
        self.x1 = max(0, min(1, x1))
        self.y1 = y1
        self.x2 = max(0, min(1, x2))
        self.y2 = y2
    }
    
    public func transform(_ t: Double) -> Double {
        guard t > 0 && t < 1 else { return t }
        
        let tParameter = solveTForX(t)
        return sampleCurveY(tParameter)
    }
    
    /// Samples the X value of the curve at parameter t.
    private func sampleCurveX(_ t: Double) -> Double {
        let cx = 3.0 * x1
        let bx = 3.0 * (x2 - x1) - cx
        let ax = 1.0 - cx - bx
        return ((ax * t + bx) * t + cx) * t
    }
    
    /// Samples the Y value of the curve at parameter t.
    private func sampleCurveY(_ t: Double) -> Double {
        let cy = 3.0 * y1
        let by = 3.0 * (y2 - y1) - cy
        let ay = 1.0 - cy - by
        return ((ay * t + by) * t + cy) * t
    }
    
    /// Calculates the derivative of X at parameter t.
    private func sampleCurveDerivativeX(_ t: Double) -> Double {
        let cx = 3.0 * x1
        let bx = 3.0 * (x2 - x1) - cx
        let ax = 1.0 - cx - bx
        return (3.0 * ax * t + 2.0 * bx) * t + cx
    }
    
    /// Solves for the parameter t given an X value using Newton-Raphson.
    private func solveTForX(_ x: Double) -> Double {
        var t = x
        
        for _ in 0..<8 {
            let xGuess = sampleCurveX(t) - x
            if abs(xGuess) < epsilon {
                return t
            }
            let derivative = sampleCurveDerivativeX(t)
            if abs(derivative) < epsilon {
                break
            }
            t -= xGuess / derivative
        }
        
        var t0: Double = 0.0
        var t1: Double = 1.0
        t = x
        
        while t0 < t1 {
            let xGuess = sampleCurveX(t)
            if abs(xGuess - x) < epsilon {
                return t
            }
            if x > xGuess {
                t0 = t
            } else {
                t1 = t
            }
            t = (t1 - t0) * 0.5 + t0
        }
        
        return t
    }
}

// MARK: - Cubic Bezier Presets

public extension CubicBezierCurve {
    /// Linear timing with no easing.
    static let linear = CubicBezierCurve(x1: 0, y1: 0, x2: 1, y2: 1)
    
    /// Standard ease curve.
    static let ease = CubicBezierCurve(x1: 0.25, y1: 0.1, x2: 0.25, y2: 1.0)
    
    /// Ease in - starts slow, accelerates.
    static let easeIn = CubicBezierCurve(x1: 0.42, y1: 0, x2: 1.0, y2: 1.0)
    
    /// Ease out - starts fast, decelerates.
    static let easeOut = CubicBezierCurve(x1: 0, y1: 0, x2: 0.58, y2: 1.0)
    
    /// Ease in out - slow start and end.
    static let easeInOut = CubicBezierCurve(x1: 0.42, y1: 0, x2: 0.58, y2: 1.0)
    
    /// Sine ease in.
    static let sineIn = CubicBezierCurve(x1: 0.47, y1: 0, x2: 0.745, y2: 0.715)
    
    /// Sine ease out.
    static let sineOut = CubicBezierCurve(x1: 0.39, y1: 0.575, x2: 0.565, y2: 1)
    
    /// Sine ease in out.
    static let sineInOut = CubicBezierCurve(x1: 0.445, y1: 0.05, x2: 0.55, y2: 0.95)
    
    /// Quad ease in.
    static let quadIn = CubicBezierCurve(x1: 0.55, y1: 0.085, x2: 0.68, y2: 0.53)
    
    /// Quad ease out.
    static let quadOut = CubicBezierCurve(x1: 0.25, y1: 0.46, x2: 0.45, y2: 0.94)
    
    /// Quad ease in out.
    static let quadInOut = CubicBezierCurve(x1: 0.455, y1: 0.03, x2: 0.515, y2: 0.955)
    
    /// Cubic ease in.
    static let cubicIn = CubicBezierCurve(x1: 0.55, y1: 0.055, x2: 0.675, y2: 0.19)
    
    /// Cubic ease out.
    static let cubicOut = CubicBezierCurve(x1: 0.215, y1: 0.61, x2: 0.355, y2: 1)
    
    /// Cubic ease in out.
    static let cubicInOut = CubicBezierCurve(x1: 0.645, y1: 0.045, x2: 0.355, y2: 1)
    
    /// Quart ease in.
    static let quartIn = CubicBezierCurve(x1: 0.895, y1: 0.03, x2: 0.685, y2: 0.22)
    
    /// Quart ease out.
    static let quartOut = CubicBezierCurve(x1: 0.165, y1: 0.84, x2: 0.44, y2: 1)
    
    /// Quart ease in out.
    static let quartInOut = CubicBezierCurve(x1: 0.77, y1: 0, x2: 0.175, y2: 1)
    
    /// Quint ease in.
    static let quintIn = CubicBezierCurve(x1: 0.755, y1: 0.05, x2: 0.855, y2: 0.06)
    
    /// Quint ease out.
    static let quintOut = CubicBezierCurve(x1: 0.23, y1: 1, x2: 0.32, y2: 1)
    
    /// Quint ease in out.
    static let quintInOut = CubicBezierCurve(x1: 0.86, y1: 0, x2: 0.07, y2: 1)
    
    /// Expo ease in.
    static let expoIn = CubicBezierCurve(x1: 0.95, y1: 0.05, x2: 0.795, y2: 0.035)
    
    /// Expo ease out.
    static let expoOut = CubicBezierCurve(x1: 0.19, y1: 1, x2: 0.22, y2: 1)
    
    /// Expo ease in out.
    static let expoInOut = CubicBezierCurve(x1: 1, y1: 0, x2: 0, y2: 1)
    
    /// Circ ease in.
    static let circIn = CubicBezierCurve(x1: 0.6, y1: 0.04, x2: 0.98, y2: 0.335)
    
    /// Circ ease out.
    static let circOut = CubicBezierCurve(x1: 0.075, y1: 0.82, x2: 0.165, y2: 1)
    
    /// Circ ease in out.
    static let circInOut = CubicBezierCurve(x1: 0.785, y1: 0.135, x2: 0.15, y2: 0.86)
    
    /// Back ease in with slight overshoot.
    static let backIn = CubicBezierCurve(x1: 0.6, y1: -0.28, x2: 0.735, y2: 0.045)
    
    /// Back ease out with slight overshoot.
    static let backOut = CubicBezierCurve(x1: 0.175, y1: 0.885, x2: 0.32, y2: 1.275)
    
    /// Back ease in out with slight overshoot.
    static let backInOut = CubicBezierCurve(x1: 0.68, y1: -0.55, x2: 0.265, y2: 1.55)
}

// MARK: - Spring Curve

/// A spring-based timing curve that simulates physical spring motion.
///
/// Spring curves create natural, organic-feeling animations by
/// simulating the physics of a damped harmonic oscillator.
public struct SpringCurve: TimingCurve {
    /// The stiffness of the spring.
    public let stiffness: Double
    
    /// The damping ratio (0 = no damping, 1 = critical damping).
    public let damping: Double
    
    /// The mass of the object being animated.
    public let mass: Double
    
    /// Initial velocity of the animation.
    public let initialVelocity: Double
    
    /// Creates a spring curve with the specified parameters.
    /// - Parameters:
    ///   - stiffness: Spring stiffness. Higher values create stiffer springs.
    ///   - damping: Damping ratio from 0.0 to 1.0.
    ///   - mass: Object mass. Higher values create slower animations.
    ///   - initialVelocity: Starting velocity. Defaults to 0.
    public init(
        stiffness: Double = 100,
        damping: Double = 10,
        mass: Double = 1,
        initialVelocity: Double = 0
    ) {
        self.stiffness = stiffness
        self.damping = damping
        self.mass = mass
        self.initialVelocity = initialVelocity
    }
    
    public func transform(_ t: Double) -> Double {
        guard t > 0 && t < 1 else { return t }
        
        let omega0 = sqrt(stiffness / mass)
        let zeta = damping / (2 * sqrt(stiffness * mass))
        
        if zeta < 1 {
            let omegaD = omega0 * sqrt(1 - zeta * zeta)
            let envelope = exp(-zeta * omega0 * t)
            let oscillation = cos(omegaD * t) + (zeta * omega0 / omegaD) * sin(omegaD * t)
            return 1 - envelope * oscillation
        } else if zeta == 1 {
            return 1 - (1 + omega0 * t) * exp(-omega0 * t)
        } else {
            let s1 = omega0 * (-zeta + sqrt(zeta * zeta - 1))
            let s2 = omega0 * (-zeta - sqrt(zeta * zeta - 1))
            let c1 = (s2 + initialVelocity) / (s2 - s1)
            let c2 = 1 - c1
            return 1 - c1 * exp(s1 * t) - c2 * exp(s2 * t)
        }
    }
}

// MARK: - Spring Presets

public extension SpringCurve {
    /// A bouncy spring with visible oscillation.
    static let bouncy = SpringCurve(stiffness: 300, damping: 10, mass: 1)
    
    /// A smooth spring with minimal oscillation.
    static let smooth = SpringCurve(stiffness: 200, damping: 20, mass: 1)
    
    /// A stiff spring that settles quickly.
    static let stiff = SpringCurve(stiffness: 500, damping: 30, mass: 1)
    
    /// A soft spring with gentle motion.
    static let soft = SpringCurve(stiffness: 100, damping: 15, mass: 1)
    
    /// An interactive spring for responsive UI.
    static let interactive = SpringCurve(stiffness: 350, damping: 25, mass: 0.8)
    
    /// A snappy spring for quick actions.
    static let snappy = SpringCurve(stiffness: 400, damping: 28, mass: 0.6)
}

// MARK: - Elastic Curve

/// An elastic timing curve that overshoots and oscillates.
///
/// Elastic curves create a rubber-band-like effect where the
/// animation overshoots its target and bounces back.
public struct ElasticCurve: TimingCurve {
    /// The amplitude of the oscillation.
    public let amplitude: Double
    
    /// The period of the oscillation.
    public let period: Double
    
    /// Whether this is an ease-in or ease-out curve.
    public let easeIn: Bool
    
    /// Creates an elastic curve.
    /// - Parameters:
    ///   - amplitude: Oscillation amplitude. Defaults to 1.0.
    ///   - period: Oscillation period. Defaults to 0.3.
    ///   - easeIn: If true, creates ease-in. Defaults to false (ease-out).
    public init(amplitude: Double = 1.0, period: Double = 0.3, easeIn: Bool = false) {
        self.amplitude = max(1.0, amplitude)
        self.period = period
        self.easeIn = easeIn
    }
    
    public func transform(_ t: Double) -> Double {
        guard t > 0 && t < 1 else { return t }
        
        let s = period / (2 * .pi) * asin(1 / amplitude)
        
        if easeIn {
            let adjustedT = t - 1
            return -(amplitude * pow(2, 10 * adjustedT) * sin((adjustedT - s) * (2 * .pi) / period))
        } else {
            return amplitude * pow(2, -10 * t) * sin((t - s) * (2 * .pi) / period) + 1
        }
    }
}

// MARK: - Bounce Curve

/// A bounce timing curve that simulates a ball bouncing.
///
/// This curve creates a natural bouncing effect where each
/// successive bounce is smaller than the previous one.
public struct BounceCurve: TimingCurve {
    /// Whether this is an ease-in or ease-out bounce.
    public let easeIn: Bool
    
    /// Creates a bounce curve.
    /// - Parameter easeIn: If true, bounces at the start. Defaults to false.
    public init(easeIn: Bool = false) {
        self.easeIn = easeIn
    }
    
    public func transform(_ t: Double) -> Double {
        if easeIn {
            return 1 - bounceOut(1 - t)
        } else {
            return bounceOut(t)
        }
    }
    
    private func bounceOut(_ t: Double) -> Double {
        if t < 1 / 2.75 {
            return 7.5625 * t * t
        } else if t < 2 / 2.75 {
            let adjustedT = t - 1.5 / 2.75
            return 7.5625 * adjustedT * adjustedT + 0.75
        } else if t < 2.5 / 2.75 {
            let adjustedT = t - 2.25 / 2.75
            return 7.5625 * adjustedT * adjustedT + 0.9375
        } else {
            let adjustedT = t - 2.625 / 2.75
            return 7.5625 * adjustedT * adjustedT + 0.984375
        }
    }
}

// MARK: - Polynomial Curve

/// A polynomial timing curve with configurable exponent.
///
/// Higher exponents create more dramatic easing effects.
public struct PolynomialCurve: TimingCurve {
    /// The exponent for the polynomial function.
    public let exponent: Double
    
    /// The easing mode.
    public let mode: EasingMode
    
    /// Defines the easing direction.
    public enum EasingMode {
        case easeIn
        case easeOut
        case easeInOut
    }
    
    /// Creates a polynomial curve.
    /// - Parameters:
    ///   - exponent: The polynomial exponent. Common values: 2 (quad), 3 (cubic), 4 (quart), 5 (quint).
    ///   - mode: The easing mode.
    public init(exponent: Double = 2, mode: EasingMode = .easeInOut) {
        self.exponent = exponent
        self.mode = mode
    }
    
    public func transform(_ t: Double) -> Double {
        switch mode {
        case .easeIn:
            return pow(t, exponent)
        case .easeOut:
            return 1 - pow(1 - t, exponent)
        case .easeInOut:
            if t < 0.5 {
                return pow(2, exponent - 1) * pow(t, exponent)
            } else {
                return 1 - pow(-2 * t + 2, exponent) / 2
            }
        }
    }
}

// MARK: - Custom Animation Extension

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension Animation {
    /// Creates an animation with a custom cubic bezier timing curve.
    /// - Parameters:
    ///   - curve: The cubic bezier curve to use.
    ///   - duration: Animation duration in seconds.
    /// - Returns: A configured Animation.
    static func cubicBezier(_ curve: CubicBezierCurve, duration: Double = 0.3) -> Animation {
        .timingCurve(curve.x1, curve.y1, curve.x2, curve.y2, duration: duration)
    }
    
    /// Sine ease in animation.
    static func sineIn(duration: Double = 0.3) -> Animation {
        cubicBezier(.sineIn, duration: duration)
    }
    
    /// Sine ease out animation.
    static func sineOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.sineOut, duration: duration)
    }
    
    /// Sine ease in out animation.
    static func sineInOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.sineInOut, duration: duration)
    }
    
    /// Quad ease in animation.
    static func quadIn(duration: Double = 0.3) -> Animation {
        cubicBezier(.quadIn, duration: duration)
    }
    
    /// Quad ease out animation.
    static func quadOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.quadOut, duration: duration)
    }
    
    /// Quad ease in out animation.
    static func quadInOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.quadInOut, duration: duration)
    }
    
    /// Cubic ease in animation.
    static func cubicIn(duration: Double = 0.3) -> Animation {
        cubicBezier(.cubicIn, duration: duration)
    }
    
    /// Cubic ease out animation.
    static func cubicOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.cubicOut, duration: duration)
    }
    
    /// Cubic ease in out animation.
    static func cubicInOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.cubicInOut, duration: duration)
    }
    
    /// Expo ease in animation.
    static func expoIn(duration: Double = 0.3) -> Animation {
        cubicBezier(.expoIn, duration: duration)
    }
    
    /// Expo ease out animation.
    static func expoOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.expoOut, duration: duration)
    }
    
    /// Expo ease in out animation.
    static func expoInOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.expoInOut, duration: duration)
    }
    
    /// Back ease in animation with overshoot.
    static func backIn(duration: Double = 0.3) -> Animation {
        cubicBezier(.backIn, duration: duration)
    }
    
    /// Back ease out animation with overshoot.
    static func backOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.backOut, duration: duration)
    }
    
    /// Back ease in out animation with overshoot.
    static func backInOut(duration: Double = 0.3) -> Animation {
        cubicBezier(.backInOut, duration: duration)
    }
}

// MARK: - Timing Curve Visualizer

/// A view that visualizes timing curves for debugging and previewing.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct TimingCurveVisualizer: View {
    /// The timing curve to visualize.
    public let curve: any TimingCurve
    
    /// The number of sample points for the curve.
    public let sampleCount: Int
    
    /// The color of the curve line.
    public let curveColor: Color
    
    /// Creates a timing curve visualizer.
    /// - Parameters:
    ///   - curve: The timing curve to display.
    ///   - sampleCount: Number of points to sample. Defaults to 100.
    ///   - curveColor: Color of the curve. Defaults to blue.
    public init(curve: any TimingCurve, sampleCount: Int = 100, curveColor: Color = .blue) {
        self.curve = curve
        self.sampleCount = sampleCount
        self.curveColor = curveColor
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                gridLines(width: width, height: height)
                
                curvePath(width: width, height: height)
                    .stroke(curveColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                
                linearReference(width: width, height: height)
                    .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func gridLines(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            for i in 0...4 {
                let x = width * CGFloat(i) / 4
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: height))
                
                let y = height * CGFloat(i) / 4
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }
        }
        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
    }
    
    private func curvePath(width: CGFloat, height: CGFloat) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: height))
            
            for i in 0...sampleCount {
                let t = Double(i) / Double(sampleCount)
                let value = curve.transform(t)
                let x = width * CGFloat(t)
                let y = height * (1 - CGFloat(value))
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }
    
    private func linearReference(width: CGFloat, height: CGFloat) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: 0))
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct TimingCurvesPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Group {
                    Text("Cubic Bezier - Ease In Out")
                        .font(.headline)
                    TimingCurveVisualizer(curve: CubicBezierCurve.easeInOut)
                        .frame(width: 200, height: 200)
                }
                
                Group {
                    Text("Spring - Bouncy")
                        .font(.headline)
                    TimingCurveVisualizer(curve: SpringCurve.bouncy, curveColor: .orange)
                        .frame(width: 200, height: 200)
                }
                
                Group {
                    Text("Elastic - Ease Out")
                        .font(.headline)
                    TimingCurveVisualizer(curve: ElasticCurve(), curveColor: .purple)
                        .frame(width: 200, height: 200)
                }
                
                Group {
                    Text("Bounce - Ease Out")
                        .font(.headline)
                    TimingCurveVisualizer(curve: BounceCurve(), curveColor: .green)
                        .frame(width: 200, height: 200)
                }
            }
            .padding()
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview("Timing Curves") {
    TimingCurvesPreview()
}
#endif
