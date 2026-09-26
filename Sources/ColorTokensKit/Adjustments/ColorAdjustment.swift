//
//  ColorAdjustment.swift
//  ColorTokensKit
//
//  The math behind the color functions, applied to one resolved color (one
//  appearance). The public API in Color+Adjustments runs these at draw time.
//
//  Lightness and hue changes keep palette colors on the palette: a color that sits
//  on a ColorTokensKit stop comes back as another exact stop, so contrast stays
//  predictable. Any other color moves by the same visual step, keeping its hue and
//  as much of its chroma as sRGB can show.
//

import Foundation

enum ColorAdjustment {
    /// Moves a color `stops` steps down the lightness ladder; negative steps go lighter.
    static func shiftingLightness(of color: OKLCHColor, byStops stops: Int) -> OKLCHColor {
        moving(color) { position in position + Double(stops) }
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
        moving(color) { position in Double(ColorConstants.rampStops - 1) - position }
    }

    /// The color's hue and chroma at a stop position on its ladder (0 is _50). Palette colors snap to the nearest stop.
    static func placing(_ color: OKLCHColor, atStopPosition position: Double) -> OKLCHColor {
        moving(color) { _ in position }
    }

    /// Moves a color to a new position on its lightness ladder (0 is _50), keeping its hue and chroma.
    /// A palette color lands on the exact stop there; any other color moves continuously.
    private static func moving(_ color: OKLCHColor, to newPosition: (Double) -> Double) -> OKLCHColor {
        if let stop = PaletteStop(color) {
            let index = Int(newPosition(Double(stop.index)).rounded())
            return PaletteStop(hue: stop.hue, index: index, isGray: stop.isGray).color(alpha: color.alpha)
        }
        let ladder = StopLadder.ladder(for: color)
        let position = newPosition(ladder.position(ofLightnessStar: color.lightnessStar))
        return Gamut.fitted(
            lightnessStar: ladder.lightnessStar(atPosition: position),
            chroma: Double(color.c), hue: Double(color.h), alpha: Double(color.alpha)
        )
    }

    /// Mixes two colors in OKLab. `fraction` 0 gives `color`, 1 gives `other`.
    static func blending(_ color: OKLCHColor, with other: OKLCHColor, by fraction: Double) -> OKLCHColor {
        let (start, end) = sharingColorAcrossTransparency(color, other)
        let mixed = start.toOKLab().lerp(end.toOKLab(), t: CGFloat(min(max(fraction, 0), 1)))
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
