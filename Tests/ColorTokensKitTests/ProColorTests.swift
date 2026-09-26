@testable import ColorTokensKit
import SwiftUI
import XCTest

final class ProColorTests: XCTestCase {
    // A brand hex gives the same ramp as its hue, so a hex-built family has the palette's contrast at every stop.
    func testHexFamilyHasTheSameStopsAsItsHue() {
        let fromHex = ProColor(hex: "#00B386")
        let fromHue = ProColor.primary(forHue: Double(OKLCHColor(hex: "#00B386").h))
        XCTAssertEqual(fromHex.allStops.map { $0.toColor().hex() }, fromHue.allStops.map { $0.toColor().hex() })
    }

    // The family's own color is the brand color itself, so `brand.toColor()` draws exactly what the brand guide says.
    func testHexFamilyKeepsTheHexAsItsOwnColor() {
        XCTAssertEqual(ProColor(hex: "#00B386").toColor().hex(), "#00b386")
    }

    // A gray has no meaningful hue: its hue number is noise, which primary(forHue:) turns into a colorful ramp.
    // ProColor(hex:) gives the gray family instead, so a gray brand stays gray.
    func testGrayHexGivesTheGrayFamily() {
        XCTAssertEqual(ProColor(hex: "#333333")._450.toColor().hex(), Color.proGray._450.toColor().hex())
    }
}
