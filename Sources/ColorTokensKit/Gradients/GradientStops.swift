//
//  GradientStops.swift
//  ColorTokensKit
//
//  Builds the stops behind every smooth gradient. Between each pair of colors it
//  adds in-between colors interpolated in OKLCH, so SwiftUI only ever blends
//  colors that are already close and never passes through gray. Each in-between
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
        let distance = [Appearance.light, .dark].map { appearance in
            let (a, b) = ColorAdjustment.sharingColorAcrossTransparency(
                start.resolvedOKLCH(for: appearance), end.resolvedOKLCH(for: appearance)
            )
            return Gamut.differenceOK(a, b)
        }.max() ?? 0
        let steps = Int((distance * stepsPerUnitDistance).rounded(.up))
        return min(max(steps, stepRange.lowerBound), stepRange.upperBound)
    }

    /// Stops through `colors`, each color evenly spaced, with smooth colors between each pair.
    /// `closingLoop` returns to the first color at the end, which angular gradients need to avoid a seam.
    static func smooth(_ colors: [Color], hue: ProGradient.HuePath, closingLoop: Bool = false) -> [Gradient.Stop] {
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
            stops.append(Gradient.Stop(color: start, location: Double(index) / segments))
            let steps = steps(from: start, to: end)
            for step in 1 ..< steps {
                let t = Double(step) / Double(steps)
                let color = Color.adapting(combining: [start, end]) { resolved, _ in
                    interpolate(resolved[0], resolved[1], at: t, hue: hue)
                }
                stops.append(Gradient.Stop(color: color, location: (Double(index) + t) / segments))
            }
        }
        stops.append(Gradient.Stop(color: last, location: 1))
        return stops
    }

    /// The color `t` of the way from `start` to `end`, interpolated in OKLCH.
    static func interpolate(_ start: OKLCHColor, _ end: OKLCHColor, at t: Double, hue path: ProGradient.HuePath) -> OKLCHColor {
        let (start, end) = ColorAdjustment.sharingColorAcrossTransparency(start, end)
        // A color with no visible hue borrows the other end's, so gray → blue doesn't sweep through other hues.
        let startHue = Double(start.isAchromatic ? end.h : start.h)
        let endHue = Double(end.isAchromatic ? start.h : end.h)
        let fraction = CGFloat(t)
        return Gamut.fitted(OKLCHColor(
            l: start.l + (end.l - start.l) * fraction,
            c: start.c + (end.c - start.c) * fraction,
            h: path.hue(from: startHue, to: endHue, at: t),
            alpha: start.alpha + (end.alpha - start.alpha) * fraction
        ))
    }
}
