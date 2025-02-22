//
//  Color+Dynamic.swift
//  ColorTokensKit
//

import SwiftUI

#if canImport(UIKit)
public extension Color {
    /// Initialize with light/dark mode colors
    init(
        light lightModeColor: @escaping @autoclosure () -> Color,
        dark darkModeColor: @escaping @autoclosure () -> Color
    ) {
        self.init(UIColor(
            light: UIColor(lightModeColor()),
            dark: UIColor(darkModeColor())
        ))
    }
    
    /// Initialize with light/dark mode LCH colors
    init(
        light lightModeColor: @escaping @autoclosure () -> LCHColor,
        dark darkModeColor: @escaping @autoclosure () -> LCHColor
    ) {
        self.init(UIColor(
            light: UIColor(lightModeColor().toColor()),
            dark: UIColor(darkModeColor().toColor())
        ))
    }
}
#endif 