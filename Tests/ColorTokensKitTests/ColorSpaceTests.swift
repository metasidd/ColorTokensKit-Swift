@testable import ColorTokensKit
import XCTest

final class ColorSpaceConversionTests: XCTestCase {

    let tolerance: CGFloat = 0.01 // Allow small floating-point drift

    // MARK: - Known Reference Colors (from CIE standards / online converters)

    // sRGB pure red (1, 0, 0) -> XYZ (0.4124, 0.2127, 0.0193) -> LAB (53.23, 80.11, 67.22) -> LCH (53.23, 104.55, ~40°)
    func testRedRGBToXYZ() {
        let red = RGBColor(r: 1, g: 0, b: 0, alpha: 1)
        let xyz = red.toXYZ()
        XCTAssertEqual(xyz.x, 0.4124, accuracy: tolerance)
        XCTAssertEqual(xyz.y, 0.2127, accuracy: tolerance)
        XCTAssertEqual(xyz.z, 0.0193, accuracy: tolerance)
    }

    func testRedRGBToLAB() {
        let red = RGBColor(r: 1, g: 0, b: 0, alpha: 1)
        let lab = red.toLAB()
        XCTAssertEqual(lab.l, 53.23, accuracy: 0.1)
        XCTAssertEqual(lab.a, 80.11, accuracy: 0.2)
        XCTAssertEqual(lab.b, 67.22, accuracy: 0.2)
    }

    func testRedRGBToLCH() {
        let red = RGBColor(r: 1, g: 0, b: 0, alpha: 1)
        let lch = red.toLCH()
        XCTAssertEqual(lch.l, 53.23, accuracy: 0.2)
        XCTAssertTrue(lch.c > 100, "Red should have high chroma, got \(lch.c)")
        XCTAssertEqual(lch.h, 40.0, accuracy: 1.0) // Hue around 40° for red
    }

    // sRGB pure green (0, 1, 0) -> LAB (87.74, -86.18, 83.18)
    func testGreenRGBToLAB() {
        let green = RGBColor(r: 0, g: 1, b: 0, alpha: 1)
        let lab = green.toLAB()
        XCTAssertEqual(lab.l, 87.74, accuracy: 0.2)
        XCTAssertEqual(lab.a, -86.18, accuracy: 0.3)
        XCTAssertEqual(lab.b, 83.18, accuracy: 0.3)
    }

    // sRGB pure blue (0, 0, 1) -> LAB (32.30, 79.20, -107.86)
    func testBlueRGBToLAB() {
        let blue = RGBColor(r: 0, g: 0, b: 1, alpha: 1)
        let lab = blue.toLAB()
        XCTAssertEqual(lab.l, 32.30, accuracy: 0.2)
        XCTAssertEqual(lab.a, 79.20, accuracy: 0.3)
        XCTAssertEqual(lab.b, -107.86, accuracy: 0.3)
    }

    // White (1, 1, 1) -> LAB (100, 0, 0)
    func testWhiteRGBToLAB() {
        let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let lab = white.toLAB()
        XCTAssertEqual(lab.l, 100.0, accuracy: 0.1)
        XCTAssertEqual(lab.a, 0.0, accuracy: 0.1)
        XCTAssertEqual(lab.b, 0.0, accuracy: 0.1)
    }

    // Black (0, 0, 0) -> LAB (0, 0, 0)
    func testBlackRGBToLAB() {
        let black = RGBColor(r: 0, g: 0, b: 0, alpha: 1)
        let lab = black.toLAB()
        XCTAssertEqual(lab.l, 0.0, accuracy: 0.1)
        XCTAssertEqual(lab.a, 0.0, accuracy: 0.1)
        XCTAssertEqual(lab.b, 0.0, accuracy: 0.1)
    }

    // 50% gray (0.5, 0.5, 0.5) -> LAB (~53.39, 0, 0)
    func testMidGrayRGBToLAB() {
        let gray = RGBColor(r: 0.5, g: 0.5, b: 0.5, alpha: 1)
        let lab = gray.toLAB()
        XCTAssertEqual(lab.l, 53.39, accuracy: 0.2)
        XCTAssertEqual(lab.a, 0.0, accuracy: 0.1)
        XCTAssertEqual(lab.b, 0.0, accuracy: 0.1)
    }

    // MARK: - Round-Trip Accuracy

