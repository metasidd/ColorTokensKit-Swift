//
//  OKLCHColor+Interpolation.swift
//  ColorTokensKit
//

import Foundation

public extension OKLCHColor {
    /// Interpolates between two OKLCH colors using shortest hue path
    func lerp(_ other: OKLCHColor, t: CGFloat) -> OKLCHColor {
        let normalizedH = h
        let normalizedOtherH = other.h

        let rawDiff = normalizedOtherH - normalizedH
        let wrappedDiff = rawDiff.normalizedHue
        let angle = (wrappedDiff <= 180 ? wrappedDiff : wrappedDiff - 360) * t

        return OKLCHColor(
            l: l + (other.l - l) * t,
            c: c + (other.c - c) * t,
            h: (normalizedH + angle + 360),
            alpha: alpha + (other.alpha - alpha) * t
        )
    }
}
