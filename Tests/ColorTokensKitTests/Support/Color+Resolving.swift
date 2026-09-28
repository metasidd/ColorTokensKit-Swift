//
//  Color+Resolving.swift
//  ColorTokensKitTests
//
//  Test helpers: resolve a Color for one appearance and compare colors the way a
//  screen would, as 8-bit hex. Palette colors are Display P3, so hex is Display P3,
//  except where a test compares against a value measured in sRGB.
//

@testable import ColorTokensKit
import SwiftUI

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension Color {
    /// This color as 8-bit Display P3 hex in one appearance, e.g. "#4480c1".
    func hex(_ colorScheme: ColorScheme = .light) -> String {
        resolvedOKLCH(for: colorScheme).hex
    }

    /// This color as 8-bit Display P3 hex in a second light appearance: Increase Contrast on UIKit, and vibrant light on
    /// AppKit, where code can't switch an appearance to high contrast.
    func alternateLightHex() -> String {
        #if canImport(AppKit)
            var resolved = OKLCHColor()
            NSAppearance(named: .vibrantLight)?.performAsCurrentDrawingAppearance {
                resolved = OKLCHColor(resolved: NSColor(self))
            }
            return resolved.hex
        #elseif canImport(UIKit) && !os(watchOS)
            let traits = UITraitCollection(traitsFrom: [
                UITraitCollection(userInterfaceStyle: .light),
                UITraitCollection(accessibilityContrast: .high),
            ])
            return OKLCHColor(resolved: UIColor(self).resolvedColor(with: traits)).hex
        #else
            return hex()
        #endif
    }

    /// A color that is `alternate` in the second light appearance (see `alternateLightHex()`), the way many system
    /// colors change with Increase Contrast.
    static func changingWithAppearance(standard: OKLCHColor, alternate: OKLCHColor) -> Color {
        #if canImport(AppKit)
            Color(nsColor: NSColor(name: nil) { appearance in
                NSColor(appearance.name == .vibrantLight ? alternate : standard)
            })
        #elseif canImport(UIKit) && !os(watchOS)
            Color(uiColor: UIColor { traits in
                UIColor(traits.accessibilityContrast == .high ? alternate : standard)
            })
        #else
            standard.toColor()
        #endif
    }

    /// Pure blue that counts how many times it's resolved.
    static func countingBlue(_ counter: ResolveCounter) -> Color {
        #if canImport(AppKit)
            Color(nsColor: NSColor(name: nil) { _ in
                counter.count += 1
                return NSColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)
            })
        #elseif canImport(UIKit) && !os(watchOS)
            Color(uiColor: UIColor { _ in
                counter.count += 1
                return UIColor(red: 0, green: 0, blue: 1, alpha: 1)
            })
        #else
            Color(red: 0, green: 0, blue: 1)
        #endif
    }
}

/// How many times a color was resolved; see `Color.countingBlue(_:)`.
final class ResolveCounter: @unchecked Sendable {
    var count = 0
}

extension OKLCHColor {
    /// This color as 8-bit Display P3 hex, the way an iPhone screen shows it.
    var hex: String {
        let (r, g, b) = Gamut.linearSRGB(lightness: Double(l), chroma: Double(c), hue: Double(h))
        let (pr, pg, pb) = Gamut.linearDisplayP3(r, g, b)
        return Self.hexString(pr, pg, pb)
    }

    /// This color as 8-bit sRGB hex, for comparing with values measured in sRGB.
    var sRGBHex: String {
        let (r, g, b) = Gamut.linearSRGB(lightness: Double(l), chroma: Double(c), hue: Double(h))
        return Self.hexString(r, g, b)
    }

    /// Display P3 and sRGB share the sRGB transfer curve.
    private static func hexString(_ r: Double, _ g: Double, _ b: Double) -> String {
        let channel = { (linear: Double) in Int((min(max(linearToSRGB(CGFloat(linear)), 0), 1) * 255).rounded()) }
        return String(format: "#%02x%02x%02x", channel(r), channel(g), channel(b))
    }
}
