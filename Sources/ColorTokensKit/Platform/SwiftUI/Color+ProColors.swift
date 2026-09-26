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
    // OKLCH hues. Each name sits at (or, where neighbors crowd it, near) the median hue
    // that Radix, Tailwind, Material, Open Color, Ant, Carbon, Apple, CSS and the XKCD survey give it.
    // Pro color getters
    static var proGray: ProColor { .primary(forHue: 0, isGrayscale: true) }
    static var proPink: ProColor { .primary(forHue: 3) }
    static var proRuby: ProColor { .primary(forHue: 14) }
    static var proRed: ProColor { .primary(forHue: 24) }
    static var proTomato: ProColor { .primary(forHue: 34) }
    static var proOrange: ProColor { .primary(forHue: 49) }
    static var proBrown: ProColor { .primary(forHue: 59) }
    static var proGold: ProColor { .primary(forHue: 78) }
    static var proYellow: ProColor { .primary(forHue: 99) }
    static var proOlive: ProColor { .primary(forHue: 110) }
    static var proLime: ProColor { .primary(forHue: 128) }
    static var proGrass: ProColor { .primary(forHue: 138) }
    static var proGreen: ProColor { .primary(forHue: 148) }
    static var proJade: ProColor { .primary(forHue: 162) }
    static var proMint: ProColor { .primary(forHue: 178) }
    static var proTeal: ProColor { .primary(forHue: 188) }
    static var proCyan: ProColor { .primary(forHue: 209) }
    static var proSky: ProColor { .primary(forHue: 229) }
    static var proBlue: ProColor { .primary(forHue: 251) }
    static var proCobalt: ProColor { .primary(forHue: 261) }
    static var proIndigo: ProColor { .primary(forHue: 273) }
    static var proIris: ProColor { .primary(forHue: 283) }
    static var proViolet: ProColor { .primary(forHue: 293) }
    static var proPurple: ProColor { .primary(forHue: 306) }
    static var proPlum: ProColor { .primary(forHue: 327) }
    static var proMagenta: ProColor { .primary(forHue: 345) }

    // Dictionary of all pro colors
    static var allProHues: [String: ProColor] {
        [
            "Gray": proGray,
            "Pink": proPink,
            "Ruby": proRuby,
            "Red": proRed,
            "Tomato": proTomato,
            "Orange": proOrange,
            "Brown": proBrown,
            "Gold": proGold,
            "Yellow": proYellow,
            "Olive": proOlive,
            "Lime": proLime,
            "Grass": proGrass,
            "Green": proGreen,
            "Jade": proJade,
            "Mint": proMint,
            "Teal": proTeal,
            "Cyan": proCyan,
            "Sky": proSky,
            "Blue": proBlue,
            "Cobalt": proCobalt,
            "Indigo": proIndigo,
            "Iris": proIris,
            "Violet": proViolet,
            "Purple": proPurple,
            "Plum": proPlum,
            "Magenta": proMagenta,
        ]
    }
}
