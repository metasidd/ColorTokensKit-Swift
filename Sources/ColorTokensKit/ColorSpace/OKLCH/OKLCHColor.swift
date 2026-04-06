//
//  OKLCHColor.swift
//  ColorTokensKit
//
//  OKLCH — the polar form of OKLab.
//  Reference: https://bottosson.github.io/posts/oklab/
//

import Foundation
import SwiftUI

public struct OKLCHColor: Hashable, Equatable, Sendable {
    public let l: CGFloat  // 0..1    Perceptual lightness
    public let c: CGFloat  // 0..~0.4 Chroma
    public let h: CGFloat  // 0..360  Hue (degrees)
    public let alpha: CGFloat // 0..1

    public init(l: CGFloat = 0, c: CGFloat = 0, h: CGFloat = 0, alpha: CGFloat = 1.0) {
        self.l = l
        self.c = c
        self.h = h.normalizedHue
        self.alpha = alpha
    }

    /// Initialize from a SwiftUI Color
    public init(color: Color) {
        let oklab = RGBColor(color: color).toOKLab()
        let oklch = oklab.toOKLCH()
        l = oklch.l
        c = oklch.c
        h = oklch.h
        alpha = oklch.alpha
    }

    /// Initialize from a hex string
    public init(hex: String) {
        self.init(color: Color(hex: hex))
    }

    /// Parse "oklch(0.7 0.15 210)" format
    public init(oklchString: String) {
        let pattern = #"oklch\((\d+\.?\d*)\s+(\d+\.?\d*)\s+(\d+\.?\d*)\)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(oklchString.startIndex ..< oklchString.endIndex, in: oklchString)

        if let match = regex.firstMatch(in: oklchString, range: range) {
            let l = Double(oklchString[Range(match.range(at: 1), in: oklchString)!]) ?? 0.7
            let c = Double(oklchString[Range(match.range(at: 2), in: oklchString)!]) ?? 0.15
            let h = Double(oklchString[Range(match.range(at: 3), in: oklchString)!]) ?? 0

            self.l = max(0, min(l, 1))
            self.c = max(0, c)
            self.h = h.normalizedHue
        } else {
            l = 0.7
            c = 0.15
            h = 0
        }
        alpha = 1.0
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(l)
        hasher.combine(c)
        hasher.combine(h)
    }

    public static func == (lhs: OKLCHColor, rhs: OKLCHColor) -> Bool {
        return lhs.l == rhs.l && lhs.c == rhs.c && lhs.h == rhs.h
    }
}
