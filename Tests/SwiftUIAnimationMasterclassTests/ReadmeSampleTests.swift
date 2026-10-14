import SwiftUI
import Testing
@testable import SwiftUIAnimationMasterclass

/// The README samples (ReadmeExamples.swift, shared with the example app) compile as part of
/// this target; these tests also lay each one out and draw it.
@MainActor
@Suite("README samples")
struct ReadmeSampleTests {
    /// Share of the frame the view covers. ImageRenderer leaves out controls backed by UIKit or
    /// AppKit (buttons, secure fields), so samples made of controls cover little or nothing.
    private func coverage(_ view: some View) throws -> Double {
        let renderer = ImageRenderer(content: view.frame(width: 390, height: 600))
        renderer.scale = 1
        return try PixelBuffer(#require(renderer.cgImage)).coverage
    }

    @Test func everySampleLaysOutAndDraws() throws {
        // Samples made of controls or SF Symbols (which the renderer may leave out when no
        // symbol font is loaded, as in a command-line test run): drawing must succeed.
        _ = try coverage(LikeButton())
        _ = try coverage(OrderButton())
        _ = try coverage(PasswordField())
        _ = try coverage(PhotoReveal())
        _ = try coverage(AnimationShowcase())
        _ = try coverage(DropBadge())
        // Samples that draw shapes or gradients must show them.
        #expect(try coverage(PullUpPanel()) > 0.3)
        #expect(try coverage(WinterScene()) > 0.99)
        #expect(try coverage(StardustView()) > 0.99)
    }

    @Test func stardustRisesAndSwirls() throws {
        var system = ParticleSystem(emitter: stardust, isEmitting: true, seed: 11)
        let canvas = CGSize(width: 400, height: 600)
        for _ in 0..<60 {
            system.update(by: 1.0 / 60, in: canvas)
        }
        #expect(!system.particles.isEmpty)
        // Born on the bottom edge and launched upward.
        #expect(system.particles.allSatisfy { $0.y < canvas.height && $0.velocityY < 0 })
    }
}
