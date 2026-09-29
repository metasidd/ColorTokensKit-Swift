//
//  GradientStops.swift
//  ColorTokensKit
//
//  Builds the stops behind every smooth gradient. SwiftUI can only blend between
//  neighboring stops in its own way, so this adds in-between colors along the path
//  the blend asks for (around the color wheel, or a straight line) and the shape
//  the easing gives it, but only where SwiftUI's blending would visibly miss them:
//  a straight or evenly fading stretch needs few, a sweep around the wheel gets as
//  many as it needs. Every stop is a color SwiftUI resolves each time it draws, so
//  fewer stops draw faster. Each in-between color is worked out when drawn, so a
//  gradient between tokens stays adaptive.
//

import SwiftUI

enum GradientStops {
    /// The most SwiftUI's own blending between two neighboring stops may miss the true gradient by, in ΔEOK with a
    /// change in opacity counted in full: about a just-noticeable difference.
    static let tolerance = 0.02

    /// How many times a stretch between two colors may be halved: at most 32 pieces.
    static let maxHalvings = 5

    /// How much a change in opacity adds to a path's length.
    static let opacityWeight = 0.4

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
            let progress = Double(index) / segments ... Double(index + 1) / segments
            let ends = AdaptiveInputs([start, end])
            for (step, location) in locations(from: start, to: end, over: progress, blend: blend, easing: easing).enumerated() {
                let t = pairProgress(at: location, over: progress, easing: easing)
                let color: Color
                if step == 0 {
                    color = start
                } else if let fixed = ends.fixedColors {
                    // Between two fixed colors the stop is fixed too, and a fixed color draws for almost nothing.
                    color = AdaptiveInputs.fixedColor(interpolate(fixed[0], fixed[1], at: t, blend: blend))
                } else {
                    color = Color.adapting(combining: ends) { resolved, _ in
                        interpolate(resolved[0], resolved[1], at: t, blend: blend)
                    }
                }
                stops.append(Gradient.Stop(color: color, location: location))
            }
        }
        stops.append(Gradient.Stop(color: last, location: 1))
        return stops
    }

    /// Where the stops between `start` and `end` go along the gradient, `start`'s first. `progress` is the share of the
    /// gradient's colors the pair covers. The stretch is halved wherever SwiftUI's blending between its ends would miss
    /// the true colors by more than `tolerance` in either appearance, checked at its middle and quarters: an S-shaped
    /// fade crosses the straight line right at its middle. Kept per pair, since a view rebuilds the same gradient every
    /// time its body runs.
    static func locations(
        from start: Color,
        to end: Color,
        over progress: ClosedRange<Double>,
        blend: ProGradient.Blend,
        easing: ProGradient.Easing
    ) -> [Double] {
        let ends = ColorScheme.allCases.map { (start.resolvedOKLCH(for: $0), end.resolvedOKLCH(for: $0)) }
        let components = ends.flatMap { [$0.0, $0.1] }.flatMap { [$0.l, $0.c, $0.h, $0.alpha] }.map { Double($0) }
        let key = LayoutKey(ends: components, progress: progress, blend: blend, easing: easing)
        layoutsLock.lock()
        let kept = layouts[key]
        layoutsLock.unlock()
        if let kept { return kept }

        func colors(at location: Double) -> [OKLCHColor] {
            let t = pairProgress(at: location, over: progress, easing: easing)
            return ends.map { interpolate($0.0, $0.1, at: t, blend: blend) }
        }
        // How far SwiftUI's straight RGB blend from `first` to `second`, `fraction` of the way, lands from `truth`.
        func miss(_ first: [OKLCHColor], _ second: [OKLCHColor], _ truth: [OKLCHColor], _ fraction: CGFloat) -> Double {
            ends.indices.map { appearance in
                let drawn = first[appearance].toRGB().lerp(second[appearance].toRGB(), t: fraction).toOKLCH()
                return Gamut.differenceOK(drawn, truth[appearance]) + abs(Double(drawn.alpha - truth[appearance].alpha))
            }.max() ?? 0
        }
        var locations: [Double] = []
        func place(from a: Double, to b: Double, _ atA: [OKLCHColor], _ atMiddle: [OKLCHColor], _ atB: [OKLCHColor], halvings: Int) {
            let middle = (a + b) / 2
            let atQuarter = colors(at: (a + middle) / 2), atThreeQuarters = colors(at: (middle + b) / 2)
            let worst = max(miss(atA, atB, atQuarter, 0.25), miss(atA, atB, atMiddle, 0.5), miss(atA, atB, atThreeQuarters, 0.75))
            if halvings < maxHalvings, worst > tolerance {
                place(from: a, to: middle, atA, atQuarter, atMiddle, halvings: halvings + 1)
                place(from: middle, to: b, atMiddle, atThreeQuarters, atB, halvings: halvings + 1)
            } else {
                locations.append(a)
            }
        }
        let first = easing.location(forProgress: progress.lowerBound), last = easing.location(forProgress: progress.upperBound)
        place(from: first, to: last, colors(at: first), colors(at: (first + last) / 2), colors(at: last), halvings: 0)

        layoutsLock.lock()
        // Bounded, so colors that change every frame can't grow it forever.
        if layouts.count >= 256 { layouts.removeAll() }
        layouts[key] = locations
        layoutsLock.unlock()
        return locations
    }

    /// How far along its own pair (0…1) the gradient's colors are at `location`.
    private static func pairProgress(at location: Double, over progress: ClosedRange<Double>, easing: ProGradient.Easing) -> Double {
        min(max((easing.progress(atLocation: location) - progress.lowerBound) / (progress.upperBound - progress.lowerBound), 0), 1)
    }

    /// Everything a pair's stop locations depend on: its ends as drawn in each appearance, the share of the gradient
    /// it covers, and its blend and easing.
    private struct LayoutKey: Hashable {
        let ends: [Double]
        let progress: ClosedRange<Double>
        let blend: ProGradient.Blend
        let easing: ProGradient.Easing
    }

    private static var layouts: [LayoutKey: [Double]] = [:]
    private static let layoutsLock = NSLock()

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
