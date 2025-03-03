//
//  ColorTokens.swift
//  ColorGenerator
//
//  Created by Siddhant Mehta on 2024-06-08.
//

import SwiftUI
import ColorTokensKit

public extension Color {
    // MARK: - Foreground colors

    /// Used for primary text, selected icons, etc.
    static var foregroundPrimary: Color { Color.proGray.foregroundPrimary }

    /// Used for secondary text like subtitles, unselected icons, etc.
    static var foregroundSecondary: Color { Color.proGray.foregroundSecondary }

    /// Used for tertiary text like placeholders, disabled icons, etc.
    static var foregroundTertiary: Color { Color.proGray.foregroundTertiary }

    // MARK: - Inverted colors

    /// Used for primary text on inverted backgrounds, selected icons, etc.
    static var invertedForegroundPrimary: Color { Color.proGray.invertedForegroundPrimary }

    /// Used for secondary text on inverted backgrounds, unselected icons, etc.
    static var invertedForegroundSecondary: Color { Color.proGray.invertedForegroundSecondary }

    /// Used for tertiary text on inverted backgrounds, disabled icons, etc.
    static var invertedForegroundTertiary: Color { Color.proGray.invertedForegroundTertiary }

    // MARK: - Background colors

    /// Used for main content background. Note that this is a pure black and white color. You can customize this for your app.
    static var backgroundPrimary: Color { Color(light: Color.white, dark: Color.black) }

    /// Used for secondary backgrounds, cards, etc.
    static var backgroundSecondary: Color { Color.proGray.backgroundSecondary }

    /// Used for tertiary backgrounds, inactive buttons, etc.
    static var backgroundTertiary: Color { Color.proGray.backgroundTertiary }

    
    // MARK: - Surface colors

    /// Used for surfaces with opacity. Cards, pills, etc.
    static var surfacePrimary: Color { Color.proGray.surfacePrimary }

    /// Used for secondary surfaces with opacity. Scrims, overlays, tooltips, etc.
    static var surfaceSecondary: Color { Color.proGray.surfaceSecondary }

    /// Used for tertiary surfaces with opacity. Tooltips, popovers, etc.
    static var surfaceTertiary: Color { Color.proGray.surfaceTertiary }

    // MARK: - Inverted surface colors

    /// Used for elements that need dark backgrounds, like cards, sheets, etc.
    static var invertedSurfacePrimary: Color { Color.proGray.invertedSurfacePrimary }

    /// Used for elements that need slightly less darker backgrounds, like panels, dialogs, etc.
    static var invertedSurfaceSecondary: Color { Color.proGray.invertedSurfaceSecondary }

    // MARK: - Inverted background colors

    /// Used for main content background on dark backgrounds, app background, etc.
    static var invertedBackgroundPrimary: Color { Color.proGray.invertedBackgroundPrimary }

    /// Used for secondary content background on dark backgrounds, card background, etc.
    static var invertedBackgroundSecondary: Color { Color.proGray.invertedBackgroundSecondary }

    /// Used for tertiary content background on dark backgrounds, modal background, etc.
    static var invertedBackgroundTertiary: Color { Color.proGray.invertedBackgroundTertiary }

    // MARK: - Outline colors

    /// Used for primary outlines, borders, etc.
    static var outlinePrimary: Color { Color.proGray.outlinePrimary }

    /// Used for secondary outlines, borders, etc.
    static var outlineSecondary: Color { Color.proGray.outlineSecondary }

    /// Used for tertiary outlines, borders, etc.
    static var outlineTertiary: Color { Color.proGray.outlineTertiary }
}

public extension LCHColor {
    // MARK: - Foreground colors
    
    /// Used for primary text, selected icons, etc.
    var foregroundPrimary: Color {
        Color(light: _1000.toColor(), dark: _50.toColor())
    }

    /// Used for secondary text, unselected icons, etc.
    var foregroundSecondary: Color {
        Color(light: _800.toColor(), dark: _200.toColor())
    }

    /// Used for tertiary text, disabled icons, etc.
    var foregroundTertiary: Color {
        Color(light: _700.toColor(), dark: _300.toColor())
    }

    // MARK: - Inverted foreground colors
    
    /// Used for primary text on dark backgrounds, selected icons, etc.
    var invertedForegroundPrimary: Color { 
        Color(light: _50.toColor(), dark: _1000.toColor()) 
    }

    /// Used for secondary text on dark backgrounds, unselected icons, etc.
    var invertedForegroundSecondary: Color { 
        Color(light: _150.toColor(), dark: _800.toColor()) 
    }

    /// Used for tertiary text on dark backgrounds, disabled icons, etc.
    var invertedForegroundTertiary: Color { 
        Color(light: _250.toColor(), dark: _700.toColor()) 
    }

    // MARK: - Background colors
    
    /// Used for main content background, app background, etc.
    var backgroundPrimary: Color { 
        Color(light: _50.toColor(), dark: _1000.toColor()) 
    }

    /// Used for secondary content background, card background, etc.
    var backgroundSecondary: Color { 
        Color(light: _100.toColor(), dark: _800.toColor()) 
    }

    /// Used for tertiary content background, modal background, etc.
    var backgroundTertiary: Color { 
        Color(light: _200.toColor(), dark: _700.toColor()) 
    }
    
    // MARK: - Surface colors
    
    /// Used for primary surfaces like cards, sheets, etc.
    var surfacePrimary: Color {
        Color(light: _200.toColor(), dark: _700.toColor()).opacity(0.5)
    }

    /// Used for secondary surfaces like panels, dialogs, etc.
    var surfaceSecondary: Color {
        Color(light: _200.toColor(), dark: _700.toColor()).opacity(0.3)
    }

    /// Used for tertiary surfaces like tooltips, popovers, etc.
    var surfaceTertiary: Color {
        Color(light: _200.toColor(), dark: _700.toColor()).opacity(0.1)
    }

    // MARK: - Inverted surface colors
    
    /// Used for primary surfaces on dark backgrounds like cards, sheets, etc.
    var invertedSurfacePrimary: Color {
        Color(light: _400.toColor(), dark: _600.toColor()).opacity(0.4)
    }

    /// Used for secondary surfaces on dark backgrounds like panels, dialogs, etc.
    var invertedSurfaceSecondary: Color {
        Color(light: _400.toColor(), dark: _600.toColor()).opacity(0.2)
    }

    // MARK: - Inverted background colors
    
    /// Used for main content background on dark backgrounds, app background, etc.
    var invertedBackgroundPrimary: Color { 
        Color(light: _900.toColor(), dark: _50.toColor()) 
    }

    /// Used for secondary content background on dark backgrounds, card background, etc.
    var invertedBackgroundSecondary: Color { 
        Color(light: _800.toColor(), dark: _150.toColor()) 
    }

    /// Used for tertiary content background on dark backgrounds, modal background, etc.
    var invertedBackgroundTertiary: Color { 
        Color(light: _650.toColor(), dark: _250.toColor()) 
    }

    // MARK: - Outline colors
    
    /// Used for primary outlines, borders, etc.
    var outlinePrimary: Color { 
        Color(light: _300.toColor(), dark: _700.toColor()) 
    }

    /// Used for secondary outlines, borders, etc.
    var outlineSecondary: Color { 
        Color(light: _200.toColor(), dark: _800.toColor())
    }

    /// Used for tertiary outlines, borders, etc.
    var outlineTertiary: Color { 
        Color(light: _100.toColor(), dark: _900.toColor()) 
    }
}
