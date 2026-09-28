//
//  Color+Adaptive.swift
//  ColorTokensKit
//
//  How the color functions stay correct in light and dark mode. A function such
//  as `lighten()` returns a Color whose value is worked out when it is drawn: the
//  original color is resolved for the current appearance, converted to OKLCH,
//  adjusted, and handed back. Tokens therefore stay adaptive, and any Color (a
//  token, a system color, a hex color) can be adjusted. Each appearance's result
//  is kept, so drawing the color again in that appearance skips the work.
//

import SwiftUI

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension Color {
    /// A color worked out from this one each time it is drawn, for the current appearance.
    func adapting(_ transform: @escaping @Sendable (OKLCHColor, ColorScheme) -> OKLCHColor) -> Color {
        Color.adapting(combining: [self]) { colors, colorScheme in transform(colors[0], colorScheme) }
    }

    /// A color worked out from several colors each time it is drawn, for the current appearance.
    static func adapting(
        combining colors: [Color],
        _ combine: @escaping @Sendable ([OKLCHColor], ColorScheme) -> OKLCHColor
    ) -> Color {
        adapting(combining: AdaptiveInputs(colors), combine)
    }

    /// A color worked out from inputs it may share with other colors, such as the ends of a gradient segment.
    static func adapting(
        combining inputs: AdaptiveInputs,
        _ combine: @escaping @Sendable ([OKLCHColor], ColorScheme) -> OKLCHColor
    ) -> Color {
        #if canImport(AppKit)
            let results = AppearanceCache<NSAppearance.Name, NSColor>()
            return Color(nsColor: NSColor(name: nil) { appearance in
                results.value(for: appearance.name) {
                    NSColor(combine(inputs.colors(in: appearance), ColorScheme(appearance)))
                }
            })
        #elseif canImport(UIKit) && !os(watchOS)
            let results = AppearanceCache<UITraitCollection, UIColor>()
            return Color(uiColor: UIColor { traits in
                results.value(for: traits) {
                    UIColor(combine(inputs.colors(with: traits), ColorScheme(traits.userInterfaceStyle) ?? .light))
                }
            })
        #else
            // watchOS always draws in dark appearance, so the color is worked out once.
            return Color(uiColor: UIColor(combine(inputs.colors, .dark)))
        #endif
    }

    /// This color's value in one appearance, as OKLCH.
    func resolvedOKLCH(for colorScheme: ColorScheme) -> OKLCHColor {
        #if canImport(AppKit)
            var resolved = OKLCHColor()
            NSAppearance(named: colorScheme == .dark ? .darkAqua : .aqua)?.performAsCurrentDrawingAppearance {
                resolved = OKLCHColor(resolved: NSColor(self))
            }
            return resolved
        #elseif canImport(UIKit) && !os(watchOS)
            let traits = UITraitCollection(userInterfaceStyle: UIUserInterfaceStyle(colorScheme))
            return OKLCHColor(resolved: UIColor(self).resolvedColor(with: traits))
        #else
            return OKLCHColor(resolved: UIColor(self))
        #endif
    }
}
