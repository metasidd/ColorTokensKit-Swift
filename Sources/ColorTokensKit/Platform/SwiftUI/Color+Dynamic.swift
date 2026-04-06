//
//  Color+Dynamic.swift
//  ColorTokensKit
//

import SwiftUI

#if canImport(AppKit)
import AppKit
fileprivate typealias NSorUIColor = NSColor

#elseif canImport(UIKit) && !os(watchOS)
import UIKit
fileprivate typealias NSorUIColor = UIColor

#endif

public extension Color {
    /// Initialize with light/dark mode colors
    init(
        light lightModeColor: @escaping @autoclosure () -> Color,
        dark darkModeColor: @escaping @autoclosure () -> Color
    ) {
        #if os(watchOS)
        // watchOS always uses dark appearance
        self = darkModeColor()
        #else
        self.init(NSorUIColor(
            light: NSorUIColor(lightModeColor()),
            dark: NSorUIColor(darkModeColor())
        ))
        #endif
    }

    /// Initialize with light/dark mode LCH colors
    init(
        light lightModeColor: @escaping @autoclosure () -> LCHColor,
        dark darkModeColor: @escaping @autoclosure () -> LCHColor
    ) {
        #if os(watchOS)
        // watchOS always uses dark appearance
        self = darkModeColor().toColor()
        #else
        self.init(NSorUIColor(
            light: NSorUIColor(lightModeColor().toColor()),
            dark: NSorUIColor(darkModeColor().toColor())
        ))
        #endif
    }
}
