//
//  Gamut.swift
//  ColorTokensKit
//
//  Display P3 gamut math in OKLCH, shared by ramp generation, color adjustments and
//  gradients. Lightness is usually held as CIELab L*, because L* is a direct
//  function of luminance, which is what WCAG contrast measures.
//
//  The palette targets Display P3, the gamut of every iPhone screen since the iPhone 7.
//  Colors travel through the library as extended sRGB, where a P3 color outside sRGB
//  has channels below 0 or above 1.
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

    /// Linear sRGB for an OKLCH color, not clamped, so values outside 0…1 mean the color is beyond sRGB.
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

    /// Linear Display P3 for a linear sRGB color (CSS Color 4's matrix).
    static func linearDisplayP3(_ r: Double, _ g: Double, _ b: Double) -> (Double, Double, Double) {
        (0.8224619687 * r + 0.1775380313 * g,
         0.0331941989 * r + 0.9668058011 * g,
         0.0170826307 * r + 0.0723974407 * g + 0.9105199286 * b)
    }

    /// Linear sRGB for a linear Display P3 color, the inverse of `linearDisplayP3`.
    static func linearSRGB(displayP3 r: Double, _ g: Double, _ b: Double) -> (Double, Double, Double) {
        (1.2249401763 * r - 0.2249401763 * g,
         -0.0420569547 * r + 1.0420569547 * g,
         -0.0196375546 * r - 0.0786360456 * g + 1.0982736001 * b)
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

    /// Whether Display P3 can show this OKLCH color.
    static func contains(lightness: Double, chroma: Double, hue: Double) -> Bool {
        let (r, g, b) = linearSRGB(lightness: lightness, chroma: chroma, hue: hue)
        let (pr, pg, pb) = linearDisplayP3(r, g, b)
        return [pr, pg, pb].allSatisfy { $0 >= -1e-6 && $0 <= 1 + 1e-6 }
    }

    /// Whether Display P3 can show this chroma at this luminance and hue. No chroma always fits.
    static func fits(chroma: Double, luminance: Double, hue: Double) -> Bool {
        chroma <= 0 || contains(lightness: lightness(forLuminance: luminance, chroma: chroma, hue: hue), chroma: chroma, hue: hue)
    }

    /// Most OKLCH chroma Display P3 can show at this luminance and hue.
    static func maxChroma(luminance: Double, hue: Double) -> Double {
        var low = 0.0, high = 0.5
        for _ in 0 ..< 30 {
            let middle = (low + high) / 2
            if fits(chroma: middle, luminance: luminance, hue: hue) {
                low = middle
            } else {
                high = middle
            }
        }
        return low
    }

    /// The color at this CIELab L* and hue with this chroma, reduced only as far as Display P3 needs.
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

    /// This color brought inside Display P3 the way CSS Color 4 maps gradients and mixes: reduce chroma at the
    /// same OKLab lightness and hue, but stop as soon as simply clipping would be within a just-noticeable
    /// difference. Colors at the edge of the gamut stay vivid, and a gradient's path has no sudden kinks.
    static func fitted(_ color: OKLCHColor) -> OKLCHColor {
        let lightness = Double(color.l), hue = Double(color.h)
        if lightness >= 1 { return OKLCHColor(l: 1, c: 0, h: hue, alpha: color.alpha) }
        if lightness <= 0 { return OKLCHColor(l: 0, c: 0, h: hue, alpha: color.alpha) }
        if contains(lightness: lightness, chroma: Double(color.c), hue: hue) { return color }

        let justNoticeable = 0.02, epsilon = 0.0001
        var current = color
        var clipped = self.clipped(current)
        if differenceOK(clipped, current) < justNoticeable { return clipped }
        var low = 0.0, high = Double(color.c), lowIsInGamut = true
        while high - low > epsilon {
            let chroma = (low + high) / 2
            current = OKLCHColor(l: lightness, c: chroma, h: hue, alpha: color.alpha)
            if lowIsInGamut, contains(lightness: lightness, chroma: chroma, hue: hue) {
                low = chroma
                continue
            }
            clipped = self.clipped(current)
            let difference = differenceOK(clipped, current)
            if difference < justNoticeable {
                if justNoticeable - difference < epsilon { return clipped }
                lowIsInGamut = false
                low = chroma
            } else {
                high = chroma
            }
        }
        return clipped
    }

    /// This color with each Display P3 channel clamped to 0…1: CSS Color 4's clip, fast but it can shift hue.
    static func clipped(_ color: OKLCHColor) -> OKLCHColor {
        let (r, g, b) = linearSRGB(lightness: Double(color.l), chroma: Double(color.c), hue: Double(color.h))
        let (pr, pg, pb) = linearDisplayP3(r, g, b)
        let clamp = { (value: Double) in min(max(value, 0), 1) }
        let (sr, sg, sb) = linearSRGB(displayP3: clamp(pr), clamp(pg), clamp(pb))
        return RGBColor(r: linearToSRGB(CGFloat(sr)), g: linearToSRGB(CGFloat(sg)), b: linearToSRGB(CGFloat(sb)), alpha: color.alpha).toOKLCH()
    }

    /// Distance between two colors in OKLab (ΔEOK); about 0.02 is just noticeable.
    static func differenceOK(_ a: OKLCHColor, _ b: OKLCHColor) -> Double {
        let x = a.toOKLab(), y = b.toOKLab()
        return Double(sqrt(pow(x.l - y.l, 2) + pow(x.a - y.a, 2) + pow(x.b - y.b, 2)))
    }
}

extension OKLCHColor {
    /// CIELab L* of this color, which decides its WCAG contrast.
    var lightnessStar: Double {
        Gamut.lightnessStar(luminance: Gamut.luminance(lightness: Double(l), chroma: Double(c), hue: Double(h)))
    }

    /// Chroma this low has no visible hue; such colors use the gray ramp. This is the one gray test:
    /// `ProTheme` uses it too, so a family and its colors agree on what is gray.
    var isAchromatic: Bool {
        c <= 0.005
    }
}
