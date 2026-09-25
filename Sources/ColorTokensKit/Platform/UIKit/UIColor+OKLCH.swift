//
//  UIColor+OKLCH.swift
//  ColorTokensKit
//
//  Moving resolved UIKit colors in and out of OKLCH, for Color+Adaptive.
//

#if canImport(UIKit) && !canImport(AppKit)
    import UIKit

    extension OKLCHColor {
        /// Reads a UIColor, already resolved for a trait collection, as OKLCH.
        init(resolved color: UIColor) {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self = RGBColor(r: red, g: green, b: blue, alpha: alpha).toOKLCH()
        }
    }

    extension UIColor {
        /// An sRGB UIColor for an OKLCH color.
        convenience init(_ color: OKLCHColor) {
            let rgb = color.toRGB()
            self.init(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: rgb.alpha)
        }
    }

    #if !os(watchOS)
        extension Appearance {
            init(_ traits: UITraitCollection) {
                self = traits.userInterfaceStyle == .dark ? .dark : .light
            }
        }
    #endif
#endif
