# ColorTokensKit

LCH-based color tokens for Apple platforms (iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+). Swift tools version 5.10. No dependencies.

## Build & Test

```bash
swift build
swift test
swift run -c release --package-path Benchmarks   # cost of making and drawing colors; see CONTRIBUTING.md for iOS
```

Tests generate marketing asset PNGs into `Tests/ColorTokensKitTests/Exports/` (gitignored). README images live in `Assets/` as lossless WebP, a third the size of the PNGs with identical pixels. To update one, convert only the images that changed and commit them deliberately; every committed version stays in the clone forever (see CONTRIBUTING.md):

```bash
cwebp -lossless -z 9 -exact -metadata icc Tests/ColorTokensKitTests/Exports/<name>.png -o Assets/<name>.webp
```

The PNGs are Display P3; `-metadata icc` keeps that profile, and without it browsers read the colors as sRGB.

## Architecture

### Color spaces (`Sources/ColorTokensKit/ColorSpace/`)

Four color space structs, each with `+Conversions`, `+Interpolation`, and `+Manipulation` extensions:

- **LCHColor** — the primary type. Lightness (0-100), Chroma (0-128), Hue (0-360). All hue values are normalized on init.
- **LABColor** — CIELAB, intermediate in conversions.
- **XYZColor** — CIE XYZ, intermediate in conversions.
- **RGBColor** — extended sRGB, bridges to/from SwiftUI `Color`. Display P3 colors have channels below 0 or above 1; nothing clamps them except hex output.

Conversion chain: `LCH <-> LAB <-> XYZ <-> RGB <-> Color`

### Palette data (`Sources/ColorTokensKit/Resources/ColorPalettes.json`)

Hand-tuned LCH color stops for base hues (gray, pink, red, orange, etc.). Each palette is a dictionary of stop index -> `"lch(L% C H)"` string. Decoded by `ColorPaletteData` and cached by `ColorRampLoader`. Only the gray ramp is read now; chromatic ramps come from `UniformRamp`. Don't regenerate or reformat this file.

### Color ramp generation (`Sources/ColorTokensKit/Services/Ramps/`)

`ColorRampGenerator.getColorRamp(forHue:steps:isGrayscale:)` is the core engine. The hue is an OKLCH hue. `UniformRamp.oklchRamp(hue:)` builds 20 stops (lightest to darkest) that share one CIELab L* and one OKLCH chroma per stop with every other hue (the tables live in `UniformRamp`). The chroma is the most that 29 of the 36 named hues can show in Display P3; a hue that can't reach it keeps 98% of its limit. The OKLCH ramps come from it directly and keep the exact hue: a clamped stop sits near the P3 edge, so a hue that drifted 0.01° would move a channel when a color function rebuilds a stop. Gray comes from the JSON.

Results are cached in a static dictionary keyed by normalized hue + step count.

### Ramp stops (`LCHColor+Stops.swift`)

Named accessors `_50` through `_1000` (20 stops) that call `getColor(at:)` -> `ColorRampGenerator`. `_50` is lightest, `_1000` is darkest.

### Design tokens (`Tests/.../ColorTokens.swift`)

Token definitions live in the test target as a usage example. They map ramp stops to semantic roles:

| Token | Light | Dark |
|---|---|---|
| `foregroundPrimary` | `_1000` | `_50` |
| `foregroundSecondary` | `_800` | `_200` |
| `backgroundPrimary` | `_50` | `_1000` |
| `backgroundSecondary` | `_100` | `_800` |
| `outlinePrimary` | `_600` | `_350` |
| `surfacePrimary` | `_200 @ 50%` | `_700 @ 50%` |

Full set includes foreground, inverted foreground, background, inverted background, surface, inverted surface, and outline tokens at primary/secondary/tertiary levels.

### Pro colors (`Color+ProColors.swift`)

Gray plus 36 hues (`Color.proBlue`, `Color.proRed`, etc.), one every 10° of OKLCH hue. The 25 names from 2.0 sit within 5° of the median hue nine color-naming sources give them (see the comment in the file). Each resolves to the "primary" stop of a generated ramp (index `steps/2 - 2`).

### Color functions (`Adjustments/`, `Harmonies/`, `Gradients/`)

Public API on SwiftUI `Color`, so it works on tokens, system colors and hex colors alike:

