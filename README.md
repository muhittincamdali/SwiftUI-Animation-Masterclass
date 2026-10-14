<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-light.svg" alt="Animation Masterclass: Physics-based motion, particles, change effects and transitions for SwiftUI on iOS and macOS."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-version-light.svg" alt="Latest version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

A Swift package of motion for SwiftUI on iOS 17+ and macOS 14+: physics-based springs, decay
and bounces, drags that keep the speed of the finger, particle effects, change effects and
transitions. It is for app developers who want an effect on one screen without adopting a
framework: everything is a view modifier, an `Animation`, a `Transition` or a plain value
type, and the package has no dependencies.

## Highlights

- **Physics you can call directly** — `DampedSpring` solves the spring equation in closed form
  (tests compare it with numeric integration), `Decay` projects where a flick ends,
  `GravityBounce` drops and bounces a value, and `.gravityBounce()` runs it as a SwiftUI
  animation.
- **Drags that keep their momentum** — `.elasticDrag()` and `.snapDrag(_:offsets:selection:)`
  pass the release velocity to the spring, stretch with rubber-band resistance past the ends,
  and let a flick carry on to the next resting offset.
- **Particles in a single Canvas** — 8 presets, 5 forces and 7 shapes (including SF Symbols
  and emoji) drawn by one `Canvas`, with a seeded simulation that gives the same frames for
  the same seed and never keeps more than 10,000 particles.
- **Change effects and transitions** — shake, jump, spin, pulse, ping and shine played when a
  value changes, and iris, wipe, flip and pop transitions on the iOS 17 `Transition` protocol.
- **Reduce Motion handled** — particles are not drawn, change effects do not play, transitions
  fade and drags settle with a short ease-out when the setting is on.
- **Tested, Swift 6** — 70 Swift Testing tests on macOS, 66 of them also on an iPhone
  simulator, including NaN, infinite and out-of-range inputs; the package builds in the Swift 6
  language mode.

### What's included

| Area           | API                                                                                                                                                        |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Physics        | `DampedSpring` (`gentle`, `snappy`, `bouncy`, `smooth`), `Decay`, `GravityBounce`, `.gravityBounce(fallDuration:restitution:)`, `RubberBand`, `SnapPoints` |
| Gestures       | `.elasticDrag(axes:resistance:spring:)`, `.snapDrag(_:offsets:selection:decay:spring:)`                                                                    |
| Particles      | `.particleBurst(_:trigger:)`, `.particleEffect(_:isActive:)`, `ParticleView`, `ParticleEmitter`, `ParticleForce`, `ParticleSystem`                         |
| Presets        | `confetti`, `fireworks`, `snow`, `rain`, `sparkles`, `bubbles`, `hearts`, `embers`                                                                         |
| Change effects | `.changeEffect(_:value:)` with `.shake`, `.jump`, `.spin`, `.pulse`, `.ping`, `.shine`                                                                     |
| Transitions    | `.iris(origin:)`, `.wipe(from:)`, `.flip(axis:)`, `.pop`                                                                                                   |
| Scrolling      | `.scrollDriven(multiplier:)` (parallax)                                                                                                                    |
| Demo           | `AnimationShowcase`, a screen with one effect of each kind                                                                                                 |

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git
```

Paste it into the search field at the top right of the window. Leave **Dependency Rule** at
**Up to Next Major Version** from `2.0.0`, then click **Add Package**. In the next window,
choose your app target next to **SwiftUIAnimationMasterclass** and click **Add Package** again.

**2. Import the module**

```swift
import SwiftUIAnimationMasterclass
```

**3. Use it**

Add a modifier to any view. This like button jumps and sends up a burst of hearts on every tap:

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

struct LikeButton: View {
    @State private var likes = 0

    var body: some View {
        Button("Like", systemImage: "heart.fill") { likes += 1 }
            .buttonStyle(.borderedProminent)
            .changeEffect(.jump(), value: likes)
            .particleBurst(.hearts, trigger: likes)
    }
}
```

