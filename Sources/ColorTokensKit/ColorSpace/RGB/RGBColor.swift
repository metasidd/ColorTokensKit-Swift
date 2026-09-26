//
//  RGBColor.swift
//
//  Original repo: https://github.com/timrwood/ColorSpaces
//

import Foundation
import SwiftUI

/// An extended sRGB color: channels run 0…1 inside sRGB and go past either end for wider colors, such as the
/// palette's Display P3 stops. SwiftUI, UIKit and AppKit all draw extended sRGB as is.
public struct RGBColor: Hashable, Sendable {
    public let r: CGFloat
    public let g: CGFloat
    public let b: CGFloat
    public let alpha: CGFloat // 0..1

    public init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
        self.r = r
        self.g = g
        self.b = b
        self.alpha = alpha
    }

    public init(color: Color) {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            let resolvedColor = color.resolve(in: .init())
            self.r = CGFloat(resolvedColor.red)
            self.g = CGFloat(resolvedColor.green)
            self.b = CGFloat(resolvedColor.blue)
            self.alpha = CGFloat(resolvedColor.cgColor.alpha)
        } else {
            #if canImport(UIKit)
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0

                UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                r = red
                g = green
                b = blue
                self.alpha = alpha
            #elseif canImport(AppKit)
                guard let convertedColor = NSColor(color).usingColorSpace(.extendedSRGB) else {
                    r = 0
                    g = 0
                    b = 0
                    self.alpha = 1
                    return
                }
                r = convertedColor.redComponent
                g = convertedColor.greenComponent
                b = convertedColor.blueComponent
                self.alpha = convertedColor.alphaComponent
            #else
                r = 0
                g = 0
                b = 0
                self.alpha = 1
            #endif
        }
    }

    func sRGBCompand(_ v: CGFloat) -> CGFloat {
        let absV = abs(v)
        let out = absV > 0.04045 ? pow((absV + 0.055) / 1.055, 2.4) : absV / 12.92
        return v > 0 ? out : -out
    }
}
