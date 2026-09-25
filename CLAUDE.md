# ColorTokensKit

LCH-based color tokens for Apple platforms (iOS 16+, macOS 13+, tvOS 16+, watchOS 9+, visionOS 1+). Swift tools version 5.10. No dependencies.

## Build & Test

```bash
swift build
swift test
```

Tests generate marketing asset PNGs into `Tests/ColorTokensKitTests/Exports/`. These change across machines/OS versions — don't commit them unless intentional.

## Architecture

### Color spaces (`Sources/ColorTokensKit/ColorSpace/`)

Four color space structs, each with `+Conversions`, `+Interpolation`, and `+Manipulation` extensions:

- **LCHColor** — the primary type. Lightness (0-100), Chroma (0-128), Hue (0-360). All hue values are normalized on init.
- **LABColor** — CIELAB, intermediate in conversions.
- **XYZColor** — CIE XYZ, intermediate in conversions.
- **RGBColor** — sRGB, bridges to/from SwiftUI `Color`.

Conversion chain: `LCH <-> LAB <-> XYZ <-> RGB <-> Color`

### Palette data (`Sources/ColorTokensKit/Resources/ColorPalettes.json`)

Hand-tuned LCH color stops for base hues (gray, pink, red, orange, etc.). Each palette is a dictionary of stop index -> `"lch(L% C H)"` string. Decoded by `ColorPaletteData` and cached by `ColorRampLoader`. Only the gray ramp is read now; chromatic ramps come from `UniformRamp`. Don't regenerate or reformat this file.

### Color ramp generation (`Sources/ColorTokensKit/Services/Ramps/`)

`ColorRampGenerator.getColorRamp(forHue:steps:isGrayscale:)` is the core engine. The hue is an OKLCH hue. `UniformRamp.ramp(hue:)` builds 20 stops (lightest to darkest) that share one CIELab L* and one OKLCH chroma per stop with every other hue — the two tables live in `UniformRamp`. A hue that can't reach a stop's chroma in sRGB gets as close as it can. Gray comes from the JSON.

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
| `outlinePrimary` | `_300` | `_700` |
| `surfacePrimary` | `_200 @ 50%` | `_700 @ 50%` |

Full set includes foreground, inverted foreground, background, inverted background, surface, inverted surface, and outline tokens at primary/secondary/tertiary levels.

### Pro colors (`Color+ProColors.swift`)

Gray plus 25 hues (`Color.proBlue`, `Color.proRed`, etc.) at OKLCH hues, each at the median hue nine color-naming sources give its name (see the comment in the file). Each resolves to the "primary" stop of a generated ramp (index `steps/2 - 2`).

### Color functions (`Adjustments/`, `Harmonies/`, `Gradients/`)

Public API on SwiftUI `Color`, so it works on tokens, system colors and hex colors alike:

- **Adjustments** — `lighten`/`darken`/`soften`/`strengthen(by:)` (whole stops), `saturate`/`desaturate(by:)`, `rotateHue(by:)`, `blend(with:by:)`, `invert()`. Math in `ColorAdjustment`.
- **Harmonies** — `complement`, `triad`, `tetrad(offset:)`, `square`, `splitComplement(spread:)`, `analogous(count:spread:)`, `harmony(_:)`, plus `monochromatic`/`tints`/`shades`. `ColorHarmony` is the single definition of the hue offsets; `ProColor+Harmonies` returns whole families from the same offsets.
- **Gradients** — `proGradient`/`proRadialGradient`/`proAngularGradient` on `[Color]`, `[ProColor]`, `Color` and `ProColor` (single colors take a `ProGradient.Recipe`), with `blend:` (`.vivid` default, `.direct`, `.rainbow`) and `easing:` (`.smooth` default, SwiftUI `Animation` names). `GradientStops` adds in-between colors along the blend's path (step count scales with the length of that path, opacity included), places them by the easing over the whole gradient, and closes angular rings; the `pro…Gradient` functions wrap those stops in SwiftUI's own gradient types.

How they stay correct in light and dark mode: every function returns a Color built by `Color.adapting` (`Platform/SwiftUI/Color+Adaptive.swift`, with `NSColor+OKLCH`/`UIColor+OKLCH`), which resolves the original color (or colors, for `blend` and gradient steps) for the current appearance each time it is drawn and applies the math to those resolved values. watchOS has no appearance switching, so it computes once.

Shared math in `Services/Ramps/`: `Gamut` (OKLCH/sRGB fitting, also used by `UniformRamp`), `StopLadder` (the lightness of each stop; chromatic and gray ladders), `PaletteStop` (recognizes a color that sits exactly on a ramp).

### Platform support (`Sources/ColorTokensKit/Platform/`)

- **SwiftUI** — `Color` extensions for color space conversion, hex/HSL init, light/dark mode init, and pro colors; `Color+Adaptive` for colors worked out per appearance, used by the color functions.
- **UIKit** — `UIColor+Dynamic` for light/dark mode (excluded on watchOS); `UIColor+OKLCH` bridges resolved colors for `Color+Adaptive`.
- **AppKit** — `NSColor+Dynamic` for light/dark mode on macOS; `NSColor+OKLCH` bridges resolved colors for `Color+Adaptive`.
- watchOS always uses dark appearance (no dynamic color switching).

## Key Conventions

- Color functions must return an adaptive color (`adapting`), never a color resolved once at call time, or tokens break in dark mode.
- Lightness and hue functions move palette colors to exact palette stops (via `PaletteStop`; `ColorAdjustment.moving` owns the split for lightness); only colors that aren't on a ramp move continuously. `saturate`, `desaturate` and `blend` leave the palette on purpose.
- Naming follows SwiftUI's own copy-returning style (`Color.mix`, `Color.opacity`): plain verbs, no `get`. Names must not collide with `View`/`ShapeStyle` members, because `Color` is both (so `desaturate`, not `saturation`). Gradient functions carry the `pro` prefix.
- US spelling in code and docs ("color", "gray").
- Tests resolve colors with `Tests/ColorTokensKitTests/Support/Color+Resolving.swift` (`color.hex(.light)` / `.hex(.dark)`); each test says in a comment why the behavior matters.
- IMPORTANT: `CGFloat+Ext.swift` and `Double+Ext.swift` must stay in sync — both define `normalizedHue` and `rounded(to:)` with identical signatures. Swift's type inference can resolve arithmetic as either type depending on Xcode version/context.
- Hue values are always normalized to 0-360 via `.normalizedHue` and rounded to 2 decimal places for cache key stability.
- Interpolation uses shortest-path hue wrapping around the 360-degree color wheel.
- `#if canImport(UIKit) && !os(watchOS)` guards are required for UIKit APIs that don't exist on watchOS.
