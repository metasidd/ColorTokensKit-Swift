//
//  Double+Ext.swift
//  ColorTokensKit
//
//  Created by Siddhant Mehta on 2025-03-04.
//
import Foundation

public extension Double {
    /// Normalizes a hue value to the range 0-359.xx with consistent precision
    var normalizedHue: Double {
        // First ensure the value is in the 0-360 range
        let normalized = (self.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        // Then round to specified decimal places for consistency
        return normalized.rounded(toPlaces: ColorConstants.huePrecision)
    }
    
    /// Rounds a value to a specific number of decimal places
    /// - Parameter places: Number of decimal places to round to
    /// - Returns: Rounded value
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
