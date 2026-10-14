import SwiftUI
import Testing
@testable import SwiftUIAnimationMasterclass

private let allEffects: [ChangeEffect] = [.shake(), .jump(), .spin(), .spin(turns: -2), .pulse(), .ping(), .shine]

private func isAtRest(_ state: ChangeEffectState) -> Bool {
    abs(state.offset.width) < 1e-9 && abs(state.offset.height) < 1e-9
        && abs(state.scale.width - 1) < 1e-9 && abs(state.scale.height - 1) < 1e-9
        && abs(state.rotation.degrees.truncatingRemainder(dividingBy: 360)) < 1e-9
        && state.echoOpacity == 0 && state.shinePosition == nil
}

@Suite("Change effects")
struct ChangeEffectTests {
    @Test("every effect starts and ends at rest", arguments: allEffects)
    func startsAndEndsAtRest(effect: ChangeEffect) {
        #expect(isAtRest(effect.state(at: 0)))
        #expect(isAtRest(effect.state(at: 1)))
        // Out of range and NaN progress count as the nearest end.
        #expect(isAtRest(effect.state(at: -3)))
        #expect(isAtRest(effect.state(at: 7)))
        #expect(isAtRest(effect.state(at: .nan)))
        #expect(effect.duration > 0 && effect.duration < 6)
    }

    @Test func shakeSwingsBothWaysWithinTheDistanceAndCountsItsSwings() {
        let effect = ChangeEffect.shake(distance: 12, count: 4)
        let samples = stride(from: 0.0, through: 1.0, by: 0.001).map { effect.state(at: $0).offset.width }
        #expect(samples.allSatisfy { abs($0) <= 12 })
        #expect(samples.max()! > 6 && samples.min()! < -6)
        // A swing goes right and back left: two sign changes per swing, minus the final rest.
        let signChanges = zip(samples, samples.dropFirst()).filter { $0 > 0 && $1 < 0 || $0 < 0 && $1 > 0 }.count
        #expect(signChanges == 4 * 2 - 1)
        #expect(effect.state(at: 0.5).offset.height == 0)
    }

    @Test func jumpPeaksHalfWayAndSquashesOnLanding() {
        let effect = ChangeEffect.jump(height: 20)
        #expect(abs(effect.state(at: 0.5).offset.height + 20) < 1e-9)
        #expect(effect.state(at: 0.25).offset.height > effect.state(at: 0.5).offset.height)
        let landing = effect.state(at: 0.9)
        #expect(landing.scale.width > 1 && landing.scale.height < 1)
        #expect(abs(landing.scale.width - 1 - (1 - landing.scale.height)) < 1e-12) // keeps the area
        #expect(effect.state(at: 0.5).scale == CGSize(width: 1, height: 1))
    }

    @Test func spinTurnsTheRequestedWayAndEases() {
        #expect(abs(ChangeEffect.spin(turns: 2).state(at: 1).rotation.degrees - 720) < 1e-9)
        #expect(abs(ChangeEffect.spin(turns: -1).state(at: 1).rotation.degrees + 360) < 1e-9)
        #expect(abs(ChangeEffect.spin(turns: 1).state(at: 0.5).rotation.degrees - 180) < 1e-9)
        // Eased: slower than linear at the start.
        #expect(ChangeEffect.spin(turns: 1).state(at: 0.1).rotation.degrees < 36)
    }

    @Test func pulseAndPingGrowWhereExpected() {
        let pulse = ChangeEffect.pulse(scale: 1.4)
        #expect(abs(pulse.state(at: 0.5).scale.width - 1.4) < 1e-9)
        #expect(pulse.state(at: 0.5).echoOpacity == 0)

        let ping = ChangeEffect.ping(scale: 2)
        let early = ping.state(at: 0.2)
        let late = ping.state(at: 0.8)
        #expect(early.echoScale < late.echoScale && late.echoScale <= 2)
        #expect(early.echoOpacity > late.echoOpacity && late.echoOpacity > 0)
        #expect(early.scale == CGSize(width: 1, height: 1)) // the view itself does not move
    }

    @Test func extremeParametersStayBounded() {
        #expect(ChangeEffect.shake(count: .max).duration == ChangeEffect.shake(count: 20).duration)
        #expect(ChangeEffect.shake(count: -4).duration == ChangeEffect.shake(count: 1).duration)
        #expect(ChangeEffect.spin(turns: .min).state(at: 1).rotation.degrees == -7200)
        #expect(ChangeEffect.shake(distance: .nan).state(at: 0.3).offset.width == 0)
        #expect(ChangeEffect.jump(height: .infinity).state(at: 0.5).offset.height == 0)
        #expect(ChangeEffect.pulse(scale: .nan).state(at: 0.5).scale.width == 1)
    }

    @Test func shineBandCrossesTheWholeView() {
        let width: CGFloat = 200
        let band = width * ShineBand.relativeWidth
        #expect(abs(ShineBand.offset(at: 0, width: width) + band) < 1e-9) // ends at the leading edge
        #expect(abs(ShineBand.offset(at: 1, width: width) - width) < 1e-9) // starts at the trailing edge
        #expect(ChangeEffect.shine.state(at: 0.5).shinePosition == 0.5)
    }

    @MainActor
    @Test func shineBrightensTheViewButNotItsTransparentCorners() throws {
        func render(_ state: ChangeEffectState) throws -> PixelBuffer {
            let view = Circle().fill(Color(red: 0, green: 0, blue: 0.6))
                .frame(width: 100, height: 100)
                .modifier(ChangeEffectFrame(state: state))
            let renderer = ImageRenderer(content: view)
            renderer.scale = 1
            return try PixelBuffer(#require(renderer.cgImage))
        }
        var shining = ChangeEffectState()
        shining.shinePosition = 0.5
        let plain = try render(.identity)
        let lit = try render(shining)

        // The band crosses the middle of the circle at 0.5.
        #expect(lit.pixel(x: 50, y: 50).red > plain.pixel(x: 50, y: 50).red + 0.3)
        // The corner is outside the circle: the band is masked to the view's opaque pixels.
        #expect(lit.pixel(x: 2, y: 2).alpha == 0)
    }
}
