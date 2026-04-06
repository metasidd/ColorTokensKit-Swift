//
//  LCH+Utils.swift
//  ColorTokensKit
//
//  Created by Siddhant Mehta on 2025-02-23.
//

import SwiftUI

public extension Color {

    /// Converts the `LCHColor` to a hexadecimal string representation.
    func getHexString() -> String {
        let rgb = RGBColor(color: self)
        let r = Double(max(0, min(rgb.r, 1)))
        let g = Double(max(0, min(rgb.g, 1)))
        let b = Double(max(0, min(rgb.b, 1)))
        let a = Double(max(0, min(rgb.alpha, 1)))

        if a != 1.0 {
            return String(format: "%02lX%02lX%02lX%02lX", lround(r * 255), lround(g * 255), lround(b * 255), lround(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lround(r * 255), lround(g * 255), lround(b * 255))
        }
    }
    
    /// Get LCH string representation
    func getLCHString() -> String {
        let lchColor = LCHColor(color: self)
        return "L:\(Int(lchColor.l)) C:\(Int(lchColor.c)) H:\(Int(lchColor.h))"
    }
    
}
