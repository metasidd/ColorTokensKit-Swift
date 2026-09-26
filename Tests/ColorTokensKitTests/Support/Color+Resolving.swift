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

extension Color {
    /// This color as 8-bit Display P3 hex in one appearance, e.g. "#4480c1".
    func hex(_ colorScheme: ColorScheme = .light) -> String {
        resolvedOKLCH(for: colorScheme).hex
    }
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