- **Adjustments** — `lighten`/`darken`/`soften`/`strengthen(by:)` (whole stops), `saturate`/`desaturate(by:)`, `rotateHue(by:)`, `blend(with:by:)`, `invert()`. Math in `ColorAdjustment`.
- **Harmonies** — `complement`, `triad`, `tetrad(offset:)`, `square`, `splitComplement(spread:)`, `analogous(count:spread:)`, `harmony(_:)`, plus `monochromatic`/`tints`/`shades`. `ColorHarmony` is the single definition of the hue offsets; `ProTheme+Harmonies` returns whole families from the same offsets.
- **Gradients** — `proGradient`/`proRadialGradient`/`proAngularGradient` on `[Color]`, `[ProTheme]`, `Color` and `ProTheme` (single colors take a `ProGradient.Recipe`), with `blend:` (`.vivid` default, `.direct`, `.rainbow`) and `easing:` (`.smooth` default, SwiftUI `Animation` names). `GradientStops` adds in-between colors only where SwiftUI's own blending between neighboring stops would miss the blend's path or the easing by more than `tolerance` (0.02 ΔEOK, opacity counted in full) in either appearance: it checks each stretch at its middle and quarters and halves it until it fits, keeps each pair's layout keyed by its ends as drawn, and closes angular rings. Every stop is a color SwiftUI resolves on each draw, so fewer stops draw faster. On UIKit, stops between two fixed colors are fixed too (UIKit hands back the same object when it resolves a fixed color), and the fading recipes fade a token through `adapting` rather than `opacity(_:)`, which a gradient would have to read back through SwiftUI; the `pro…Gradient` functions wrap those stops in SwiftUI's own gradient types.

How they stay correct in light and dark mode: every function returns a Color built by `Color.adapting` (`Platform/SwiftUI/Color+Adaptive.swift`, with `NSColor+OKLCH`/`UIColor+OKLCH`), which resolves the original color (or colors, for `blend` and gradient steps) for the current appearance when it is drawn and applies the math to those resolved values. Each appearance's result is kept in an `AppearanceCache`, keyed by the whole trait collection (UIKit) or appearance name (AppKit), never by color scheme alone, so Increase Contrast and elevated backgrounds get their own. The inputs are an `AdaptiveInputs`, which a gradient segment's stops share, so its ends are resolved once per appearance rather than once per stop. watchOS has no appearance switching, so it computes once.

Shared math in `Services/Ramps/`: `Gamut` (OKLCH/Display P3 fitting, also used by `UniformRamp`), `StopLadder` (the lightness of each stop; chromatic and gray ladders), `PaletteStop` (recognizes a color that sits exactly on a ramp).

### Platform support (`Sources/ColorTokensKit/Platform/`)

- **SwiftUI** — `Color` extensions for color space conversion, hex/HSL init, light/dark mode init, and pro colors; `Color+Adaptive` for colors worked out per appearance, used by the color functions.
- **UIKit** — `UIColor+Dynamic` for light/dark mode (excluded on watchOS); `UIColor+OKLCH` bridges resolved colors for `Color+Adaptive`.
- **AppKit** — `NSColor+Dynamic` for light/dark mode on macOS; `NSColor+OKLCH` bridges resolved colors for `Color+Adaptive`.
- watchOS always uses dark appearance (no dynamic color switching).

## Key Conventions

- Colors are extended sRGB end to end, so the palette's Display P3 colors survive: don't clamp channels to 0…1 except for hex output, and build `NSColor`s in `.extendedSRGB` (`NSColor(srgbRed:)` gets clipped when AppKit converts it).
- Color functions must return an adaptive color (`adapting`), never a color resolved once at call time, or tokens break in dark mode.
- Lightness and hue functions move palette colors to exact palette stops (via `PaletteStop`; `ColorAdjustment.moving` owns the split for lightness); only colors that aren't on a ramp move continuously. `saturate`, `desaturate` and `blend` leave the palette on purpose.
- Naming follows SwiftUI's own copy-returning style (`Color.mix`, `Color.opacity`): plain verbs, no `get`. Names must not collide with `View`/`ShapeStyle` members, because `Color` is both (so `desaturate`, not `saturation`). Gradient functions carry the `pro` prefix.
- US spelling in code and docs ("color", "gray").
- Tests resolve colors with `Tests/ColorTokensKitTests/Support/Color+Resolving.swift` (`color.hex(.light)` / `.hex(.dark)`); each test says in a comment why the behavior matters.
- IMPORTANT: `CGFloat+Ext.swift` and `Double+Ext.swift` must stay in sync — both define `normalizedHue` and `rounded(to:)` with identical signatures. Swift's type inference can resolve arithmetic as either type depending on Xcode version/context.
- Hue values are always normalized to 0-360 via `.normalizedHue` and rounded to 2 decimal places for cache key stability.
- Interpolation uses shortest-path hue wrapping around the 360-degree color wheel.
- `#if canImport(UIKit) && !os(watchOS)` guards are required for UIKit APIs that don't exist on watchOS.
