//
//  NSColor+OKLCH.swift
//  ColorTokensKit
//
//  Moving resolved AppKit colors in and out of OKLCH, for Color+Adaptive.
//

#if canImport(AppKit)
import AppKit
import SwiftUI

extension OKLCHColor {
    /// Reads an NSColor, already resolved for the current drawing appearance, as OKLCH.
    init(resolved color: NSColor) {
        let srgb = color.usingColorSpace(.extendedSRGB) ?? color
        self = RGBColor(r: srgb.redComponent, g: srgb.greenComponent, b: srgb.blueComponent, alpha: srgb.alphaComponent).toOKLCH()
    }
}

extension NSColor {
    /// An extended sRGB NSColor for an OKLCH color, which keeps Display P3 colors intact. `NSColor(srgbRed:)`
    /// would tag it plain sRGB, and AppKit clips such a color to 0…1 when it converts it.
    convenience init(_ color: OKLCHColor) {
        let rgb = color.toRGB()
        self.init(colorSpace: .extendedSRGB, components: [rgb.r, rgb.g, rgb.b, rgb.alpha], count: 4)
    }
}

extension ColorScheme {
    /// The color scheme of an AppKit appearance. UIKit's trait collections have this built in.
    init(_ appearance: NSAppearance) {
        self = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? .dark : .light
    }
}
#endif
