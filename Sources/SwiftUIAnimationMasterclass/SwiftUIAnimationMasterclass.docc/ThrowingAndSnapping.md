# Throwing and Snapping

Build drags that keep the speed of the finger: rubber-band edges, flicks that carry on, and
springs that start where the gesture left off.

## Overview

A drag feels physical when three things hold: past an edge the view follows the finger less
and less, a quick flick travels further than a slow release, and the spring that settles the
view starts at the speed the finger had. The two drag modifiers do all three; the value types
underneath let you build your own.

## Pull and let go

``SwiftUICore/View/elasticDrag(axes:resistance:spring:)`` lets a view be pulled with
rubber-band resistance and springs it back on release:

```swift
Image(systemName: "hand.draw")
    .font(.system(size: 64))
    .elasticDrag(axes: .vertical, resistance: 180, spring: .bouncy)
```

`resistance` is the distance the view approaches but never reaches; smaller values feel
stiffer. The release velocity is scaled by how stretched the view was, because a stretched
view moves slower than the finger, and passed to the spring.

## Snap between resting offsets

``SwiftUICore/View/snapDrag(_:offsets:selection:decay:spring:)`` drags a view along one axis
between resting offsets, such as the detents of a pull-up panel:

```swift
struct PullUpPanel: View {
    @State private var detent = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.blue.gradient)
            .frame(height: 400)
            .snapDrag(.vertical, offsets: [0, 260], selection: $detent)
    }
}
```

On release, the view lands on the offset closest to where its momentum would carry it. A
slow release returns to the nearest offset; a flick moves on to the next one. Changing
`selection` from code moves the view with the same spring.

## The math underneath

The modifiers are built from value types you can use on their own, for example in a custom
`Gesture` or in a game loop.

``Decay`` models a flicked scroll view: the velocity keeps a fixed share of itself every
millisecond. ``Decay/projectedDistance(initialVelocity:)`` says how far the content would
travel, which is what you need to choose a landing point:

```swift
let landing = position + Decay.normal.projectedDistance(initialVelocity: velocity)
```

``SnapPoints`` turns that into a choice among resting positions with
``SnapPoints/index(forRelease:velocity:decay:)``, and ``RubberBand`` gives the resistance past
an edge with ``RubberBand/clamp(_:to:dimension:coefficient:)``.

``DampedSpring`` solves the spring equation in closed form, so its position does not drift
with the frame rate. It accepts the physical constants or the `response` and damping ratio
SwiftUI uses, answers where the spring is at any time and when it settles, and converts itself
into a SwiftUI animation:

```swift
let spring = DampedSpring(response: 0.4, dampingRatio: 0.7)
let settles = spring.settlingDuration(initialDisplacement: 120, initialVelocity: 0)
let animation = spring.animation(
    initialVelocity: DampedSpring.relativeVelocity(velocity, from: start, to: target)
)
```

SwiftUI springs take their initial velocity relative to the change being animated: `1` means
the value would cover the whole change in one second.
``DampedSpring/relativeVelocity(_:from:to:)`` converts a velocity in points per second.

## Bounce onto a target

``GravityBounce`` drops a value onto a floor and bounces it, losing a share of the speed at
each impact. ``SwiftUICore/Animation/gravityBounce(fallDuration:restitution:)`` runs it as a
SwiftUI animation; ``GravityBounce/impactTimes(height:initialVelocity:)`` gives the moments of
each impact, for example to play a sound or a haptic in time with the bounces.
