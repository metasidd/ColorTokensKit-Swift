//
//  ProGradient.swift
//  ColorTokensKit
//
//  Smooth gradients. SwiftUI's default on iOS (`.perceptual`) draws a straight
//  line through OKLab, so distant colors meet in a paler middle; `.device` blends
//  in RGB, through gray. ColorTokensKit adds in-between colors worked out in
//  OKLCH, the space CSS uses for `linear-gradient(in oklch, …)`, so colors stay
//  vivid and a gradient looks the same on every OS version. It eases gently from
//  first color to last by default (`easing: .linear` matches CSS), then hands
//  back SwiftUI's own gradient types, so it works anywhere a gradient already does.
//
//      [top, bottom].proGradient()                  // colors you choose
//      [blue, yellow].proGradient(blend: .direct)   // a straight line, no hues in between
//      brand.proGradient(.fade)                     // generated from one color
//      brand.triad.proAngularGradient()             // a harmony, as a ring
//
//  The functions live in Array+ProGradient (colors you choose) and
//  Color+ProGradient (one color and a recipe). This file holds their options.
//

import SwiftUI

/// Options for the `proGradient`, `proRadialGradient` and `proAngularGradient` functions:
/// how they blend between colors, how they ease from first to last, and recipes for one color.
public enum ProGradient {
    /// How a gradient travels from one color to the next.
    public enum Blend: Hashable, Sendable {
        /// Around the OKLCH hue wheel the short way, as CSS's `linear-gradient(in oklch, …)` does,
        /// so colors stay saturated: blue to yellow passes teal and green. The default.
        case vivid
        /// A straight line through OKLab, with no hues in between; distant colors meet in a paler
        /// middle. This matches SwiftUI's own gradients on iOS.
        case direct
        /// Around the OKLCH hue wheel the long way, through the hues on the other side.
        case rainbow
    }

    /// How quickly a gradient changes from its first color to its last, with the same names as
    /// SwiftUI's `Animation`. The default, `.smooth`, starts and finishes gently, so the gradient
    /// has no hard edges where it meets the colors around it.
    public struct Easing: Hashable, Sendable {
        private let x1, y1, x2, y2: Double

        /// A constant rate of change, like SwiftUI's own gradients.
        public static let linear = Easing(0, 0, 1, 1)
        /// Starts slowly and speeds up.
        public static let easeIn = Easing(0.42, 0, 1, 1)
        /// Starts quickly and slows down.
        public static let easeOut = Easing(0, 0, 0.58, 1)
        /// Slow at both ends, quick in the middle.
        public static let easeInOut = Easing(0.42, 0, 0.58, 1)
        /// Gentle at both ends and a little softer than `.easeInOut`: CSS's ease-in-out-sine,
        /// `cubic-bezier(0.37, 0, 0.63, 1)`, so a design tool can match it. The default.
        public static let smooth = Easing(0.37, 0, 0.63, 1)

        /// A custom cubic Bézier curve, as in SwiftUI's `Animation.timingCurve(_:_:_:_:)`.
        /// Values are held to 0…1, since a gradient can't overshoot its colors.
        public static func timingCurve(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Easing {
            Easing(x1, y1, x2, y2)
        }

        private init(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) {
            (self.x1, self.y1, self.x2, self.y2) = (min(max(x1, 0), 1), min(max(y1, 0), 1), min(max(x2, 0), 1), min(max(y2, 0), 1))
        }

        /// Where along the gradient (0…1) the colors are `progress` (0…1) of the way from the first to the last.
        func location(forProgress progress: Double) -> Double {
            if progress <= 0 { return 0 }
            if progress >= 1 { return 1 }
            guard self != .linear else { return progress }
            var low = 0.0, high = 1.0
            for _ in 0 ..< 40 {
                let t = (low + high) / 2
                if bezier(t, y1, y2) < progress { low = t } else { high = t }
            }
            return bezier((low + high) / 2, x1, x2)
        }

        /// One coordinate of the cubic Bézier from (0, 0) to (1, 1) at parameter `t`.
        private func bezier(_ t: Double, _ first: Double, _ second: Double) -> Double {
            let u = 1 - t
            return 3 * u * u * t * first + 3 * u * t * t * second + t * t * t
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

        /// A recipe that makes a gradient's colors from one color, in gradient order.
        ///
        /// ```swift
        /// let deepen = ProGradient.Recipe { [$0, $0.darken(by: 4)] }
        /// brand.proGradient(deepen)
        /// ```
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

    /// From the hue 30° to one side, through this color, to the hue 30° to the other, at the same lightness.
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
