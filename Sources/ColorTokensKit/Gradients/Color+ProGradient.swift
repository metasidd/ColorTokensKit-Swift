//
//  Color+ProGradient.swift
//  ColorTokensKit
//
//  Smooth gradients generated from a single color with a recipe: `.subtle` (the
//  default), `.fade`, `.tonal`, `.analogous`, `.wash`, `.sheen`, `.edgeHighlight`,
//  or one of your own. See ProGradient.Recipe.
//

import SwiftUI

public extension Color {
    /// A smooth linear gradient generated from this color, top to bottom unless you say otherwise.
    ///
    /// ```swift
    /// Image(systemName: "star.fill").foregroundStyle(accent.proGradient())   // .subtle
    /// .background(tinge.proGradient(.fade))
    /// .overlay(Color.white.proGradient(.sheen, from: .topLeading, to: .bottomTrailing))
    /// ```
    func proGradient(
        _ recipe: ProGradient.Recipe = .subtle,
        from start: UnitPoint = .top,
        to end: UnitPoint = .bottom,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> LinearGradient {
        recipe.colors(from: self).proGradient(from: start, to: end, blend: blend, easing: easing)
    }

    /// A smooth gradient generated from this color, from the center outward.
    ///
    /// ```swift
    /// .background(glow.proRadialGradient(.fade))
    /// ```
    func proRadialGradient(
        _ recipe: ProGradient.Recipe = .subtle,
        center: UnitPoint = .center,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> EllipticalGradient {
        recipe.colors(from: self).proRadialGradient(center: center, blend: blend, easing: easing)
    }

    /// A smooth gradient generated from this color, around a center.
    ///
    /// ```swift
    /// Circle().stroke(accent.proAngularGradient(.analogous), lineWidth: 6)
    /// ```
    func proAngularGradient(
        _ recipe: ProGradient.Recipe = .subtle,
        center: UnitPoint = .center,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> AngularGradient {
        recipe.colors(from: self).proAngularGradient(center: center, blend: blend, easing: easing)
    }
}

public extension ProColor {
    /// A smooth linear gradient generated from this family's color.
    ///
    /// ```swift
    /// .background(Color.proBlue.proGradient(.tonal))
    /// ```
    func proGradient(
        _ recipe: ProGradient.Recipe = .subtle,
        from start: UnitPoint = .top,
        to end: UnitPoint = .bottom,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> LinearGradient {
        toColor().proGradient(recipe, from: start, to: end, blend: blend, easing: easing)
    }

    /// A smooth gradient generated from this family's color, from the center outward.
    func proRadialGradient(
        _ recipe: ProGradient.Recipe = .subtle,
        center: UnitPoint = .center,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> EllipticalGradient {
        toColor().proRadialGradient(recipe, center: center, blend: blend, easing: easing)
    }

    /// A smooth gradient generated from this family's color, around a center.
    func proAngularGradient(
        _ recipe: ProGradient.Recipe = .subtle,
        center: UnitPoint = .center,
        blend: ProGradient.Blend = .vivid,
        easing: ProGradient.Easing = .smooth
    ) -> AngularGradient {
        toColor().proAngularGradient(recipe, center: center, blend: blend, easing: easing)
    }
}
