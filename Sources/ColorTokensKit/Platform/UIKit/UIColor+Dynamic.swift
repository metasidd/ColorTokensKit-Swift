//
//  UIColor+Dynamic.swift
//  ColorTokensKit
//

#if canImport(UIKit) && !os(watchOS)
    import UIKit

    public extension UIColor {
        /// Initialize with light/dark mode colors
        convenience init(
            light lightModeColor: @escaping @autoclosure () -> UIColor,
            dark darkModeColor: @escaping @autoclosure () -> UIColor
        ) {
            self.init { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .light:
                    return lightModeColor()
                case .dark:
                    return darkModeColor()
                default:
                    return lightModeColor()
                }
            }
        }
    }
#endif