To see every effect before writing code, put `AnimationShowcase()` in a `#Preview`.

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git
```

Or add it to the `dependencies` in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftUIAnimationMasterclass", package: "SwiftUI-Animation-Masterclass")
    ])
]
```

Use 2.0.0 or later: the 1.0.0 release did not build.

## Usage

Every sample below is copied from
[`ReadmeSamples.swift`](Examples/MotionGallery/MotionGallery/ReadmeSamples.swift), which the
example app and the test target compile.

### Drop a value with a bounce

`.gravityBounce()` is an `Animation`: the value falls onto its new target and bounces there.

```swift
struct DropBadge: View {
    @State private var isDropped = false

    var body: some View {
        Image(systemName: "bell.fill")
            .font(.largeTitle)
            .offset(y: isDropped ? 0 : -120)
            .animation(.gravityBounce(restitution: 0.5), value: isDropped)
            .onAppear { isDropped = true }
    }
}
```

### Celebrate with particles

`.particleBurst(_:trigger:)` emits a burst every time a value changes; `.particleEffect(_:)`
keeps an effect running over a view.

```swift
struct OrderButton: View {
    @State private var orders = 0

    var body: some View {
        Button("Place order") { orders += 1 }
            .buttonStyle(.borderedProminent)
            .particleBurst(.confetti, trigger: orders)
    }
}

struct WinterScene: View {
    var body: some View {
        LinearGradient(colors: [.indigo, .blue], startPoint: .top, endPoint: .bottom)
            .particleEffect(.snow)
            .ignoresSafeArea()
    }
}
```

### Draw attention to a change

```swift
struct PasswordField: View {
    @State private var password = ""
    @State private var failures = 0

    var body: some View {
        SecureField("Password", text: $password)
            .textFieldStyle(.roundedBorder)
            .changeEffect(.shake(), value: failures)
            .onSubmit { if password.count < 8 { failures += 1 } }
    }
}
```

### Show and hide views

The transitions work with `if` and `withAnimation` like the built-in ones.

```swift
struct PhotoReveal: View {
    @State private var showsPhoto = false

    var body: some View {
        VStack {
            Button(showsPhoto ? "Hide" : "Reveal") {
                withAnimation(.smooth(duration: 0.6)) { showsPhoto.toggle() }
            }
            if showsPhoto {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 120))
                    .foregroundStyle(.blue)
                    .transition(.iris(origin: .topTrailing))
            }
        }
        .frame(height: 220, alignment: .top)
    }
}
```

### Drag with momentum

A pull-up panel with two detents: a slow release returns to the nearest one, a flick moves on.

```swift
struct PullUpPanel: View {
    @State private var detent = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.blue.gradient)
            .frame(height: 400)
            .overlay(alignment: .top) {
                Capsule().fill(.white.opacity(0.6)).frame(width: 40, height: 5).padding(10)
            }
            .snapDrag(.vertical, offsets: [0, 260], selection: $detent)
    }
}
```

### Design your own particle effect

Every emitter parameter has a default, so set only what makes the effect different:

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

## Demo

Rendered frame by frame from the package's own simulation and effect code by
[`scripts/render-readme-media.sh`](scripts/render-readme-media.sh) (particle colors set to the
blue palette, as in the Usage section):

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/particles-dark.gif">
  <img src="docs/images/particles-light.gif" alt="Confetti and fireworks bursts, snow and embers drawn by ParticleSystem" width="720">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/effects-dark.gif">
  <img src="docs/images/effects-light.gif" alt="The shake, jump, spin, pulse, ping and shine change effects" width="720">
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/physics-dark.gif">
  <img src="docs/images/physics-light.gif" alt="A ball dropped with gravityBounce, a bouncy DampedSpring and a Decay flick" width="720">
</picture>

