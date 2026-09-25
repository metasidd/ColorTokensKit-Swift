# Contributing to ColorTokensKit

This guide covers building and testing the package, updating the README images, keeping the repository small, clearing old history, and the conventions the code follows. Architecture notes for each part of the code live in [CLAUDE.md](CLAUDE.md).

## Build and test

You need macOS and a recent Xcode; `Package.swift` requires Swift tools 5.10 or later.

```bash
swift build
swift test
```

`swift test` also renders the README images into `Tests/ColorTokensKitTests/Exports/` (see [README images](#readme-images)). That folder is gitignored.

A macOS build doesn't compile the UIKit code paths, so check the other platforms before you push anything that touches `Platform/` or `Package.swift`:

```bash
for spec in "arm64-apple-ios16.0 iphoneos" "arm64-apple-tvos16.0 appletvos" \
            "arm64_32-apple-watchos9.0 watchos" "arm64-apple-xros1.0 xros"; do
    triple=${spec%% *}
    sdk=${spec##* }
    swift build --scratch-path .build/$sdk --triple $triple --sdk "$(xcrun --sdk $sdk --show-sdk-path)"
done
```

## Where things live

| Folder | What's in it |
|--------|--------------|
| `Sources/ColorTokensKit/ProColor/` | `ProColor`: a color family and its stops and tokens |
| `Sources/ColorTokensKit/ColorSpace/` | Color types (RGB, LCH, OKLCH, OKLab, …) and conversions |
| `Sources/ColorTokensKit/Services/Ramps/` | Ramp generation (`UniformRamp`, `ColorRampGenerator`, gray is listed there) and the shared math: `Gamut`, `StopLadder`, `PaletteStop` |
| `Sources/ColorTokensKit/Adjustments/` | `lighten`, `soften`, `saturate`, `blend`, `invert`, … on `Color` |
| `Sources/ColorTokensKit/Harmonies/` | `complement`, `triad`, `analogous`, … on `Color` and `ProColor` |
| `Sources/ColorTokensKit/Gradients/` | `proGradient` and friends, blends, easing, recipes |
| `Sources/ColorTokensKit/Platform/` | SwiftUI, UIKit and AppKit glue, including `Color.adapting` |
| `Tests/ColorTokensKitTests/` | Tests; `Support/` has helpers; `Marketing/` renders the README images |

## Conventions

**API**
- Color functions are extensions on SwiftUI `Color`, so they work on tokens, system colors and hex colors alike.
- Follow SwiftUI's naming: plain verbs that return a copy (`saturate()`, not `saturated()` or `getSaturated()`). Names must not collide with `View` or `ShapeStyle` members, because `Color` is both.
- Gradient functions carry the `pro` prefix (`proGradient`, `proRadialGradient`, `proAngularGradient`).
- Give every parameter a sensible default so the common call needs no arguments.

**Behavior**
- A color function must return an adaptive color, built with `Color.adapting`, never a color resolved once when it's called. Otherwise tokens break in dark mode.
- Lightness and hue changes keep palette colors on the palette: `_600.lighten()` is exactly `_550`. Only colors that aren't on a ramp move continuously. `saturate`, `desaturate` and `blend` leave the palette on purpose.
- Color functions run every time a color is drawn. Keep that work small, and measure changes with a release build (`swift build -c release`) rather than a debug one.

**Code**
- US spelling in code and docs: color, gray, neighbor, math.
- Full words in names: `context`, not `ctx`.
- Every public symbol gets a doc comment that says what it does for the caller, with a short ```` ```swift ```` example where it helps. Internal comments are one terse line, and only for a non-obvious why.
- No dependencies and no resource files. Data the library needs lives in Swift (the gray ramp is a literal list). A resource file would make every app ship an extra bundle.
- Don't shorten code to save space. Formatting and names don't change the size of the compiled library, and apps strip what they don't call.

**Tests**
- Each test starts with a comment saying why the behavior matters, not just what it checks.
- Resolve colors with the helpers in `Tests/ColorTokensKitTests/Support/`: `color.hex(.light)` and `color.hex(.dark)`.
- Make sure a new test can fail. Commit first, break the behavior it guards, run the test and watch it fail, then restore with `git checkout -- <file>`.

## README images

The README images are SwiftUI views rendered by the tests.

1. The views live in `Tests/ColorTokensKitTests/Marketing/Views/`. Add a new image by writing a view and registering it in `Marketing/MarketingAssets.swift`.
2. Render them:
   ```bash
   swift test --filter MarketingTests
   ```
   PNGs land in `Tests/ColorTokensKitTests/Exports/` (gitignored). Never commit that folder.
3. Convert only the images that changed to lossless WebP (`brew install webp` provides `cwebp`):
   ```bash
   cwebp -lossless -z 9 -exact Tests/ColorTokensKitTests/Exports/<name>.png -o Assets/<name>.webp
   ```
   Lossless WebP is about a third the size of the PNG and keeps every pixel. To confirm, run `magick compare -metric AE <name>.png Assets/<name>.webp null:`, which prints 0 for a lossless file.
4. Reference it in the README as `![Name](/Assets/<name>.webp)`. In a pull request description, use a raw URL pinned to a commit so it keeps showing what you reviewed: `https://raw.githubusercontent.com/metasidd/ColorTokensKit-Swift/<commit>/Assets/<name>.webp`.

Iterate on an image locally and push it once, when it's final. Every version you push stays in what everyone downloads, even on a pull request branch you later delete (see below).

## Keeping the repository small

When an app depends on this package, SwiftPM downloads a mirror of the whole repository: every commit on every branch and tag, plus the commits of every pull request GitHub keeps. On September 25, 2026 that was 289 MB in SwiftPM's cache, while the files themselves were about 2 MB. Almost all of it is old PNG exports, committed before the Exports folder was ignored.

- Don't commit generated files: exports, build folders, `.DS_Store`.
- Commit images as lossless WebP, and push them only when they're final. GitHub keeps every pull request's commits forever, and SwiftPM downloads those too, so a squash merge doesn't undo an image pushed five times.
- Squash-merge pull requests and delete the branch afterwards, so `main` and the tags carry one version of each change.
- Delete branches that are merged or abandoned. SwiftPM downloads every branch.

## Clearing old history

This is a one-time cleanup that removes the old PNGs from every commit. It's destructive: it rewrites every commit and tag. Plan it, and don't run it with a pull request open.

**What it saves.** A rehearsal on a copy of the repository on September 25, 2026:

| History | Clone size |
|---------|------------|
| As it is | 176 MB (289 MB as SwiftPM's mirror) |
| Without `Tests/ColorTokensKitTests/Exports/` | 13 MB |
| Without that folder and without any `.png` | 2.1 MB |

The current README images are WebP, so removing every `.png` from history loses nothing current. Old tags' READMEs will show broken images.

**What it breaks.**
- Every commit hash changes, and so does every tag's commit. Apps that pinned a version need to update the pin: reset the package caches in Xcode, or delete the `ColorTokensKit` entry in `Package.resolved`, and resolve again.
- Everyone with a clone or a fork has to clone again.
- GitHub keeps pull request refs (`refs/pull/*`) and nobody can rewrite them, and SwiftPM's mirrors download them. The mirror only shrinks once GitHub Support removes them (next section).

**Steps.**

1. Merge or close open pull requests, then delete merged and abandoned branches on GitHub.
2. Start from a fresh mirror (`brew install git-filter-repo` if you don't have it):
   ```bash
   git clone --mirror https://github.com/metasidd/ColorTokensKit-Swift.git
   cd ColorTokensKit-Swift.git
   git filter-repo --invert-paths --path Tests/ColorTokensKitTests/Exports/ --path-glob '*.png'
   ```
3. Check the result before pushing anything:
   ```bash
   git count-objects -vH                    # size-pack should be a few MB
   git for-each-ref refs/heads refs/tags    # branches and tags still there
   git clone . ../check && cd ../check && swift test
   ```
4. `git filter-repo` removes the `origin` remote so you can't push by accident. Add it back and push branches and tags. Don't use `--mirror`, since GitHub rejects pushes to its pull request refs:
   ```bash
   cd ../ColorTokensKit-Swift.git
   git remote add origin https://github.com/metasidd/ColorTokensKit-Swift.git
   git push --force origin 'refs/heads/*' 'refs/tags/*'
   ```
5. Ask GitHub Support (support.github.com) to remove the old pull request refs and cached objects, and to run garbage collection. It's the same request as [removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository), so link that page and say the goal is download size.
6. Re-clone your working copies, and update the pin in apps that use the package, CrosswordChef included.

## Releasing

SwiftPM resolves versions from git tags, so a release is a tag on `main`:

```bash
git checkout main && git pull
git tag 1.2.0
git push origin 1.2.0
```

Use semantic versioning: a new minor version for new API, a new major version for anything that breaks existing code. Never move or reuse a published tag, because apps record the commit behind each tag and refuse to resolve when it changes.
