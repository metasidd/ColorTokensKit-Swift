//
//  ProGradient.swift
//  ColorTokensKit
//
//  Smooth gradients. SwiftUI blends gradient colors either in the device's RGB
//  space (`.device`), which takes distant colors through gray, or in a perceptual
//  space it doesn't specify (`.perceptual`). ColorTokensKit adds in-between colors
//  worked out in OKLCH, the space CSS uses for `linear-gradient(in oklch, …)`, so
//  a gradient looks the same on every OS version and on the web, and you choose
//  which way hues travel. It then hands back SwiftUI's own gradient types, so a
//  smooth gradient works anywhere a gradient already does.
//
//      [top, bottom].proGradient()             // colors you choose
//      brand.proGradient(.fade)                // generated from one color
//      brand.triad.proAngularGradient()        // a harmony, as a ring
//
//  The functions live in Array+ProGradient (colors you choose) and
//  Color+ProGradient (one color and a recipe). This file holds their options.
//

import SwiftUI

/// Options for the `proGradient`, `proRadialGradient` and `proAngularGradient` functions.
public enum ProGradient {
    /// Which way hues travel round the color wheel between two colors, using CSS Color 4's names.
    public enum HuePath: Hashable, Sendable {
        /// The short way round. The default.
        case shorter
        /// The long way round, for rainbow sweeps.
        case longer
        /// Always toward higher hue angles.
        case increasing
        /// Always toward lower hue angles.
        case decreasing

        /// The hue `t` of the way from `start` to `end` along this path.
        func hue(from start: Double, to end: Double, at t: Double) -> Double {
            var delta = end - start
            switch self {
            case .shorter:
                if delta > 180 { delta -= 360 } else if delta < -180 { delta += 360 }
            case .longer:
                if delta > 0, delta < 180 { delta -= 360 } else if delta > -180, delta <= 0 { delta += 360 }
            case .increasing:
                if delta < 0 { delta += 360 }
            case .decreasing:
                if delta > 0 { delta -= 360 }
            }
            return (start + delta * t).normalizedHue
        }
    }

    /// A way to build a gradient from a single color.
    ///
    /// Use a preset (`.subtle`, `.fade`, `.tonal`, `.analogous`, `.wash`, `.sheen`, `.edgeHighlight`)
    /// or make your own:
    ///
    /// ```swift
    /// extension ProGradient.Recipe {
    ///     static var deepen: Self { Self { [$0, $0.darken(by: 4)] } }
    /// }
    /// brand.proGradient(.deepen)
    /// ```
    public struct Recipe {
        private let makeColors: (Color) -> [Color]

        public init(_ makeColors: @escaping (Color) -> [Color]) {
            self.makeColors = makeColors
        }

        /// The colors this recipe makes from `color`, in gradient order.
        public func colors(from color: Color) -> [Color] {
            makeColors(color)
        }
    }
}

public extension ProGradient.Recipe {
    /// A touch lighter at the start: the look of SwiftUI's `Color.gradient`, made smooth.
    static var subtle: Self {
        Self { [$0.lighten(), $0] }
    }

    /// The color fading to transparent, for glows, scrims and edges.
    static var fade: Self {
        Self { [$0, $0.opacity(0)] }
    }

    /// Two stops lighter to two stops darker, for depth.
    static var tonal: Self {
        Self { [$0.lighten(by: 2), $0, $0.darken(by: 2)] }
    }

    /// The neighboring hues on either side, at the same lightness.
    static var analogous: Self {
        Self { $0.analogous() }
    }

    /// A light, translucent tint that deepens toward the end: a soft backdrop for cards.
    static var wash: Self {
        Self { [$0.opacity(0.1), $0.opacity(0.3)] }
    }

    /// A band of the color across the middle, clear at both ends. Use white for a shine.
    static var sheen: Self {
        Self { [$0.opacity(0), $0.opacity(0.5), $0.opacity(0)] }
    }

    /// Strongest in the middle and faint at the ends, for highlighted borders.
    static var edgeHighlight: Self {
        Self { [$0.opacity(0.15), $0, $0.opacity(0.15)] }
    }
}
