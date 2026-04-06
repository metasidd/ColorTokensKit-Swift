//
//  OKLCHColor+Manipulation.swift
//  ColorTokensKit
//

import Foundation
import SwiftUI

public extension OKLCHColor {
    /// Creates a new Color with adjusted OKLCH values
    func getColor(
        l: CGFloat? = nil,
        c: CGFloat? = nil,
        h: CGFloat? = nil,
        alpha: CGFloat? = nil
    ) -> Color {
        return OKLCHColor(
            l: l ?? self.l,
            c: c ?? 0,
            h: h ?? 0,
            alpha: alpha ?? self.alpha
        ).toColor()
    }

    /// Gets a color at specified index in the ramp
    func getColor(at index: Int) -> OKLCHColor {
        let isGrayscale = c <= 0.005
        let ramp = ColorRampGenerator.shared.getOKLCHColorRamp(forHue: Double(h), isGrayscale: isGrayscale)
        let clampedIndex = min(index, ramp.count - 1)
        return ramp[clampedIndex]
    }

    /// Creates primary color for given hue
    static func getPrimaryColor(forHue hue: Double, isGrayscale: Bool = false) -> OKLCHColor {
        let steps = ColorConstants.rampStops
        let dataPoints = ColorRampGenerator.shared.getOKLCHColorRamp(forHue: hue, steps: steps, isGrayscale: isGrayscale)
        return dataPoints[Int(steps / 2) - 2]
    }
}
