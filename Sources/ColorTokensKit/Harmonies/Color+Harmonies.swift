//
//  Color+Harmonies.swift
//  ColorTokensKit
//
//  Related colors for any Color: its complement, triad, square, analogous
//  neighbors, and lighter or darker sets. Every result is a ready-to-use Color
//  that stays correct in light and dark mode, and keeps the original's role: the
//  triad of a background is three backgrounds.
//

import SwiftUI

public extension Color {
    // MARK: - Hue harmonies

    /// The opposite hue at the same lightness.
    ///
    /// ```swift
    /// theme.foregroundTertiary.complement
    /// ```
    var complement: Color {
        rotateHue(by: .degrees(180))
    }

    /// This color and the two hues a third of the wheel away.
    ///
    /// ```swift
    /// theme.backgroundSecondary.triad    // three backgrounds, one per card
    /// ```
    var triad: [Color] {
        harmony(.triad)
    }

    /// This color, the hue `offset` around the wheel, and the complements of both, in that order.
    ///
    /// ```swift
    /// badge.tetrad()                     // offset 60°
    /// ```
    func tetrad(offset: Angle = .degrees(60)) -> [Color] {
        harmony(.tetrad(offset: offset))
    }

    /// Four hues a quarter of the wheel apart, starting with this color.
    var square: [Color] {
        harmony(.square)
    }

    /// This color and the two hues either side of its complement.
    ///
    /// ```swift
    /// accent.splitComplement()           // ±30° around the complement
    /// ```
    func splitComplement(spread: Angle = .degrees(30)) -> [Color] {
        harmony(.splitComplement(spread: spread))
    }

    /// `count` neighboring hues `spread` apart, centered on this color. With an even `count`
    /// there is no middle, so this color itself isn't one of them.
    ///
    /// ```swift
    /// brand.analogous()                  // 3 colors, 30° apart
    /// brand.analogous(count: 5, spread: .degrees(15))
    /// ```
    func analogous(count: Int = 3, spread: Angle = .degrees(30)) -> [Color] {
        harmony(.analogous(count: count, spread: spread))
    }

    /// The colors of a harmony built from this color, in the order of its `hueOffsets`.
    /// Useful when the harmony is chosen at runtime.
    ///
    /// ```swift
    /// brand.harmony(.splitComplement(spread: .degrees(20)))
    /// ```
    func harmony(_ harmony: ColorHarmony) -> [Color] {
        harmony.hueOffsets.map { $0 == 0 ? self : rotateHue(by: .degrees($0)) }
    }

    // MARK: - Lightness sets

    /// `count` colors of this hue, spread evenly from the lightest stop to the darkest.
    ///
    /// ```swift
    /// brand.monochromatic()              // 5 colors, light to dark
    /// ```
    func monochromatic(count: Int = 5) -> [Color] {
        let count = max(count, 1)
        let lastPosition = Double(ColorConstants.rampStops - 1)
        return (0 ..< count).map { index in
            let position = count == 1 ? 0 : Double(index) * lastPosition / Double(count - 1)
            return adapting { color, _ in ColorAdjustment.placing(color, atStopPosition: position) }
        }
    }

    /// `count` lighter versions of this color, one stop apart, nearest first.
    func tints(count: Int = 3) -> [Color] {
        (0 ..< max(count, 0)).map { lighten(by: $0 + 1) }
    }

    /// `count` darker versions of this color, one stop apart, nearest first.
    func shades(count: Int = 3) -> [Color] {
        (0 ..< max(count, 0)).map { darken(by: $0 + 1) }
    }
}
