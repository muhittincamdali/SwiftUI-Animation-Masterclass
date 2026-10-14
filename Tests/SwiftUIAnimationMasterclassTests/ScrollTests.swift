import SwiftUI
import Testing
@testable import SwiftUIAnimationMasterclass

@Suite("Scroll parallax")
struct ScrollTests {
    @Test func offsetTakesBackTheMultipliedShareOfTheScroll() {
        // Scrolled 100 pt down: the view's top moved from 0 to -100.
        #expect(ScrollParallax.offset(minY: -100, multiplier: 0.5) == 50)
        #expect(ScrollParallax.offset(minY: -100, multiplier: 1) == 100) // stays put on screen
        #expect(ScrollParallax.offset(minY: -100, multiplier: 0) == 0)
        #expect(ScrollParallax.offset(minY: 80, multiplier: 0.25) == -20)
    }

    @Test func nonFiniteValuesGiveNoOffset() {
        #expect(ScrollParallax.offset(minY: .nan, multiplier: 0.5) == 0)
        #expect(ScrollParallax.offset(minY: -100, multiplier: .infinity) == 0)
    }
}
