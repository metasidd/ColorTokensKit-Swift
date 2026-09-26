//
//  PaletteStop.swift
//  ColorTokensKit
//
//  A color that sits exactly on a ColorTokensKit ramp: its hue plus its stop.
//  Because every chromatic ramp shares one lightness per stop, and each stop's
//  chroma is the sRGB limit at its hue, a color's lightness says which stop it is
//  and its hue says which ramp. Color
//  functions use this to move palette colors stop by stop, so their results are
//  real palette colors and contrast stays predictable.
//

import Foundation

struct PaletteStop {
    /// OKLCH hue of the ramp. Gray has no hue and ignores it.
    let hue: Double
    /// 0 is _50, 19 is _1000.
    let index: Int
    let isGray: Bool

    /// How far a color may sit from a stop and still count as it: enough for 8-bit rounding and float
    /// noise, and far less than the 3.5 L* or more between neighboring stops.
    static let lightnessTolerance = 0.6
    /// The same for chroma.
    static let chromaTolerance = 0.006

    init(hue: Double, index: Int, isGray: Bool) {
        self.hue = hue
        self.index = min(max(index, 0), ColorConstants.rampStops - 1)
        self.isGray = isGray
    }

    /// The palette stop this color is, or nil when it isn't a palette color.
    init?(_ color: OKLCHColor) {
        let lightnessStar = color.lightnessStar
        if color.isAchromatic {
            guard let index = StopLadder.gray.stop(atLightnessStar: lightnessStar, tolerance: Self.lightnessTolerance) else {
                return nil
            }
            self.init(hue: 0, index: index, isGray: true)
            return
        }
        guard let index = StopLadder.chromatic.stop(atLightnessStar: lightnessStar, tolerance: Self.lightnessTolerance),
              UniformRamp.isChroma(Double(color.c), atStop: index, hue: Double(color.h), tolerance: Self.chromaTolerance)
        else {
            return nil
        }
        self.init(hue: Double(color.h), index: index, isGray: false)
    }

    /// The palette color at this stop.
    func color(alpha: CGFloat) -> OKLCHColor {
        let stop = ColorRampGenerator.shared.getOKLCHColorRamp(forHue: hue, isGrayscale: isGray)[index]
        return OKLCHColor(l: stop.l, c: stop.c, h: stop.h, alpha: alpha)
    }

    /// The same stop on the ramp `degrees` around the hue wheel. Gray has no hue, so it stays gray.
    func rotated(byDegrees degrees: Double) -> PaletteStop {
        isGray ? self : PaletteStop(hue: (hue + degrees).normalizedHue, index: index, isGray: false)
    }
}
