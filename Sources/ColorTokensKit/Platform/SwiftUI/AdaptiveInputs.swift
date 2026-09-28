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

        init(_ colors: [Color]) {
            bases = colors.map { NSColor($0) }
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

        init(_ colors: [Color]) {
            bases = colors.map { UIColor($0) }
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

        init(_ colors: [Color]) {
            self.colors = colors.map { OKLCHColor(resolved: UIColor($0)) }
        }
    #endif
}
