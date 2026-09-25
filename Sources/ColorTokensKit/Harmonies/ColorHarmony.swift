//
//  ColorHarmony.swift
//  ColorTokensKit
//
//  Color harmonies: sets of hues that work together, measured round the OKLCH hue
//  wheel. Every color in a harmony keeps the original's lightness, so the
//  harmony of a palette color is balanced by construction: same contrast, and the
//  same vividness wherever the screen allows.
//
//  This type is the single definition of each harmony. Color and ProColor both
//  read it, which is why `color.triad` and `family.triad` always agree.
//

import SwiftUI

public enum ColorHarmony: Hashable {
    /// The color and its opposite.
    case complement
    /// Three hues a third of the wheel apart.
    case triad
    /// Two complementary pairs, `offset` apart. An offset of 90° is a square.
    case tetrad(offset: Angle = .degrees(60))
    /// Four hues a quarter of the wheel apart.
    case square
    /// The color and the two hues either side of its complement.
    case splitComplement(spread: Angle = .degrees(30))
    /// `count` neighboring hues `spread` apart, centered on the color.
    case analogous(count: Int = 3, spread: Angle = .degrees(30))

    /// How far round the wheel each color sits from the original, in degrees, in the order colors are returned.
    /// An offset of 0 is the original color itself.
    public var hueOffsets: [Double] {
        switch self {
        case .complement:
            return [0, 180]
        case .triad:
            return [0, 120, 240]
        case let .tetrad(offset):
            return [0, offset.degrees, 180, 180 + offset.degrees]
        case .square:
            return [0, 90, 180, 270]
        case let .splitComplement(spread):
            return [0, 180 - spread.degrees, 180 + spread.degrees]
        case let .analogous(count, spread):
            let count = max(count, 1)
            let center = Double(count - 1) / 2
            return (0 ..< count).map { (Double($0) - center) * spread.degrees }
        }
    }
}
