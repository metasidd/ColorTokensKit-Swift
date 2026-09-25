//
//  Color+Resolving.swift
//  ColorTokensKitTests
//
//  Test helpers: resolve a Color for one appearance and compare colors the way a
//  screen would, as 8-bit hex.
//

@testable import ColorTokensKit
import SwiftUI

extension Color {
    /// This color as 8-bit sRGB hex in one appearance, e.g. "#3c80c4".
    func hex(_ appearance: Appearance = .light) -> String {
        resolvedOKLCH(for: appearance).hex
    }
}

extension OKLCHColor {
    /// This color as 8-bit sRGB hex, e.g. "#3c80c4".
    var hex: String {
        let rgb = toRGB()
        return String(
            format: "#%02x%02x%02x",
            Int((rgb.r * 255).rounded()), Int((rgb.g * 255).rounded()), Int((rgb.b * 255).rounded())
        )
    }
}
