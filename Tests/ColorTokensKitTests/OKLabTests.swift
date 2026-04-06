@testable import ColorTokensKit
import XCTest
import SwiftUI

final class OKLabTests: XCTestCase {

    let tolerance: CGFloat = 0.01

    // MARK: - Reference Values

    func testWhiteInOKLab() {
        let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let oklab = white.toOKLab()
        XCTAssertEqual(oklab.l, 1.0, accuracy: tolerance, "White should have L=1")
        XCTAssertEqual(oklab.a, 0.0, accuracy: tolerance, "White should have a=0")
        XCTAssertEqual(oklab.b, 0.0, accuracy: tolerance, "White should have b=0")
    }

    func testBlackInOKLab() {
        let black = RGBColor(r: 0, g: 0, b: 0, alpha: 1)
        let oklab = black.toOKLab()
        XCTAssertEqual(oklab.l, 0.0, accuracy: tolerance, "Black should have L=0")
        XCTAssertEqual(oklab.a, 0.0, accuracy: tolerance, "Black should have a=0")
        XCTAssertEqual(oklab.b, 0.0, accuracy: tolerance, "Black should have b=0")
    }

    func testRedInOKLab() {
        let red = RGBColor(r: 1, g: 0, b: 0, alpha: 1)
        let oklab = red.toOKLab()
        // Red: L≈0.628, a≈0.225, b≈0.126
        XCTAssertEqual(oklab.l, 0.628, accuracy: 0.01)
        XCTAssertGreaterThan(oklab.a, 0, "Red should have positive a (red-green axis)")
        XCTAssertGreaterThan(oklab.b, 0, "Red should have positive b (yellow-blue axis)")
    }

    func testGrayInOKLab() {
        let gray = RGBColor(r: 0.5, g: 0.5, b: 0.5, alpha: 1)
        let oklab = gray.toOKLab()
        XCTAssertEqual(oklab.a, 0.0, accuracy: tolerance, "Gray should have a≈0")
        XCTAssertEqual(oklab.b, 0.0, accuracy: tolerance, "Gray should have b≈0")
        XCTAssertGreaterThan(oklab.l, 0, "Gray L should be > 0")
        XCTAssertLessThan(oklab.l, 1, "Gray L should be < 1")
    }

    // MARK: - Round-Trip

    func testRGBRoundTripThroughOKLab() {
        let testColors: [(CGFloat, CGFloat, CGFloat, String)] = [
            (1.0, 0.0, 0.0, "red"),
            (0.0, 1.0, 0.0, "green"),
            (0.0, 0.0, 1.0, "blue"),
            (1.0, 1.0, 0.0, "yellow"),
            (0.0, 1.0, 1.0, "cyan"),
            (1.0, 0.0, 1.0, "magenta"),
            (1.0, 1.0, 1.0, "white"),
            (0.0, 0.0, 0.0, "black"),
            (0.5, 0.5, 0.5, "gray"),
            (0.8, 0.2, 0.6, "arbitrary"),
        ]

        for (r, g, b, name) in testColors {
            let original = RGBColor(r: r, g: g, b: b, alpha: 1)
            let roundTrip = original.toOKLab().toRGB()
            XCTAssertEqual(roundTrip.r, original.r, accuracy: tolerance,
                           "OKLab round-trip failed for \(name) R")
            XCTAssertEqual(roundTrip.g, original.g, accuracy: tolerance,
                           "OKLab round-trip failed for \(name) G")
            XCTAssertEqual(roundTrip.b, original.b, accuracy: tolerance,
                           "OKLab round-trip failed for \(name) B")
        }
    }

    func testRGBRoundTripThroughOKLCH() {
        let testColors: [(CGFloat, CGFloat, CGFloat, String)] = [
            (1.0, 0.0, 0.0, "red"),
            (0.0, 1.0, 0.0, "green"),
            (0.0, 0.0, 1.0, "blue"),
            (0.5, 0.5, 0.5, "gray"),
            (0.3, 0.7, 0.9, "arbitrary"),
        ]

        for (r, g, b, name) in testColors {
            let original = RGBColor(r: r, g: g, b: b, alpha: 1)
            let roundTrip = original.toOKLCH().toRGB()
            XCTAssertEqual(roundTrip.r, original.r, accuracy: tolerance,
                           "OKLCH round-trip failed for \(name) R")
            XCTAssertEqual(roundTrip.g, original.g, accuracy: tolerance,
                           "OKLCH round-trip failed for \(name) G")
            XCTAssertEqual(roundTrip.b, original.b, accuracy: tolerance,
                           "OKLCH round-trip failed for \(name) B")
        }
    }

    // MARK: - Alpha Preservation

