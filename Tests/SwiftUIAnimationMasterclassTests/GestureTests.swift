import SwiftUI
import Testing
@testable import SwiftUIAnimationMasterclass

@Suite("Gestures")
struct GestureTests {
    @Test func elasticOffsetOnlyMovesAlongAllowedAxes() {
        let both = ElasticDrag.offset(for: CGSize(width: 100, height: -100), axes: [.horizontal, .vertical], resistance: 240)
        #expect(both.width > 0 && both.width < 100)
        #expect(both.height == -both.width)

        let horizontal = ElasticDrag.offset(for: CGSize(width: 100, height: -100), axes: .horizontal, resistance: 240)
        #expect(horizontal.height == 0)
        #expect(horizontal.width == both.width)
    }

    @Test func offsetVelocityShrinksWithTheStretch() {
        let finger = CGSize(width: 1000, height: 0)
        let atStart = ElasticDrag.offsetVelocity(finger, at: .zero, axes: .horizontal, resistance: 240)
        let stretched = ElasticDrag.offsetVelocity(finger, at: CGSize(width: 300, height: 0), axes: .horizontal, resistance: 240)
        #expect(abs(atStart.width - 550) < 1e-9) // slope at zero is the coefficient, 0.55
        #expect(stretched.width < atStart.width)
        #expect(stretched.width > 0)

        // The slope is the derivative of the rubber band: compare with a finite difference.
        let step: CGFloat = 0.001
        let difference = (RubberBand.offset(300 + step, dimension: 240) - RubberBand.offset(300, dimension: 240)) / step
        #expect(abs(stretched.width / 1000 - difference) < 1e-4)
    }

    @Test func returnVelocityIsRelativeToTheDistanceBack() {
        // Pulled 100 pt right and still moving right at 200 pt/s: moving away from zero.
        #expect(ElasticDrag.returnVelocity(offset: CGSize(width: 100, height: 0), velocity: CGSize(width: 200, height: 0)) == -2)
        // Moving back toward zero at 300 pt/s from 100 pt: three changes per second.
        #expect(ElasticDrag.returnVelocity(offset: CGSize(width: 0, height: 100), velocity: CGSize(width: 0, height: -300)) == 3)
        // Velocity across the direction of travel does not count.
        #expect(ElasticDrag.returnVelocity(offset: CGSize(width: 100, height: 0), velocity: CGSize(width: 0, height: 500)) == 0)
        #expect(ElasticDrag.returnVelocity(offset: .zero, velocity: CGSize(width: 10, height: 10)) == 0)
    }

    @Test func snapDragFollowsTheFingerBetweenOffsetsAndStretchesBeyond() {
        let offsets: [CGFloat] = [260, 0]
        #expect(SnapDrag.position(start: 0, translation: 120, offsets: offsets) == 120)
        let below = SnapDrag.position(start: 260, translation: 100, offsets: offsets)
        #expect(below > 260 && below < 360)
        let above = SnapDrag.position(start: 0, translation: -100, offsets: offsets)
        #expect(above < 0 && above > -100)
        #expect(abs(abs(above) - (below - 260)) < 1e-9)
    }
}
