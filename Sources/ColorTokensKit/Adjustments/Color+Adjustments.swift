//
//  Color+Adjustments.swift
//  ColorTokensKit
//
//  Make any Color lighter, darker, softer, stronger, more or less saturated; turn
//  its hue, blend it with another color, or invert it. Each function returns a
//  new Color that stays correct in light and dark mode, so it works on tokens as
//  well as on fixed colors.
//
//  Lightness moves in stops of the ColorTokensKit palette. A palette color comes
//  back as another exact palette color; any other color moves by the same
//  visual step.
//

import SwiftUI

public extension Color {
    // MARK: - Lightness

    /// A lighter version of this color, `stops` steps up the palette.
    ///
    /// ```swift
    /// Color.proBlue._600.toColor().lighten()     // exactly Color.proBlue._550
    /// theme.foregroundTertiary.lighten(by: 2)    // lighter in light and in dark mode
    /// ```
    func lighten(by stops: Int = 1) -> Color {
        adapting { color, _ in ColorAdjustment.shiftingLightness(of: color, byStops: -stops) }
    }

    /// A darker version of this color, `stops` steps down the palette.
    ///
    /// ```swift
    /// Color.proBlue._600.toColor().darken()      // exactly Color.proBlue._650
    /// ```
    func darken(by stops: Int = 1) -> Color {
        adapting { color, _ in ColorAdjustment.shiftingLightness(of: color, byStops: stops) }
    }

    /// A version closer to the background, for less emphasis: lighter in light mode, darker in dark mode.
    ///
    /// ```swift
    /// theme.foregroundPrimary.soften()           // quieter text in both appearances
    /// ```
    func soften(by stops: Int = 1) -> Color {
        adapting { color, appearance in
            ColorAdjustment.shiftingLightness(of: color, byStops: appearance == .light ? -stops : stops)
        }
    }

    /// A version further from the background, for more emphasis: darker in light mode, lighter in dark mode.
    ///
    /// ```swift
    /// theme.foregroundTertiary.strengthen()      // stands out more in both appearances
    /// ```
    func strengthen(by stops: Int = 1) -> Color {
        adapting { color, appearance in
            ColorAdjustment.shiftingLightness(of: color, byStops: appearance == .light ? stops : -stops)
        }
    }

    // MARK: - Saturation

    /// A more vivid version: `amount` 0.2 means 20% more chroma, as far as the screen can show.
    ///
    /// ```swift
    /// Color.proGreen._500.toColor().saturate()
    /// ```
    func saturate(by amount: Double = 0.2) -> Color {
        adapting { color, _ in ColorAdjustment.scalingChroma(of: color, by: 1 + amount) }
    }

    /// A less vivid version: `amount` 0.2 means 20% less chroma; 1 leaves a gray of the same lightness.
    ///
    /// ```swift
    /// badge.desaturate(by: 1)                     // a gray version, e.g. for a finished state
    /// ```
    func desaturate(by amount: Double = 0.2) -> Color {
        adapting { color, _ in ColorAdjustment.scalingChroma(of: color, by: 1 - amount) }
    }

    // MARK: - Hue

    /// The same color with its hue turned round the color wheel, at the same lightness.
    ///
    /// ```swift
    /// Color.proBlue._500.toColor().rotateHue(by: .degrees(30))
    /// ```
    func rotateHue(by angle: Angle) -> Color {
        let degrees = angle.degrees
        return adapting { color, _ in ColorAdjustment.rotatingHue(of: color, byDegrees: degrees) }
    }

    // MARK: - Mixing

    /// This color mixed with another in OKLab, so the mix doesn't go muddy. `fraction` 0 is this color, 1 is `other`.
    ///
    /// Named `blend` because SwiftUI's own `mix(with:by:in:)` needs iOS 18.
    ///
    /// ```swift
    /// Color.proBlue._500.toColor().blend(with: Color.proPink._500.toColor())
    /// ```
    func blend(with other: Color, by fraction: Double = 0.5) -> Color {
        Color.adapting(combining: [self, other]) { colors, _ in
            ColorAdjustment.blending(colors[0], with: colors[1], by: fraction)
        }
    }

    // MARK: - Inversion

    /// The same hue at the mirrored stop (_200 ↔ _850): what this color becomes on an inverted surface.
    ///
    /// Unlike SwiftUI's `colorInvert()`, which flips RGB (blue becomes yellow), the hue stays.
    ///
    /// ```swift
    /// Color.proBlue._200.toColor().invert()      // exactly Color.proBlue._850
    /// ```
    func invert() -> Color {
        adapting { color, _ in ColorAdjustment.invertingLightness(of: color) }
    }
}
