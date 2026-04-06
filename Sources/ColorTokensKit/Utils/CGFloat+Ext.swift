//
//  CGFloat+Ext.swift
//  ColorTokensKit
//
//  Created by Siddhant Mehta on 2025-03-04.
//
import Foundation
import CoreGraphics

/// Apply sRGB gamma curve (linear → sRGB). Shared by XYZ and OKLab conversions.
func linearToSRGB(_ v: CGFloat) -> CGFloat {
    let absV = abs(v)
    let out = absV > 0.0031308 ? 1.055 * pow(absV, 1.0 / 2.4) - 0.055 : absV * 12.92
    return v > 0 ? out : -out
}

public extension CGFloat {
    /// Normalizes a hue value to the range 0-359.xx with consistent precision
    var normalizedHue: CGFloat {
        // Ensure the value is in the 0-360 range
        let normalized = (self.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return normalized.rounded(to: ColorConstants.huePrecision)
    }
    
    /// Rounds a value to a specific number of decimal places
    /// - Parameter places: Number of decimal places to round to
    /// - Returns: Rounded value
    func rounded(to places: Int) -> CGFloat {
        let multiplier = pow(10.0, CGFloat(places))
        return (self * multiplier).rounded() / multiplier
    }
} 
