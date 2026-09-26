//
//  Array+ProGradient.swift
//  ColorTokensKit
//
//  Smooth gradients through colors you choose: any array of Color or ProColor,
//  harmonies such as `brand.triad` included. Each function returns SwiftUI's own
//  gradient type, so it works in backgrounds, fills, strokes and text.
//

import SwiftUI

public extension Array where Element == Color {
    /// A smooth linear gradient through these colors, top to bottom unless you say otherwise.
    /// By default it blends `.vivid` and eases `.smooth`.
    ///
    /// ```swift
    /// .background([theme.surfaceTertiary, theme.surfaceSecondary].proGradient())
    /// .background(brand.analogous().proGradient(from: .leading, to: .trailing))
    /// .background([blue, yellow].proGradient(blend: .direct))     // no hues in between
    /// .background([glow, .clear].proGradient(easing: .easeOut))
    /// ```
    func proGradient(
        from start: UnitPoint = .top,
        to end: UnitPoint = .bottom,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> LinearGradient {
        LinearGradient(stops: GradientStops.smooth(self, blend: blend, easing: easing), startPoint: start, endPoint: end)
    }

    /// A smooth gradient from the center outward, filling its view.
    ///
    /// ```swift
    /// .background([glow, .clear].proRadialGradient())
    /// ```
    func proRadialGradient(
        center: UnitPoint = .center,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> EllipticalGradient {
        EllipticalGradient(stops: GradientStops.smooth(self, blend: blend, easing: easing), center: center)
    }

    /// A smooth gradient around a center that returns to its first color, so there's no seam.
    ///
    /// ```swift
    /// Circle().stroke(brand.triad.proAngularGradient(), lineWidth: 8)
    /// ```
    func proAngularGradient(
        center: UnitPoint = .center,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> AngularGradient {
        AngularGradient(stops: GradientStops.smooth(GradientStops.closingLoop(self), blend: blend, easing: easing), center: center)
    }
}

public extension Array where Element == ProColor {
    /// A smooth linear gradient through these families' colors, top to bottom unless you say otherwise.
    ///
    /// ```swift
    /// .background(Color.proBlue.triad.proGradient(from: .leading, to: .trailing))
    /// ```
    func proGradient(
        from start: UnitPoint = .top,
        to end: UnitPoint = .bottom,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> LinearGradient {
        map { $0.toColor() }.proGradient(from: start, to: end, blend: blend, easing: easing)
    }

    /// A smooth gradient through these families' colors, from the center outward.
    func proRadialGradient(
        center: UnitPoint = .center,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> EllipticalGradient {
        map { $0.toColor() }.proRadialGradient(center: center, blend: blend, easing: easing)
    }

    /// A smooth gradient through these families' colors, around a center.
    func proAngularGradient(
        center: UnitPoint = .center,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> AngularGradient {
        map { $0.toColor() }.proAngularGradient(center: center, blend: blend, easing: easing)
    }
}
