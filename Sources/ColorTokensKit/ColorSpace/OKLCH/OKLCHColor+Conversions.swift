//
//  OKLCHColor+Conversions.swift
//  ColorTokensKit
//

import Foundation
import SwiftUI

public extension OKLCHColor {
    /// Converts to OKLab (cartesian form)
    func toOKLab() -> OKLabColor {
        let rad = h / ColorConstants.RAD_TO_DEG
        let a = cos(rad) * c
        let b = sin(rad) * c
        return OKLabColor(l: l, a: a, b: b, alpha: alpha)
    }

    /// Converts to RGB via OKLab
    func toRGB() -> RGBColor {
        return toOKLab().toRGB()
    }

    /// Converts to SwiftUI Color
    func toColor() -> Color {
        let rgb = toRGB()
        return Color(red: rgb.r, green: rgb.g, blue: rgb.b)
    }

    /// Converts to CIELab LCH via RGB
    func toLCH() -> LCHColor {
        return toRGB().toLCH()
    }
}
