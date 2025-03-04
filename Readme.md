# 🌈 ColorTokensKit - Alpha

[![License: MIT](https://cdn.prod.website-files.com/5e0f1144930a8bc8aace526c/65dd9eb5aaca434fac4f1c34_License-MIT-blue.svg)](/LICENSE)

By designers, for developers. 

![Cover Image](/Tests/ColorTokensKitTests/Exports/cover-image.png)

# Features

ColorTokensKit is a powerful design library that extends Swift's native capabilities by offering ergonomic access to the LCH color system, and thousands of accessible colors. 

- 📱 Designed for Apple apps
- ⭐️ Easy to use color token APIs
- 🎨 Pre-defined LCH color palettes
- 🤝 Built-in support for accessible contrast ratios
- 🌘 Built-in dark mode capability
- 🌈 Built-in theming for all apps
- 🎛️ Easy conversions between RGB/HSL/LCH/LAB/XYZ spaces
- 🕊️ No dependencies

> 💚 The broader concept of LCH-based design tokens is widely trusted, and utilized by leading companies like [Linear](https://linear.app/blog/how-we-redesigned-the-linear-ui), [Slack](https://slack.design/articles/a-new-visual-language-for-slack/), [Stripe](https://stripe.com/blog/accessible-color-systems), [Zapier](https://zapier.com/blog/lch-easier-accessibility-prettier-colors/) and many others.

# 🍎 Why Native Apple Colors Aren't Enough

Swift's native color system provides only basic functionality for color representation. Native colors are limited to RGB and HSL, which do not offer perceptual uniformity. This can lead to inconsistent color experiences across different devices and environments. 

Additionally, native colors do not inherently support accessible contrast ratios, dark mode or theming, making it challenging to maintain a cohesive design system. ColorTokensKit addresses these limitations by leveraging the LCH color system, which provides a more intuitive and flexible approach to color management.

```swift
Text("The Everything Company")
  .background(Color(hex: "#FA3499")) // ❌ Please don't do this
  .background(Color(red: 0.5, green: 0.5, blue: 1.0)) // ❌ Messy & unscalable
  .background(Color.red.secondary) // ❌ No control, limited to few colors
  .background(Color.brandColorBackground) // ❌ Needs many variables, hard to maintain, not responsive to dark mode, probably not accessible
  .background(Color.brandColor.backgroundPrimary) // ✅ Semantic naming, accessible, responsive to dark mode, and ergonomic. 
```

# 🤔 But wait, what are design tokens?
Design tokens are the fundamental building blocks of a design system. They represent the smallest, atomic decisions in your UI, such as colors, typography, spacing, and more. In the context of ColorTokensKit, we focus just on colors. 

![Color Grid](/Tests/ColorTokensKitTests/Exports/color-grid.png)

# 🌈 What's LCH though? 
The LCH (**L**ightness, **C**hroma, **H**ue) color system offers significant advantages over RGB and HSL based initializers. LCH is "perceptually uniform", meaning changes in color values correspond more closely to how humans perceive color differences. This makes it easier to create harmonious color palettes, ensure proper contrast for accessibility, and make predictable color adjustments. Unlike RGB or HSL, LCH also supports a wider gamut of colors and provides more intuitive control over color properties, making it an excellent choice for modern iOS app development.

![Color System Comparison](/Tests/ColorTokensKitTests/Exports/color-system-comparison.png)

# ✨ Can you give me a quick example?
Imagine you have a primary color used for your brand. This color is used in various levels of brightness and saturation in various areas (backgrounds, text, hovers, buttons, onpress states etc). 

Instead of hardcoding each of the color values in multiple places, you define a design token named `brandColor`. 

```swift
extension Color {
    var brandColor: LCHColor {
        LCHColor("#FF04DA") // The hex would represent your brand color
    }
}
```

Now, whenever the brand color needs to be used, you just use `brandColor.backgroundPrimary`. If the hue needs to change, you update just one token value, and all instances of `brandColor` in your app automatically update to the new colors.

```swift
VStack {
  Text("The Everything Company")
    .foregroundStyle(Color.brandColor.foregroundPrimary) // ✅ A dark text color that's accessible by default
  }
  .padding(8)
  .background(Color.brandColor.backgroundPrimary) // ✅ A balanced background color that's accessible
  .overlay(
    RoundedRectangle(cornerRadius: 16)
      .stroke(Color.brandColor.outlineTertiary, lineWidth: 1) // ✅ A suitable outline that's not too dark or light
  )
}
```

And VOILA! You also now support dark mode out of the box.

# 📦 Ready to get started?

- **Step 1:** Install with SPM. Use `https://github.com/metasidd/ColorTokensKit-Swift.git` to install the package in your project.
- **Step 2:** Add `import ColorTokensKit` to all files that need these tokens.
- **Step 3:** Copy-paste [this file](https://github.com/metasidd/ColorTokensKit-Swift/blob/main/Tests/ColorTokensKitTests/Marketing/Setup/ColorTokens.swift) into your project, OR define your own tokens.
- **Step 4:** That's all! You're ready to give your app a fresh coat of paint.

# 🎁 More examples for you to learn from

## A Simple Card View

This is a simple card view that uses the basic gray ramp without using any theming shenanigans.

```swift
import ColorTokensKit

struct CardView: View {
    var body: some View {
        VStack {
            Text("Welcome to ColorTokensKit")
                .foregroundStyle(Color.foregroundPrimary) // Uses the most accessible color available for text
            Text("This is a subtitle")
                .foregroundStyle(Color.foregroundSecondary) // Uses a lighter shade of the foreground color
        }
        .background(Color.backgroundPrimary) // Uses the primary background color available
        .shadow(color: Color.outlineSecondary, radius: 5) // Uses the primary outline color available as a shadow
    }
}
```

## Pills ([Example Code](/Tests/ColorTokensKitTests/Marketing/Views/PillView.swift))

The `PillView` demonstrates the benefits of using ColorTokensKit's color tokens. You can use the pre-defined color tokens below (like `Color.backgroundPrimary`, `Color.foregroundTertiary`, `Color.outlinePrimary`), or use the custom tokens you created in Step 2.

![Pill View](/Tests/ColorTokensKitTests/Exports/pill-view.png)

## Themes & Dark mode ([Example Code](/Tests/ColorTokensKitTests/Marketing/Views/ThemedCardView.swift))

Theming is made extremely ergonomic with this approach. You can pass theme values as needed, and all children elements are dynamically assigned colors depending on the LCH color chosen.

![Simple Card View](/Tests/ColorTokensKitTests/Exports/simple-card-view.png)
![Simple Card Dark Mode View](/Tests/ColorTokensKitTests/Exports/simple-card-dark-mode-view.png)

```swift
import ColorTokensKit
import SwiftUI

struct ContentView: View {
  var body: some View {
    CardView() // Themeless
    CardView(theme: Color.proMint) // Mint theme
    CardView(theme: Color.proBlue) // Blue theme
    CardView(theme: Color.proGold) // Gold theme
    CardView(theme: Color.proRuby) // Ruby theme
    CardView(theme: LCHColor("#abcdef")) // Custom theme based on hex values
  }
}

struct CardView: View {
  let title: String
  let subtitle: String
  let theme: LCHColor // This could very well be an `@Environment var`. Whatever floats your boat.

  init(
    title: String, 
    subtitle: String,
    theme: LCHColor = Color.proGray // Default component could be themeless, or have a default hue
    ) {
      self.title = title
      self.subtitle = subtitle
      self.theme = theme
  }

  var body: some View {
    VStack {
      Text(title)
        .foregroundStyle(theme.foregroundPrimary) // Uses the darkest text color available
      Text(subtitle)
        .foregroundStyle(theme.foregroundSecondary) // Since it's a secondary piece of text, it uses a lighter shade available
    }
    .background(
      RoundedRectangle(cornerRadius: 16) // Creates a rounded rectangle container that works in light & dark mode
        .fill(theme.backgroundPrimary) // Uses `backgroundPrimary` as its base, resulting in a white background
        .stroke(theme.outlineTertiary, lineWidth: 1) // Uses the lightest gray outline for a border
    )
  }
}
```

# 🛠️ Utilities

In addition to just using color tokens, we offer some easy conversions, and interpolations colors for niche usecases.

## Interpolating
Transitioning colors using LCH offer much smoother color values.

```swift
let color1 = LCHColor(l: 40, c: 30, h: 60)
let color2 = LCHColor(l: 60, c: 60, h: 90)
let interpolatedColor = color1.lerp(color2, t: 0.5)
print(interpolatedColor) // Output: LCHColor(l: 50, c: 45, h: 75)
```

## Conversions
ColorKit allows you to convert between different color types - RGB, HSL, HEX, LCH, LAB etc. Here are some simple examples:

```swift

// HEX to Color
let color = Color(hex: "#abcdef")

// RGB to LCH Color
let rgbColor = Color(r: 0.5, g: 0.4, b: 0.3, alpha: 1.0)
let lchColor = LCHColor(color: rgbColor)

// HEX to LCH Color
let lchColor = LCHColor(hex: "#abcdef")

// HSL to LCH Color
let hslColor = Color(h: 50, s: 50, l: 50)
let lchColor = LCHColor(color: hslColor)

// LCH to RGB
let lchColor = LCHColor(l: 40, c: 30, h: 60)
let rgbColor: color = lchColor.toRGB()

// LCH to HEX
let lchColor = LCHColor(l: 40, c: 30, h: 60)
let hexColor: String = lchColor.toHex()

// LCH to UIColor
let lchColor = LCHColor(l: 42.33, c: 29.65, h: 59.53, alpha: 1.0)
let uiColor = lchColor.toColor()
print(uiColor) // Output: UIDeviceRGBColorSpace 0.5 0.4 0.3 1

```

# Future Ideas
- [ ] Offer `.lighten()`, `.darken()`, `.saturate()` and `.desaturate()` for LCH Colors
- [ ] Create smooth gradients using LCH colors
- [ ] Add resource links to Read Me
- [ ] Basic Unit Tests
- [ ] UI Snapshot Tests
- [ ] Example Figma
- [ ] Custom Lightness, Chroma or Hue curves
- [ ] Any other feedback?

# License
The source code for the site is licensed under the MIT license, which you can find in the MIT-LICENSE.txt file.
