//
//  OKLabColor+Conversions.swift
//  ColorTokensKit
//
//  Conversion between OKLab and other color spaces.
//  Uses Björn Ottosson's reference matrices (direct linear sRGB path).
//

import Foundation
import SwiftUI

public extension OKLabColor {
    /// Converts to linear sRGB then applies gamma for sRGB output
    func toRGB() -> RGBColor {
        // OKLab → LMS' (inverse M2)
        let lp = l + 0.3963377774 * a + 0.2158037573 * b
        let mp = l - 0.1055613458 * a - 0.0638541728 * b
        let sp = l - 0.0894841775 * a - 1.2914855480 * b

        // Cube to get LMS
        let lc = lp * lp * lp
        let mc = mp * mp * mp
        let sc = sp * sp * sp

        // LMS → linear sRGB (inverse M1)
        let rLin =  4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc
        let gLin = -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc
        let bLin = -0.0041960863 * lc - 0.7034186147 * mc + 1.7076147010 * sc

        // Linear sRGB → sRGB (gamma companding + clamp)
        let r = min(max(OKLabColor.gammaCompand(rLin), 0), 1)
        let g = min(max(OKLabColor.gammaCompand(gLin), 0), 1)
        let b = min(max(OKLabColor.gammaCompand(bLin), 0), 1)

        return RGBColor(r: r, g: g, b: b, alpha: alpha)
    }

    /// Converts to OKLCH (polar form)
    func toOKLCH() -> OKLCHColor {
        let c = sqrt(a * a + b * b)
        let angle = atan2(b, a) * ColorConstants.RAD_TO_DEG
        let h = angle < 0 ? angle + 360 : angle
        return OKLCHColor(l: l, c: c, h: h, alpha: alpha)
    }

    /// Converts to SwiftUI Color
    func toColor() -> Color {
        let rgb = toRGB()
        return Color(red: rgb.r, green: rgb.g, blue: rgb.b)
    }

    /// Converts to CIELab via RGB → XYZ → LAB
    func toLAB() -> LABColor {
        return toRGB().toLAB()
    }

    /// Converts to LCH via CIELab
    func toLCH() -> LCHColor {
        return toRGB().toLCH()
    }

    // MARK: - sRGB Gamma Companding

    /// Apply sRGB gamma curve (linear → sRGB)
    private static func gammaCompand(_ v: CGFloat) -> CGFloat {
        let absV = abs(v)
        let out = absV > 0.0031308 ? 1.055 * pow(absV, 1.0 / 2.4) - 0.055 : absV * 12.92
        return v > 0 ? out : -out
    }
}
