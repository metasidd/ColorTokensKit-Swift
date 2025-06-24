//
//  LCHColor+Interpolation.swift
//  ColorTokensKit
//
//  Created by Siddhant Mehta on 2024-07-29.
//

import Foundation

public extension LCHColor {
    /// Interpolates between two LCH colors
    func lerp(_ other: LCHColor, t: CGFloat) -> LCHColor {
        // Normalize the angle calculation for consistent results
        let normalizedH = h // Already normalized during initialization
        let normalizedOtherH = other.h // Already normalized during initialization
        let normalizedT = t.rounded(to: ColorConstants.interpolationPrecision)
        
        // Calculate the shortest path around the color wheel
        let rawDiff = normalizedOtherH - normalizedH
        let wrappedDiff = rawDiff.normalizedHue
        let angle = (wrappedDiff <= 180 ? wrappedDiff : wrappedDiff - 360) * normalizedT
        
        return LCHColor(
            l: l + (other.l - l) * normalizedT,
            c: c + (other.c - c) * normalizedT,
            h: (normalizedH + angle + 360), // Will be normalized in the initializer
            alpha: alpha + (other.alpha - alpha) * normalizedT
        )
    }
}
