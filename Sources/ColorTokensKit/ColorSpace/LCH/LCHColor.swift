//
//  LCHColor.swift
//
//  Original repo: https://github.com/timrwood/ColorSpaces
//

import Foundation
import SwiftUI

public struct LCHColor: Hashable, Equatable {
    public let l: CGFloat // 0..100. Lightness
    public let c: CGFloat // 0..128. Chroma
    public let h: CGFloat // 0..360. Hue
    public let alpha: CGFloat // 0..1

    public func hash(into hasher: inout Hasher) {
        hasher.combine(l)
        hasher.combine(c)
        hasher.combine(h)
    }

    public static func == (lhs: LCHColor, rhs: LCHColor) -> Bool {
        return lhs.l == rhs.l &&
            lhs.c == rhs.c &&
            lhs.h == rhs.h
    }

    public init(
        l: CGFloat = 0,
        c: CGFloat = 0,
        h: CGFloat = 0,
        alpha: CGFloat = 1.0
    ) {
        self.l = l
        self.c = c
        self.h = h.normalizedHue
        self.alpha = alpha
    }

    public init(color: Color) {
        let lchColor = RGBColor(color: color).toLCH()
        l = lchColor.l
        c = lchColor.c
        h = lchColor.h.normalizedHue
        alpha = lchColor.alpha
    }

    /// Parse "lch(97% 4.3 0)" format
    public init(lchString: String) {
        let pattern = #"lch\((\d+\.?\d*)%\s+(\d+\.?\d*)\s+(\d+\.?\d*)\)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(lchString.startIndex ..< lchString.endIndex, in: lchString)

        if let match = regex.firstMatch(in: lchString, range: range) {
            let l = Double(lchString[Range(match.range(at: 1), in: lchString)!]) ?? 70
            let c = Double(lchString[Range(match.range(at: 2), in: lchString)!]) ?? 30
            let h = Double(lchString[Range(match.range(at: 3), in: lchString)!]) ?? 0

            self.l = max(0, min(l, 100))
            self.c = max(0, min(c, 128))
            self.h = h.normalizedHue
        } else {
            l = 70 // Default lightness
            c = 30 // Default chroma
            h = 0 // Default hue
        }

        alpha = 1.0
    }
    
    /// Initialize a LCHColor from a hex string. 
    public init(hex: String) {
        let color = Color(hex: hex)
        self.init(color: color)
    }
}