Screens of the example app on an iPhone simulator, captured by
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh):

| Physics lab                                                  | Change effects                                                  | Transitions                                                      |
| ------------------------------------------------------------ | --------------------------------------------------------------- | ---------------------------------------------------------------- |
| ![Physics lab, light](docs/images/example-physics-light.png) | ![Change effects, light](docs/images/example-effects-light.png) | ![Transitions, light](docs/images/example-transitions-light.png) |
| ![Physics lab, dark](docs/images/example-physics-dark.png)   | ![Change effects, dark](docs/images/example-effects-dark.png)   | ![Transitions, dark](docs/images/example-transitions-dark.png)   |

To try the effects yourself, open `MotionGallery.xcodeproj` in
[`Examples/MotionGallery`](Examples/MotionGallery) with Xcode, choose an iPhone simulator or
**My Mac**, and press **Run**. [Examples/README.md](Examples/README.md) has the details.

## Documentation

Reference documentation and articles:

- [API reference](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/)
  (DocC, published to GitHub Pages from `main`)
- Build it locally in Xcode with **Product › Build Documentation**, or from the command line:

```sh
xcodebuild docbuild -scheme SwiftUIAnimationMasterclass -destination 'generic/platform=macOS'
```

## Guides

- [Getting Started](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/gettingstarted)
  — add the package, then a bounce, a burst, a shake and a transition
  ([source](Sources/SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.docc/GettingStarted.md)).
- [Throwing and Snapping](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/throwingandsnapping)
  — the drag modifiers, and the springs, decay and snap points underneath
  ([source](Sources/SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.docc/ThrowingAndSnapping.md)).
- [Designing Particle Effects](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/designingparticleeffects)
  — presets, emitters, forces, limits and driving the simulation yourself
  ([source](Sources/SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.docc/DesigningParticleEffects.md)).
- [Respecting Reduce Motion](https://muhittincamdali.github.io/SwiftUI-Animation-Masterclass/documentation/swiftuianimationmasterclass/respectingreducemotion)
  — what each effect does when the setting is on
  ([source](Sources/SwiftUIAnimationMasterclass/SwiftUIAnimationMasterclass.docc/RespectingReduceMotion.md)).

## Requirements

| Platform  | Minimum version       |
| --------- | --------------------- |
| iOS       | 17                    |
| macOS     | 14                    |
| Toolchain | Swift 6.2 · Xcode 26+ |

## Architecture

- `Sources/SwiftUIAnimationMasterclass/` has one folder per area: `Physics`, `Gestures`,
  `Particles`, `Effects`, `Transitions`, `Scroll` and `Showcase`.
- The motion is computed by value types with no view code: `DampedSpring`, `Decay`,
  `GravityBounce`, `RubberBand`, `SnapPoints`, `ParticleSystem` and `ChangeEffect.state(at:)`.
  The modifiers only read the environment, keep the gesture or animation state and apply the
  result, so the math is unit-tested without a screen.
- `ParticleSystem` is a struct with a SplitMix64 generator: a seed fully determines the
  particles on every platform. `ParticleView` advances it inside a `TimelineView` and draws all
  particles into one `Canvas`; the clock pauses when nothing is alive.
- Values from outside the package (emitter settings changed at run time, frame times, canvas
  sizes, gesture velocities) are clamped: non-finite numbers do not reach the simulation, and
  particle counts and bounce counts have hard limits.
- CI runs `swift test` on macOS, `xcodebuild test` on an iPhone simulator, builds the example
  app for iOS and macOS, and publishes the DocC documentation.

Run the tests locally:

```sh
swift test                                    # macOS
xcodebuild test -scheme SwiftUIAnimationMasterclass \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Roadmap

- Add the package to the Swift Package Index; `.spi.yml` is already in the repository.
- A path-following animation (move a view along a `Path` with a timing curve).
- More transitions built on the same `Transition` protocol, such as a page curl.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
