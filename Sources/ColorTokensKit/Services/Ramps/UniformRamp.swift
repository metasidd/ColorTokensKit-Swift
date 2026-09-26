//
//  UniformRamp.swift
//  ColorTokensKit
//
//  Every hue shares one lightness per stop, and gets as much chroma as sRGB can show
//  there. Lightness is CIELab L* (so WCAG contrast is the same for every hue at a stop);
//  chroma and hue are OKLCH, and hue is constant along a ramp.
//

import Foundation

enum UniformRamp {
    /// CIELab L* for _50 … _1000: the previous palette's per-stop average across the 23 named hues.
    static let lightness: [Double] = [
        96.5, 92.7, 88.8, 84.8, 80.6, 76.3, 72.0, 67.5, 62.8, 58.2,
        53.5, 48.8, 44.0, 39.2, 34.4, 29.5, 24.6, 19.9, 15.0, 10.2,
    ]

    /// Fraction of the sRGB edge every stop reaches, so 8-bit rounding never pushes a stop outside sRGB.
    static let gamutMargin = 0.98

    /// Each stop is the most vivid color sRGB can show at its lightness and the ramp's hue.
    /// The stops keep the ramp's exact hue: a stop sits on the sRGB edge, so a hue that drifted even
    /// 0.01° in a round trip would move a channel by one 8-bit step when a color function rebuilds it.
    static func oklchRamp(hue: Double) -> [OKLCHColor] {
        lightness.map { lightnessStar in
            let luminance = Gamut.luminance(lightnessStar: lightnessStar)
            let chroma = gamutMargin * Gamut.maxChroma(luminance: luminance, hue: hue)
            let oklabLightness = Gamut.lightness(forLuminance: luminance, chroma: chroma, hue: hue)
            return OKLCHColor(l: oklabLightness, c: chroma, h: hue)
        }
    }

    /// The same ramp in CIELab LCH, for the LCH API.
    static func ramp(hue: Double) -> [LCHColor] {
        oklchRamp(hue: hue).map { $0.toRGB().toLCH() }
    }

    /// Whether `chroma` is what `ramp(hue:)` gives `hue` at a stop, within `tolerance`: the sRGB limit there.
    /// Two gamut checks bracket that limit, which is far cheaper than searching for it, and this runs every
    /// time a color function draws.
    static func isChroma(_ chroma: Double, atStop index: Int, hue: Double, tolerance: Double) -> Bool {
        let luminance = Gamut.luminance(lightnessStar: lightness[index])
        return Gamut.fits(chroma: (chroma - tolerance) / gamutMargin, luminance: luminance, hue: hue)
            && !Gamut.fits(chroma: (chroma + tolerance) / gamutMargin, luminance: luminance, hue: hue)
    }
}
