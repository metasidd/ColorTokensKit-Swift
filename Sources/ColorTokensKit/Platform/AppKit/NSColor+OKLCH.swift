//
//  NSColor+OKLCH.swift
//  ColorTokensKit
//
//  Moving resolved AppKit colors in and out of OKLCH, for Color+Adaptive.
//

#if canImport(AppKit)
import AppKit

extension OKLCHColor {
    /// Reads an NSColor, already resolved for the current drawing appearance, as OKLCH.
    init(resolved color: NSColor) {
        let srgb = color.usingColorSpace(.extendedSRGB) ?? color
        self = RGBColor(r: srgb.redComponent, g: srgb.greenComponent, b: srgb.blueComponent, alpha: srgb.alphaComponent).toOKLCH()
    }
}

extension NSColor {
    /// An sRGB NSColor for an OKLCH color.
    convenience init(_ color: OKLCHColor) {
        let rgb = color.toRGB()
        self.init(srgbRed: rgb.r, green: rgb.g, blue: rgb.b, alpha: rgb.alpha)
    }
}

extension Appearance {
    init(_ appearance: NSAppearance) {
        self = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? .dark : .light
    }
}
#endif
