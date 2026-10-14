# Examples

## MotionGallery

A small iOS and macOS app with every effect in the package:

- **Showcase**: `AnimationShowcase`, one effect of each kind on one screen.
- **Physics lab**: a spring curve that redraws as you change its response and damping ratio,
  with its settling time, and a ball dropped with an adjustable restitution.
- **Particles**: every preset; continuous ones run, burst ones fire from a button.
- **Change effects**: tap a tile to play shake, jump, spin, pulse, ping or shine.
- **Transitions**: show and hide a card with the iris, wipe, flip or pop transition.
- **Gestures**: an elastic card and a carousel that snaps between pages.
- One screen per README sample.

It uses the package from this checkout (a local package reference to `../..`), so it always
shows the current code.

Run it:

1. Open `Examples/MotionGallery/MotionGallery.xcodeproj` in Xcode 26 or later.
2. Choose the **MotionGallery** scheme and an iPhone simulator or **My Mac** as the run
   destination.
3. Press **Run** (⌘R).

From the command line:

```sh
cd Examples/MotionGallery
xcodebuild build -scheme MotionGallery -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme MotionGallery -destination 'platform=macOS'
```

To open one screen directly, pass its name as a launch argument, for example
`-sample particles` (the names are the cases of `GalleryView.Sample`).

The README samples live in
[`MotionGallery/ReadmeSamples.swift`](MotionGallery/MotionGallery/ReadmeSamples.swift). The
README copies its code from that file, and the package's test target compiles and draws the
same file through the symlink `Tests/SwiftUIAnimationMasterclassTests/ReadmeExamples.swift`.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](MotionGallery/project.yml) and committed, so you only need XcodeGen after
editing `project.yml`.
