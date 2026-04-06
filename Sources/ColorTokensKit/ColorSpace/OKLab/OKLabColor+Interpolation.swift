//
//  OKLabColor+Interpolation.swift
//  ColorTokensKit
//

import Foundation

public extension OKLabColor {
    /// Linear interpolation in OKLab space
    func lerp(_ other: OKLabColor, t: CGFloat) -> OKLabColor {
        return OKLabColor(
            l: l + (other.l - l) * t,
            a: a + (other.a - a) * t,
            b: b + (other.b - b) * t,
            alpha: alpha + (other.alpha - alpha) * t
        )
    }
}
