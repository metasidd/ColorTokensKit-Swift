//
//  ProColor+Harmonies.swift
//  ColorTokensKit
//
//  Harmonies for whole color families. Where Color's harmonies return single
//  colors, these return ProColor families, so you can take any stop or token from
//  the related hue: `brand.complement.backgroundSecondary`.
//
//  Both routes give the same color: `brand.complement._600` is
//  `brand._600.toColor().complement`.
//

import SwiftUI

public extension ProColor {
    /// The family on the opposite side of the hue wheel, at this color's stop.
    var complement: ProColor {
        rotateHue(by: .degrees(180))
    }

    /// This family and the two a third of the wheel away.
    var triad: [ProColor] {
        harmony(.triad)
    }

    /// This family, the one `offset` around the wheel, and the complements of both, in that order.
    func tetrad(offset: Angle = .degrees(60)) -> [ProColor] {
        harmony(.tetrad(offset: offset))
    }

    /// Four families a quarter of the wheel apart, starting with this one.
    var square: [ProColor] {
        harmony(.square)
    }

    /// This family and the two either side of its complement.
    func splitComplement(spread: Angle = .degrees(30)) -> [ProColor] {
        harmony(.splitComplement(spread: spread))
    }

    /// `count` neighboring families `spread` apart, centered on this one. With an even `count`
    /// there is no middle, so this family itself isn't one of them.
    func analogous(count: Int = 3, spread: Angle = .degrees(30)) -> [ProColor] {
        harmony(.analogous(count: count, spread: spread))
    }

    /// The families of a harmony built from this one, in the order of its `hueOffsets`.
    func harmony(_ harmony: ColorHarmony) -> [ProColor] {
        harmony.hueOffsets.map { $0 == 0 ? self : rotateHue(by: .degrees($0)) }
    }

    /// The family `angle` around the hue wheel, at this color's stop. Gray has no hue, so it stays gray.
    ///
    /// ```swift
    /// Color.proBlue.rotateHue(by: .degrees(30))
    /// ```
    func rotateHue(by angle: Angle) -> ProColor {
        guard !isGrayscale else { return self }
        let index = StopLadder.chromatic.nearestStop(toLightnessStar: oklch.lightnessStar)
        let stop = PaletteStop(hue: rampHue, index: index, isGray: false).rotated(byDegrees: angle.degrees)
        return ProColor(oklch: stop.color(alpha: oklch.alpha), rampHue: stop.hue, isGrayscale: false)
    }
}
