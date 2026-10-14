# Designing Particle Effects

Start from a preset, change what you need, or describe a new effect with an emitter and forces.

## Overview

A particle effect has two parts. A ``ParticleEmitter`` describes how particles are born, how
they move and what they look like. A ``ParticleSystem`` runs the simulation: births, forces,
motion and deaths. ``ParticleView`` and the two modifiers own a system and draw it every frame
into a single `Canvas`, so hundreds of particles cost one view.

## Pick a modifier

Use ``SwiftUICore/View/particleBurst(_:trigger:)`` for one-off bursts tied to an event:

```swift
Button("Like", systemImage: "heart.fill") { likes += 1 }
    .particleBurst(.hearts, trigger: likes)
```

The burst is drawn in a square of twice the emitter's ``ParticleEmitter/reach`` centered on
the view, so particles can fly past its edges. If neighbouring views cover them, raise the
view with `zIndex`.

Use ``SwiftUICore/View/particleEffect(_:isActive:)`` for effects that keep running and fill
the view, such as weather:

```swift
Image("cabin")
    .resizable()
    .scaledToFill()
    .particleEffect(.snow, isActive: isWinter)
```

Turning `isActive` off stops new births and lets the living particles finish. The animation
clock pauses once nothing is left to draw.

## Change a preset

The presets are ``ParticleEmitter/confetti``, ``ParticleEmitter/fireworks``,
``ParticleEmitter/snow``, ``ParticleEmitter/rain``, ``ParticleEmitter/sparkles``,
``ParticleEmitter/bubbles``, ``ParticleEmitter/hearts`` and ``ParticleEmitter/embers``. They
are plain values, so copy one and change any property:

```swift
var brandConfetti = ParticleEmitter.confetti
brandConfetti.colors = [.blue, .cyan, .white]
brandConfetti.burstCount = 80
```

## Describe a new effect

Every parameter of ``ParticleEmitter/init(source:position:birthRate:burstCount:maxParticles:lifetime:speed:direction:spread:size:endScale:spin:tumble:alignsWithMotion:drag:forces:colors:shapes:fadeIn:fadeOutStart:blending:reach:)``
has a default, so set only what makes your effect different. This one sends stars up from the
bottom edge and lets them swirl around the center:

```swift
let stardust = ParticleEmitter(
    source: .edge(.bottom),
    birthRate: 30,
    lifetime: 2...3,
    speed: 60...120,
    direction: .degrees(-90),
    spread: .degrees(20),
    size: 6...10,
    endScale: 0.3,
    forces: [.vortex(center: .center, strength: 80), .gravity(-20)],
    colors: [.white, .cyan],
    shapes: [.star],
    fadeIn: 0.1,
    blending: .additive
)
```

Directions follow SwiftUI: `0°` points right and `90°` points down. Ranges are sampled
uniformly for every particle. ``ParticleForce`` values add up; gravity with a negative
strength makes particles rise.

Shapes can be drawn paths (``ParticleShape/circle``, ``ParticleShape/rectangle(aspectRatio:)``,
``ParticleShape/star`` and others), SF Symbols tinted with the particle color
(``ParticleShape/symbol(_:)``), or short text such as an emoji (``ParticleShape/text(_:)``).

## Limits

``ParticleEmitter/maxParticles`` caps the living particles of one emitter, and a system never
keeps more than ``ParticleSystem/particleLimit`` whatever the emitter says. Births beyond the
cap are skipped, not queued. Frame times longer than a quarter of a second, for example after
the app returns from the background, are simulated as a quarter of a second.

## Drive the simulation yourself

``ParticleSystem`` has no timer of its own. Call ``ParticleSystem/update(by:in:)`` with the
time that passed and draw ``ParticleSystem/particles`` however you like. With a fixed seed the
same calls always give the same particles, which makes effects testable:

```swift
var system = ParticleSystem(emitter: .confetti, seed: 1)
system.burst()
system.update(by: 1 / 60, in: CGSize(width: 400, height: 400))
let count = system.particles.count // 120
```
