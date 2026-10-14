import SwiftUI
import Testing
@testable import SwiftUIAnimationMasterclass

@Suite("Transitions")
struct TransitionTests {
    @Test func irisRadiusReachesTheFarthestCorner() {
        let size = CGSize(width: 300, height: 400)
        #expect(IrisTransition.coveringRadius(in: size, origin: .center) == 250)
        #expect(IrisTransition.coveringRadius(in: size, origin: .topLeading) == 500)
        #expect(IrisTransition.coveringRadius(in: size, origin: .bottomTrailing) == 500)
        #expect(IrisTransition.coveringRadius(in: .zero, origin: .center) == 0)
        #expect(IrisTransition.coveringRadius(in: CGSize(width: CGFloat.nan, height: 10), origin: .center) == 0)
    }

    @Test func wipeGrowsFromItsEdgeAlongOneAxis() {
        #expect(WipeTransition.anchor(for: .leading) == .leading)
        #expect(WipeTransition.anchor(for: .bottom) == .bottom)
        #expect(WipeTransition.scale(for: .leading, isIdentity: true) == CGSize(width: 1, height: 1))
        let horizontal = WipeTransition.scale(for: .trailing, isIdentity: false)
        #expect(horizontal.width < 0.01 && horizontal.height == 1)
        let vertical = WipeTransition.scale(for: .top, isIdentity: false)
        #expect(vertical.height < 0.01 && vertical.width == 1)
    }

    @Test func flipEntersFromOneSideAndLeavesToTheOther() {
        #expect(FlipTransition.angle(for: .willAppear).degrees == -90)
        #expect(FlipTransition.angle(for: .identity).degrees == 0)
        #expect(FlipTransition.angle(for: .didDisappear).degrees == 90)
    }

    @MainActor
    @Test func hiddenIrisAndWipeShowNothingAndRestingOnesShowEverything() throws {
        func coverage(_ view: some View) throws -> Double {
            let renderer = ImageRenderer(content: view.frame(width: 80, height: 80))
            renderer.scale = 1
            let pixels = try PixelBuffer(#require(renderer.cgImage))
            return pixels.coverage
        }
        let square = Rectangle().fill(.blue)
        #expect(try coverage(square.modifier(TransitionPreview(transition: .iris(), phase: .identity))) > 0.99)
        #expect(try coverage(square.modifier(TransitionPreview(transition: .iris(), phase: .willAppear))) < 0.01)
        #expect(try coverage(square.modifier(TransitionPreview(transition: .wipe(from: .leading), phase: .identity))) > 0.99)
        #expect(try coverage(square.modifier(TransitionPreview(transition: .wipe(from: .leading), phase: .didDisappear))) < 0.01)
        #expect(try coverage(square.modifier(TransitionPreview(transition: .pop, phase: .willAppear))) < 0.01)
    }
}

/// Applies a transition in a fixed phase, so a test can render it.
private struct TransitionPreview<T: Transition>: ViewModifier {
    let transition: T
    let phase: TransitionPhase

    func body(content: Content) -> some View {
        transition.apply(content: content, phase: phase)
    }
}
