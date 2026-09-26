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
    static var proGray: ProColor { .primary(forHue: 0, isGrayscale: true) }
    static var proPink: ProColor { .primary(forHue: 0) }
    static var proRuby: ProColor { .primary(forHue: 10) }
    static var proRed: ProColor { .primary(forHue: 20) }
    static var proTomato: ProColor { .primary(forHue: 30) }
    static var proCoral: ProColor { .primary(forHue: 40) }
    static var proOrange: ProColor { .primary(forHue: 50) }
    static var proBrown: ProColor { .primary(forHue: 60) }
    static var proAmber: ProColor { .primary(forHue: 70) }
    static var proGold: ProColor { .primary(forHue: 80) }
    static var proMustard: ProColor { .primary(forHue: 90) }
    static var proYellow: ProColor { .primary(forHue: 100) }
    static var proOlive: ProColor { .primary(forHue: 110) }
    static var proChartreuse: ProColor { .primary(forHue: 120) }
    static var proLime: ProColor { .primary(forHue: 130) }
    static var proGrass: ProColor { .primary(forHue: 140) }
    static var proGreen: ProColor { .primary(forHue: 150) }
    static var proJade: ProColor { .primary(forHue: 160) }
    static var proEmerald: ProColor { .primary(forHue: 170) }
    static var proMint: ProColor { .primary(forHue: 180) }
    static var proTeal: ProColor { .primary(forHue: 190) }
    static var proTurquoise: ProColor { .primary(forHue: 200) }
    static var proCyan: ProColor { .primary(forHue: 210) }
    static var proCerulean: ProColor { .primary(forHue: 220) }
    static var proSky: ProColor { .primary(forHue: 230) }
    static var proAzure: ProColor { .primary(forHue: 240) }
    static var proBlue: ProColor { .primary(forHue: 250) }
    static var proCobalt: ProColor { .primary(forHue: 260) }
    static var proIndigo: ProColor { .primary(forHue: 270) }
    static var proIris: ProColor { .primary(forHue: 280) }
    static var proViolet: ProColor { .primary(forHue: 290) }
    static var proGrape: ProColor { .primary(forHue: 300) }
    static var proPurple: ProColor { .primary(forHue: 310) }
    static var proOrchid: ProColor { .primary(forHue: 320) }
    static var proPlum: ProColor { .primary(forHue: 330) }
    static var proMagenta: ProColor { .primary(forHue: 340) }
    static var proRose: ProColor { .primary(forHue: 350) }

    // Dictionary of all pro colors
    static var allProHues: [String: ProColor] {
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
