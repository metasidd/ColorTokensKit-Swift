//
// Color+ProColors.swift
// ColorTokensKit
//
// Defines the professional color set backed by OKLCH.
// These colors serve as the foundation for the design system,
// offering a comprehensive palette of harmonious colors.
//
// Each color is carefully tuned to:
// - Maintain perceptual uniformity
// - Ensure accessibility
// - Provide consistent visual weight
//

import Foundation
import SwiftUI

public extension Color {
    // Pro color getters
    static var proGray: ProColor { .primary(forHue: 0, isGrayscale: true) }
    static var proPink: ProColor { .primary(forHue: 5) }
    static var proRed: ProColor { .primary(forHue: 10) }
    static var proTomato: ProColor { .primary(forHue: 20) }
    static var proOrange: ProColor { .primary(forHue: 35) }
    static var proBrown: ProColor { .primary(forHue: 50) }
    static var proGold: ProColor { .primary(forHue: 70) }
    static var proYellow: ProColor { .primary(forHue: 85) }
    static var proLime: ProColor { .primary(forHue: 100) }
    static var proOlive: ProColor { .primary(forHue: 110) }
    static var proGrass: ProColor { .primary(forHue: 125) }
    static var proGreen: ProColor { .primary(forHue: 140) }
    static var proMint: ProColor { .primary(forHue: 160) }
    static var proCyan: ProColor { .primary(forHue: 175) }
    static var proTeal: ProColor { .primary(forHue: 190) }
    static var proBlue: ProColor { .primary(forHue: 210) }
    static var proSky: ProColor { .primary(forHue: 235) }
    static var proCobalt: ProColor { .primary(forHue: 250) }
    static var proIndigo: ProColor { .primary(forHue: 270) }
    static var proIris: ProColor { .primary(forHue: 292.5) }
    static var proPurple: ProColor { .primary(forHue: 310) }
    static var proViolet: ProColor { .primary(forHue: 325) }
    static var proPlum: ProColor { .primary(forHue: 342.5) }
    static var proRuby: ProColor { .primary(forHue: 355) }

    // Dictionary of all pro colors
    static var allProHues: [String: ProColor] {
        [
            "Gray": proGray,
            "Pink": proPink,
            "Red": proRed,
            "Tomato": proTomato,
            "Orange": proOrange,
            "Brown": proBrown,
            "Gold": proGold,
            "Yellow": proYellow,
            "Lime": proLime,
            "Olive": proOlive,
            "Grass": proGrass,
            "Green": proGreen,
            "Mint": proMint,
            "Cyan": proCyan,
            "Teal": proTeal,
            "Blue": proBlue,
            "Sky": proSky,
            "Indigo": proIndigo,
            "Iris": proIris,
            "Purple": proPurple,
            "Violet": proViolet,
            "Plum": proPlum,
            "Ruby": proRuby,
        ]
    }
}
