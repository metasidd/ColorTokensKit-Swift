//
//  GradientStops.swift
//  ColorTokensKit
//
//  Builds the stops behind every smooth gradient. SwiftUI can only blend between
//  neighboring stops in its own way, so this adds in-between colors along the path
//  the blend asks for (round the color wheel, or a straight line), close enough
//  that SwiftUI's blending between them never shows. The stops are spaced evenly
//  along that path and placed along the gradient by its easing. Each in-between
//  color is worked out when drawn, so a gradient between tokens stays adaptive.
//

import SwiftUI

enum GradientStops {
    /// Steps per unit of OKLab distance between two colors. Pure blue and pure yellow (0.73 apart)
    /// get about 30; a fade within one hue gets a handful. Measured to keep SwiftUI's own blending
    /// between neighbors under about 3 ΔE2000 for the most saturated pairs, and under 1 for UI colors.
    static let stepsPerUnitDistance = 40.0

    /// Fewest and most steps for one pair of colors.
    static let stepRange = 2 ... 32

    /// How many steps a pair of colors needs, from how far apart they are in either appearance.
    static func steps(from start: Color, to end: Color) -> Int {
        let distance = ColorScheme.allCases.map { colorScheme in
            let (a, b) = ColorAdjustment.sharingColorAcrossTransparency(
                start.resolvedOKLCH(for: colorScheme), end.resolvedOKLCH(for: colorScheme)
            )
            return Gamut.differenceOK(a, b)
        }.max() ?? 0
        let steps = Int((distance * stepsPerUnitDistance).rounded(.up))
        return min(max(steps, stepRange.lowerBound), stepRange.upperBound)
    }

    /// Stops through `colors`, blended with `blend` and placed along the gradient with `easing`.
    /// `closingLoop` returns to the first color at the end, which angular gradients need to avoid a seam.
    static func smooth(
        _ colors: [Color],
        blend: ProGradient.Blend,
        easing: ProGradient.Easing,
        closingLoop: Bool = false
    ) -> [Gradient.Stop] {
        var colors = colors
        if closingLoop, colors.count > 1, let first = colors.first, colors.last != first {
            colors.append(first)
        }
        guard let last = colors.last else { return [] }
        guard colors.count > 1 else {
            return [Gradient.Stop(color: last, location: 0), Gradient.Stop(color: last, location: 1)]
        }

        let segments = Double(colors.count - 1)
        var stops: [Gradient.Stop] = []
        for (index, (start, end)) in zip(colors, colors.dropFirst()).enumerated() {
            let steps = steps(from: start, to: end)
            for step in 0 ..< steps {
                let t = Double(step) / Double(steps)
                let location = easing.location(forProgress: (Double(index) + t) / segments)
                let color = step == 0 ? start : Color.adapting(combining: [start, end]) { resolved, _ in
                    interpolate(resolved[0], resolved[1], at: t, blend: blend)
                }
                stops.append(Gradient.Stop(color: color, location: location))
            }
        }
        stops.append(Gradient.Stop(color: last, location: 1))
        return stops
    }

    /// The color `t` of the way from `start` to `end`: round the hue wheel for `.vivid` and
    /// `.rainbow`, or a straight line through OKLab for `.direct`.
    static func interpolate(_ start: OKLCHColor, _ end: OKLCHColor, at t: Double, blend: ProGradient.Blend) -> OKLCHColor {
        if blend == .direct {
            return ColorAdjustment.blending(start, with: end, by: t)
        }
        let (start, end) = ColorAdjustment.sharingColorAcrossTransparency(start, end)
        // A color with no visible hue borrows the other end's, so gray → blue doesn't sweep through other hues.
        let startHue = Double(start.isAchromatic ? end.h : start.h)
        let endHue = Double(end.isAchromatic ? start.h : end.h)
        let fraction = CGFloat(t)
        return Gamut.fitted(OKLCHColor(
            l: start.l + (end.l - start.l) * fraction,
            c: start.c + (end.c - start.c) * fraction,
            h: hue(from: startHue, to: endHue, at: t, theLongWay: blend == .rainbow),
            alpha: start.alpha + (end.alpha - start.alpha) * fraction
        ))
    }

    /// The hue `t` of the way from `start` to `end`, the short way round the wheel or the long way.
    private static func hue(from start: Double, to end: Double, at t: Double, theLongWay: Bool) -> Double {
        var delta = end - start
        if delta > 180 { delta -= 360 } else if delta < -180 { delta += 360 }
        if theLongWay { delta += delta > 0 ? -360 : 360 }
        return (start + delta * t).normalizedHue
    }
}
