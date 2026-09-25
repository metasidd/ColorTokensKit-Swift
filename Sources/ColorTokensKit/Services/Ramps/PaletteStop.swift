//
//  PaletteStop.swift
//  ColorTokensKit
//
//  A color that sits exactly on a ColorTokensKit ramp: its hue plus its stop.
//  Because every chromatic ramp shares one lightness and one chroma per stop, a
//  color's lightness says which stop it is and its hue says which ramp. Color
//  functions use this to move palette colors stop by stop, so their results are
//  real palette colors and contrast stays predictable.
//

import Foundation

struct PaletteStop: Equatable {
    /// OKLCH hue of the ramp. Gray has no hue and ignores it.
    let hue: Double
    /// 0 is _50, 19 is _1000.
    let index: Int
    let isGray: Bool

    /// How far a color may sit from a stop and still count as it: covers 8-bit rounding and float noise.
    static let lightnessTolerance = 0.6
    static let chromaTolerance = 0.006

    private static var lastIndex: Int {
        ColorConstants.rampStops - 1
    }

    init(hue: Double, index: Int, isGray: Bool) {
        self.hue = hue
        self.index = min(max(index, 0), Self.lastIndex)
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
        guard let index = StopLadder.chromatic.stop(atLightnessStar: lightnessStar, tolerance: Self.lightnessTolerance) else {
            return nil
        }
        let chroma = Double(color.c)
        let target = UniformRamp.chroma[index]
        if abs(chroma - target) > Self.chromaTolerance {
            // A hue sRGB can't push to the stop's chroma sits at its gamut limit instead.
            guard chroma < target else { return nil }
            let luminance = Gamut.luminance(lightnessStar: UniformRamp.lightness[index])
            let limit = UniformRamp.gamutMargin * Gamut.maxChroma(luminance: luminance, hue: Double(color.h))
            guard abs(chroma - limit) <= Self.chromaTolerance else { return nil }
        }
        self.init(hue: Double(color.h), index: index, isGray: false)
    }

    /// The palette color at this stop.
    func color(alpha: CGFloat = 1) -> OKLCHColor {
        let stop = ColorRampGenerator.shared.getOKLCHColorRamp(forHue: hue, isGrayscale: isGray)[index]
        return OKLCHColor(l: stop.l, c: stop.c, h: stop.h, alpha: alpha)
    }

    /// The stop `offset` steps darker (negative is lighter), held at the ends of the ramp.
    func moved(by offset: Int) -> PaletteStop {
        PaletteStop(hue: hue, index: index + offset, isGray: isGray)
    }

    /// The same position counted from the other end of the ramp: _200 ↔ _850.
    func mirrored() -> PaletteStop {
        PaletteStop(hue: hue, index: Self.lastIndex - index, isGray: isGray)
    }

    /// The same stop on the ramp `degrees` round the hue wheel. Gray has no hue, so it stays gray.
    func rotated(byDegrees degrees: Double) -> PaletteStop {
        isGray ? self : PaletteStop(hue: (hue + degrees).normalizedHue, index: index, isGray: false)
    }
}
