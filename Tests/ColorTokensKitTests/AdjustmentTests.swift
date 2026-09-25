@testable import ColorTokensKit
import SwiftUI
import XCTest

final class AdjustmentTests: XCTestCase {
    private let blue = Color.proBlue

    /// A token: one stop in light mode, another in dark mode.
    private var token: Color {
        let blue = self.blue
        return Color(light: blue._700.toColor(), dark: blue._300.toColor())
    }

    // MARK: - Lightness

    // Palette colors must land on exact palette stops, or contrast stops being predictable.
    func testLightenAndDarkenMoveAPaletteColourToExactStops() {
        XCTAssertEqual(blue._600.toColor().lighten().hex(), blue._550.toColor().hex())
        XCTAssertEqual(blue._600.toColor().darken(by: 2).hex(), blue._700.toColor().hex())
    }

    // A token is two colors. An adjustment has to apply to each appearance, or dark mode breaks.
    func testAdjustmentsApplyInLightAndDarkMode() {
        let lighter = token.lighten()
        XCTAssertEqual(lighter.hex(.light), blue._650.toColor().hex())
        XCTAssertEqual(lighter.hex(.dark), blue._250.toColor().hex())
    }

    // Softer means closer to the background, which is light in light mode and dark in dark mode.
    func testSoftenMovesTowardTheBackgroundAndStrengthenMovesAway() {
        XCTAssertEqual(token.soften().hex(.light), blue._650.toColor().hex())
        XCTAssertEqual(token.soften().hex(.dark), blue._350.toColor().hex())
        XCTAssertEqual(token.strengthen().hex(.light), blue._750.toColor().hex())
        XCTAssertEqual(token.strengthen().hex(.dark), blue._250.toColor().hex())
    }

    // Most text and surfaces are gray, and the gray ramp has its own lightness ladder.
    func testGrayMovesAlongTheGrayRamp() {
        let gray = Color.proGray
        XCTAssertEqual(gray._700.toColor().lighten().hex(), gray._650.toColor().hex())
        XCTAssertEqual(gray._300.toColor().darken().hex(), gray._350.toColor().hex())
    }

    func testLightnessHoldsAtTheEndsOfTheRamp() {
        XCTAssertEqual(blue._50.toColor().lighten().hex(), blue._50.toColor().hex())
        XCTAssertEqual(blue._1000.toColor().darken(by: 3).hex(), blue._1000.toColor().hex())
    }

    // Colors from outside the palette get the same visual step and keep their hue.
    func testAnOffPaletteColourMovesOneStepAndKeepsItsHue() {
        let brick = Color(red: 0.72, green: 0.28, blue: 0.2)
        let before = brick.resolvedOKLCH(for: .light)
        let after = brick.lighten().resolvedOKLCH(for: .light)
        let ladder = StopLadder.chromatic
        let step = ladder.position(ofLightnessStar: before.lightnessStar) - ladder.position(ofLightnessStar: after.lightnessStar)
        XCTAssertEqual(step, 1, accuracy: 0.02)
        XCTAssertEqual(Double(after.h), Double(before.h), accuracy: 0.5)
    }

    // MARK: - Saturation

    // A full desaturate must keep lightness, or a "disabled" color changes contrast.
    func testDesaturatingFullyLeavesAGrayOfTheSameLightness() {
        let source = blue._500.toColor()
        let gray = source.desaturate(by: 1).resolvedOKLCH(for: .light)
        XCTAssertLessThan(Double(gray.c), 0.002)
        XCTAssertEqual(gray.lightnessStar, source.resolvedOKLCH(for: .light).lightnessStar, accuracy: 0.3)
    }

    func testSaturateAddsChromaAtTheSameLightnessAndStaysDisplayable() {
        let green = Color.proGreen._500.toColor()
        let source = green.resolvedOKLCH(for: .light)
        let vivid = green.saturate().resolvedOKLCH(for: .light)
        XCTAssertGreaterThan(vivid.c, source.c)
        XCTAssertEqual(vivid.lightnessStar, source.lightnessStar, accuracy: 0.3)
        XCTAssertTrue(Gamut.contains(lightness: Double(vivid.l), chroma: Double(vivid.c) * 0.999, hue: Double(vivid.h)))
    }

    // MARK: - Hue

    func testRotatingAFullTurnGivesTheSameColour() {
        XCTAssertEqual(blue._500.toColor().rotateHue(by: .degrees(360)).hex(), blue._500.toColor().hex())
    }

    // A rotated palette color is the same stop of another hue's ramp, so it keeps the stop's lightness.
    func testRotatingAPaletteColourLandsOnTheSameStopOfTheNewHue() {
        let rotated = blue._500.toColor().rotateHue(by: .degrees(120))
        let expected = ProColor.primary(forHue: 251 + 120)._500
        XCTAssertEqual(rotated.hex(), expected.toColor().hex())
    }

    // MARK: - Mixing and inversion

    func testBlendEndsAreTheTwoColours() {
        let a = blue._500.toColor(), b = Color.proPink._500.toColor()
        XCTAssertEqual(a.blend(with: b, by: 0).hex(), a.hex())
        XCTAssertEqual(a.blend(with: b, by: 1).hex(), b.hex())
    }

    // Invert keeps the hue and mirrors the stop, so inverting twice changes nothing.
    func testInvertMirrorsTheStopAndKeepsTheHue() {
        XCTAssertEqual(blue._200.toColor().invert().hex(), blue._850.toColor().hex())
        XCTAssertEqual(blue._200.toColor().invert().invert().hex(), blue._200.toColor().hex())
    }

    // Surfaces are translucent. Adjusting one must not change its opacity.
    func testAdjustmentsKeepOpacity() {
        let surface = blue._200.toColor().opacity(0.5)
        XCTAssertEqual(Double(surface.lighten().resolvedOKLCH(for: .light).alpha), 0.5, accuracy: 0.01)
        XCTAssertEqual(Double(surface.rotateHue(by: .degrees(90)).resolvedOKLCH(for: .light).alpha), 0.5, accuracy: 0.01)
    }
}
