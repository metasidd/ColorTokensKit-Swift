@testable import ColorTokensKit
import SwiftUI
import XCTest

final class ProThemeTests: XCTestCase {
    // A brand hex gives the same ramp as its hue, so a hex-built family has the palette's contrast at every stop.
    func testHexFamilyHasTheSameStopsAsItsHue() {
        let fromHex = ProTheme(hex: "#00B386")
        let fromHue = ProTheme.primary(forHue: Double(OKLCHColor(hex: "#00B386").h))
        XCTAssertEqual(fromHex.allStops.map { $0.toColor().hex() }, fromHue.allStops.map { $0.toColor().hex() })
    }

    // The family's own color is the brand color itself, so `brand.toColor()` draws exactly what the brand guide says.
    // A brand hex is sRGB, so the check is in sRGB.
    func testHexFamilyKeepsTheHexAsItsOwnColor() {
        XCTAssertEqual(ProTheme(hex: "#00B386").toColor().resolvedOKLCH(for: .light).sRGBHex, "#00b386")
    }

    // A gray has no meaningful hue: its hue number is noise, which primary(forHue:) turns into a colorful ramp.
    // ProTheme(hex:) gives the gray family instead, so a gray brand stays gray.
    func testGrayHexGivesTheGrayFamily() {
        XCTAssertEqual(ProTheme(hex: "#333333")._450.toColor().hex(), Color.proGray._450.toColor().hex())
    }

    // Apps written for 2.x keep compiling after the rename: ProColor is the same type under its old name, so their
    // families, stops and tokens don't change.
    @available(*, deprecated)
    func testTheOldNameStillWorks() {
        let family: ProColor = .primary(forHue: 250)
        XCTAssertEqual(family, Color.proBlue)
        XCTAssertEqual(ProColor(hex: "#00B386"), ProTheme(hex: "#00B386"))
    }
}
