# ColorTokensKit

[![License: MIT](https://cdn.prod.website-files.com/5e0f1144930a8bc8aace526c/65dd9eb5aaca434fac4f1c34_License-MIT-blue.svg)](/LICENSE)

By designers, for developers.

**Perceptually uniform color tokens for Swift and SwiftUI.** Generate accessible, themeable color ramps from any hue using OKLCH and CIELab LCH. Works on iOS, macOS, tvOS, watchOS, and visionOS.

![Cover Image](/Assets/cover-image.webp)

## A quick taste

```swift
// One hue gives you a whole accessible palette, dark mode included
// (foregroundPrimary and friends come from ColorTokens.swift, see Setup)
Text("Hello").foregroundStyle(Color.proBlue.foregroundPrimary)

// Adjust any color, and it stays right in dark mode
Text("Subtitle").foregroundStyle(theme.foregroundSecondary.soften())

// Colors that go together, from one color
let chartColors = brand.foregroundPrimary.triad

// Gradients that stay vivid, from one color or many
.background(brand.proGradient(.tonal))
Circle().stroke(brand.triad.proAngularGradient(), lineWidth: 8)
```

Everything hands back a plain SwiftUI `Color` or gradient, so it drops into code you already have.

## Why does this exist?

Swift's native color system gives you RGB and HSL. That's fine for picking a single color, but the moment you need a *system* of colors — consistent brightness across hues, accessible contrast, dark mode, theming — it falls apart. Two colors with the same "lightness" in RGB can look wildly different to the human eye.

ColorTokensKit fixes this by building on perceptually uniform color spaces (OKLCH and CIELab LCH). You pick a hue, and we generate an entire palette that just *works*.

- **Thousands of colors from a single hue** — 20-stop ramps generated automatically
- **Perceptual uniformity** — equal lightness values actually look equally bright
- **Built-in accessibility** — WCAG 2.x and APCA contrast ratio utilities
- **Automatic dark mode** — every token resolves to light and dark variants
- **Theming in one line** — pass any `ProColor` and get a complete, accessible palette
- **Color functions** — `lighten()`, `soften()`, `saturate()`, `rotateHue(by:)`, `blend(with:)` and `invert()` on any `Color`, correct in light and dark mode
- **Harmonies** — `complement`, `triad`, `analogous()` and more, balanced by construction
- **Smooth gradients** — `proGradient()` interpolates in OKLCH, the same as CSS, from colors you pick or from a single color
- **OKLCH + CIELab LCH** — two perceptually uniform color spaces, plus RGB, XYZ, LAB, OKLab conversions
- **Thread-safe and Sendable** — ready for Swift concurrency
- **Zero dependencies** — pure Swift, SPM only

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

We've all been here:

```swift
Text("The Everything Company")
  .background(Color(hex: "#FA3499"))                    // Please don't do this
  .background(Color(red: 0.5, green: 0.5, blue: 1.0))  // Messy & unscalable
  .background(Color.red.secondary)                      // No control, limited to a few colors
  .background(Color.brandColorBackground)               // Needs many variables, hard to maintain
  .background(Color.brandColor.backgroundPrimary)       // Semantic, accessible, dark mode, ergonomic
```

Then the design asks for a quieter subtitle, an accent that goes with it, and a gradient:

```swift
.foregroundStyle(Color("SubtitleMuted"))                           // another asset: two more hex values
.foregroundStyle(Color("AccentPairing"))                           // picked by eye, contrast unknown
.background(LinearGradient(colors: [Color("CardTop"), Color("CardBottom")],
                           startPoint: .top, endPoint: .bottom))   // two more assets, and it can go gray

.foregroundStyle(theme.foregroundSecondary.soften())               // derived, adapts to dark mode
.foregroundStyle(theme.foregroundSecondary.complement)             // same lightness, same contrast
.background(theme.backgroundSecondary.proGradient())               // generated from one color, smooth
```

## But wait, what are design tokens?

Design tokens are the smallest, atomic decisions in your UI — the building blocks everything else is made of. Think of them as your single source of truth for colors, so you never have to argue about hex values in a PR again.

```
                         Your Brand Hue (e.g. Blue)
                                  |
                                  v
                    +--------------------------+
                    |   Color Ramp Generator   |
                    |  20 stops, light → dark  |
                    +--------------------------+
                                  |
                  +---------------+---------------+
                  |               |               |
                  v               v               v
             _50 (light)    _500 (mid)     _1000 (dark)
                  |               |               |
                  v               v               v
          +-------------+ +-------------+ +-------------+
          | background  | | foreground  | | outline     |
          | Primary     | | Secondary   | | Tertiary    |
          | (light/dark)| | (light/dark)| | (light/dark)|
          +-------------+ +-------------+ +-------------+
```

In ColorTokensKit, each token maps a semantic role (like "primary background" or "secondary text") to the right shade for both light and dark mode. Change one hue, and your entire app updates.

## How It Works

ColorTokensKit generates a 20-stop ramp for any OKLCH hue, from near-white (`_50`) to near-black (`_1000`). Every hue shares the same lightness and chroma at each stop. Lightness is CIELab L\*, so a given stop has the same contrast (WCAG) whatever the hue; chroma is the most that nearly every hue can show in sRGB, and a hue that can't reach it gets as close as it can.

The `ProColor` type wraps these ramps with semantic accessors — `.foregroundPrimary`, `.backgroundSecondary`, `.outlineTertiary` — that automatically resolve to the right stop for light and dark mode.

### What's OKLCH?

![Color System Comparison](/Assets/color-system-comparison.webp)

**OKLCH** is Bjorn Ottosson's perceptually uniform color space, and it's what we use under the hood. It fixes CIELab's hue linearity issues — blues stay blue when you adjust chroma, instead of drifting toward purple. It's also what CSS Color Level 4, Tailwind v4, and most modern design tools have adopted.

**CIELab LCH** is the classic perceptually uniform space. Still fully available for conversions and ramp generation if you prefer it.

### LCH Color Grid

![LCH Color Grid](/Assets/color-grid.webp)

### OKLCH Color Grid

![OKLCH Color Grid](/Assets/oklch-color-grid.webp)

## Quick Start

### Installation

Add ColorTokensKit via Swift Package Manager:

```
https://github.com/metasidd/ColorTokensKit-Swift.git
```

### Setup (3 steps, seriously)

1. `import ColorTokensKit` in your files
2. Copy [ColorTokens.swift](Tests/ColorTokensKitTests/Marketing/Setup/ColorTokens.swift) into your project, or define your own semantic tokens (it uses `ProColor` under the hood — backed by OKLCH)
3. Start using `Color.proBlue.backgroundPrimary`, `Color.foregroundPrimary`, etc.

That's it. You're ready to give your app a fresh coat of paint.

### Define a Brand Color

```swift
import ColorTokensKit

extension Color {
    static var brandColor: ProColor {
        .primary(forHue: 210) // Any OKLCH hue 0-360, or use a preset like Color.proBlue
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

And voila — dark mode works out of the box. No extra code.

## 26 Built-in Pro Colors

We ship gray and 25 hues so you can get started without choosing anything. Each hue sits where its name points: the median of nine color-naming sources (Radix, Tailwind, Material, Open Color, Ant Design, IBM Carbon, Apple's system colors, CSS named colors and the XKCD color survey), kept at least 10° from its neighbors.

```swift
Color.proGray     Color.proPink     Color.proRuby     Color.proRed
Color.proTomato   Color.proOrange   Color.proBrown    Color.proGold
Color.proYellow   Color.proOlive    Color.proLime     Color.proGrass
Color.proGreen    Color.proJade     Color.proMint     Color.proTeal
Color.proCyan     Color.proSky      Color.proBlue     Color.proCobalt
Color.proIndigo   Color.proIris     Color.proViolet   Color.proPurple
Color.proPlum     Color.proMagenta
```

Each one is a `ProColor` with 20 stops (`_50` through `_1000`) and the full set of semantic tokens for foreground, background, surface, outline, and their inverted variants.

## Theming

This is where it gets fun. Pass any `ProColor` as a theme, and your entire component gets a coherent, accessible color system — for free:

![Simple Card View](/Assets/simple-card-view.webp)
![Simple Card Dark Mode View](/Assets/simple-card-dark-mode-view.webp)

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

// Usage — swap the theme, everything updates
CardView(theme: Color.proBlue)
CardView(theme: Color.proGold)
CardView(theme: .primary(forHue: 173)) // Any custom hue
```

![Pill View](/Assets/pill-view.webp)

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

## Color Functions

**Before:** every variation is another color to pick, twice over for light and dark mode.

```swift
extension Color {
    static let subtitle = Color("Subtitle")              // Assets.xcassets: a light hex and a dark hex
    static let subtitleMuted = Color("SubtitleMuted")    // two more
    static let subtitleStrong = Color("SubtitleStrong")  // and two more
}
```

**After:** derive them. Each one follows the original into dark mode.

```swift
let subtitle = theme.foregroundSecondary
subtitle.soften()       // quieter
subtitle.strengthen()   // stronger
```

Every function works on any SwiftUI `Color` (a token, a system color, a hex color) and returns a new `Color` that stays correct in light and dark mode.

```swift
theme.foregroundTertiary.lighten()                // one stop lighter, in light and dark mode
theme.foregroundTertiary.soften()                 // closer to the background: quieter in both modes
theme.foregroundTertiary.strengthen()             // further from the background: louder in both modes
badge.saturate()                                  // 20% more vivid
badge.desaturate(by: 1)                           // gray, at the same lightness (so the same contrast)
accent.rotateHue(by: .degrees(30))
accent.blend(with: Color.proPink._500.toColor())  // mixed in OKLab, so it doesn't go muddy
Color.proBlue._200.toColor().invert()             // _850: same hue, mirrored stop
```

| Function | What it does |
|----------|--------------|
| `lighten(by:)`, `darken(by:)` | Moves up or down the palette by whole stops (default 1) |
| `soften(by:)`, `strengthen(by:)` | Moves toward or away from the background: lighter or darker depending on the appearance |
| `saturate(by:)`, `desaturate(by:)` | More or less vivid (default 20%); `desaturate(by: 1)` is gray |
| `rotateHue(by:)` | Turns the hue around the color wheel, keeping lightness |
| `blend(with:by:)` | Mixes with another color in OKLab (SwiftUI's `mix` needs iOS 18) |
| `invert()` | The same hue at the mirrored stop, `_200` ↔ `_850` (SwiftUI's `colorInvert()` flips RGB instead) |

Lightness and hue changes keep palette colors on the palette: `Color.proBlue._600.toColor().lighten()` is exactly `_550`, so contrast stays predictable. Any other color moves by the same visual step. `saturate`, `desaturate` and `blend` make colors off the palette, on purpose.

## Color Harmonies

**Before:** colors that "go together" are picked by eye, and nobody checks their contrast.

```swift
let series = [Color(hex: "#4C6EF5"), Color(hex: "#F76707"), Color(hex: "#12B886")]
```

**After:** ask for them. They share the original's lightness, so they share its contrast too.

```swift
let series = brand.foregroundPrimary.triad
```

Related colors come back ready to use, in the same role as the original: the triad of a background is three backgrounds. Every member keeps the original's lightness, so a harmony is balanced by construction. Parameters have defaults, so you only pass them to change something.

```swift
let accent = theme.foregroundPrimary      // any Color: a token, a stop, a hex color

accent.complement                         // the opposite hue
accent.triad                              // accent and the two hues a third of the wheel away
accent.square                             // four hues a quarter of the wheel apart
accent.tetrad()                           // two complementary pairs, 60° apart
accent.splitComplement()                  // accent and the hues either side of its complement
accent.analogous()                        // 3 colors, 30° apart, accent in the middle
accent.monochromatic()                    // 5 colors of the same hue, light to dark
accent.tints()                            // 3 lighter, one stop apart
accent.shades()                           // 3 darker, one stop apart

accent.analogous(count: 5, spread: .degrees(15))
accent.harmony(.splitComplement(spread: .degrees(20)))   // chosen at runtime
```

The same harmonies work on a whole `ProColor` family and return families, so you can take any token of the related hue. Both routes give the same color:

```swift
Color.proBlue.complement.backgroundSecondary   // the family route
Color.proBlue.backgroundSecondary.complement   // the color route: the same color
```

## Smooth Gradients

![Smooth Gradients](/Assets/smooth-gradients.webp)

**Before:** every gradient is two or three more colors to pick, plus a start point and an end point, and distant colors meet in a pale middle, or pass through gray with `.device`.

```swift
LinearGradient(colors: [Color("CardTop"), Color("CardBottom")], startPoint: .top, endPoint: .bottom)
LinearGradient(colors: [glow, glow.opacity(0)], startPoint: .top, endPoint: .bottom)
LinearGradient(colors: [.blue, .yellow], startPoint: .leading, endPoint: .trailing)
```

**After:** generate it from one color, or pass the colors you want. Top to bottom is the default.

```swift
card.proGradient()                                               // a touch lighter at the top
glow.proGradient(.fade)                                          // fades out, keeping its color
[Color.blue, .yellow].proGradient(from: .leading, to: .trailing) // stays vivid all the way across
```

What you get:

- **Vivid, or direct.** By default (`.vivid`) colors travel around the color wheel in OKLCH, the space CSS uses for `linear-gradient(in oklch, …)`, so they stay saturated: blue to yellow passes teal and green. `blend: .direct` draws a straight line with no hues in between, which is SwiftUI's own look (its default `.perceptual` gradient measures as exactly this on iOS). `blend: .rainbow` goes the long way around. SwiftUI's `.device` blends in RGB, through gray.
- **Gentle by default.** Easing uses SwiftUI's `Animation` names. The default, `.smooth`, starts and finishes gently, so a gradient has no hard edge where it meets the colors around it. `.linear`, `.easeIn`, `.easeOut`, `.easeInOut` and `.timingCurve(…)` are there when you want them.
- **The same everywhere.** ColorTokensKit works out the in-between colors itself, so a gradient looks the same on every OS version. With `easing: .linear` it matches CSS's `linear-gradient(in oklch, …)` on the web.
- **Drop-in.** You get SwiftUI's own `LinearGradient`, `EllipticalGradient` and `AngularGradient` back, so they go anywhere a gradient goes: `.background`, `.fill`, `.stroke`, `.foregroundStyle` for text and SF Symbols. iOS 16 and up.
- **From one color.** Recipes turn a single color into a gradient (see the table below), and you can write your own.
- **Dark mode for free.** A gradient between tokens is right in both appearances.
- **Clean fades and rings.** A fade to `.clear` keeps its color all the way out, and angular gradients return to their first color, so there's no seam.

![Gradient Recipes](/Assets/gradient-recipes.webp)

| Recipe | What it makes | Good for |
|--------|---------------|----------|
| `.subtle` (default) | A touch lighter at the start | Buttons and icons, like SwiftUI's `Color.gradient` |
| `.fade` | The color fading to transparent | Glows, scrims, soft edges |
| `.tonal` | Two stops lighter to two stops darker | Depth on cards and headers |
| `.analogous` | A drift through the neighboring hues | Banners and illustrations |
| `.wash` | A soft, translucent tint | Card backdrops |
| `.sheen` | A band of color, clear at both ends | A shine across a button (use white) |
| `.edgeHighlight` | Strongest in the middle, faint at the ends | Borders and rims |

From colors you choose, any array of `Color` or `ProColor`, harmonies included:

```swift
.background([theme.surfaceTertiary, theme.surfaceSecondary].proGradient())   // top → bottom
.background(brand.analogous().proGradient(from: .leading, to: .trailing))
.background([glow, .clear].proRadialGradient())                               // fills its view
Circle().stroke(brand.triad.proAngularGradient(), lineWidth: 8)              // no seam
[blue, yellow].proGradient(blend: .direct)                                    // a straight line, no green
[red, orange].proGradient(blend: .rainbow)                                    // the long way around
[glow, .clear].proGradient(easing: .easeOut)                                  // fades quickly, then lingers
```

| Blend | Blue → yellow goes | Use it for |
|-------|--------------------|------------|
| `.vivid` (default) | Through teal and green, staying saturated | Brand gradients and harmonies |
| `.direct` | Straight through a paler middle | When no other hues should appear |
| `.rainbow` | The long way: through purple, red and orange | Rainbow sweeps |

Easing sets where along the gradient the colors change. The default, `.smooth`, lingers a little at both ends:

![Gradient Easing](/Assets/gradient-easing.webp)

From a single color, with a recipe:

```swift
accent.proGradient()               // .subtle: a touch lighter at the top
tinge.proGradient(.fade)           // to transparent, keeping its color
brand.proGradient(.tonal)          // two stops lighter to two stops darker
brand.proGradient(.analogous)      // a neighboring hue, through brand, to the other
card.proGradient(.wash)            // a soft, translucent tint
Color.white.proGradient(.sheen, from: .topLeading, to: .bottomTrailing)
rim.proGradient(.edgeHighlight, from: .leading, to: .trailing)

// Or your own
extension ProGradient.Recipe {
    static var deepen: Self { Self { [$0, $0.darken(by: 4)] } }
}
brand.proGradient(.deepen)
```

Gradients between tokens stay correct in light and dark mode, and a fade to `.clear` keeps its color instead of drifting toward black.

## Accessibility

### Contrast Ratios

Making sure your colors are accessible shouldn't require a separate tool. Check WCAG 2.x or APCA contrast right in your code:

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

Need to drop down to raw color values? Convert freely between RGB, LCH, OKLCH, OKLab, LAB, XYZ, HEX, and HSL:

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

Smooth color transitions that don't go muddy in the middle? That's what perceptually uniform interpolation gives you:

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

For the curious, here's how the types connect:

```
ProColor (a color family: ramps, stops, tokens, harmonies; backed by OKLCH)
  |-- OKLCHColor <-> OKLabColor <-> RGBColor <-> Color
  |-- LCHColor   <-> LABColor   <-> XYZColor <-> RGBColor

Color (any SwiftUI color)
  |-- Adjustments, Harmonies, Gradients: worked out per appearance when drawn
```

- **ProColor** — the recommended type for design tokens. Wraps OKLCH internally, so we can evolve the internals without breaking your code.
- **OKLCHColor / OKLabColor** — OKLCH polar and OKLab cartesian forms (Ottosson's reference).
- **LCHColor / LABColor / XYZColor** — CIELab color spaces.
- **RGBColor** — sRGB, bridges to/from SwiftUI `Color`.
- **ColorRampGenerator** — builds and caches 20-stop ramps: `UniformRamp` for hues (one lightness and one chroma per stop, shared by every hue), the palette data for gray.
- **Adjustments, Harmonies, Gradients** — the color functions. Each returns a `Color` that is worked out when drawn, for the current appearance (`Color+Adaptive`).
- **Gamut, StopLadder, PaletteStop** — shared math: fitting colors into sRGB, the lightness of each stop, and recognizing palette colors so they move stop by stop.

## Future Ideas

Got a feature request? [Open an issue](https://github.com/metasidd/ColorTokensKit-Swift/issues) — we'd love to hear from you.

- [ ] Delta E color difference API (CIE76 / CIEDE2000)
- [ ] Non-linear lightness curves for ramp generation
- [ ] Semantic token layer in main library (primitive -> semantic -> component)
- [ ] Color blindness simulation (Brettel/Vienot)
- [ ] HSL/HSV color space types
- [ ] Display P3 gamut awareness
- [ ] OKLCH-native palette data (currently converts from LCH)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for building and testing, updating the README images, keeping the repository small, and releasing.

## License

MIT License. See [LICENSE](/LICENSE) for details.
