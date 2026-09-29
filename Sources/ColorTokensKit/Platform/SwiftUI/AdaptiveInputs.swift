//
//  AdaptiveInputs.swift
//  ColorTokensKit
//

import SwiftUI

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// The colors a color function reads, resolved once per appearance and shared by every color made from them.
///
/// A gradient segment's stops all read the same two ends, so they share one of these: the ends are resolved
/// once per appearance instead of once per stop.
final class AdaptiveInputs: @unchecked Sendable {
    #if canImport(AppKit)
        private let bases: [NSColor]
        private let resolved = AppearanceCache<NSAppearance.Name, [OKLCHColor]>()

        /// Always nil on AppKit, which has no cheap way to tell a fixed color from one that changes.
        let fixedColors: [OKLCHColor]? = nil

        init(_ colors: [Color]) {
            bases = colors.map { NSColor($0) }
        }

        /// A color worked out from `fixedColors`, built the way an adaptive one is, so opacity and Display P3 survive.
        static func fixedColor(_ color: OKLCHColor) -> Color {
            Color(nsColor: NSColor(color))
        }

        /// The inputs as they look in `appearance`.
        func colors(in appearance: NSAppearance) -> [OKLCHColor] {
            resolved.value(for: appearance.name) {
                var colors: [OKLCHColor] = []
                appearance.performAsCurrentDrawingAppearance {
                    colors = bases.map { OKLCHColor(resolved: $0) }
                }
                return colors
            }
        }
    #elseif canImport(UIKit) && !os(watchOS)
        private let bases: [UIColor]
        private let resolved = AppearanceCache<UITraitCollection, [OKLCHColor]>()

        /// The inputs when none of them changes with the appearance, so what's made from them can be fixed too. UIKit
        /// hands back the same object when it resolves a fixed color.
        let fixedColors: [OKLCHColor]?

        init(_ colors: [Color]) {
            bases = colors.map { UIColor($0) }
            let traits = UITraitCollection(userInterfaceStyle: .light)
            fixedColors = bases.allSatisfy { $0.resolvedColor(with: traits) === $0 } ? bases.map { OKLCHColor(resolved: $0) } : nil
        }

        /// A color worked out from `fixedColors`, built the way an adaptive one is, so opacity and Display P3 survive.
        static func fixedColor(_ color: OKLCHColor) -> Color {
            Color(uiColor: UIColor(color))
        }

        /// The inputs as they look with `traits`.
        func colors(with traits: UITraitCollection) -> [OKLCHColor] {
            resolved.value(for: traits) {
                bases.map { OKLCHColor(resolved: $0.resolvedColor(with: traits)) }
            }
        }
    #else
        /// watchOS always draws in dark appearance, so the inputs are resolved once.
        let colors: [OKLCHColor]

        /// Always nil on watchOS, where every color made from the inputs is already worked out once.
        let fixedColors: [OKLCHColor]? = nil

        init(_ colors: [Color]) {
            self.colors = colors.map { OKLCHColor(resolved: UIColor($0)) }
        }

        /// A color worked out from `fixedColors`, built the way an adaptive one is, so opacity and Display P3 survive.
        static func fixedColor(_ color: OKLCHColor) -> Color {
            Color(uiColor: UIColor(color))
        }
    #endif
}
