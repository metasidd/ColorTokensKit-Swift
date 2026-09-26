//
//  XYZColor+Conversions.swift
//  ColorTokensKit
//

import Foundation
import SwiftUI

public extension XYZColor {
    /// Converts to extended sRGB: a color beyond sRGB, such as a Display P3 palette color, keeps
    /// channels below 0 or above 1 instead of being clipped.
    func toRGB() -> RGBColor {
        let r = (x * 3.2404542) + (y * -1.5371385) + (z * -0.4985314)
        let g = (x * -0.9692660) + (y * 1.8760108) + (z * 0.0415560)
        let b = (x * 0.0556434) + (y * -0.2040259) + (z * 1.0572252)
        return RGBColor(r: sRGBCompand(r), g: sRGBCompand(g), b: sRGBCompand(b), alpha: alpha)
    }

    /// Converts to LAB color space
    func toLAB() -> LABColor {
        let fx = labCompand(x / ColorConstants.LAB_X)
        let fy = labCompand(y / ColorConstants.LAB_Y)
        let fz = labCompand(z / ColorConstants.LAB_Z)
        return LABColor(
            l: 116 * fy - 16,
            a: 500 * (fx - fy),
            b: 200 * (fy - fz),
            alpha: alpha
        )
    }

    /// Converts to LCH via LAB
    func toLCH() -> LCHColor {
        return toLAB().toLCH()
    }
}
