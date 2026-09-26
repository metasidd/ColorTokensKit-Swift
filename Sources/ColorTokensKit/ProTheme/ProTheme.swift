//
//  ProTheme.swift
//  ColorTokensKit
//
//  A stable public type for design system colors. Wraps the underlying
//  color space (currently OKLCH) so the internal representation can
//  evolve without breaking callers.
//

import Foundation
import SwiftUI

/// The name before 3.0. Code written for 2.x keeps compiling, and Xcode offers to rename it.
@available(*, deprecated, renamed: "ProTheme")
public typealias ProColor = ProTheme

public struct ProTheme: Hashable, Sendable {
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

public extension ProTheme {
    var allStops: [ProTheme] {
        ramp.map { ProTheme(oklch: $0, rampHue: rampHue, isGrayscale: isGrayscale) }
    }

    var _50: ProTheme { stop(at: 0) }
    var _100: ProTheme { stop(at: 1) }
    var _150: ProTheme { stop(at: 2) }
    var _200: ProTheme { stop(at: 3) }
    var _250: ProTheme { stop(at: 4) }
    var _300: ProTheme { stop(at: 5) }
    var _350: ProTheme { stop(at: 6) }
    var _400: ProTheme { stop(at: 7) }
    var _450: ProTheme { stop(at: 8) }
    var _500: ProTheme { stop(at: 9) }
    var _550: ProTheme { stop(at: 10) }
    var _600: ProTheme { stop(at: 11) }
    var _650: ProTheme { stop(at: 12) }
    var _700: ProTheme { stop(at: 13) }
    var _750: ProTheme { stop(at: 14) }
    var _800: ProTheme { stop(at: 15) }
    var _850: ProTheme { stop(at: 16) }
    var _900: ProTheme { stop(at: 17) }
    var _950: ProTheme { stop(at: 18) }
    var _1000: ProTheme { stop(at: 19) }
}

private extension ProTheme {
    var ramp: [OKLCHColor] {
        ColorRampGenerator.shared.getOKLCHColorRamp(forHue: rampHue, isGrayscale: isGrayscale)
    }

    func stop(at index: Int) -> ProTheme {
        ProTheme(oklch: ramp[index], rampHue: rampHue, isGrayscale: isGrayscale)
    }
}

// MARK: - Factory

public extension ProTheme {
    /// A family from a hex color, such as your brand color: `ProTheme(hex: "#00B386")`.
    ///
    /// The color's OKLCH hue gives the ramp, so the stops and tokens match every other family's lightness
    /// and contrast. The color itself stays the family's own color (`toColor()`), even though it usually
    /// sits between two stops. A gray hex gives the gray family. Same as `ProTheme(oklch: OKLCHColor(hex:))`.
    init(hex: String) {
        self.init(oklch: OKLCHColor(hex: hex))
    }

    /// Creates a primary ProTheme for a given hue
    static func primary(forHue hue: Double, isGrayscale: Bool = false) -> ProTheme {
        ProTheme(
            oklch: OKLCHColor.getPrimaryColor(forHue: hue, isGrayscale: isGrayscale),
            rampHue: hue,
            isGrayscale: isGrayscale
        )
    }
}

// MARK: - Contrast

public extension ProTheme {
    /// Contrast ratio between two ProColors
    func contrastRatio(to other: ProTheme, method: ContrastMethod = .wcag2) -> CGFloat {
        toRGB().contrastRatio(to: other.toRGB(), method: method)
    }
}
