# Contributing

Thanks for taking the time to improve SwiftUI Animation Masterclass.

## Reporting bugs

Open an issue with:

- the modifier, emitter or physics type and the arguments you used,
- what you expected and what happened (a screen recording helps for motion bugs),
- whether Reduce Motion was on,
- platform and OS version (iOS simulator/device or macOS) and Xcode version.

## Pull requests

1. Fork the repository and branch from `main`.
2. Keep each pull request focused on one change.
3. Run the tests on both platforms:

    ```sh
    swift test
    xcodebuild test -scheme SwiftUIAnimationMasterclass \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
    ```

4. Keep the motion in value types (`DampedSpring`, `ParticleSystem`, `ChangeEffect.state(at:)`
   and the small enums next to each modifier) and add or update a test for it in
   `Tests/SwiftUIAnimationMasterclassTests`. Compare physics against a numeric integration or a
   closed form, not against numbers copied from the implementation.
5. Values that come from outside (emitter settings, frame times, sizes, gesture velocities)
   may be NaN, infinite, negative or huge. Clamp them before they reach the simulation, and
   add a case to `InputBoundsTests`.
6. New effects respect Reduce Motion; describe what they do with it in
   `RespectingReduceMotion.md`.
7. If you change a README code sample, change the copy in
   `Examples/MotionGallery/MotionGallery/ReadmeSamples.swift` as well. That file is what gets
   compiled: by the example app, and by `swift test` through the symlink
   `Tests/SwiftUIAnimationMasterclassTests/ReadmeExamples.swift`. Build the app with:

    ```sh
    cd Examples/MotionGallery
    xcodebuild build -scheme MotionGallery -destination 'generic/platform=iOS Simulator'
    ```

8. If a change affects the README media, regenerate it with `scripts/render-readme-media.sh`
   (GIFs) and `scripts/capture-example-screens.sh` (example app screenshots).
9. `README.md` has translations (`README.<language>.md`). Each one records the version of
   `README.md` it follows, and CI fails while a translation is behind. If you change `README.md`
   and cannot update the translations, say so in the pull request and they will be updated
   before it is merged.

## Code style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- The package builds in the Swift 6 language mode; new code should not add warnings.
- Document public API with DocC comments (`///`); the documentation builds with
  `--warnings-as-errors`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).

## License

By contributing you agree that your contributions are licensed under the MIT License.
