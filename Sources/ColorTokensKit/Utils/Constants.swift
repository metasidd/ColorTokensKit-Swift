//
//  Constants.swift
//
//
//  Created by Siddhant Mehta on 2024-06-10.
//

import Foundation

enum ColorConstants {
    // Color space constants
    static let RAD_TO_DEG = 180 / Double.pi
    static let LAB_E: CGFloat = 0.008856
    static let LAB_16_116: CGFloat = 0.1379310
    static let LAB_K_116: CGFloat = 7.787036
    static let LAB_X: CGFloat = 0.95047
    static let LAB_Y: CGFloat = 1
    static let LAB_Z: CGFloat = 1.08883
    
    // Number of stops in a color ramp
    static let rampStops: Int = 20
    
    // Precision constants for consistent rounding
    static let huePrecision: Int = 2  // Decimal places for hue values
    static let valuePrecision: Int = 2  // Decimal places for general values
    static let interpolationPrecision: Int = 3  // Decimal places for interpolation factors
}
