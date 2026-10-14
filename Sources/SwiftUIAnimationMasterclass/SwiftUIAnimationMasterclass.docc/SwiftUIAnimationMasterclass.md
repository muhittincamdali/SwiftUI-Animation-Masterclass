# `SwiftUIAnimationMasterclass`

Physics-based motion, particle effects, change effects and transitions for SwiftUI on iOS 17 and macOS 14.

## Overview

SwiftUIAnimationMasterclass is a single Swift package with no dependencies. Everything is a
SwiftUI modifier, an `Animation`, a `Transition` or a plain value type, so you can add one
effect to an existing screen without adopting anything else:

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

struct LikeButton: View {
    @State private var likes = 0

    var body: some View {
        Button("Like", systemImage: "heart.fill") { likes += 1 }
            .changeEffect(.jump(), value: likes)
            .particleBurst(.hearts, trigger: likes)
    }
}
```

The motion behind each effect is computed by value types that you can call directly and
that the package's tests check against the physics: ``DampedSpring`` solves the spring
equation in closed form, ``Decay`` projects where a flick ends, ``GravityBounce`` drops and
bounces a value, and ``ParticleSystem`` simulates particles with a seeded generator, so the
same seed always gives the same frames.

Every effect respects Reduce Motion: particles are not drawn, change effects do not play,
transitions become fades and drags settle with a short ease-out.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:ThrowingAndSnapping>
- <doc:DesigningParticleEffects>
- <doc:RespectingReduceMotion>
- ``AnimationShowcase``
- ``AnimationMasterclass``

### Physics

- ``DampedSpring``
- ``Decay``
- ``GravityBounce``
- ``GravityBounceAnimation``
- ``RubberBand``
- ``SnapPoints``

### Gestures

- ``SwiftUICore/View/elasticDrag(axes:resistance:spring:)``
- ``SwiftUICore/View/snapDrag(_:offsets:selection:decay:spring:)``

### Particles

- ``SwiftUICore/View/particleEffect(_:isActive:)``
- ``SwiftUICore/View/particleBurst(_:trigger:)``
- ``ParticleView``
- ``ParticleEmitter``
- ``ParticleForce``
- ``ParticleShape``
- ``ParticleBlending``
- ``ParticleSystem``
- ``Particle``

### Change effects

- ``SwiftUICore/View/changeEffect(_:value:)``
- ``ChangeEffect``
- ``ChangeEffectState``

### Transitions

- ``IrisTransition``
- ``WipeTransition``
- ``FlipTransition``
- ``PopTransition``

### Scrolling

- ``SwiftUICore/View/scrollDriven(multiplier:)``
- ``ScrollDrivenAnimator``
