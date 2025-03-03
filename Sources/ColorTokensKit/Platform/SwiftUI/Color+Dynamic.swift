//
//  Color+Dynamic.swift
//  ColorTokensKit
//

import SwiftUI

#if canImport(AppKit)
import AppKit
fileprivate typealias NSorUIColor = NSColor

#elseif canImport(UIKit)
import UIKit
fileprivate typealias NSorUIColor = UIColor

#endif

public extension Color {
    /// Initialize with light/dark mode colors for iOS
    init(
        light lightModeColor: @escaping @autoclosure () -> Color,
        dark darkModeColor: @escaping @autoclosure () -> Color
    ) {
        self.init(NSorUIColor(
            light: NSorUIColor(lightModeColor()),
            dark: NSorUIColor(darkModeColor())
        ))
    }

    /// Initialize with light/dark mode LCH colors for iOS
    init(
        light lightModeColor: @escaping @autoclosure () -> LCHColor,
        dark darkModeColor: @escaping @autoclosure () -> LCHColor
    ) {
        self.init(NSorUIColor(
            light: NSorUIColor(lightModeColor().toColor()),
            dark: NSorUIColor(darkModeColor().toColor())
        ))
    }
}
