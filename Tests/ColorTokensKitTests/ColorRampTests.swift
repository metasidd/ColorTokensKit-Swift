@testable import ColorTokensKit
import XCTest
import SwiftUI

final class ColorRampTests: XCTestCase {

    // MARK: - LCH Ramp Generation

    func testRampGeneratesCorrectNumberOfStops() {
        let generator = ColorRampGenerator()
        let ramp = generator.getColorRamp(forHue: 210)
        XCTAssertEqual(ramp.count, ColorConstants.rampStops,
                       "Default ramp should have \(ColorConstants.rampStops) stops, got \(ramp.count)")
    }

    func testRampLightnessDecreases() {
        let generator = ColorRampGenerator()
        let ramp = generator.getColorRamp(forHue: 210)

        // Ramp should go from light to dark (decreasing L)
        for i in 0..<(ramp.count - 1) {
            XCTAssertGreaterThanOrEqual(ramp[i].l, ramp[i + 1].l,
                "Lightness should decrease monotonically: stop \(i) (L=\(ramp[i].l)) should be >= stop \(i+1) (L=\(ramp[i+1].l))")
        }
    }

    func testRampFirstStopIsLight() {
        let generator = ColorRampGenerator()
        let ramp = generator.getColorRamp(forHue: 210)
        XCTAssertGreaterThan(ramp.first!.l, 80,
                             "First ramp stop should be very light, got L=\(ramp.first!.l)")
    }

    func testRampLastStopIsDark() {
        let generator = ColorRampGenerator()
        let ramp = generator.getColorRamp(forHue: 210)
        XCTAssertLessThan(ramp.last!.l, 20,
                          "Last ramp stop should be very dark, got L=\(ramp.last!.l)")
    }

    func testGrayscaleRampHasLowChroma() {
        let generator = ColorRampGenerator()
        let ramp = generator.getColorRamp(forHue: 0, isGrayscale: true)
        for (i, color) in ramp.enumerated() {
            XCTAssertLessThan(color.c, 1.0,
                "Grayscale ramp stop \(i) should have near-zero chroma, got C=\(color.c)")
        }
    }

    // MARK: - OKLCH Ramp Generation

    func testOKLCHRampGeneratesCorrectNumberOfStops() {
        let generator = ColorRampGenerator()
        let ramp = generator.getOKLCHColorRamp(forHue: 210)
        XCTAssertEqual(ramp.count, ColorConstants.rampStops)
    }

    func testOKLCHRampLightnessDecreases() {
        let generator = ColorRampGenerator()
        let ramp = generator.getOKLCHColorRamp(forHue: 210)
        for i in 0..<(ramp.count - 1) {
            XCTAssertGreaterThanOrEqual(ramp[i].l, ramp[i + 1].l,
                "OKLCH lightness should decrease: stop \(i) (L=\(ramp[i].l)) >= stop \(i+1) (L=\(ramp[i+1].l))")
        }
    }

    // MARK: - Ramp Determinism

    func testRampIsDeterministic() {
        let generator = ColorRampGenerator()
        let ramp1 = generator.getColorRamp(forHue: 140)
        let ramp2 = generator.getColorRamp(forHue: 140)
        XCTAssertEqual(ramp1.count, ramp2.count)
        for i in 0..<ramp1.count {
            XCTAssertEqual(ramp1[i].l, ramp2[i].l, accuracy: 0.001,
                           "Ramp should be deterministic at stop \(i)")
            XCTAssertEqual(ramp1[i].c, ramp2[i].c, accuracy: 0.001)
            XCTAssertEqual(ramp1[i].h, ramp2[i].h, accuracy: 0.001)
        }
    }

    func testDifferentHuesProduceDifferentRamps() {
        let generator = ColorRampGenerator()
        let blueRamp = generator.getColorRamp(forHue: 210)
        let redRamp = generator.getColorRamp(forHue: 10)

        let blueMiddle = blueRamp[blueRamp.count / 2]
        let redMiddle = redRamp[redRamp.count / 2]
        XCTAssertNotEqual(blueMiddle.h, redMiddle.h, "Blue and red ramps should have different hues")
    }

    // MARK: - Named Stops API (LCH)

    func testLCHNamedStopsAccessors() {
        let color = LCHColor(l: 50, c: 30, h: 210)
        let first = color._50
        let last = color._1000
        XCTAssertGreaterThan(first.l, last.l, "_50 should be lighter than _1000")
    }

    func testLCHAllStopsReturns20Colors() {
        let color = LCHColor(l: 50, c: 30, h: 210)
        let stops = color.allStops
        XCTAssertEqual(stops.count, 20, "allStops should return 20 colors")
    }

    // MARK: - Named Stops API (OKLCH)

    func testOKLCHNamedStopsAccessors() {
        let color = OKLCHColor(l: 0.5, c: 0.1, h: 210)
        let first = color._50
        let last = color._1000
        XCTAssertGreaterThan(first.l, last.l, "_50 should be lighter than _1000")
    }

    func testOKLCHAllStopsReturns20Colors() {
        let color = OKLCHColor(l: 0.5, c: 0.1, h: 210)
        let stops = color.allStops
        XCTAssertEqual(stops.count, 20, "allStops should return 20 colors")
    }

    // MARK: - Pro Colors

    func testProColorsAreDistinct() {
        let hues = Color.allProHues
        XCTAssertGreaterThan(hues.count, 20, "Should have 20+ pro colors")

        var seen = Set<ProColor>()
        for (name, color) in hues {
            XCTAssertFalse(seen.contains(color), "Pro color '\(name)' is a duplicate")
            seen.insert(color)
        }
    }

    func testProGrayIsLowChroma() {
        let gray = Color.proGray
        XCTAssertLessThan(gray.c, 0.02, "proGray should have very low chroma, got \(gray.c)")
    }

    func testProBlueHasBlueHue() {
        let blue = Color.proBlue
        // Blue hue in OKLCH is roughly 200-270
        XCTAssertGreaterThan(blue.h, 190, "proBlue hue should be in blue range, got \(blue.h)")
        XCTAssertLessThan(blue.h, 270, "proBlue hue should be in blue range, got \(blue.h)")
    }

    // MARK: - Edge Cases

    func testRampAtHueZeroAndHue360AreEquivalent() {
        let generator = ColorRampGenerator()
        let ramp0 = generator.getColorRamp(forHue: 0)
        let ramp360 = generator.getColorRamp(forHue: 360)
        XCTAssertEqual(ramp0.count, ramp360.count)
        for i in 0..<ramp0.count {
            XCTAssertEqual(ramp0[i].l, ramp360[i].l, accuracy: 0.01,
                "Hue 0 and 360 should produce identical ramps at stop \(i)")
            XCTAssertEqual(ramp0[i].c, ramp360[i].c, accuracy: 0.01)
            XCTAssertEqual(ramp0[i].h, ramp360[i].h, accuracy: 0.01)
        }
    }

    func testRampAtArbitraryHue() {
        let generator = ColorRampGenerator()
        let ramp = generator.getColorRamp(forHue: 173.5)
        XCTAssertEqual(ramp.count, ColorConstants.rampStops)
        for (i, color) in ramp.enumerated() {
            XCTAssertTrue(color.l >= 0 && color.l <= 100,
                "Stop \(i) lightness \(color.l) should be in [0, 100]")
            XCTAssertTrue(color.c >= 0,
                "Stop \(i) chroma \(color.c) should be non-negative")
            XCTAssertTrue(color.h >= 0 && color.h < 360,
                "Stop \(i) hue \(color.h) should be in [0, 360)")
        }
    }
}
