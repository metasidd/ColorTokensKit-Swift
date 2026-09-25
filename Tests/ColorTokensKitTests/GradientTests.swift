@testable import ColorTokensKit
import SwiftUI
import XCTest

final class GradientTests: XCTestCase {
    private let blue = Color(red: 0, green: 0, blue: 1)
    private let yellow = Color(red: 1, green: 1, blue: 0)
    private let middle = GradientStops.stepsPerSegment / 2

    /// The resolved colors of a gradient's stops, in order.
    private func resolved(_ stops: [Gradient.Stop], _ appearance: Appearance = .light) -> [OKLCHColor] {
        stops.map { $0.color.resolvedOKLCH(for: appearance) }
    }

    // Blending blue → yellow in RGB (SwiftUI's `.device` space) passes through gray; OKLCH keeps its color.
    func testTheMiddleOfBlueToYellowIsNotGray() {
        let middleColor = resolved(GradientStops.smooth([blue, yellow], hue: .shorter))[middle]
        XCTAssertGreaterThan(middleColor.c, 0.08)
    }

    func testStopsRunEvenlyFromTheFirstColorToTheLast() {
        let pink = Color.proPink._500.toColor()
        let stops = GradientStops.smooth([blue, yellow, pink], hue: .shorter)
        XCTAssertEqual(stops.count, 2 * GradientStops.stepsPerSegment + 1)
        XCTAssertEqual(stops.first?.location, 0)
        XCTAssertEqual(stops.last?.location, 1)
        XCTAssertEqual(stops.map(\.location), stops.map(\.location).sorted())
        XCTAssertEqual(stops.first?.color.hex(), blue.hex())
        XCTAssertEqual(stops.last?.color.hex(), pink.hex())
    }

    // Fading to .clear should only fade. The color keeps its hue, lightness and chroma instead of drifting toward black.
    func testFadingToClearKeepsTheColor() {
        let source = Color.proBlue._500.toColor()
        let colors = resolved(GradientStops.smooth([source, .clear], hue: .shorter))
        let original = source.resolvedOKLCH(for: .light)
        for color in colors.dropLast() {
            XCTAssertEqual(Double(color.h), Double(original.h), accuracy: 1)
            XCTAssertEqual(color.lightnessStar, original.lightnessStar, accuracy: 0.5)
            XCTAssertEqual(Double(color.c), Double(original.c), accuracy: 0.005)
        }
        let alphas = colors.map { Double($0.alpha) }
        XCTAssertEqual(alphas, alphas.sorted(by: >))
        XCTAssertEqual(alphas.last ?? 1, 0, accuracy: 0.001)
    }

    // An angular gradient must end where it starts, or the ring shows a seam.
    func testAngularGradientsCloseTheLoop() {
        let stops = GradientStops.smooth([blue, yellow], hue: .shorter, closingLoop: true)
        XCTAssertEqual(stops.first?.color.hex(), stops.last?.color.hex())
    }

    func testTheLongerHuePathGoesTheOtherWayRound() {
        let red = Color.proRed._500.toColor(), gold = Color.proGold._500.toColor() // hues 24° and 78°
        let shorter = resolved(GradientStops.smooth([red, gold], hue: .shorter))[middle]
        let longer = resolved(GradientStops.smooth([red, gold], hue: .longer))[middle]
        XCTAssertEqual(Double(shorter.h), 51, accuracy: 2)
        XCTAssertEqual(Double(longer.h), 231, accuracy: 2)
    }

    // A gradient between tokens stays adaptive, so it's right in both appearances.
    func testGradientsBetweenTokensWorkInBothAppearances() {
        let family = Color.proBlue
        let top = Color(light: family._100.toColor(), dark: family._800.toColor())
        let bottom = Color(light: family._300.toColor(), dark: family._600.toColor())
        let middleColor = GradientStops.smooth([top, bottom], hue: .shorter)[middle].color
        XCTAssertGreaterThan(middleColor.resolvedOKLCH(for: .light).lightnessStar, 70)
        XCTAssertLessThan(middleColor.resolvedOKLCH(for: .dark).lightnessStar, 50)
    }

    // MARK: - Recipes

    func testRecipesMakeTheColorsTheyDescribe() {
        let source = Color.proBlue._500.toColor()
        XCTAssertEqual(ProGradient.Recipe.subtle.colors(from: source).first?.hex(), Color.proBlue._450.toColor().hex())

        let fade = ProGradient.Recipe.fade.colors(from: source)
        XCTAssertEqual(Double(fade.last?.resolvedOKLCH(for: .light).alpha ?? 1), 0, accuracy: 0.001)

        let tonal = ProGradient.Recipe.tonal.colors(from: source).map { $0.resolvedOKLCH(for: .light).lightnessStar }
        XCTAssertEqual(tonal, tonal.sorted(by: >))

        let sheen = ProGradient.Recipe.sheen.colors(from: .white).map { Double($0.resolvedOKLCH(for: .light).alpha) }
        XCTAssertEqual(sheen.first ?? 1, 0, accuracy: 0.001)
        XCTAssertEqual(sheen.last ?? 1, 0, accuracy: 0.001)
        XCTAssertGreaterThan(sheen[1], 0)

        let edge = ProGradient.Recipe.edgeHighlight.colors(from: source).map { Double($0.resolvedOKLCH(for: .light).alpha) }
        XCTAssertGreaterThan(edge[1], edge[0])
        XCTAssertGreaterThan(edge[1], edge[2])
    }

    func testCustomRecipesAreFirstClass() {
        let deepen = ProGradient.Recipe { [$0, $0.darken(by: 4)] }
        XCTAssertEqual(deepen.colors(from: Color.proBlue._500.toColor()).last?.hex(), Color.proBlue._700.toColor().hex())
    }
}
