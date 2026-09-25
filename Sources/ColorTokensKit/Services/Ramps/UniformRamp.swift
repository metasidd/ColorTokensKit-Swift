//
//  UniformRamp.swift
//  ColorTokensKit
//
//  Every hue shares one lightness and one chroma per stop. Lightness is
//  CIELab L* (so WCAG contrast is the same for every hue at a stop); chroma and hue
//  are OKLCH, and hue is constant along a ramp. A hue that can't reach a stop's
//  chroma in sRGB gets as close as it can.
//

import Foundation

enum UniformRamp {
    /// CIELab L* for _50 … _1000: the previous palette's per-stop average across the 23 named hues.
    static let lightness: [Double] = [
        96.5, 92.7, 88.8, 84.8, 80.6, 76.3, 72.0, 67.5, 62.8, 58.2,
        53.5, 48.8, 44.0, 39.2, 34.4, 29.5, 24.6, 19.9, 15.0, 10.2,
    ]

    /// OKLCH chroma for _50 … _1000: the most that at least 20 of the 25 named hues can show in sRGB.
    static let chroma: [Double] = [
        0.014, 0.029, 0.047, 0.065, 0.085, 0.106, 0.126, 0.141, 0.139, 0.131,
        0.123, 0.114, 0.106, 0.097, 0.089, 0.080, 0.072, 0.063, 0.055, 0.046,
    ]

    /// Fraction of the sRGB edge a clamped hue may reach.
    static let gamutMargin = 0.98

    static func ramp(hue: Double) -> [LCHColor] {
        zip(lightness, chroma).map { lightnessStar, targetChroma in
            let luminance = Gamut.luminance(lightnessStar: lightnessStar)
            let chroma = min(targetChroma, gamutMargin * Gamut.maxChroma(luminance: luminance, hue: hue))
            let oklabLightness = Gamut.lightness(forLuminance: luminance, chroma: chroma, hue: hue)
            return OKLCHColor(l: oklabLightness, c: chroma, h: hue).toRGB().toLCH()
        }
    }
}
