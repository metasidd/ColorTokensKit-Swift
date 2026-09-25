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
            let luminance = luminanceOf(lightnessStar: lightnessStar)
            let chroma = min(targetChroma, gamutMargin * maxChroma(luminance: luminance, hue: hue))
            let oklabLightness = lightnessFor(luminance: luminance, chroma: chroma, hue: hue)
            return OKLCHColor(l: oklabLightness, c: chroma, h: hue).toRGB().toLCH()
        }
    }

    private static func luminanceOf(lightnessStar: Double) -> Double {
        lightnessStar > 8 ? pow((lightnessStar + 16) / 116, 3) : lightnessStar / 903.3
    }

    private static func linearSRGB(lightness: Double, chroma: Double, hue: Double) -> (Double, Double, Double) {
        let radians = hue * .pi / 180
        let a = cos(radians) * chroma, b = sin(radians) * chroma
        let lp = lightness + 0.3963377774 * a + 0.2158037573 * b
        let mp = lightness - 0.1055613458 * a - 0.0638541728 * b
        let sp = lightness - 0.0894841775 * a - 1.2914855480 * b
        let lc = lp * lp * lp, mc = mp * mp * mp, sc = sp * sp * sp
        return (4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc,
                -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc,
                -0.0041960863 * lc - 0.7034186147 * mc + 1.7076147010 * sc)
    }

    private static func luminanceOf(lightness: Double, chroma: Double, hue: Double) -> Double {
        let (r, g, b) = linearSRGB(lightness: lightness, chroma: chroma, hue: hue)
        return 0.2126390059 * r + 0.7151686788 * g + 0.0721923054 * b
    }

    /// OKLab L that gives this luminance at this chroma and hue.
    private static func lightnessFor(luminance: Double, chroma: Double, hue: Double) -> Double {
        var low = 0.0, high = 1.0
        for _ in 0 ..< 40 {
            let middle = (low + high) / 2
            if luminanceOf(lightness: middle, chroma: chroma, hue: hue) < luminance { low = middle } else { high = middle }
        }
        return (low + high) / 2
    }

    /// Most OKLCH chroma sRGB can show at this luminance and hue.
    private static func maxChroma(luminance: Double, hue: Double) -> Double {
        var low = 0.0, high = 0.5
        for _ in 0 ..< 30 {
            let middle = (low + high) / 2
            let (r, g, b) = linearSRGB(lightness: lightnessFor(luminance: luminance, chroma: middle, hue: hue), chroma: middle, hue: hue)
            if [r, g, b].allSatisfy({ $0 >= -1e-6 && $0 <= 1 + 1e-6 }) { low = middle } else { high = middle }
        }
        return low
    }
}
