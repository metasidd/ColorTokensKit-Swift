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

Hand-tuned LCH color stops for base hues (gray, pink, red, orange, etc.). Each palette is a dictionary of stop index -> `"lch(L% C H)"` string. Decoded by `ColorPaletteData` and cached by `ColorRampLoader`. Don't regenerate or reformat this file.

### Color ramp generation (`Sources/ColorTokensKit/Services/Ramps/`)

`ColorRampGenerator.getColorRamp(forHue:steps:isGrayscale:)` is the core engine. For a given target hue:

1. Finds the two bounding palettes from the JSON data
2. Interpolates between them based on hue proximity
3. Returns an array of `LCHColor` stops (default 20 steps, from lightest to darkest)

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

23 predefined colors (`Color.proBlue`, `Color.proRed`, etc.) mapped to specific hue values. Each resolves to the "primary" stop of a generated ramp (index `steps/2 - 2`).

### Platform support (`Sources/ColorTokensKit/Platform/`)

- **SwiftUI** — `Color` extensions for color space conversion, hex/HSL init, light/dark mode init, and pro colors.
- **UIKit** — `UIColor+Dynamic` for light/dark mode (excluded on watchOS).
- **AppKit** — `NSColor+Dynamic` for light/dark mode on macOS.
- watchOS always uses dark appearance (no dynamic color switching).

## Key Conventions

- IMPORTANT: `CGFloat+Ext.swift` and `Double+Ext.swift` must stay in sync — both define `normalizedHue` and `rounded(to:)` with identical signatures. Swift's type inference can resolve arithmetic as either type depending on Xcode version/context.
- Hue values are always normalized to 0-360 via `.normalizedHue` and rounded to 2 decimal places for cache key stability.
- Interpolation uses shortest-path hue wrapping around the 360-degree color wheel.
- `#if canImport(UIKit) && !os(watchOS)` guards are required for UIKit APIs that don't exist on watchOS.
