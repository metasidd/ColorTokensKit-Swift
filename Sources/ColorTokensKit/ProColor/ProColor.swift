//
//  ProColor.swift
//  ColorTokensKit
//
//  A stable public type for design system colors. Wraps the underlying
//  color space (currently OKLCH) so the internal representation can
//  evolve without breaking callers.
//

import Foundation
import SwiftUI

public struct ProColor: Hashable, Sendable {
    /// The underlying OKLCH representation
    let oklch: OKLCHColor

    public init(oklch: OKLCHColor) {
        self.oklch = oklch
    }

    /// Hue value (0-360)
    public var h: CGFloat { oklch.h }

    /// Chroma value
    public var c: CGFloat { oklch.c }

    /// Lightness value (0-1)
    public var l: CGFloat { oklch.l }

    /// Alpha value (0-1)
    public var alpha: CGFloat { oklch.alpha }

    /// Convert to SwiftUI Color
    public func toColor() -> Color {
        oklch.toColor()
    }

    /// Convert to RGBColor
    public func toRGB() -> RGBColor {
        oklch.toRGB()
    }

    /// Convert to OKLCHColor
    public func toOKLCH() -> OKLCHColor {
        oklch
    }

    /// Convert to LCHColor
    public func toLCH() -> LCHColor {
        oklch.toLCH()
    }
}

// MARK: - Stops

public extension ProColor {
    var allStops: [ProColor] {
        oklch.allStops.map { ProColor(oklch: $0) }
    }

    var _50: ProColor { ProColor(oklch: oklch._50) }
    var _100: ProColor { ProColor(oklch: oklch._100) }
    var _150: ProColor { ProColor(oklch: oklch._150) }
    var _200: ProColor { ProColor(oklch: oklch._200) }
    var _250: ProColor { ProColor(oklch: oklch._250) }
    var _300: ProColor { ProColor(oklch: oklch._300) }
    var _350: ProColor { ProColor(oklch: oklch._350) }
    var _400: ProColor { ProColor(oklch: oklch._400) }
    var _450: ProColor { ProColor(oklch: oklch._450) }
    var _500: ProColor { ProColor(oklch: oklch._500) }
    var _550: ProColor { ProColor(oklch: oklch._550) }
    var _600: ProColor { ProColor(oklch: oklch._600) }
    var _650: ProColor { ProColor(oklch: oklch._650) }
    var _700: ProColor { ProColor(oklch: oklch._700) }
    var _750: ProColor { ProColor(oklch: oklch._750) }
    var _800: ProColor { ProColor(oklch: oklch._800) }
    var _850: ProColor { ProColor(oklch: oklch._850) }
    var _900: ProColor { ProColor(oklch: oklch._900) }
    var _950: ProColor { ProColor(oklch: oklch._950) }
    var _1000: ProColor { ProColor(oklch: oklch._1000) }
}

// MARK: - Factory

public extension ProColor {
    /// Creates a primary ProColor for a given hue
    static func primary(forHue hue: Double, isGrayscale: Bool = false) -> ProColor {
        ProColor(oklch: OKLCHColor.getPrimaryColor(forHue: hue, isGrayscale: isGrayscale))
    }
}

// MARK: - Contrast

public extension ProColor {
    /// Contrast ratio between two ProColors
    func contrastRatio(to other: ProColor, method: ContrastMethod = .wcag2) -> CGFloat {
        toRGB().contrastRatio(to: other.toRGB(), method: method)
    }
}
