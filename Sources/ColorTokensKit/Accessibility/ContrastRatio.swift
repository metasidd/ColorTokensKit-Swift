//
//  ContrastRatio.swift
//  ColorTokensKit
//

import Foundation
import SwiftUI

/// Methods for computing color contrast
public enum ContrastMethod {
    /// WCAG 2.x luminance contrast ratio (range 1–21)
    case wcag2
    /// APCA (Accessible Perceptual Contrast Algorithm) as proposed for WCAG 3.0.
    /// Returns a signed Lc value: positive = dark text on light background,
    /// negative = light text on dark background. Typical threshold ~60 for body text.
    case apca
}

public extension RGBColor {
    /// Relative luminance per WCAG 2.x definition (0 = darkest, 1 = lightest)
    var relativeLuminance: CGFloat {
        func linearize(_ v: CGFloat) -> CGFloat {
            return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
    }

    /// Contrast ratio between two colors using the specified method
    func contrastRatio(to other: RGBColor, method: ContrastMethod = .wcag2) -> CGFloat {
        switch method {
        case .wcag2:
            return wcag2ContrastRatio(to: other)
        case .apca:
            return apcaContrast(text: other)
        }
    }

    // MARK: - WCAG 2.x

    /// WCAG 2.x contrast ratio (1–21). Always returns the ratio with the lighter
    /// color in the numerator, so the result is always >= 1.
    private func wcag2ContrastRatio(to other: RGBColor) -> CGFloat {
        let l1 = relativeLuminance
        let l2 = other.relativeLuminance
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    // MARK: - APCA

    /// APCA contrast value (Lc). `self` is the background, `other` is the text.
    /// Positive Lc = dark text on light bg. Negative Lc = light text on dark bg.
    /// Based on APCA-W3 0.0.98G-4g (Silver/WCAG 3.0 candidate).
    private func apcaContrast(text: RGBColor) -> CGFloat {
        // Estimated screen luminance using sRGB coefficients with APCA exponent
        func screenLuminance(_ color: RGBColor) -> CGFloat {
            let rLin = pow(color.r, 2.4)
            let gLin = pow(color.g, 2.4)
            let bLin = pow(color.b, 2.4)
            return 0.2126729 * rLin + 0.7151522 * gLin + 0.0721750 * bLin
        }

        let bgY = screenLuminance(self)
        let txtY = screenLuminance(text)

        // Soft clamp near black
        let bgYc = bgY > 0.022 ? bgY : bgY + pow(0.022 - bgY, 1.414)
        let txtYc = txtY > 0.022 ? txtY : txtY + pow(0.022 - txtY, 1.414)

        // SAPC (S-Luv Accessible Perceptual Contrast)
        let contrast: CGFloat
        if bgYc > txtYc {
            // Light background, dark text (positive polarity)
            contrast = (pow(bgYc, 0.56) - pow(txtYc, 0.57)) * 1.14
        } else {
            // Dark background, light text (negative polarity)
            contrast = (pow(bgYc, 0.65) - pow(txtYc, 0.62)) * 1.14
        }

        // Low contrast clamp
        if abs(contrast) < 0.1 {
            return 0
        }

        // Scale to Lc value
        if contrast > 0 {
            return (contrast - 0.027) * 100
        } else {
            return (contrast + 0.027) * 100
        }
    }
}

public extension LCHColor {
    /// Contrast ratio between two LCH colors
    func contrastRatio(to other: LCHColor, method: ContrastMethod = .wcag2) -> CGFloat {
        return toRGB().contrastRatio(to: other.toRGB(), method: method)
    }
}

public extension Color {
    /// Contrast ratio between two SwiftUI colors
    func contrastRatio(to other: Color, method: ContrastMethod = .wcag2) -> CGFloat {
        return toRGB().contrastRatio(to: other.toRGB(), method: method)
    }
}
