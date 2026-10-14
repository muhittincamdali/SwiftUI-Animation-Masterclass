# Getting Started

Add the package, then add a bounce, a burst and a transition to a screen.

## Add the package

In Xcode choose **File > Add Package Dependencies…**, paste
`https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git` into the search field at
the top right, leave **Dependency Rule** at **Up to Next Major Version** from `2.0.0`, choose
**Add Package**, and in the next sheet add the **SwiftUIAnimationMasterclass** library to your
app target. Use 2.0.0 or later: the 1.0.0 release did not build. In a package, add it to
`Package.swift` instead:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git", from: "2.0.0")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "SwiftUIAnimationMasterclass", package: "SwiftUI-Animation-Masterclass")
    ])
]
```

The package requires Swift 6.2 tools and runs on iOS 17 or macOS 14 and later.

## See everything at once

``AnimationShowcase`` is a ready-made screen with one effect of each kind. Put it in a preview
to try the package before writing any code:

```swift
import SwiftUI
import SwiftUIAnimationMasterclass

#Preview {
    AnimationShowcase()
}
```

## Drop a value with a bounce

``SwiftUICore/Animation/gravityBounce(fallDuration:restitution:)`` is an `Animation`, so it works
anywhere an animation does. The value falls onto its new target and bounces there:

```swift
struct DropBadge: View {
    @State private var isDropped = false

    var body: some View {
        Image(systemName: "bell.fill")
            .offset(y: isDropped ? 0 : -120)
            .animation(.gravityBounce(restitution: 0.5), value: isDropped)
            .onAppear { isDropped = true }
    }
}
```

## Celebrate with particles

``SwiftUICore/View/particleBurst(_:trigger:)`` emits a burst from the view every time a value
changes. Start from a preset such as ``ParticleEmitter/confetti`` or ``ParticleEmitter/hearts``:

```swift
struct OrderButton: View {
    @State private var orders = 0

    var body: some View {
        Button("Place order") { orders += 1 }
            .buttonStyle(.borderedProminent)
            .particleBurst(.confetti, trigger: orders)
    }
}
```

For effects that keep running, such as ``ParticleEmitter/snow``, use
``SwiftUICore/View/particleEffect(_:isActive:)``. <doc:DesigningParticleEffects> shows how to
build your own emitter.

## Draw attention to a change

``SwiftUICore/View/changeEffect(_:value:)`` plays a short animation each time a value changes.
A shake is a good answer to a wrong password:

```swift
struct PasswordField: View {
    @State private var password = ""
    @State private var failures = 0

    var body: some View {
        SecureField("Password", text: $password)
            .changeEffect(.shake(), value: failures)
            .onSubmit { if password.count < 8 { failures += 1 } }
    }
}
```

## Show and hide views

The transitions work with `if` and `withAnimation` like the built-in ones:

```swift
struct PhotoReveal: View {
    @State private var showsPhoto = false

    var body: some View {
        VStack {
            Button("Reveal") {
                withAnimation(.smooth(duration: 0.6)) { showsPhoto.toggle() }
            }
            if showsPhoto {
                Image(systemName: "photo")
                    .font(.system(size: 120))
                    .transition(.iris(origin: .topTrailing))
            }
        }
    }
}
```

Next, <doc:ThrowingAndSnapping> adds draggable views that keep the speed of the finger.
