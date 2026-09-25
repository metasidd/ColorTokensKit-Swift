@testable import ColorTokensKit
import SwiftUI
import XCTest

final class GradientTests: XCTestCase {
    private let blue = Color(red: 0, green: 0, blue: 1)
    private let yellow = Color(red: 1, green: 1, blue: 0)

    /// The resolved colors of a gradient's stops, in order.
    private func resolved(_ stops: [Gradient.Stop], _ appearance: Appearance = .light) -> [OKLCHColor] {
        stops.map { $0.color.resolvedOKLCH(for: appearance) }
    }

    /// The stop nearest a location, e.g. the middle of a two-color gradient.
    private func stop(nearest location: Double, in stops: [Gradient.Stop]) -> Gradient.Stop {
        stops.min { abs($0.location - location) < abs($1.location - location) }!
    }

    /// Distance between two colors in OKLab: about 0.01 is just noticeable side by side.
    private func distance(_ a: OKLCHColor, _ b: OKLCHColor) -> Double {
        let x = a.toOKLab(), y = b.toOKLab()
        return Double(sqrt(pow(x.l - y.l, 2) + pow(x.a - y.a, 2) + pow(x.b - y.b, 2)))
    }

    // MARK: - The path

    // Blending blue → yellow in RGB (SwiftUI's `.device` space) passes through gray; `.vivid` keeps its color.
    func testVividKeepsTheMiddleOfBlueToYellowColorful() {
        let middle = GradientStops.interpolate(blue.resolvedOKLCH(for: .light), yellow.resolvedOKLCH(for: .light), at: 0.5, blend: .vivid)
        XCTAssertGreaterThan(middle.c, 0.08)
        let shown = stop(nearest: 0.5, in: GradientStops.smooth([blue, yellow], blend: .vivid, easing: .smooth))
        XCTAssertGreaterThan(shown.color.resolvedOKLCH(for: .light).c, 0.08)
    }

    // `.direct` promises SwiftUI's own look: a straight line through OKLab. In the iOS 17–27 simulators,
    // SwiftUI's default blue → yellow gradient meets at #6cabc7, so `.direct` must meet there too.
    func testDirectMatchesSwiftUIsOwnGradient() {
        let middle = GradientStops.interpolate(blue.resolvedOKLCH(for: .light), yellow.resolvedOKLCH(for: .light), at: 0.5, blend: .direct)
        XCTAssertEqual(middle.hex, "#6cabc7")
    }

    func testRainbowGoesTheLongWayRound() {
        let red = Color.proRed._500.toColor().resolvedOKLCH(for: .light) // hue 24°
        let gold = Color.proGold._500.toColor().resolvedOKLCH(for: .light) // hue 78°
        XCTAssertEqual(Double(GradientStops.interpolate(red, gold, at: 0.5, blend: .vivid).h), 51, accuracy: 2)
        XCTAssertEqual(Double(GradientStops.interpolate(red, gold, at: 0.5, blend: .rainbow).h), 231, accuracy: 2)
    }

    // MARK: - Easing

