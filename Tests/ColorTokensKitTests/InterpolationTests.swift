@testable import ColorTokensKit
import XCTest

final class InterpolationTests: XCTestCase {

    let tolerance: CGFloat = 0.5

    // MARK: - LCH Lerp Basics

    func testLerpAtZeroReturnsStart() {
        let a = LCHColor(l: 30, c: 40, h: 100)
        let b = LCHColor(l: 70, c: 80, h: 200)
        let result = a.lerp(b, t: 0)
        XCTAssertEqual(result.l, 30, accuracy: tolerance)
        XCTAssertEqual(result.c, 40, accuracy: tolerance)
        XCTAssertEqual(result.h, 100, accuracy: tolerance)
    }

    func testLerpAtOneReturnsEnd() {
        let a = LCHColor(l: 30, c: 40, h: 100)
        let b = LCHColor(l: 70, c: 80, h: 200)
        let result = a.lerp(b, t: 1)
        XCTAssertEqual(result.l, 70, accuracy: tolerance)
        XCTAssertEqual(result.c, 80, accuracy: tolerance)
        XCTAssertEqual(result.h, 200, accuracy: tolerance)
    }

    func testLerpAtHalfReturnsMidpoint() {
        let a = LCHColor(l: 20, c: 40, h: 100)
        let b = LCHColor(l: 80, c: 80, h: 200)
        let result = a.lerp(b, t: 0.5)
        XCTAssertEqual(result.l, 50, accuracy: tolerance)
        XCTAssertEqual(result.c, 60, accuracy: tolerance)
        XCTAssertEqual(result.h, 150, accuracy: tolerance)
    }

    // MARK: - Hue Wrapping (shortest path)

    func testLerpHueShortestPathForward() {
        // 10 -> 350: shortest path is backwards (-20), not forward (+340)
        let a = LCHColor(l: 50, c: 50, h: 10)
        let b = LCHColor(l: 50, c: 50, h: 350)
        let result = a.lerp(b, t: 0.5)
        // Midpoint should be at 0/360, not at 180
        let hue = result.h
        XCTAssertTrue(hue < 10 || hue > 350,
                       "Midpoint hue between 10 and 350 should wrap around 0, got \(hue)")
    }

    func testLerpHueShortestPathBackward() {
        // 350 -> 10: shortest path is forward (+20)
        let a = LCHColor(l: 50, c: 50, h: 350)
        let b = LCHColor(l: 50, c: 50, h: 10)
        let result = a.lerp(b, t: 0.5)
        let hue = result.h
        XCTAssertTrue(hue < 10 || hue > 350,
                       "Midpoint hue between 350 and 10 should wrap around 0, got \(hue)")
    }

    func testLerpHueSameValue() {
        let a = LCHColor(l: 50, c: 50, h: 180)
        let b = LCHColor(l: 50, c: 50, h: 180)
        let result = a.lerp(b, t: 0.5)
        XCTAssertEqual(result.h, 180, accuracy: 0.1)
    }

    func testLerpHueOppositeValues() {
        // 0 -> 180: exactly opposite, either direction is valid
        let a = LCHColor(l: 50, c: 50, h: 0)
        let b = LCHColor(l: 50, c: 50, h: 180)
        let result = a.lerp(b, t: 0.5)
        // Should be 90 or 270 depending on direction chosen
        XCTAssertTrue(
            abs(result.h - 90) < tolerance || abs(result.h - 270) < tolerance,
            "Midpoint between 0 and 180 should be 90 or 270, got \(result.h)"
        )
    }

    // MARK: - Alpha Interpolation

    func testLerpInterpolatesAlpha() {
        let a = LCHColor(l: 50, c: 50, h: 100, alpha: 0.0)
        let b = LCHColor(l: 50, c: 50, h: 100, alpha: 1.0)
        let result = a.lerp(b, t: 0.5)
        XCTAssertEqual(result.alpha, 0.5, accuracy: 0.01)
    }

    // MARK: - RGB/LAB/XYZ Interpolation

    func testRGBLerp() {
        let a = RGBColor(r: 0, g: 0, b: 0, alpha: 1)
        let b = RGBColor(r: 1, g: 1, b: 1, alpha: 1)
        let mid = a.lerp(b, t: 0.5)
        XCTAssertEqual(mid.r, 0.5, accuracy: 0.01)
        XCTAssertEqual(mid.g, 0.5, accuracy: 0.01)
        XCTAssertEqual(mid.b, 0.5, accuracy: 0.01)
    }

    func testLABLerp() {
        let a = LABColor(l: 0, a: -50, b: -50, alpha: 1)
        let b = LABColor(l: 100, a: 50, b: 50, alpha: 1)
        let mid = a.lerp(b, t: 0.5)
        XCTAssertEqual(mid.l, 50, accuracy: 0.01)
        XCTAssertEqual(mid.a, 0, accuracy: 0.01)
        XCTAssertEqual(mid.b, 0, accuracy: 0.01)
    }
}
