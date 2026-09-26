//
//  UniformRamp.swift
//  ColorTokensKit
//
//  Every hue shares one lightness and one chroma per stop. Lightness is
//  CIELab L* (so WCAG contrast is the same for every hue at a stop); chroma and hue
//  are OKLCH, and hue is constant along a ramp. A hue that can't reach a stop's
//  chroma in Display P3 gets as close as it can.
//

import Foundation

enum UniformRamp {
    /// CIELab L* for _50 … _1000: the previous palette's per-stop average across the 23 named hues.
    static let lightness: [Double] = [
        96.5, 92.7, 88.8, 84.8, 80.6, 76.3, 72.0, 67.5, 62.8, 58.2,
        53.5, 48.8, 44.0, 39.2, 34.4, 29.5, 24.6, 19.9, 15.0, 10.2,
    ]

    /// OKLCH chroma for _50 … _1000: the most that at least 29 of the 36 named hues (80%) can show in
    /// Display P3, rounded down. More would light up the hues that can follow and leave the rest behind.
    static let chroma: [Double] = [
        0.017, 0.037, 0.058, 0.081, 0.107, 0.134, 0.163, 0.161, 0.160, 0.150,
        0.141, 0.131, 0.121, 0.112, 0.102, 0.092, 0.082, 0.072, 0.062, 0.053,
    ]

    /// Fraction of the Display P3 edge a clamped hue may reach.
    static let gamutMargin = 0.98

    /// The stops keep the ramp's exact hue. A hue that can't reach a stop's chroma sits near the Display P3
    /// edge, so a hue that drifted even 0.01° in a round trip would move a channel when a color function
    /// rebuilds the stop.
    static func oklchRamp(hue: Double) -> [OKLCHColor] {
        zip(lightness, chroma).map { lightnessStar, targetChroma in
            let luminance = Gamut.luminance(lightnessStar: lightnessStar)
            let chroma = min(targetChroma, gamutMargin * Gamut.maxChroma(luminance: luminance, hue: hue))
            let oklabLightness = Gamut.lightness(forLuminance: luminance, chroma: chroma, hue: hue)
            return OKLCHColor(l: oklabLightness, c: chroma, h: hue)
        }
    }

    /// The same ramp in CIELab LCH, for the LCH API.
    static func ramp(hue: Double) -> [LCHColor] {
        oklchRamp(hue: hue).map { $0.toRGB().toLCH() }
    }

    /// Whether `chroma` is what `ramp(hue:)` gives `hue` at a stop, within `tolerance`: the shared chroma,
    /// or the gamut limit of a hue that can't reach it. Two gamut checks bracket that limit, which is far
    /// cheaper than searching for it, and this runs every time a color function draws.
    static func isChroma(_ chroma: Double, atStop index: Int, hue: Double, tolerance: Double) -> Bool {
        if abs(chroma - self.chroma[index]) <= tolerance { return true }
        guard chroma < self.chroma[index] else { return false }
        let luminance = Gamut.luminance(lightnessStar: lightness[index])
        return Gamut.fits(chroma: (chroma - tolerance) / gamutMargin, luminance: luminance, hue: hue)
            && !Gamut.fits(chroma: (chroma + tolerance) / gamutMargin, luminance: luminance, hue: hue)
    }
}
