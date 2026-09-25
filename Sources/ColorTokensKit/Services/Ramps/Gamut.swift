//
//  Gamut.swift
//  ColorTokensKit
//
//  sRGB gamut maths in OKLCH, shared by ramp generation, color adjustments and
//  gradients. Lightness is usually held as CIELab L*, because L* is a direct
//  function of luminance, which is what WCAG contrast measures.
//

import Foundation

enum Gamut {
    // MARK: - Lightness and luminance

    /// Relative luminance (CIE Y, 0…1) for a CIELab L* (0…100).
    static func luminance(lightnessStar: Double) -> Double {
        lightnessStar > 8 ? pow((lightnessStar + 16) / 116, 3) : lightnessStar / 903.3
    }

    /// CIELab L* (0…100) for a relative luminance (0…1).
    static func lightnessStar(luminance: Double) -> Double {
        luminance > 216.0 / 24389.0 ? 116 * cbrt(luminance) - 16 : luminance * 903.3
    }

    /// Linear sRGB for an OKLCH color, not clamped, so values outside 0…1 mean out of gamut.
    static func linearSRGB(lightness: Double, chroma: Double, hue: Double) -> (Double, Double, Double) {
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

    /// Relative luminance of an OKLCH color.
    static func luminance(lightness: Double, chroma: Double, hue: Double) -> Double {
        let (r, g, b) = linearSRGB(lightness: lightness, chroma: chroma, hue: hue)
        return 0.2126390059 * r + 0.7151686788 * g + 0.0721923054 * b
    }

    /// OKLab L that gives this luminance at this chroma and hue.
    static func lightness(forLuminance luminance: Double, chroma: Double, hue: Double) -> Double {
        var low = 0.0, high = 1.0
        for _ in 0 ..< 40 {
            let middle = (low + high) / 2
            if self.luminance(lightness: middle, chroma: chroma, hue: hue) < luminance { low = middle } else { high = middle }
        }
        return (low + high) / 2
    }

    // MARK: - Gamut

    /// Whether sRGB can show this OKLCH color.
    static func contains(lightness: Double, chroma: Double, hue: Double) -> Bool {
        let (r, g, b) = linearSRGB(lightness: lightness, chroma: chroma, hue: hue)
        return [r, g, b].allSatisfy { $0 >= -1e-6 && $0 <= 1 + 1e-6 }
    }

    /// Most OKLCH chroma sRGB can show at this luminance and hue.
    static func maxChroma(luminance: Double, hue: Double) -> Double {
        var low = 0.0, high = 0.5
        for _ in 0 ..< 30 {
            let middle = (low + high) / 2
            if contains(lightness: lightness(forLuminance: luminance, chroma: middle, hue: hue), chroma: middle, hue: hue) {
                low = middle
            } else {
                high = middle
            }
        }
        return low
    }

    /// The color at this CIELab L* and hue with this chroma, reduced only as far as sRGB needs.
    /// Holding L* keeps the color's contrast; only its vividness gives way.
    static func fitted(lightnessStar: Double, chroma: Double, hue: Double, alpha: Double) -> OKLCHColor {
        let luminance = luminance(lightnessStar: min(max(lightnessStar, 0), 100))
        var chroma = max(chroma, 0)
        var lightness = lightness(forLuminance: luminance, chroma: chroma, hue: hue)
        if !contains(lightness: lightness, chroma: chroma, hue: hue) {
            chroma = maxChroma(luminance: luminance, hue: hue)
            lightness = self.lightness(forLuminance: luminance, chroma: chroma, hue: hue)
        }
        return OKLCHColor(l: lightness, c: chroma, h: hue, alpha: alpha)
    }

    /// This color with its chroma reduced, at the same OKLab lightness and hue, until sRGB can show it.
    static func fitted(_ color: OKLCHColor) -> OKLCHColor {
        let lightness = min(max(Double(color.l), 0), 1)
        let hue = Double(color.h)
        guard !contains(lightness: lightness, chroma: Double(color.c), hue: hue) else { return color }
        var low = 0.0, high = Double(color.c)
        for _ in 0 ..< 30 {
            let middle = (low + high) / 2
            if contains(lightness: lightness, chroma: middle, hue: hue) { low = middle } else { high = middle }
        }
        return OKLCHColor(l: lightness, c: low, h: hue, alpha: color.alpha)
    }
}

extension OKLCHColor {
    /// CIELab L* of this color, which decides its WCAG contrast.
    var lightnessStar: Double {
        Gamut.lightnessStar(luminance: Gamut.luminance(lightness: Double(l), chroma: Double(c), hue: Double(h)))
    }

    /// Chroma this low has no visible hue; such colors use the gray ramp.
    var isAchromatic: Bool {
        c <= 0.005
    }
}
