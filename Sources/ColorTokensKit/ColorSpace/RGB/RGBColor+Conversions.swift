//
//  RGBColor+Conversions.swift
//  ColorTokensKit
//

import Foundation
import SwiftUI

public extension RGBColor {
    /// Converts to XYZ color space
    func toXYZ() -> XYZColor {
        let R = sRGBCompand(r)
        let G = sRGBCompand(g)
        let B = sRGBCompand(b)
        let x: CGFloat = (R * 0.4124564) + (G * 0.3575761) + (B * 0.1804375)
        let y: CGFloat = (R * 0.2126729) + (G * 0.7151522) + (B * 0.0721750)
        let z: CGFloat = (R * 0.0193339) + (G * 0.1191920) + (B * 0.9503041)
        return XYZColor(x: x, y: y, z: z, alpha: alpha)
    }

    /// Converts to LAB via XYZ
    func toLAB() -> LABColor {
        return toXYZ().toLAB()
    }

    /// Converts to LCH via XYZ
    func toLCH() -> LCHColor {
        return toXYZ().toLCH()
    }

    /// Converts to OKLab (direct path, no XYZ intermediate)
    func toOKLab() -> OKLabColor {
        // sRGB → linear sRGB
        let rLin = sRGBCompand(r)
        let gLin = sRGBCompand(g)
        let bLin = sRGBCompand(b)

        // Linear sRGB → LMS (M1 matrix from Ottosson's reference)
        let l = 0.4122214708 * rLin + 0.5363325363 * gLin + 0.0514459929 * bLin
        let m = 0.2119034982 * rLin + 0.6806995451 * gLin + 0.1073969566 * bLin
        let s = 0.0883024619 * rLin + 0.2817188376 * gLin + 0.6299787005 * bLin

        // LMS → LMS' (cube root)
        let lp = cbrt(l)
        let mp = cbrt(m)
        let sp = cbrt(s)

        // LMS' → OKLab (M2 matrix)
        let L = 0.2104542553 * lp + 0.7936177850 * mp - 0.0040720468 * sp
        let a = 1.9779984951 * lp - 2.4285922050 * mp + 0.4505937099 * sp
        let b = 0.0259040371 * lp + 0.7827717662 * mp - 0.8086757660 * sp

        return OKLabColor(l: L, a: a, b: b, alpha: alpha)
    }

    /// Converts to OKLCH via OKLab
    func toOKLCH() -> OKLCHColor {
        return toOKLab().toOKLCH()
    }

    #if canImport(UIKit)
        /// Converts to UIColor
        func color() -> UIColor {
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }
    #endif
}
