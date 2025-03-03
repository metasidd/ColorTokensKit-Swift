//
//  NSColor+Dynamic.swift
//  ColorTokensKit
//

#if canImport(AppKit)
import AppKit

public extension NSColor {
	convenience init(
		light lightModeColor: @escaping @autoclosure () -> NSColor,
		dark darkModeColor: @escaping @autoclosure () -> NSColor
	) {
		self.init(name: nil) { appearance in
			if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
				return darkModeColor()
			} else {
				return lightModeColor()
			}
		}
	}
}
#endif
