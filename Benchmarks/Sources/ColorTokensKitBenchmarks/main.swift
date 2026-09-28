//
//  main.swift
//  ColorTokensKitBenchmarks
//
//  What it costs to make and draw ColorTokensKit colors, the way a SwiftUI view does:
//  a view rebuilds its colors every time its body runs, then SwiftUI resolves them to draw.
//  Run a release build, since debug builds of the library are several times slower:
//
//      swift run -c release --package-path Benchmarks
//

import ColorTokensKit
import SwiftUI

let family = Color.proBlue
let lightMode = EnvironmentValues()
var sink: Float = 0

/// A token built the way apps build them, e.g. `backgroundSecondary`.
func topToken() -> Color { Color(light: family._100.toColor(), dark: family._800.toColor()) }
func bottomToken() -> Color { Color(light: family._300.toColor(), dark: family._600.toColor()) }

/// Runs `body` five rounds of `iterations` and prints the fastest round's time per iteration.
@MainActor
func measure(_ name: String, iterations: Int = 2000, _ body: () -> Void) {
    let clock = ContinuousClock()
    let fastest = (0 ..< 5).map { _ in
        clock.measure { for _ in 0 ..< iterations { body() } }
    }.min()!
    let microseconds = Double(fastest.components.seconds) * 1e6 + Double(fastest.components.attoseconds) / 1e12
    print(name.padding(toLength: 46, withPad: " ", startingAt: 0) + String(format: "%9.2f µs", microseconds / Double(iterations)))
}

/// Draws a small view filled with `style`, so every color in it is resolved.
@MainActor
func draw(_ style: some ShapeStyle) {
    _ = ImageRenderer(content: Rectangle().fill(style).frame(width: 8, height: 64)).cgImage
}

MainActor.assumeIsolated {
    measure("Token: make and draw") { sink += topToken().resolve(in: lightMode).red }
    measure("Token: make, draw 25 times", iterations: 200) {
        let token = topToken()
        for _ in 0 ..< 25 { sink += token.resolve(in: lightMode).red }
    }
    measure("soften(): make and draw") { sink += topToken().soften().resolve(in: lightMode).red }
    measure("soften(): make, draw 25 times (a grid)", iterations: 200) {
        let softened = topToken().soften()
        for _ in 0 ..< 25 { sink += softened.resolve(in: lightMode).red }
    }
    measure("proGradient: make") { _ = [topToken(), bottomToken()].proGradient() }
    measure("proGradient(.sheen): make") { _ = Color.white.proGradient(.sheen) }
    measure("LinearGradient: make and draw", iterations: 300) {
        draw(LinearGradient(colors: [topToken(), bottomToken()], startPoint: .top, endPoint: .bottom))
    }
    measure("proGradient: make and draw", iterations: 300) { draw([topToken(), bottomToken()].proGradient()) }
    measure("proGradient(.sheen): make and draw", iterations: 300) { draw(Color.white.proGradient(.sheen)) }
    measure("Border, 3-color LinearGradient: make and draw", iterations: 300) {
        draw(LinearGradient(colors: [.clear, bottomToken(), .clear], startPoint: .top, endPoint: .bottom))
    }
    measure("Border, .edgeHighlight: make and draw", iterations: 300) { draw(bottomToken().proGradient(.edgeHighlight)) }
}
print(sink > 0 ? "" : " ")
