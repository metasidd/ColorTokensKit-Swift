# ColorTokensKit

[![License: MIT](https://cdn.prod.website-files.com/5e0f1144930a8bc8aace526c/65dd9eb5aaca434fac4f1c34_License-MIT-blue.svg)](/MIT-LICENSE.txt)

**The most complete color system for SwiftUI.** By designers, for everyone, and readable by the AI agent that writes your code.

📘 **Full documentation: [colortokenskit.com](https://colortokenskit.com)**

![Cover Image](/Assets/cover-image.webp)

- **740 colors.** 37 themes (36 hues, one every 10° around the color wheel, plus gray) with 20 stops each, in Display P3.
- **20 semantic tokens per theme** for text, backgrounds, surfaces and outlines. Each one has a light stop and a dark stop, so dark mode works with no extra code.
- **Contrast you can count on.** Every hue has the same lightness at each stop, so every text token passes WCAG AA on its page background in both modes, and `outlinePrimary` reaches 3:1 on every background.
- **A theme from your brand color** in one line: `ProTheme(hex: "#00B386")`.
- **Color functions, harmonies and smooth gradients** that stay correct in light and dark mode.
- **Docs made for agents too.** Every page on [colortokenskit.com](https://colortokenskit.com) has a markdown version, and [llms.txt](https://colortokenskit.com/llms.txt) lists them all.
- **Pure Swift.** No dependencies, `Sendable`, and it runs on iOS 16, macOS 13, tvOS 16, watchOS 9 and visionOS 1 or later.

## A quick taste

```swift
struct TripCard: View {
    let theme: ProTheme   // Color.proBlue, or your brand: ProTheme(hex: "#00B386")

    var body: some View {
        VStack(alignment: .leading) {
            Text("Lisbon")
                .foregroundStyle(theme.foregroundPrimary)            // dark mode included
            Text("3 nights from October 12")
                .foregroundStyle(theme.foregroundSecondary.soften()) // one stop quieter, in both modes
        }
        .padding()
        .background(theme.backgroundSecondary.proGradient())         // a gentle gradient from one color
    }
}
```

Everything hands back a plain SwiftUI `Color` or gradient, so it drops into code you already have. [Using your first tokens](https://colortokenskit.com/getting-started/first-tokens/) walks through a real screen.

## Install

In Xcode, choose **File > Add Package Dependencies**, paste this URL, and keep the rule at **Up to Next Major Version**:

```text
https://github.com/metasidd/ColorTokensKit-Swift.git
```

In a Swift package:

```swift
.package(url: "https://github.com/metasidd/ColorTokensKit-Swift.git", from: "3.0.0"),
```

Then add `.product(name: "ColorTokensKit", package: "ColorTokensKit-Swift")` to your target.

## Set up

1. `import ColorTokensKit` in your files.
2. Copy [ColorTokens.swift](Tests/ColorTokensKitTests/Marketing/Setup/ColorTokens.swift) into your project. It defines the semantic tokens, and you can edit them for your app.
3. Use them: `Color.proBlue.backgroundPrimary`, `Color.foregroundPrimary` and the rest.

[Installing ColorTokensKit](https://colortokenskit.com/getting-started/installing/) covers each step, and [replacing your app colors](https://colortokenskit.com/getting-started/replacing-colors/) moves an existing app over one screen at a time.

## Your brand color

```swift
import ColorTokensKit

extension Color {
    static let brandColor = ProTheme(hex: "#00B386") // Your brand's hex, or a preset like Color.proBlue
}
```

The theme takes your hex's hue at the palette's lightness for every stop, so it has the same contrast as the built-in themes, and `brandColor.toColor()` is your exact hex. You can also start from any hue with `.primary(forHue: 210)`, or from exact OKLCH numbers. [ProTheme](https://colortokenskit.com/api/protheme/) has every way to make one. `ProTheme` was called `ProColor` before 3.0; the old name still works, and Xcode offers to rename it.

## 37 ready-made themes

Gray and 36 hues, one every 10° around the OKLCH wheel, so neighbors are equally far apart:

```swift
Color.proGray        Color.proPink        Color.proRuby        Color.proRed
Color.proTomato      Color.proCoral       Color.proOrange      Color.proBrown
Color.proAmber       Color.proGold        Color.proMustard     Color.proYellow
Color.proOlive       Color.proChartreuse  Color.proLime        Color.proGrass
Color.proGreen       Color.proJade        Color.proEmerald     Color.proMint
Color.proTeal        Color.proTurquoise   Color.proCyan        Color.proCerulean
Color.proSky         Color.proAzure       Color.proBlue        Color.proCobalt
Color.proIndigo      Color.proIris        Color.proViolet      Color.proGrape
Color.proPurple      Color.proOrchid      Color.proPlum        Color.proMagenta
Color.proRose
```

Each one is a `ProTheme` with 20 stops (`_50` to `_1000`) and every semantic token. [Ready-made themes](https://colortokenskit.com/api/named-themes/) shows them all, and [what the library offers](https://colortokenskit.com/basics/color-library/) shows every stop.

## Theming

Pass any `ProTheme` to a view, and the whole component gets a coherent, accessible set of colors:

![Simple Card View](/Assets/simple-card-view.webp)
![Simple Card Dark Mode View](/Assets/simple-card-dark-mode-view.webp)

```swift
struct CardView: View {
    let theme: ProTheme

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

// Swap the theme, and everything updates
CardView(theme: Color.proBlue)
CardView(theme: Color.proGold)
CardView(theme: .primary(forHue: 173)) // any hue
```

![Pill View](/Assets/pill-view.webp)

[Setting up themes](https://colortokenskit.com/advanced/themes/) covers theming a view, a screen or a whole app, and [components and examples](https://colortokenskit.com/getting-started/components/) has 30 ready-made components to copy.

## Semantic tokens

Every `ProTheme` has these tokens, and each resolves to its light or dark stop on its own:

| Kind | Tokens |
|------|--------|
| **Foreground** | `foregroundPrimary`, `foregroundSecondary`, `foregroundTertiary` |
| **Inverted foreground** | `invertedForegroundPrimary`, `invertedForegroundSecondary`, `invertedForegroundTertiary` |
| **Background** | `backgroundPrimary`, `backgroundSecondary`, `backgroundTertiary` |
| **Inverted background** | `invertedBackgroundPrimary`, `invertedBackgroundSecondary`, `invertedBackgroundTertiary` |
| **Surface** | `surfacePrimary` (50% opacity), `surfaceSecondary` (30%), `surfaceTertiary` (10%) |
| **Inverted surface** | `invertedSurfacePrimary` (40%), `invertedSurfaceSecondary` (20%) |
| **Outline** | `outlinePrimary` (edges of controls: 3:1 on every background), `outlineSecondary` and `outlineTertiary` (decorative dividers and hairlines) |

[Understanding semantic tokens](https://colortokenskit.com/getting-started/semantic-tokens/) explains each kind with an annotated example, and [managing dark mode](https://colortokenskit.com/getting-started/dark-mode/) shows how they switch.

## How it works

ColorTokensKit builds a 20-stop ramp for any OKLCH hue, from near-white (`_50`) to near-black (`_1000`). Every hue shares the same lightness and the same chroma at each stop. Lightness is CIELab L\*, so a stop has the same WCAG contrast whatever the hue. Chroma is the most that 29 of the 36 named hues can show in Display P3, the gamut of every iPhone since the iPhone 7, so the palette is as vivid as it can be while the hues stay even. On an sRGB-only screen, such as many external monitors, the system clips these colors, so they look a little less vivid there.

![Color System Comparison](/Assets/color-system-comparison.webp)

**OKLCH** is Björn Ottosson's perceptually uniform color space, the one CSS Color 4 and Tailwind v4 use. Blues stay blue as they get lighter, instead of drifting toward purple the way they do in CIELab LCH.

Here is the palette itself, with one row per hue. Each column is a stop, and every hue has the same lightness (L) at each stop:

![The palette](/Assets/color-grid.webp)

[How the colors were made](https://colortokenskit.com/basics/how-the-colors-were-built/) tells the story with interactive charts, and [under the hood](https://colortokenskit.com/under-the-hood/why-oklch/) has the math.

## Smooth gradients

![Smooth Gradients](/Assets/smooth-gradients.webp)

Generate a gradient from one color, or pass the colors you want. Colors travel around the color wheel in OKLCH, so blue to yellow stays vivid instead of passing through gray, and a gradient between tokens is right in both light and dark mode:

```swift
card.proGradient()                                               // a touch lighter at the top
glow.proGradient(.fade)                                          // fades out, keeping its color
[Color.blue, .yellow].proGradient(from: .leading, to: .trailing) // stays vivid all the way across
```

[Gradient theory](https://colortokenskit.com/advanced/gradient-theory/) explains the blends, [`.proGradient()`](https://colortokenskit.com/api/pro-gradient/) covers easing and every option, and [ProGradient recipes](https://colortokenskit.com/api/gradient-recipes/) makes gradients from a single color.

## Accessibility

Contrast is built in: every stop has the same lightness in every hue, so swapping a theme never breaks contrast. You can also check contrast in code with WCAG 2.x or APCA:

```swift
let background = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
let text = RGBColor(r: 0.1, g: 0.1, b: 0.1, alpha: 1)

background.contrastRatio(to: text)                  // about 17.5 (WCAG 2, range 1 to 21)
background.contrastRatio(to: text, method: .apca)   // about 104 (APCA Lc, positive for dark on light)
Color.white.contrastRatio(to: Color.black)          // 21.0
```

[How accessible is it?](https://colortokenskit.com/basics/how-accessible/) lists what's guaranteed, [`.contrastRatio(to:method:)`](https://colortokenskit.com/api/contrast-ratio/) covers checking pairs in tests, and [high contrast modes](https://colortokenskit.com/advanced/high-contrast/) handles Increase Contrast.

## More in the docs

- **Color functions:** `lighten`, `darken`, `soften`, `strengthen`, `saturate`, `desaturate`, `rotateHue`, `blend` and `invert` on any `Color`, correct in both modes. Start with [`.lighten(by:)`](https://colortokenskit.com/api/lighten/) or [building for interaction states](https://colortokenskit.com/getting-started/interaction-states/).
- **Harmonies:** `complement`, `triad`, `analogous()`, `tints()` and more, at the same lightness as the original. See [color theory](https://colortokenskit.com/advanced/color-theory/) and [`.triad`](https://colortokenskit.com/api/triad/).
- **Charts:** series colors that keep their contrast. See [using tokens in charts](https://colortokenskit.com/advanced/charts/).
- **Conversions and interpolation:** RGB, OKLCH, OKLab, CIELab, LCH, XYZ and hex. See [`.toOKLCH()`](https://colortokenskit.com/api/to-oklch/), [`Color(hex:)`](https://colortokenskit.com/api/color-hex/) and [`.lerp(_:t:)`](https://colortokenskit.com/api/lerp/).
- **UIKit, AppKit, watchOS and visionOS:** see [platforms](https://colortokenskit.com/platforms/uikit/).
- **Architecture:** how the ramps are built and fitted into Display P3, in [under the hood](https://colortokenskit.com/under-the-hood/how-ramps-are-built/). [CLAUDE.md](CLAUDE.md) maps the code.
- **Something not working?** See [troubleshooting](https://colortokenskit.com/reference/troubleshooting/) and the [changelog](https://colortokenskit.com/reference/changelog/).

Got an idea or found a bug? [Open an issue](https://github.com/metasidd/ColorTokensKit-Swift/issues).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for building and testing, updating the README images, keeping the repository small, and releasing.

## License

MIT License. See [LICENSE](/MIT-LICENSE.txt) for details.