    func testRGBRoundTripThroughLCH() {
        let testColors: [(r: CGFloat, g: CGFloat, b: CGFloat, name: String)] = [
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

        for color in testColors {
            let original = RGBColor(r: color.r, g: color.g, b: color.b, alpha: 1)
            let roundTrip = original.toLCH().toRGB()
            XCTAssertEqual(roundTrip.r, original.r, accuracy: tolerance,
                           "Round-trip failed for \(color.name) R: \(roundTrip.r) vs \(original.r)")
            XCTAssertEqual(roundTrip.g, original.g, accuracy: tolerance,
                           "Round-trip failed for \(color.name) G: \(roundTrip.g) vs \(original.g)")
            XCTAssertEqual(roundTrip.b, original.b, accuracy: tolerance,
                           "Round-trip failed for \(color.name) B: \(roundTrip.b) vs \(original.b)")
        }
    }

    // MARK: - Alpha Preservation

    func testAlphaPreservedThroughConversions() {
        let original = RGBColor(r: 0.5, g: 0.5, b: 0.5, alpha: 0.42)
        let xyz = original.toXYZ()
        XCTAssertEqual(xyz.alpha, 0.42, accuracy: 0.001)
        let lab = xyz.toLAB()
        XCTAssertEqual(lab.alpha, 0.42, accuracy: 0.001)
        let lch = lab.toLCH()
        XCTAssertEqual(lch.alpha, 0.42, accuracy: 0.001)
        let backToRGB = lch.toRGB()
        XCTAssertEqual(backToRGB.alpha, 0.42, accuracy: 0.001)
    }

    // MARK: - LCH Specific

    func testLCHHueNormalization() {
        // Negative hue should normalize to 0-360
        let color1 = LCHColor(l: 50, c: 30, h: -30)
        XCTAssertTrue(color1.h >= 0 && color1.h < 360,
                       "Hue \(color1.h) should be normalized to [0, 360)")

        // Hue > 360 should normalize
        let color2 = LCHColor(l: 50, c: 30, h: 400)
        XCTAssertTrue(color2.h >= 0 && color2.h < 360,
                       "Hue \(color2.h) should be normalized to [0, 360)")

        // Hue = 360 should become 0
        let color3 = LCHColor(l: 50, c: 30, h: 360)
        XCTAssertEqual(color3.h, 0.0, accuracy: 0.01)
    }

    func testLCHFromLCHString() {
        let color = LCHColor(lchString: "lch(65% 40 210)")
        XCTAssertEqual(color.l, 65.0, accuracy: 0.01)
        XCTAssertEqual(color.c, 40.0, accuracy: 0.01)
        XCTAssertEqual(color.h, 210.0, accuracy: 0.01)
    }

    func testLCHFromInvalidStringUsesDefaults() {
        let color = LCHColor(lchString: "not a color")
        XCTAssertEqual(color.l, 70.0, accuracy: 0.01)
        XCTAssertEqual(color.c, 30.0, accuracy: 0.01)
        XCTAssertEqual(color.h, 0.0, accuracy: 0.01)
    }

    func testLCHFromHexRoundTrips() {
        let color = LCHColor(hex: "#FF0000")
        XCTAssertEqual(color.l, 53.23, accuracy: 0.5)
        XCTAssertTrue(color.c > 100, "Red hex should have high chroma")
    }

    // MARK: - Gamut Clamping

    func testOutOfGamutLCHClampsRGBToValidRange() {
        // Highly saturated LCH color that would produce out-of-gamut RGB
        let outOfGamut = LCHColor(l: 50, c: 128, h: 270) // extreme blue-purple
        let rgb = outOfGamut.toRGB()
        XCTAssertGreaterThanOrEqual(rgb.r, 0, "R should be clamped >= 0, got \(rgb.r)")
        XCTAssertLessThanOrEqual(rgb.r, 1, "R should be clamped <= 1, got \(rgb.r)")
        XCTAssertGreaterThanOrEqual(rgb.g, 0, "G should be clamped >= 0, got \(rgb.g)")
        XCTAssertLessThanOrEqual(rgb.g, 1, "G should be clamped <= 1, got \(rgb.g)")
        XCTAssertGreaterThanOrEqual(rgb.b, 0, "B should be clamped >= 0, got \(rgb.b)")
        XCTAssertLessThanOrEqual(rgb.b, 1, "B should be clamped <= 1, got \(rgb.b)")
    }

    func testInGamutColorUnaffectedByClamping() {
        // A well-behaved mid-range color should round-trip without being clipped
        let original = RGBColor(r: 0.5, g: 0.3, b: 0.7, alpha: 1)
        let roundTrip = original.toLCH().toRGB()
        XCTAssertEqual(roundTrip.r, original.r, accuracy: tolerance)
        XCTAssertEqual(roundTrip.g, original.g, accuracy: tolerance)
        XCTAssertEqual(roundTrip.b, original.b, accuracy: tolerance)
    }

    func testLCHEquality() {
        let a = LCHColor(l: 50, c: 30, h: 180)
        let b = LCHColor(l: 50, c: 30, h: 180)
        let c = LCHColor(l: 51, c: 30, h: 180)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
}