    // The default must be gentler than linear at both ends, so a gradient has no hard edge where it meets
    // the colors around it; it stays symmetric, so the middle color sits in the middle.
    func testSmoothEasingStartsAndEndsGently() {
        let smooth = ProGradient.Easing.smooth
        XCTAssertGreaterThan(smooth.location(forProgress: 0.1), 0.15)
        XCTAssertLessThan(smooth.location(forProgress: 0.9), 0.85)
        XCTAssertEqual(smooth.location(forProgress: 0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(ProGradient.Easing.linear.location(forProgress: 0.3), 0.3, accuracy: 0.000_001)
    }

    func testEaseInStartsSlowlyAndEaseOutStartsQuickly() {
        XCTAssertGreaterThan(ProGradient.Easing.easeIn.location(forProgress: 0.5), 0.55)
        XCTAssertLessThan(ProGradient.Easing.easeOut.location(forProgress: 0.5), 0.45)
    }

    func testACustomCurveBehavesLikeTheBuiltInOneWithTheSameShape() {
        XCTAssertEqual(ProGradient.Easing.timingCurve(0.42, 0, 0.58, 1), .easeInOut)
    }

    // Easing moves where the colors land, not which colors appear: the ends stay put and stops stay in order.
    func testEasingKeepsTheEndsAndTheOrder() {
        let stops = GradientStops.smooth([Color.proBlue._200.toColor(), Color.proBlue._800.toColor()], blend: .vivid, easing: .smooth)
        XCTAssertEqual(stops.first?.location, 0)
        XCTAssertEqual(stops.last?.location, 1)
        XCTAssertEqual(stops.map(\.location), stops.map(\.location).sorted())
        let early = stop(nearest: 0.1, in: stops).color.resolvedOKLCH(for: .light).lightnessStar
        let start = Color.proBlue._200.toColor().resolvedOKLCH(for: .light).lightnessStar
        let end = Color.proBlue._800.toColor().resolvedOKLCH(for: .light).lightnessStar
        XCTAssertLessThan((start - early) / (start - end), 0.1, "the first tenth changes less than a tenth of the way")
    }

    // MARK: - Steps

    // Far-apart colors need more steps to follow their path; close ones need few, which keeps drawing cheap.
    func testDistantColorsGetMoreStepsThanCloseOnes() {
        let family = Color.proBlue
        XCTAssertGreaterThanOrEqual(GradientStops.steps(from: blue, to: yellow), 24)
        XCTAssertLessThanOrEqual(GradientStops.steps(from: family._100.toColor(), to: family._300.toColor()), 8)
        XCTAssertEqual(GradientStops.steps(from: blue, to: blue), GradientStops.stepRange.lowerBound)
    }

    // Between two steps SwiftUI blends in its own way. The steps must be close enough that this never shows,
    // even for the most saturated pair: halfway between neighbors, an RGB blend stays within 0.03 of the true path.
    func testStepsAreCloseEnoughThatSwiftUIsOwnBlendingDoesNotShow() {
        let start = blue.resolvedOKLCH(for: .light), end = yellow.resolvedOKLCH(for: .light)
        let stops = GradientStops.smooth([blue, yellow], blend: .vivid, easing: .linear)
        for (a, b) in zip(stops, stops.dropFirst()) {
            let x = a.color.resolvedOKLCH(for: .light).toRGB(), y = b.color.resolvedOKLCH(for: .light).toRGB()
            let rgbBlend = RGBColor(r: (x.r + y.r) / 2, g: (x.g + y.g) / 2, b: (x.b + y.b) / 2, alpha: 1).toOKLCH()
            let truth = GradientStops.interpolate(start, end, at: (a.location + b.location) / 2, blend: .vivid)
            XCTAssertLessThan(distance(rgbBlend, truth), 0.03, "between \(a.location) and \(b.location)")
        }
    }

    func testStopsRunEvenlyFromTheFirstColorToTheLast() {
        let pink = Color.proPink._500.toColor()
        let stops = GradientStops.smooth([blue, yellow, pink], blend: .vivid, easing: .smooth)
        XCTAssertEqual(stops.count, GradientStops.steps(from: blue, to: yellow) + GradientStops.steps(from: yellow, to: pink) + 1)
        XCTAssertEqual(stops.first?.location, 0)
        XCTAssertEqual(stops.last?.location, 1)
        XCTAssertEqual(stops.map(\.location), stops.map(\.location).sorted())
        XCTAssertEqual(stop(nearest: 0.5, in: stops).color.hex(), yellow.hex())
        XCTAssertEqual(stops.first?.color.hex(), blue.hex())
        XCTAssertEqual(stops.last?.color.hex(), pink.hex())
    }

    // MARK: - Transparency, loops and appearances

    // Fading to .clear should only fade. The color keeps its hue, lightness and chroma instead of drifting toward black.
    func testFadingToClearKeepsTheColor() {
        let source = Color.proBlue._500.toColor()
        let colors = resolved(GradientStops.smooth([source, .clear], blend: .vivid, easing: .smooth))
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
        let stops = GradientStops.smooth([blue, yellow], blend: .vivid, easing: .smooth, closingLoop: true)
        XCTAssertEqual(stops.first?.color.hex(), stops.last?.color.hex())
    }

    // A gradient between tokens stays adaptive, so it's right in both appearances.
    func testGradientsBetweenTokensWorkInBothAppearances() {
        let family = Color.proBlue
        let top = Color(light: family._100.toColor(), dark: family._800.toColor())
        let bottom = Color(light: family._300.toColor(), dark: family._600.toColor())
        let middle = stop(nearest: 0.5, in: GradientStops.smooth([top, bottom], blend: .vivid, easing: .smooth)).color
        XCTAssertGreaterThan(middle.resolvedOKLCH(for: .light).lightnessStar, 70)
        XCTAssertLessThan(middle.resolvedOKLCH(for: .dark).lightnessStar, 50)
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
