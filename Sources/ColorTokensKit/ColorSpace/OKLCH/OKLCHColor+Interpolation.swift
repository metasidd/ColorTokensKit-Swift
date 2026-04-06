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
        let normalizedT = t.rounded(to: ColorConstants.interpolationPrecision)

        let rawDiff = normalizedOtherH - normalizedH
        let wrappedDiff = rawDiff.normalizedHue
        let angle = (wrappedDiff <= 180 ? wrappedDiff : wrappedDiff - 360) * normalizedT

        return OKLCHColor(
            l: l + (other.l - l) * normalizedT,
            c: c + (other.c - c) * normalizedT,
            h: (normalizedH + angle + 360),
            alpha: alpha + (other.alpha - alpha) * normalizedT
        )
    }
}
