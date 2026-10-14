# Respecting Reduce Motion

What each effect does when the person using the app has turned on Reduce Motion.

## Overview

Reduce Motion (Settings › Accessibility › Motion on iOS, System Settings › Accessibility ›
Display on macOS) asks apps to avoid large or unexpected movement. Every effect in the package
reads `accessibilityReduceMotion` from the environment and changes its behaviour on its own,
so you do not have to check it at each call site.

| Effect                                                                                                                  | With Reduce Motion on                                                                      |
| ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| ``SwiftUICore/View/particleEffect(_:isActive:)``, ``SwiftUICore/View/particleBurst(_:trigger:)``, ``ParticleView``            | Nothing is drawn; living particles are removed when the setting turns on.                  |
| ``SwiftUICore/View/changeEffect(_:value:)``                                                                               | The effect does not play.                                                                  |
| ``IrisTransition``, ``WipeTransition``, ``FlipTransition``, ``PopTransition``                                                   | The view fades in and out.                                                                 |
| ``SwiftUICore/View/elasticDrag(axes:resistance:spring:)``, ``SwiftUICore/View/snapDrag(_:offsets:selection:decay:spring:)`` | The view still follows the finger, then settles with a 0.2 s ease-out instead of a spring. |
| ``SwiftUICore/View/scrollDriven(multiplier:)``                                                                            | The view scrolls with its content.                                                         |

## Animations you start yourself

``SwiftUICore/Animation/gravityBounce(fallDuration:restitution:)`` and
``DampedSpring/animation(initialVelocity:)`` return ordinary `Animation` values. SwiftUI does
not change animations you pass to `withAnimation` or `animation(_:value:)`, so choose a calmer
one yourself when the setting is on:

```swift
struct Badge: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isDropped = false

    var body: some View {
        Image(systemName: "star.fill")
            .offset(y: isDropped ? 0 : -80)
            .animation(reduceMotion ? .easeOut(duration: 0.2) : .gravityBounce(), value: isDropped)
            .onAppear { isDropped = true }
    }
}
```

## Test it

In the iOS Simulator, turn the setting on under Settings › Accessibility › Motion. In an Xcode
preview, open the canvas's device settings or set the environment value directly.
