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

    /// OKLCH hue of the ramp `_50`…`_1000` index into.
    let rampHue: Double

    let isGrayscale: Bool

    public init(oklch: OKLCHColor) {
        self.init(oklch: oklch, rampHue: Double(oklch.h), isGrayscale: oklch.isAchromatic)
    }

    init(oklch: OKLCHColor, rampHue: Double, isGrayscale: Bool) {
        self.oklch = oklch
        self.rampHue = rampHue
        self.isGrayscale = isGrayscale
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
        ramp.map { ProColor(oklch: $0, rampHue: rampHue, isGrayscale: isGrayscale) }
    }

    var _50: ProColor { stop(at: 0) }
    var _100: ProColor { stop(at: 1) }
    var _150: ProColor { stop(at: 2) }
    var _200: ProColor { stop(at: 3) }
    var _250: ProColor { stop(at: 4) }
    var _300: ProColor { stop(at: 5) }
    var _350: ProColor { stop(at: 6) }
    var _400: ProColor { stop(at: 7) }
    var _450: ProColor { stop(at: 8) }
    var _500: ProColor { stop(at: 9) }
    var _550: ProColor { stop(at: 10) }
    var _600: ProColor { stop(at: 11) }
    var _650: ProColor { stop(at: 12) }
    var _700: ProColor { stop(at: 13) }
    var _750: ProColor { stop(at: 14) }
    var _800: ProColor { stop(at: 15) }
    var _850: ProColor { stop(at: 16) }
    var _900: ProColor { stop(at: 17) }
    var _950: ProColor { stop(at: 18) }
    var _1000: ProColor { stop(at: 19) }
}

private extension ProColor {
    var ramp: [OKLCHColor] {
        ColorRampGenerator.shared.getOKLCHColorRamp(forHue: rampHue, isGrayscale: isGrayscale)
    }

    func stop(at index: Int) -> ProColor {
        ProColor(oklch: ramp[index], rampHue: rampHue, isGrayscale: isGrayscale)
    }
}

// MARK: - Factory

public extension ProColor {
    /// Creates a primary ProColor for a given hue
    static func primary(forHue hue: Double, isGrayscale: Bool = false) -> ProColor {
        ProColor(
            oklch: OKLCHColor.getPrimaryColor(forHue: hue, isGrayscale: isGrayscale),
            rampHue: hue,
            isGrayscale: isGrayscale
        )
    }
}

// MARK: - Contrast

public extension ProColor {
    /// Contrast ratio between two ProColors
    func contrastRatio(to other: ProColor, method: ContrastMethod = .wcag2) -> CGFloat {
        toRGB().contrastRatio(to: other.toRGB(), method: method)
    }
}
