//
//  ColorAdjustment.swift
//  ColorTokensKit
//
//  The maths behind the color functions, applied to one resolved color (one
//  appearance). The public API in Color+Adjustments runs these at draw time.
//
//  Palette colors move along the palette: a color that sits on a ColorTokensKit
//  stop comes back as another exact stop, so contrast stays predictable. Any other
//  color moves by the same visual step, keeping its hue and as much of its chroma
//  as sRGB can show.
//

import Foundation

enum ColorAdjustment {
    /// Moves a color `stops` steps down the lightness ladder; negative steps go lighter.
    static func shiftingLightness(of color: OKLCHColor, byStops stops: Int) -> OKLCHColor {
        if let stop = PaletteStop(color) {
            return stop.moved(by: stops).color(alpha: color.alpha)
        }
        let ladder = StopLadder.ladder(for: color)
        let position = ladder.position(ofLightnessStar: color.lightnessStar) + Double(stops)
        return Gamut.fitted(
            lightnessStar: ladder.lightnessStar(atPosition: position),
            chroma: Double(color.c), hue: Double(color.h), alpha: Double(color.alpha)
        )
    }

    /// Scales chroma by `factor` at the same lightness and hue. The result leaves the palette on purpose.
    static func scalingChroma(of color: OKLCHColor, by factor: Double) -> OKLCHColor {
        guard !color.isAchromatic else { return color }
        return Gamut.fitted(
            lightnessStar: color.lightnessStar,
            chroma: Double(color.c) * max(factor, 0), hue: Double(color.h), alpha: Double(color.alpha)
        )
    }

    /// Turns the hue by `degrees` at the same lightness. A palette color lands on the same stop of the new hue's ramp.
    static func rotatingHue(of color: OKLCHColor, byDegrees degrees: Double) -> OKLCHColor {
        guard !color.isAchromatic else { return color }
        if let stop = PaletteStop(color) {
            return stop.rotated(byDegrees: degrees).color(alpha: color.alpha)
        }
        return Gamut.fitted(
            lightnessStar: color.lightnessStar,
            chroma: Double(color.c), hue: (Double(color.h) + degrees).normalizedHue, alpha: Double(color.alpha)
        )
    }

    /// Mirrors a color's lightness on its ladder (_200 ↔ _850), keeping its hue.
    static func invertingLightness(of color: OKLCHColor) -> OKLCHColor {
        if let stop = PaletteStop(color) {
            return stop.mirrored().color(alpha: color.alpha)
        }
        let ladder = StopLadder.ladder(for: color)
        let position = Double(ladder.lastIndex) - ladder.position(ofLightnessStar: color.lightnessStar)
        return Gamut.fitted(
            lightnessStar: ladder.lightnessStar(atPosition: position),
            chroma: Double(color.c), hue: Double(color.h), alpha: Double(color.alpha)
        )
    }

    /// The color's hue and chroma at a stop position on its ladder (0 is _50). Palette colors snap to the nearest stop.
    static func placing(_ color: OKLCHColor, atStopPosition position: Double) -> OKLCHColor {
        if let stop = PaletteStop(color) {
            return PaletteStop(hue: stop.hue, index: Int(position.rounded()), isGray: stop.isGray).color(alpha: color.alpha)
        }
        return Gamut.fitted(
            lightnessStar: StopLadder.ladder(for: color).lightnessStar(atPosition: position),
            chroma: Double(color.c), hue: Double(color.h), alpha: Double(color.alpha)
        )
    }

    /// Mixes two colors in OKLab. `fraction` 0 gives `color`, 1 gives `other`.
    static func blending(_ color: OKLCHColor, with other: OKLCHColor, by fraction: Double) -> OKLCHColor {
        let (start, end) = sharingColorAcrossTransparency(color, other)
        let a = start.toOKLab(), b = end.toOKLab()
        let t = CGFloat(min(max(fraction, 0), 1))
        let mixed = OKLabColor(
            l: a.l + (b.l - a.l) * t,
            a: a.a + (b.a - a.a) * t,
            b: a.b + (b.b - a.b) * t,
            alpha: a.alpha + (b.alpha - a.alpha) * t
        )
        return Gamut.fitted(mixed.toOKLCH())
    }

    /// A fully transparent end takes the other end's color, so fading to `.clear` only fades
    /// instead of drifting toward whatever color `.clear` is stored as.
    static func sharingColorAcrossTransparency(_ a: OKLCHColor, _ b: OKLCHColor) -> (OKLCHColor, OKLCHColor) {
        if a.alpha < 0.001 { return (OKLCHColor(l: b.l, c: b.c, h: b.h, alpha: a.alpha), b) }
        if b.alpha < 0.001 { return (a, OKLCHColor(l: a.l, c: a.c, h: a.h, alpha: b.alpha)) }
        return (a, b)
    }
}
