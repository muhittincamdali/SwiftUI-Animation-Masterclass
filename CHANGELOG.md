# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-15

A rebuilt package. The 1.0.0 release did not build (its manifest pointed at folders that did
not exist), and later commits had reduced the sources to a demo view and a scroll modifier
that did nothing. This release keeps the public names that were left (`AnimationShowcase`,
`AnimationMasterclass.version`, `ScrollDrivenAnimator`, `scrollDriven(multiplier:)`) and adds
working physics, gestures, particles, change effects and transitions. Code from two of the
author's packages that are being archived, MobileMotion and SwiftParticles, was rewritten for
this package rather than copied.

### Added

- Physics: `DampedSpring`, solved in closed form, with `gentle`, `snappy`, `bouncy` and
  `smooth` presets, settling time and conversion to a SwiftUI animation with a relative
  initial velocity; `Decay` with the iOS scroll-view rates and projected distance;
  `GravityBounce` and the `.gravityBounce(fallDuration:restitution:)` animation;
  `RubberBand` and `SnapPoints`. Based on MobileMotion's spring, friction and gravity models.
- Gestures: `.elasticDrag(axes:resistance:spring:)` and
  `.snapDrag(_:offsets:selection:decay:spring:)`, which carry the release velocity into the
  spring. Based on MobileMotion's gesture-driven animations.
- Particles: `ParticleEmitter`, `ParticleForce` (gravity, wind, turbulence, attractor,
  vortex), `ParticleShape` (including SF Symbols and text), `ParticleSystem` with a seeded
  generator, `ParticleView`, `.particleEffect(_:isActive:)`, `.particleBurst(_:trigger:)` and
  the presets `confetti`, `fireworks`, `snow`, `rain`, `sparkles`, `bubbles`, `hearts` and
  `embers`. Based on SwiftParticles' emitters, forces and presets.
- Change effects: `.changeEffect(_:value:)` with `shake`, `jump`, `spin`, `pulse`, `ping`
  and `shine`, and `ChangeEffect.state(at:)` to inspect any frame.
- Transitions: `.iris(origin:)`, `.wipe(from:)`, `.flip(axis:)` and `.pop`.
- Every effect respects Reduce Motion.
- DocC catalog with four articles, the MotionGallery example app for iOS and macOS, README
  media rendered from the package's code, and `.spi.yml`.

### Changed

- `scrollDriven(multiplier:)` and `ScrollDrivenAnimator` now move the view: a parallax offset
  of `multiplier` times the scroll distance. Before, they measured the view and discarded the
  result.
- `AnimationShowcase` shows the package's own effects instead of a stock spring.
- The package requires Swift 6.2 tools, iOS 17 and macOS 14, and builds in the Swift 6
  language mode.

### Removed

- The CocoaPods podspec, the circuit breaker, retry and event bus utilities, and sources that
  were outside the target or did not compile.

### Security

- Values that reach the package at run time cannot crash it or grow memory without limit:
  particle counts are capped at `ParticleSystem.particleLimit` (10,000), queued bursts are a
  single bounded count, huge or infinite birth rates, infinite ranges, emptied color or shape
  lists, degenerate forces, non-finite frame times and canvas sizes are handled, bounces are
  capped at `GravityBounce.bounceLimit` (100), NaN or infinite gesture velocities start
  springs at rest, and `.gravityBounce(fallDuration:restitution:)` rejects fall durations
  that are not finite or whose gravity (2 / T²) would be zero or infinite.
- `DampedSpring.mass`, `stiffness` and `damping`, `Decay.decelerationRate` and
  `GravityBounce.gravity` check the initializer's rules when they are set, instead of letting
  an invalid value produce NaN or infinite results later.

## [1.0.0] - 2026-02-02

First release. Its package manifest referenced source folders that were not in the
repository, so it could not be built.

[Unreleased]: https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/releases/tag/v1.0.0
