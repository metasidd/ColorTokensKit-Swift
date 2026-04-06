@testable import ColorTokensKit
import XCTest

final class UtilityTests: XCTestCase {

    // MARK: - Double.normalizedHue

    func testNormalizedHuePositive() {
        XCTAssertEqual(Double(90).normalizedHue, 90.0, accuracy: 0.01)
        XCTAssertEqual(Double(359).normalizedHue, 359.0, accuracy: 0.01)
    }

    func testNormalizedHueNegative() {
        XCTAssertEqual(Double(-10).normalizedHue, 350.0, accuracy: 0.01)
        XCTAssertEqual(Double(-360).normalizedHue, 0.0, accuracy: 0.01)
        XCTAssertEqual(Double(-90).normalizedHue, 270.0, accuracy: 0.01)
    }

    func testNormalizedHueOverflow() {
        XCTAssertEqual(Double(370).normalizedHue, 10.0, accuracy: 0.01)
        XCTAssertEqual(Double(720).normalizedHue, 0.0, accuracy: 0.01)
        XCTAssertEqual(Double(810).normalizedHue, 90.0, accuracy: 0.01)
    }

    func testNormalizedHueZero() {
        XCTAssertEqual(Double(0).normalizedHue, 0.0, accuracy: 0.01)
    }

    func testNormalizedHue360() {
        XCTAssertEqual(Double(360).normalizedHue, 0.0, accuracy: 0.01)
    }

    // MARK: - Double.rounded(to:)

    func testRoundedToPlaces() {
        XCTAssertEqual(Double(3.14159).rounded(to: 2), 3.14, accuracy: 0.001)
        XCTAssertEqual(Double(3.14159).rounded(to: 4), 3.1416, accuracy: 0.00001)
        XCTAssertEqual(Double(3.14159).rounded(to: 0), 3.0, accuracy: 0.001)
    }

    // MARK: - CGFloat.rounded(to:)

    func testCGFloatRoundedToPlaces() {
        XCTAssertEqual(CGFloat(2.71828).rounded(to: 2), 2.72, accuracy: 0.001)
        XCTAssertEqual(CGFloat(2.71828).rounded(to: 3), 2.718, accuracy: 0.0001)
    }

    // MARK: - Double and CGFloat consistency

    func testDoubleAndCGFloatNormalizedHueMatch() {
        let testValues: [Double] = [-90, 0, 45, 180, 359.5, 400, 720]
        for value in testValues {
            let doubleResult = value.normalizedHue
            let cgfloatResult = CGFloat(value).normalizedHue
            XCTAssertEqual(doubleResult, Double(cgfloatResult), accuracy: 0.01,
                "normalizedHue should match for Double and CGFloat at value \(value)")
        }
    }

    func testDoubleAndCGFloatRoundedToMatch() {
        let testValues: [Double] = [3.14159, 0.0, -2.718, 100.555]
        for value in testValues {
            let doubleResult = value.rounded(to: 2)
            let cgfloatResult = CGFloat(value).rounded(to: 2)
            XCTAssertEqual(doubleResult, Double(cgfloatResult), accuracy: 0.001,
                "rounded(to:) should match for Double and CGFloat at value \(value)")
        }
    }
}
