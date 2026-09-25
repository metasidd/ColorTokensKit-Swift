@testable import ColorTokensKit
import SwiftUI
import XCTest

final class HarmonyTests: XCTestCase {
    private let blue = Color.proBlue

    // A palette color's harmony is balanced: every member keeps the original's lightness, so the same contrast.
    func testTriadIsThreeHuesAThirdApartAtTheSameLightness() {
        let colors = blue._500.toColor().triad.map { $0.resolvedOKLCH(for: .light) }
        let hues = colors.map { Double($0.h) }
        XCTAssertEqual(colors.count, 3)
        XCTAssertEqual(turn(from: hues[0], to: hues[1]), 120, accuracy: 1)
        XCTAssertEqual(turn(from: hues[0], to: hues[2]), 240, accuracy: 1)
        for color in colors {
            XCTAssertEqual(color.lightnessStar, colors[0].lightnessStar, accuracy: 0.5)
        }
    }

    // Every harmony except analogous (which is centered on the color) starts with the original, untouched:
    // even one sRGB can't show, like Display P3 red.
    func testHarmoniesStartWithTheOriginalColor() {
        let source = blue._500.toColor()
        XCTAssertEqual(source.triad[0].hex(), source.hex())
        XCTAssertEqual(source.square[0].hex(), source.hex())
        XCTAssertEqual(source.tetrad()[0].hex(), source.hex())
        XCTAssertEqual(source.splitComplement()[0].hex(), source.hex())

        let displayP3Red = Color(.displayP3, red: 1, green: 0, blue: 0)
        XCTAssertEqual(displayP3Red.triad[0], displayP3Red)
    }

    // Two half turns must come back exactly, or switching to the complement and back drifts a color off the palette.
    func testComplementOfTheComplementIsTheOriginal() {
        let source = blue._500.toColor()
        XCTAssertEqual(source.complement.complement.hex(), source.hex())
    }

    // Analogous colors sit either side of the original, so it is in the middle.
    func testAnalogousIsCenteredOnTheColor() {
        let colors = blue._500.toColor().analogous(count: 5, spread: .degrees(20))
        XCTAssertEqual(colors.count, 5)
        XCTAssertEqual(colors[2].hex(), blue._500.toColor().hex())
        XCTAssertEqual(ColorHarmony.analogous(count: 5, spread: .degrees(20)).hueOffsets, [-40, -20, 0, 20, 40])
    }

    // Family first or color first, the answer must be the same color.
    func testFamilyAndColorHarmoniesAgree() {
        XCTAssertEqual(blue.complement._600.toColor().hex(), blue._600.toColor().complement.hex())
        XCTAssertEqual(blue.triad[1]._300.toColor().hex(), blue._300.toColor().triad[1].hex())
    }

    // Gray has no hue, so every hue harmony of gray is gray.
    func testGrayHarmoniesStayGray() {
        let gray = Color.proGray._500.toColor()
        for color in gray.triad {
            XCTAssertEqual(color.hex(), gray.hex())
        }
        XCTAssertEqual(Color.proGray.complement._500.toColor().hex(), gray.hex())
    }

    // A token's harmony stays adaptive: each appearance gets its own rotated stop.
    func testHarmoniesOfATokenWorkInBothAppearances() {
        let blue = self.blue
        let token = Color(light: blue._700.toColor(), dark: blue._300.toColor())
        XCTAssertEqual(token.complement.hex(.light), blue.complement._700.toColor().hex())
        XCTAssertEqual(token.complement.hex(.dark), blue.complement._300.toColor().hex())
    }

    // Callers index into tints and shades (`tints()[0]` is the nearest), so their order and spacing are part of the API.
    func testTintsAreLighterAndShadesDarkerOneStopAtATime() {
        let source = blue._500.toColor()
        XCTAssertEqual(source.tints().map { $0.hex() }, [blue._450, blue._400, blue._350].map { $0.toColor().hex() })
        XCTAssertEqual(source.shades().map { $0.hex() }, [blue._550, blue._600, blue._650].map { $0.toColor().hex() })
    }

    // A monochromatic set covers the whole ramp, so its ends are the ramp's own lightest and darkest stops, in order.
    func testMonochromaticSpansTheRampFromLightToDark() {
        let colors = blue._500.toColor().monochromatic()
        XCTAssertEqual(colors.first?.hex(), blue._50.toColor().hex())
        XCTAssertEqual(colors.last?.hex(), blue._1000.toColor().hex())
        let lightness = colors.map { $0.resolvedOKLCH(for: .light).lightnessStar }
        XCTAssertEqual(lightness, lightness.sorted(by: >))
    }

    /// Degrees from one hue to another, going up around the wheel.
    private func turn(from start: Double, to end: Double) -> Double {
        (end - start).normalizedHue
    }
}
