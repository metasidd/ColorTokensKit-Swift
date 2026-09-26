//
//  GradientStops.swift
//  ColorTokensKit
//
//  Builds the stops behind every smooth gradient. SwiftUI can only blend between
//  neighboring stops in its own way, so this adds in-between colors along the path
//  the blend asks for (around the color wheel, or a straight line), close enough
//  that SwiftUI's blending between them doesn't show. The stops are spaced evenly
//  along that path and placed along the gradient by its easing. Each in-between
//  color is worked out when drawn, so a gradient between tokens stays adaptive.
//

import SwiftUI

enum GradientStops {
    /// Steps per unit of path length (ΔEOK). Measured to keep SwiftUI's own blending between
    /// neighboring stops within about a just-noticeable difference, even for pure blue to pure yellow.
    static let stepsPerUnitDistance = 40.0

    /// How much a change in opacity adds to a path's length. A full fade gets 16 steps, enough to
    /// follow the default easing to within 0.3% opacity.
    static let opacityWeight = 0.4

    /// Fewest and most steps for one pair of colors. Even a close pair gets a color in between,
    /// so it follows its blend's path; 32 bounds the stops a long path adds.
    static let stepRange = 2 ... 32

    /// How many steps a pair of colors needs: the longest path `blend` draws between them in either appearance.
    static func steps(from start: Color, to end: Color, blend: ProGradient.Blend) -> Int {
        let length = ColorScheme.allCases.map { colorScheme in
            pathLength(from: start.resolvedOKLCH(for: colorScheme), to: end.resolvedOKLCH(for: colorScheme), blend: blend)
        }.max() ?? 0
        let steps = Int((length * stepsPerUnitDistance).rounded(.up))
        return min(max(steps, stepRange.lowerBound), stepRange.upperBound)
    }

    /// How far the path `blend` draws from `start` to `end` travels, opacity included, measured over
    /// eight straight pieces. It can be far longer than the distance between the ends: `.rainbow`
    /// between neighboring hues goes most of the way around the wheel.
    static func pathLength(from start: OKLCHColor, to end: OKLCHColor, blend: ProGradient.Blend) -> Double {
        let points = (0 ... 8).map { interpolate(start, end, at: Double($0) / 8, blend: blend) }
        return zip(points, points.dropFirst()).reduce(0) { length, piece in
            length + Gamut.differenceOK(piece.0, piece.1) + abs(Double(piece.1.alpha - piece.0.alpha)) * opacityWeight
        }
    }

    /// `colors` with the first color again at the end, so an angular gradient has no seam. Colors are
    /// compared as drawn, because two tokens built separately are never equal as `Color`s.
    static func closingLoop(_ colors: [Color]) -> [Color] {
        guard colors.count > 1, let first = colors.first, let last = colors.last else { return colors }
        let isClosed = ColorScheme.allCases.allSatisfy { colorScheme in
            pathLength(from: last.resolvedOKLCH(for: colorScheme), to: first.resolvedOKLCH(for: colorScheme), blend: .direct) < 0.001
        }
        return isClosed ? colors : colors + [first]
    }

    /// Stops through `colors`, blended with `blend` and placed along the gradient with `easing`.
    static func smooth(_ colors: [Color], blend: ProGradient.Blend, easing: ProGradient.Easing) -> [Gradient.Stop] {
        guard let last = colors.last else { return [] }
        guard colors.count > 1 else {
            return [Gradient.Stop(color: last, location: 0), Gradient.Stop(color: last, location: 1)]
        }

        let segments = Double(colors.count - 1)
        var stops: [Gradient.Stop] = []
        for (index, (start, end)) in zip(colors, colors.dropFirst()).enumerated() {
            let steps = steps(from: start, to: end, blend: blend)
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

    /// The color `t` of the way from `start` to `end`: around the hue wheel for `.vivid` and
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

    /// The hue `t` of the way from `start` to `end`, the short way around the wheel or the long way.
    private static func hue(from start: Double, to end: Double, at t: Double, theLongWay: Bool) -> Double {
        var delta = end - start
        if delta > 180 { delta -= 360 } else if delta < -180 { delta += 360 }
        if theLongWay { delta += delta > 0 ? -360 : 360 }
        return (start + delta * t).normalizedHue
    }
}
