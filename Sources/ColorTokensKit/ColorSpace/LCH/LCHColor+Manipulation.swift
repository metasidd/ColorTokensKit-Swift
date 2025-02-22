//
//  LCHColor+Manipulation.swift
//  ColorTokensKit
//
//  Created by Siddhant Mehta on 2024-07-29.
//

import Foundation
import SwiftUI

public extension LCHColor {
    /// Creates a new Color with adjusted LCH values
    func getColor(
        l: CGFloat? = nil,
        c: CGFloat? = nil,
        h: CGFloat? = nil,
        alpha: CGFloat? = nil
    ) -> Color {
        return LCHColor(
            l: l ?? self.l,
            c: c ?? 0,
            h: h ?? 0,
            alpha: alpha ?? self.alpha
        ).toColor()
    }

    /// Gets a color at specified index in the ramp
    func getColor(at index: Int) -> LCHColor {
        let rampGenerator = ColorRampGenerator()
        let isGrayscale = c <= 0.1
        let ramp = rampGenerator.getColorRamp(forHue: h, isGrayscale: isGrayscale)
        let clampedIndex = min(index, ramp.count - 1)
        return ramp[clampedIndex]
    }

    /// Creates primary color for given hue
    static func getPrimaryColor(forHue hue: Double, isGrayscale: Bool = false) -> LCHColor {
        let steps = ColorConstants.rampStops
        let rampGenerator = ColorRampGenerator()
        let dataPoints = rampGenerator.getColorRamp(forHue: hue, steps: steps, isGrayscale: isGrayscale)
        let primaryColor = dataPoints[Int(steps / 2) - 2]

        return LCHColor(
            l: primaryColor.l,
            c: primaryColor.c,
            h: primaryColor.h,
            alpha: primaryColor.alpha
        )
    }
}
