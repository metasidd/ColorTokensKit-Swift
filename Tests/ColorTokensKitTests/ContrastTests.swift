@testable import ColorTokensKit
import XCTest
import SwiftUI

final class ContrastTests: XCTestCase {

    // MARK: - WCAG 2.x

    func testBlackWhiteMaxContrast() {
        let black = RGBColor(r: 0, g: 0, b: 0, alpha: 1)
        let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let ratio = black.contrastRatio(to: white, method: .wcag2)
        XCTAssertEqual(ratio, 21.0, accuracy: 0.05)
    }

    func testSameColorMinContrast() {
        let gray = RGBColor(r: 0.5, g: 0.5, b: 0.5, alpha: 1)
        let ratio = gray.contrastRatio(to: gray, method: .wcag2)
        XCTAssertEqual(ratio, 1.0, accuracy: 0.01)
    }

    func testWCAGIsSymmetric() {
        let a = RGBColor(r: 0.2, g: 0.4, b: 0.8, alpha: 1)
        let b = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let ab = a.contrastRatio(to: b, method: .wcag2)
        let ba = b.contrastRatio(to: a, method: .wcag2)
        XCTAssertEqual(ab, ba, accuracy: 0.001, "WCAG contrast should be symmetric")
    }

    func testWCAGAlwaysAtLeastOne() {
        let colors: [(CGFloat, CGFloat, CGFloat)] = [
            (0.1, 0.1, 0.1), (0.5, 0.5, 0.5), (0.9, 0.9, 0.9),
            (1, 0, 0), (0, 1, 0), (0, 0, 1),
        ]
        for (r, g, b) in colors {
            let color = RGBColor(r: r, g: g, b: b, alpha: 1)
            let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
            let ratio = color.contrastRatio(to: white, method: .wcag2)
            XCTAssertGreaterThanOrEqual(ratio, 1.0)
        }
    }

    func testWCAGKnownValue() {
        // Pure blue (#0000FF) on white has a contrast ratio of ~8.59
        let blue = RGBColor(r: 0, g: 0, b: 1, alpha: 1)
        let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let ratio = blue.contrastRatio(to: white, method: .wcag2)
        XCTAssertEqual(ratio, 8.59, accuracy: 0.1)
    }

    // MARK: - APCA

    func testAPCABlackOnWhiteIsPositive() {
        let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let black = RGBColor(r: 0, g: 0, b: 0, alpha: 1)
        // Background is white, text is black → positive Lc (dark text on light bg)
        let lc = white.contrastRatio(to: black, method: .apca)
        XCTAssertGreaterThan(lc, 100, "Black on white should have high positive Lc, got \(lc)")
    }

    func testAPCAWhiteOnBlackIsNegative() {
        let black = RGBColor(r: 0, g: 0, b: 0, alpha: 1)
        let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        // Background is black, text is white → negative Lc (light text on dark bg)
        let lc = black.contrastRatio(to: white, method: .apca)
        XCTAssertLessThan(lc, -100, "White on black should have high negative Lc, got \(lc)")
    }

    func testAPCASameColorIsZero() {
        let gray = RGBColor(r: 0.5, g: 0.5, b: 0.5, alpha: 1)
        let lc = gray.contrastRatio(to: gray, method: .apca)
        XCTAssertEqual(lc, 0, accuracy: 1, "Same color should have near-zero APCA contrast")
    }

    func testAPCAIsAsymmetric() {
        let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let darkGray = RGBColor(r: 0.2, g: 0.2, b: 0.2, alpha: 1)
        let darkOnLight = white.contrastRatio(to: darkGray, method: .apca)
        let lightOnDark = darkGray.contrastRatio(to: white, method: .apca)
        // APCA is deliberately asymmetric — the magnitudes differ
        XCTAssertNotEqual(abs(darkOnLight), abs(lightOnDark), accuracy: 1,
            "APCA should be asymmetric: |\(darkOnLight)| vs |\(lightOnDark)|")
    }

    // MARK: - LCH and Color convenience

    func testLCHContrastRatio() {
        let light = LCHColor(l: 95, c: 0, h: 0)
        let dark = LCHColor(l: 10, c: 0, h: 0)
        let ratio = light.contrastRatio(to: dark, method: .wcag2)
        XCTAssertGreaterThan(ratio, 10, "High lightness difference should produce high contrast")
    }

    func testDefaultMethodIsWCAG2() {
        let a = RGBColor(r: 0, g: 0, b: 0, alpha: 1)
        let b = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let defaultResult = a.contrastRatio(to: b)
        let wcagResult = a.contrastRatio(to: b, method: .wcag2)
        XCTAssertEqual(defaultResult, wcagResult, accuracy: 0.001)
    }

    // MARK: - Relative Luminance

    func testRelativeLuminanceBlack() {
        let black = RGBColor(r: 0, g: 0, b: 0, alpha: 1)
        XCTAssertEqual(black.relativeLuminance, 0, accuracy: 0.001)
    }

    func testRelativeLuminanceWhite() {
        let white = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        XCTAssertEqual(white.relativeLuminance, 1, accuracy: 0.001)
    }
}