    func testAlphaPreservedThroughOKLab() {
        let original = RGBColor(r: 0.5, g: 0.5, b: 0.5, alpha: 0.42)
        let oklab = original.toOKLab()
        XCTAssertEqual(oklab.alpha, 0.42, accuracy: 0.001)
        let backToRGB = oklab.toRGB()
        XCTAssertEqual(backToRGB.alpha, 0.42, accuracy: 0.001)
    }

    // MARK: - OKLCH Specific

    func testOKLCHHueNormalization() {
        let color1 = OKLCHColor(l: 0.5, c: 0.1, h: -30)
        XCTAssertTrue(color1.h >= 0 && color1.h < 360)

        let color2 = OKLCHColor(l: 0.5, c: 0.1, h: 400)
        XCTAssertTrue(color2.h >= 0 && color2.h < 360)

        let color3 = OKLCHColor(l: 0.5, c: 0.1, h: 360)
        XCTAssertEqual(color3.h, 0.0, accuracy: 0.01)
    }

    func testOKLCHFromString() {
        let color = OKLCHColor(oklchString: "oklch(0.7 0.15 210)")
        XCTAssertEqual(color.l, 0.7, accuracy: 0.01)
        XCTAssertEqual(color.c, 0.15, accuracy: 0.01)
        XCTAssertEqual(color.h, 210.0, accuracy: 0.01)
    }

    func testOKLCHFromInvalidStringUsesDefaults() {
        let color = OKLCHColor(oklchString: "not a color")
        XCTAssertEqual(color.l, 0.7, accuracy: 0.01)
        XCTAssertEqual(color.c, 0.15, accuracy: 0.01)
        XCTAssertEqual(color.h, 0.0, accuracy: 0.01)
    }

    // MARK: - OKLCH Interpolation

    func testOKLCHLerpMidpoint() {
        let a = OKLCHColor(l: 0.2, c: 0.1, h: 100)
        let b = OKLCHColor(l: 0.8, c: 0.3, h: 200)
        let mid = a.lerp(b, t: 0.5)
        XCTAssertEqual(mid.l, 0.5, accuracy: 0.01)
        XCTAssertEqual(mid.c, 0.2, accuracy: 0.01)
        XCTAssertEqual(mid.h, 150, accuracy: 1.0)
    }

    func testOKLCHLerpHueWrapping() {
        let a = OKLCHColor(l: 0.5, c: 0.1, h: 350)
        let b = OKLCHColor(l: 0.5, c: 0.1, h: 10)
        let mid = a.lerp(b, t: 0.5)
        XCTAssertTrue(mid.h < 10 || mid.h > 350,
                       "Should wrap around 0, got \(mid.h)")
    }

    // MARK: - OKLab Interpolation

    func testOKLabLerp() {
        let a = OKLabColor(l: 0, a: -0.2, b: -0.2)
        let b = OKLabColor(l: 1, a: 0.2, b: 0.2)
        let mid = a.lerp(b, t: 0.5)
        XCTAssertEqual(mid.l, 0.5, accuracy: 0.01)
        XCTAssertEqual(mid.a, 0.0, accuracy: 0.01)
        XCTAssertEqual(mid.b, 0.0, accuracy: 0.01)
    }

    // MARK: - Cross-Space Conversions

    func testOKLCHToLCHAndBack() {
        let original = RGBColor(r: 0.4, g: 0.6, b: 0.8, alpha: 1)
        let viaOKLCH = original.toOKLCH().toLCH().toRGB()
        let viaLCH = original.toLCH().toRGB()
        // Both paths should produce similar RGB (not identical due to different color spaces)
        XCTAssertEqual(viaOKLCH.r, viaLCH.r, accuracy: 0.02)
        XCTAssertEqual(viaOKLCH.g, viaLCH.g, accuracy: 0.02)
        XCTAssertEqual(viaOKLCH.b, viaLCH.b, accuracy: 0.02)
    }

    func testColorToOKLCHConvenience() {
        let blue = Color.blue
        let oklch = blue.toOKLCH()
        XCTAssertGreaterThan(oklch.c, 0.1, "Blue should have noticeable chroma")
        XCTAssertGreaterThan(oklch.l, 0, "Blue should have some lightness")
    }

    // MARK: - Gamut Clamping

    func testOutOfGamutOKLCHClampsRGB() {
        let extreme = OKLCHColor(l: 0.5, c: 0.4, h: 270)
        let rgb = extreme.toRGB()
        XCTAssertGreaterThanOrEqual(rgb.r, 0)
        XCTAssertLessThanOrEqual(rgb.r, 1)
        XCTAssertGreaterThanOrEqual(rgb.g, 0)
        XCTAssertLessThanOrEqual(rgb.g, 1)
        XCTAssertGreaterThanOrEqual(rgb.b, 0)
        XCTAssertLessThanOrEqual(rgb.b, 1)
    }
}
