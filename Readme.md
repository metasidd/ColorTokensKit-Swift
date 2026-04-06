# ColorTokensKit

[![License: MIT](https://cdn.prod.website-files.com/5e0f1144930a8bc8aace526c/65dd9eb5aaca434fac4f1c34_License-MIT-blue.svg)](/LICENSE)

**Perceptually uniform color tokens for Swift and SwiftUI.** Generate accessible, themeable color ramps from any hue using OKLCH and CIELab LCH color spaces. Built for iOS, macOS, tvOS, watchOS, and visionOS.

![Cover Image](/Assets/cover-image.png)

## Why ColorTokensKit?

Swift's built-in colors are limited to RGB and HSL — neither is perceptually uniform. That means two colors with the "same" lightness value can look completely different to the human eye. Design systems built on RGB break when you need consistent brightness across hues, accessible contrast, dark mode, or theming.

ColorTokensKit solves this with perceptually uniform color spaces (OKLCH and CIELab LCH), giving you:

- **Thousands of colors from a single hue** — 20-stop ramps generated automatically
- **Perceptual uniformity** — equal lightness values look equally bright across all hues
- **Built-in accessibility** — WCAG 2.x and APCA contrast ratio utilities
- **Automatic dark mode** — every token resolves to light and dark variants
- **Theming in one line** — pass any `ProColor` and get a complete, accessible palette
- **OKLCH + CIELab LCH** — two perceptually uniform color spaces, plus RGB, XYZ, LAB, OKLab conversions
- **Thread-safe and Sendable** — ready for Swift concurrency
- **Zero dependencies** — pure Swift, Swift Package Manager only

### Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS | 16.0+ |
| macOS | 13.0+ |
| tvOS | 16.0+ |
| watchOS | 9.0+ |
| visionOS | 1.0+ |

> The broader concept of LCH-based design tokens is widely trusted by companies like [Linear](https://linear.app/blog/how-we-redesigned-the-linear-ui), [Slack](https://slack.design/articles/a-new-visual-language-for-slack/), [Stripe](https://stripe.com/blog/accessible-color-systems), [Zapier](https://zapier.com/blog/lch-easier-accessibility-prettier-colors/) and many others.

## The Problem

```swift
Text("The Everything Company")
  .background(Color(hex: "#FA3499")) // Hard-coded hex — not accessible, no dark mode
  .background(Color(red: 0.5, green: 0.5, blue: 1.0)) // Raw RGB — not perceptually uniform
  .background(Color.red.secondary) // Native colors — limited palette, no control
  .background(Color.brandColorBackground) // Manual tokens — hard to maintain, not responsive
  .background(Color.brandColor.backgroundPrimary) // ColorTokensKit — accessible, dark mode, semantic
```

## How It Works

ColorTokensKit generates 20-stop color ramps for any hue using hand-tuned palette data interpolated in perceptually uniform color spaces. Each stop is a precise lightness level from near-white (`_50`) to near-black (`_1000`).

The `ProColor` type wraps these ramps with semantic accessors — `.foregroundPrimary`, `.backgroundSecondary`, `.outlineTertiary` — that automatically resolve to the right stop for light and dark mode.

### Color Spaces

![Color System Comparison](/Assets/color-system-comparison.png)

**OKLCH** (default) — Bjorn Ottosson's perceptually uniform color space. Fixes CIELab's hue linearity issues: blues stay blue when you adjust chroma, instead of shifting toward purple. Used by CSS Color Level 4, Tailwind v4, and modern design tools.

**CIELab LCH** — The classic perceptually uniform space. Still available for all conversions and ramp generation.

### LCH Color Grid

![LCH Color Grid](/Assets/color-grid.png)

### OKLCH Color Grid

![OKLCH Color Grid](/Assets/oklch-color-grid.png)

## Quick Start

### Installation

Add ColorTokensKit via Swift Package Manager:

```
https://github.com/metasidd/ColorTokensKit-Swift.git
```

### Setup

1. `import ColorTokensKit` in your files
2. Copy [ColorTokens.swift](https://github.com/metasidd/ColorTokensKit-Swift/blob/main/Tests/ColorTokensKitTests/Marketing/Setup/ColorTokens.swift) into your project, or define your own semantic tokens
3. Start using `Color.proBlue.backgroundPrimary`, `Color.foregroundPrimary`, etc.

### Define a Brand Color

```swift
import ColorTokensKit

extension Color {
    static var brandColor: ProColor {
        .primary(forHue: 210) // Any hue 0-360, or use a preset like Color.proBlue
    }
}
```

Now use it everywhere — backgrounds, text, outlines — with automatic dark mode:

```swift
VStack {
    Text("The Everything Company")
        .foregroundStyle(Color.brandColor.foregroundPrimary)
}
.padding(8)
.background(Color.brandColor.backgroundPrimary)
.overlay(
    RoundedRectangle(cornerRadius: 16)
        .stroke(Color.brandColor.outlineTertiary, lineWidth: 1)
)
```

## 23 Built-in Pro Colors

Every pro color is a `ProColor` with full ramp access and semantic tokens:

```swift
Color.proGray    Color.proPink    Color.proRed      Color.proTomato
Color.proOrange  Color.proBrown   Color.proGold     Color.proYellow
Color.proLime    Color.proOlive   Color.proGrass    Color.proGreen
Color.proMint    Color.proCyan    Color.proTeal     Color.proBlue
Color.proSky     Color.proCobalt  Color.proIndigo   Color.proIris
Color.proPurple  Color.proViolet  Color.proPlum     Color.proRuby
```

Each has 20 stops (`_50` through `_1000`) and semantic tokens for foreground, background, surface, outline, and their inverted variants.

## Theming

Pass any `ProColor` as a theme and get a complete, accessible color system for that component:

![Simple Card View](/Assets/simple-card-view.png)
![Simple Card Dark Mode View](/Assets/simple-card-dark-mode-view.png)

```swift
struct CardView: View {
    let theme: ProColor

    var body: some View {
        VStack {
            Text("Title")
                .foregroundStyle(theme.foregroundPrimary)
            Text("Subtitle")
                .foregroundStyle(theme.foregroundSecondary)
        }
        .background(theme.backgroundPrimary)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.outlineTertiary, lineWidth: 1)
        )
    }
}

// Usage
CardView(theme: Color.proBlue)
CardView(theme: Color.proGold)
CardView(theme: .primary(forHue: 173)) // Any custom hue
```

![Pill View](/Assets/pill-view.png)

## Semantic Tokens

Every `ProColor` provides these semantic tokens, each resolving to light/dark mode automatically:

| Category | Tokens |
|----------|--------|
| **Foreground** | `foregroundPrimary`, `foregroundSecondary`, `foregroundTertiary` |
| **Inverted Foreground** | `invertedForegroundPrimary`, `invertedForegroundSecondary`, `invertedForegroundTertiary` |
| **Background** | `backgroundPrimary`, `backgroundSecondary`, `backgroundTertiary` |
| **Inverted Background** | `invertedBackgroundPrimary`, `invertedBackgroundSecondary`, `invertedBackgroundTertiary` |
| **Surface** | `surfacePrimary` (50% opacity), `surfaceSecondary` (30%), `surfaceTertiary` (10%) |
| **Inverted Surface** | `invertedSurfacePrimary` (40%), `invertedSurfaceSecondary` (20%) |
| **Outline** | `outlinePrimary`, `outlineSecondary`, `outlineTertiary` |

## Accessibility

### Contrast Ratios

Check color accessibility with WCAG 2.x or APCA contrast:

```swift
let bg = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
let text = RGBColor(r: 0.1, g: 0.1, b: 0.1, alpha: 1)

// WCAG 2.x (range 1-21, higher is better)
let wcag = bg.contrastRatio(to: text) // ~18.4 — passes AAA

// APCA (signed Lc value, positive = dark on light)
let apca = bg.contrastRatio(to: text, method: .apca) // ~106 — passes for all text sizes

// Works on any color type
let ratio = Color.white.contrastRatio(to: Color.black) // 21.0
```

## Color Space Conversions

Convert between RGB, LCH, OKLCH, OKLab, LAB, XYZ, HEX, and HSL:

```swift
// HEX
let color = Color(hex: "#abcdef")

// HSL
let hslColor = Color(h: 50, s: 0.5, l: 0.5)

// OKLCH
let oklch = OKLCHColor(l: 0.7, c: 0.15, h: 210)
let swiftUIColor = oklch.toColor()

// LCH
let lch = LCHColor(l: 70, c: 30, h: 210)
let rgb = lch.toRGB()

// Any Color to any space
let blue = Color.blue
blue.toOKLCH()  // OKLCHColor
blue.toLCH()    // LCHColor
blue.toOKLab()  // OKLabColor
blue.toLAB()    // LABColor
blue.toXYZ()    // XYZColor
blue.toRGB()    // RGBColor
```

## Interpolation

Interpolate between colors in perceptually uniform space for smooth gradients:

```swift
// OKLCH interpolation (recommended)
let a = OKLCHColor(l: 0.4, c: 0.12, h: 60)
let b = OKLCHColor(l: 0.8, c: 0.15, h: 200)
let mid = a.lerp(b, t: 0.5) // Smooth midpoint with shortest hue path

// LCH interpolation
let c = LCHColor(l: 40, c: 30, h: 60)
let d = LCHColor(l: 60, c: 60, h: 90)
let midLCH = c.lerp(d, t: 0.5)
```

## Architecture

```
ProColor (stable public API, backed by OKLCH)
  └── OKLCHColor ←→ OKLabColor ←→ RGBColor ←→ Color
  └── LCHColor  ←→ LABColor   ←→ XYZColor ←→ RGBColor
```

- **ProColor** — the recommended type for design tokens. Wraps OKLCH internally.
- **OKLCHColor / OKLabColor** — OKLCH polar and OKLab cartesian forms (Ottosson's reference).
- **LCHColor / LABColor / XYZColor** — CIELab color spaces.
- **RGBColor** — sRGB, bridges to/from SwiftUI `Color`.
- **ColorRampGenerator** — generates 20-stop ramps from hand-tuned palette data.

## Future Ideas

- [ ] Delta E color difference API (CIE76 / CIEDE2000)
- [ ] Non-linear lightness curves for ramp generation
- [ ] Semantic token layer in main library (primitive -> semantic -> component)
- [ ] `.lighten()`, `.darken()`, `.saturate()`, `.desaturate()` modifiers
- [ ] Smooth gradients using perceptually uniform interpolation
- [ ] Color blindness simulation (Brettel/Vienot)
- [ ] HSL/HSV color space types
- [ ] Display P3 gamut awareness
- [ ] OKLCH-native palette data (currently converts from LCH)

## License

MIT License. See [LICENSE](/LICENSE) for details.
