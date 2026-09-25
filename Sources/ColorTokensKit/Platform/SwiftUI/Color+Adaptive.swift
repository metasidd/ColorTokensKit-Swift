//
//  Color+Adaptive.swift
//  ColorTokensKit
//
//  How the color functions stay correct in light and dark mode. A function such
//  as `lighten()` returns a Color whose value is worked out when it is drawn: the
//  original color is resolved for the current appearance, converted to OKLCH,
//  adjusted, and handed back. Tokens therefore stay adaptive, and any Color (a
//  token, a system color, a hex color) can be adjusted.
//

import SwiftUI

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// The appearance a color is resolved for.
enum Appearance {
    case light
    case dark
}

extension Color {
    /// A color worked out from this one each time it is drawn, for the current appearance.
    func adapting(_ transform: @escaping @Sendable (OKLCHColor, Appearance) -> OKLCHColor) -> Color {
        Color.adapting(combining: [self]) { colors, appearance in transform(colors[0], appearance) }
    }

    /// A color worked out from several colors each time it is drawn, for the current appearance.
    static func adapting(
        combining colors: [Color],
        _ combine: @escaping @Sendable ([OKLCHColor], Appearance) -> OKLCHColor
    ) -> Color {
        #if canImport(AppKit)
            let bases = colors.map { NSColor($0) }
            return Color(nsColor: NSColor(name: nil) { appearance in
                var resolved: [OKLCHColor] = []
                appearance.performAsCurrentDrawingAppearance {
                    resolved = bases.map { OKLCHColor(resolved: $0) }
                }
                return NSColor(combine(resolved, Appearance(appearance)))
            })
        #elseif canImport(UIKit) && !os(watchOS)
            let bases = colors.map { UIColor($0) }
            return Color(uiColor: UIColor { traits in
                let resolved = bases.map { OKLCHColor(resolved: $0.resolvedColor(with: traits)) }
                return UIColor(combine(resolved, Appearance(traits)))
            })
        #else
            // watchOS always draws in dark appearance, so the color is worked out once.
            let resolved = colors.map { OKLCHColor(resolved: UIColor($0)) }
            return Color(uiColor: UIColor(combine(resolved, .dark)))
        #endif
    }

    /// This color's value in one appearance, as OKLCH.
    func resolvedOKLCH(for appearance: Appearance) -> OKLCHColor {
        #if canImport(AppKit)
            var resolved = OKLCHColor()
            NSAppearance(named: appearance == .dark ? .darkAqua : .aqua)?.performAsCurrentDrawingAppearance {
                resolved = OKLCHColor(resolved: NSColor(self))
            }
            return resolved
        #elseif canImport(UIKit) && !os(watchOS)
            let traits = UITraitCollection(userInterfaceStyle: appearance == .dark ? .dark : .light)
            return OKLCHColor(resolved: UIColor(self).resolvedColor(with: traits))
        #else
            return OKLCHColor(resolved: UIColor(self))
        #endif
    }
}
