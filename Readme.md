# 🌈 ColorTokensKit 🌈
By designers, for developers. 

ColorTokensKit is a powerful design library that extends Swift's native capabilities by offering ergonomic access to the LCH color system, and 1000's of pre-defined colors built using the LCH color system. 

- [What are design tokens?](#what-are-design-tokens)
- [How does LCH work?](#how-does-lch-work)
- [What does the code look like in practice?](#what-does-the-code-look-like-in-practice)
- [Setting them up](#setting-them-up)
  - [Step 1: Define a color ramp for your brand](#step-1-define-a-color-ramp-for-your-brand)
  - [Step 2: Pick your custom design tokens](#step-2-pick-your-custom-design-tokens)
  - [Step 3: Using them for UI](#step-3-using-them-for-ui)
- [Going beyond the basics](#going-beyond-the-basics)
  - [Defining your own tokens](#defining-your-own-tokens)
  - [Working with themes](#working-with-themes)
  - [Making exceptions for dark mode](#making-exceptions-for-dark-mode)
  - [Interpolating Colors](#interpolating-colors)
- [Sample Application](#sample-application)
- [Future ideas](#future-ideas)
- [License](#license)

<!-- Table of contents look good. Rest needs work. -->

## What are design tokens?
Design tokens are the fundamental building blocks of a design system. They represent the smallest, atomic decisions in your UI, such as colors, typography, spacing, and more. In the context of ColorTokensKit, we focus on color tokens. These tokens allow designers and developers to maintain consistency across an application, making it easier to update and maintain the visual language of your iOS app.

#### Let's take an example
Imagine you have a primary color used for your brand. This color is used in various levels of brightness and saturation in various areas (backgrounds, text, hovers, buttons, onpress states etc).  Instead of hardcoding each of the color values in multiple places, you define a design token named `brandColor`. Now, whenever the brand color needs to be used, you just use `brandColor.backgroundPrimary`. If it needs to change, you update just one token value, and all instances of `brandColor` in your app automatically update. Design tokens ensure consistency and make it easier to maintain and update your design system.

```swift
Text("Hello to ColorTokensKit")
  .background(Color(red: 0.5, green: 0.5, blue: 1.0)) // Messy: Defining colors inline
  .background(Color.brandColorBackground) // Defining variables per application: Often hardcoded. Changing various values associated with brandColor is hard and impractical.
  .background(Color.brandColor.backgroundPrimary) // New way: Semantic naming that enables reusabusability, predictability and enables accessible colors. 
```

 Behind the scenes, brandColor uses an LCH color system to get a specific color. It gets the "hue" value from `brandColor` and calculates an accessibile background according to a few defined primitives.


## What is the LCH color system? 
The LCH (**L**ightness, **C**hroma, **H**ue) color system offers significant advantages over RGB and HSL based initializers. LCH is "perceptually uniform", meaning changes in color values correspond more closely to how humans perceive color differences. This makes it easier to create harmonious color palettes, ensure proper contrast for accessibility, and make predictable color adjustments. Unlike RGB or HSL, LCH also supports a wider gamut of colors and provides more intuitive control over color properties, making it an excellent choice for modern iOS app development.

#### RGB vs LCH color ramps
[Insert image]

#### Let's take an example

```swift
Text("Hello to ColorTokensKit")
    .background(Color("#8080FF")) // HEX: Handpicked colors that aren't easy to scale to various usecases. Lots of room for error
    .background(Color(red: 0.5, green: 0.5, blue: 1.0)) // RGB: Inconsistent brightness across colors
    .background(Color(h: 0.24, s: 0.32, l: 0.44)) // HSL: Inconsistent color intensity. Some colors like yellow are brighter than others, making it hard to read
    .background(Color(l: 0.32, c: 0.44, h: 0.9)) // LCH: Perceptually uniform; consistent brightness and saturation across hues
```


## Basic Example
Let's create a simple container with a name and a subtitle. An extension on `Color` offers ready to use design tokens with a `Color.gray` color ramp

You can use the pre-defined color tokens below (like `Color.backgroundPrimary`, `Color.foregroundTertiary`, `Color.outlinePrimary`), or create custom ones to your needs. The library integrates seamlessly with SwiftUI and UIKit, allowing you to use color tokens in your views and UI components with minimal effort. 

```swift
import ColorTokensKit


VStack {
  Text("Title")
    .foregroundStyle(Color.foregroundPrimary) // Uses the darkest text color available
  Text("Subtitle")
    .foregroundStyle(Color.foregroundSecondary) // Since it's a secondary piece of text, it uses a lighter shade available
}
.background(
  RoundedRectangle(cornerRadius: 16) // Creates a rounded rectangle container that works in light & dark mode
    .fill(Color.backgroundPrimary) // Uses `backgroundPrimary` as its base, resulting in a white background
    .stroke(Color.outlineTertiary, lineWidth: 1) // Uses the lightest gray outline for a border
)
```

## Setting it up

### Step 1: Define default tokens for all hues
Copy this into a new extension file called `LCHColor+Ext`. 

```swift
import ColorTokensKit

public extension LCHColor {
    // Foreground colors
    var foregroundPrimary: Color { Color(light: _100, dark: _0_pastel) }
    var foregroundSecondary: Color { Color(light: _80, dark: _20_pastel) }
    var foregroundTertiary: Color { Color(light: _65, dark: _35_pastel) }
    
    // Inverted foreground colors
    var invertedForegroundPrimary: Color { Color(light: _0, dark: _100_pastel) }
    var invertedForegroundSecondary: Color { Color(light: _10, dark: _90_pastel) }
    var invertedForegroundTertiary: Color { Color(light: _20, dark: _80_pastel) }
    
    // Background colors
    var backgroundPrimary: Color { Color(light: _0, dark: _100_pastel) }
    var backgroundSecondary: Color { Color(light: _5, dark: _90_pastel) }
    var backgroundTertiary: Color { Color(light: _20, dark: _80_pastel) }
    
    // Surface colors
    var surfacePrimary: Color { Color(light: _40, dark: _60).opacity(0.5) }
    var surfaceSecondary: Color { Color(light: _40, dark: _60).opacity(0.3) }
    var surfaceTertiary: Color { Color(light: _40, dark: _60).opacity(0.2) }

    // Inverted surface colors
    var invertedSurfacePrimary: Color { Color(light: _40, dark: _60).opacity(0.4)  }
    var invertedSurfaceSecondary: Color { Color(light: _40, dark: _60).opacity(0.2) }
    
    // Inverted background colors
    var invertedBackgroundPrimary: Color { Color(light: _90, dark: _10) }
    var invertedBackgroundSecondary: Color { Color(light: _75, dark: _25) }
    var invertedBackgroundTertiary: Color { Color(light: _60, dark: _40) }
    
    // Outline colors
    var outlinePrimary: Color { Color(light: _50, dark: _30_pastel) }
    var outlineSecondary: Color { Color(light: _30, dark: _50_pastel) }
    var outlineTertiary: Color { Color(light: _10, dark: _70_pastel) }

}
```

Now, create your Default Gray Ramps as an extension to Color. Copy this into a new file called `Color+Ext.swift`.

```swift
import ColorTokensKit

extension Color {
    // Foreground colors
    public static var foregroundPrimary: Color {
        .gray.foregroundPrimary
    }
    public static var foregroundSecondary: Color {
        .gray.foregroundSecondary
    }
    public static var foregroundTertiary: Color {
        .gray.foregroundTertiary
    }
    
    // Inverted colors
    public static var invertedForegroundPrimary: Color {
        .gray.invertedForegroundPrimary
    }
    public static var invertedForegroundSecondary: Color {
        .gray.invertedForegroundSecondary
    }
    public static var invertedForegroundTertiary: Color {
        .gray.invertedForegroundTertiary
    }
    
    // Background colors
    public static var backgroundPrimary: Color {
        Color(light: .white, dark: .black) // Pure black and white
    }
    public static var backgroundSecondary: Color {
        .gray.backgroundSecondary
    }
    public static var backgroundTertiary: Color {
        .gray.backgroundTertiary
    }
    
    // Inverted background colors
    public static var invertedBackgroundPrimary: Color {
        Color(light: .black, dark: .white) // Pure black and white
    }
    public static var invertedBackgroundSecondary: Color {
        .gray.invertedBackgroundSecondary
    }
    public static var invertedBackgroundTertiary: Color {
        .gray.invertedBackgroundTertiary
    }
    

    // Inverted surface colors
    public static var surfacePrimary: Color {
        .gray.surfacePrimary
    }
    public static var surfaceSecondary: Color {
        .gray.surfaceSecondary
    }
    public static var surfaceTertiary: Color {
        .gray.surfaceTertiary
    }
    
    // Inverted surface colors
    public static var invertedSurfacePrimary: Color {
        .gray.invertedSurfacePrimary
    }
    public static var invertedSurfaceSecondary: Color {
        .gray.invertedForegroundSecondary
    }
    
    // Outline colors
    public static var outlinePrimary: Color {
        .gray.outlinePrimary
    }
    public static var outlineSecondary: Color {
        .gray.outlineSecondary
    }
    public static var outlineTertiary: Color {
        .gray.outlineTertiary
    }
}
```

### Step 2: Pick your custom design tokens
Now that we have our design token system, and the basic gray ramp set up, you can create additional tokens for your brand colors, or any primary/secondary colors you have. 

```swift
import ColorTokensKit

public extension Color {
extension Color {
   // Your main brand color can be defined by HEX, RGB, HSL or any other system
    public static var brandColor: LCHColor {
        LCHColor(hex: "#F12E53")
    }

    // Setup any additional secondary colors you need
    public static var positive: LCHColor {
        Color.proGreen
    }
    
    // For example, this one is created for destructive, negative moments like errors etc.
    public static var negative: LCHColor {
        Color.proRed
    }
}
```


### Step 3: Using them for UI
We're all set up. You're ready to start using them in code. You can just use the extension on `Color` for themeless, gray components. Or, you can pass themes to your components for a more powerful setup. 

```swift
import ColorTokensKit

struct ContainerComponentView: View {
  let title: String
  let subtitle: String
  let theme: LCHColor

  init(
    title: String, 
    subtitle: String,
    theme: LCHColor = Color.proGray // Default component would be themeless
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


## Usage Examples

### Converting Colors
ColorKit allows you to convert between different color spaces with ease. Here are some examples:

#### Convert RGB to LCH
```swift
import ColorKit

let rgbColor = RGBColor(r: 0.5, g: 0.4, b: 0.3, alpha: 1.0)
let lchColor = rgbColor.toLCH()
print(lchColor) // Output: LCHColor(l: 42.33, c: 29.65, h: 59.53, alpha: 1.0)
```

#### Convert LCH to UIColor
```swift
let lchColor = LCHColor(l: 42.33, c: 29.65, h: 59.53, alpha: 1.0)
let uiColor = lchColor.toColor()
print(uiColor) // Output: UIDeviceRGBColorSpace 0.5 0.4 0.3 1
```

### Interpolating Color
ColorKit also supports color interpolation, which can be useful for animations or generating color gradients.

#### Interpolate Between Two LCH Colors
```swift
let color1 = LCHColor(l: 42.33, c: 29.65, h: 59.53, alpha: 1.0)
let color2 = LCHColor(l: 52.33, c: 39.65, h: 69.53, alpha: 1.0)
let interpolatedColor = color1.lerp(color2, t: 0.5)
print(interpolatedColor) // Output: LCHColor(l: 47.33, c: 34.65, h: 64.53, alpha: 1.0)
```


### Setting Up Design Tokens
Design tokens are a great way to manage and apply consistent colors throughout your app. Here's how you can set up design tokens using ColorKit.
