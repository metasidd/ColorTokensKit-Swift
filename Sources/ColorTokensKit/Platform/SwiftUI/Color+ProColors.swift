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
    // 36 OKLCH hues, one every 10°, so every pair of neighbors is equally far apart. The 25 names from 2.0 each
    // moved 5° or less from 2.0's hue, which sat at the median hue that Radix, Tailwind, Material, Open Color, Ant,
    // Carbon, Apple, CSS and the XKCD survey give the name. Coral, amber, mustard, chartreuse, emerald, turquoise,
    // cerulean, azure, grape, orchid and rose fill the gaps between them.
    // Pro color getters
    static var proGray: ProTheme { .primary(forHue: 0, isGrayscale: true) }
    static var proPink: ProTheme { .primary(forHue: 0) }
    static var proRuby: ProTheme { .primary(forHue: 10) }
    static var proRed: ProTheme { .primary(forHue: 20) }
    static var proTomato: ProTheme { .primary(forHue: 30) }
    static var proCoral: ProTheme { .primary(forHue: 40) }
    static var proOrange: ProTheme { .primary(forHue: 50) }
    static var proBrown: ProTheme { .primary(forHue: 60) }
    static var proAmber: ProTheme { .primary(forHue: 70) }
    static var proGold: ProTheme { .primary(forHue: 80) }
    static var proMustard: ProTheme { .primary(forHue: 90) }
    static var proYellow: ProTheme { .primary(forHue: 100) }
    static var proOlive: ProTheme { .primary(forHue: 110) }
    static var proChartreuse: ProTheme { .primary(forHue: 120) }
    static var proLime: ProTheme { .primary(forHue: 130) }
    static var proGrass: ProTheme { .primary(forHue: 140) }
    static var proGreen: ProTheme { .primary(forHue: 150) }
    static var proJade: ProTheme { .primary(forHue: 160) }
    static var proEmerald: ProTheme { .primary(forHue: 170) }
    static var proMint: ProTheme { .primary(forHue: 180) }
    static var proTeal: ProTheme { .primary(forHue: 190) }
    static var proTurquoise: ProTheme { .primary(forHue: 200) }
    static var proCyan: ProTheme { .primary(forHue: 210) }
    static var proCerulean: ProTheme { .primary(forHue: 220) }
    static var proSky: ProTheme { .primary(forHue: 230) }
    static var proAzure: ProTheme { .primary(forHue: 240) }
    static var proBlue: ProTheme { .primary(forHue: 250) }
    static var proCobalt: ProTheme { .primary(forHue: 260) }
    static var proIndigo: ProTheme { .primary(forHue: 270) }
    static var proIris: ProTheme { .primary(forHue: 280) }
    static var proViolet: ProTheme { .primary(forHue: 290) }
    static var proGrape: ProTheme { .primary(forHue: 300) }
    static var proPurple: ProTheme { .primary(forHue: 310) }
    static var proOrchid: ProTheme { .primary(forHue: 320) }
    static var proPlum: ProTheme { .primary(forHue: 330) }
    static var proMagenta: ProTheme { .primary(forHue: 340) }
    static var proRose: ProTheme { .primary(forHue: 350) }

    // Dictionary of all pro colors
    static var allProHues: [String: ProTheme] {
        [
            "Gray": proGray,
            "Pink": proPink,
            "Ruby": proRuby,
            "Red": proRed,
            "Tomato": proTomato,
            "Coral": proCoral,
            "Orange": proOrange,
            "Brown": proBrown,
            "Amber": proAmber,
            "Gold": proGold,
            "Mustard": proMustard,
            "Yellow": proYellow,
            "Olive": proOlive,
            "Chartreuse": proChartreuse,
            "Lime": proLime,
            "Grass": proGrass,
            "Green": proGreen,
            "Jade": proJade,
            "Emerald": proEmerald,
            "Mint": proMint,
            "Teal": proTeal,
            "Turquoise": proTurquoise,
            "Cyan": proCyan,
            "Cerulean": proCerulean,
            "Sky": proSky,
            "Azure": proAzure,
            "Blue": proBlue,
            "Cobalt": proCobalt,
            "Indigo": proIndigo,
            "Iris": proIris,
            "Violet": proViolet,
            "Grape": proGrape,
            "Purple": proPurple,
            "Orchid": proOrchid,
            "Plum": proPlum,
            "Magenta": proMagenta,
            "Rose": proRose,
        ]
    }
}
