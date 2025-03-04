//
// ColorRampGenerator.swift
// ColorTokensKit
//
// Provides interpolation functionality between color ramps.
// This allows smooth transitions between predefined colors while
// maintaining perceptual uniformity and accessibility.
//
// The interpolator considers:
// - Lightness progression
// - Chroma intensity
// - Hue shifts
//
// This enables generation of harmonious color ramps for any hue value.
//

import Foundation

public class ColorRampGenerator {
    // Make this static to share cache across instances
    private static var interpolatedRamps: [String: [LCHColor]] = [:]
    private let colorPaletteData: ColorPaletteData

    /// Initializes the color ramp generator with required palette data
    public init() {
        guard let data = ColorRampLoader.loadColorRamps() else {
            fatalError("Required color palette data is missing")
        }
        colorPaletteData = data
    }

    /// Generates a color ramp for a given hue value
    /// - Parameters:
    ///   - targetHue: The target hue value (0-360 degrees)
    ///   - steps: Optional number of steps in the ramp (defaults to palette's step count)
    ///   - isGrayscale: Whether to generate a grayscale ramp (ignoring hue)
    /// - Returns: Array of LCHColors representing the color ramp
    public func getColorRamp(forHue targetHue: Double, steps: Int? = nil, isGrayscale: Bool = false) -> [LCHColor] {
        // Assign a constant value
        let steps = steps ?? ColorConstants.rampStops

        // Handle grayscale and generate appropriate cache key
        let cacheKey = {
            if isGrayscale {
                return "gray-\(steps)"
            } else {
                // For color ramps, normalize hue to 0-359 range with consistent precision
                // This ensures consistent interpolation around the color wheel
                let normalizedHue = (targetHue.truncatingRemainder(dividingBy: 360) * 100).rounded() / 100
                return "H\(normalizedHue)-\(steps)"
            }
        }()

        // Check static cache first
        if let cached = ColorRampGenerator.interpolatedRamps[cacheKey] {
            return cached
        }

        // If grayscale is requested, use the gray ramp from palette data
        if isGrayscale {
            let grayRamp = colorPaletteData.colorRamps.first { $0.name == "gray" }
            if let grayRamp = grayRamp {
                let result = interpolateStops(from: grayRamp, to: grayRamp, t: 0)
                ColorRampGenerator.interpolatedRamps[cacheKey] = result
                return result
            }
        }

        // Get all ramps sorted by hue, excluding gray
        let sortedRamps = colorPaletteData.colorRamps
            .filter { $0.name != "gray" }
            .sorted { ramp1, ramp2 in
                let hue1 = ramp1.stops.first?.value.h ?? 0
                let hue2 = ramp2.stops.first?.value.h ?? 0
                return hue1 < hue2
            }

        // Find bounding ramps
        let (lowerRamp, upperRamp) = findBoundingRamps(forHue: targetHue, in: sortedRamps)

        // Get the first stop to determine hues
        let lowerHue = lowerRamp.stops.first?.value.h ?? 0
        let upperHue = upperRamp.stops.first?.value.h ?? 0

        // Calculate interpolation factor with proper wrapping
        let hueDiff = (upperHue - lowerHue + 360).truncatingRemainder(dividingBy: 360)
        
        // Normalize the target hue for consistent calculation
        let normalizedTargetHue = (targetHue.truncatingRemainder(dividingBy: 360) * 100).rounded() / 100
        let normalizedLowerHue = (lowerHue.truncatingRemainder(dividingBy: 360) * 100).rounded() / 100
        
        // Calculate t with consistent precision
        let rawT = (normalizedTargetHue - normalizedLowerHue + 360).truncatingRemainder(dividingBy: 360) / hueDiff
        let t = (rawT * 10000).rounded() / 10000

        // Interpolate between corresponding stops
        let result = interpolateStops(from: lowerRamp, to: upperRamp, t: t)

        // Cache in static dictionary
        ColorRampGenerator.interpolatedRamps[cacheKey] = result

        return result
    }

    /// Finds the two color ramps that bound the target hue
    /// - Parameters:
    ///   - hue: Target hue value
    ///   - ramps: Array of available color ramps
    /// - Returns: Tuple of (lower, upper) ramps that bound the target hue
    private func findBoundingRamps(forHue hue: Double, in ramps: [ColorRamp]) -> (ColorRamp, ColorRamp) {
        // If only one ramp exists, use it for both bounds
        guard ramps.count > 1 else {
            return (ramps[0], ramps[0])
        }

        // Find the first ramp with hue greater than target
        let upperIndex = ramps.firstIndex { ramp in
            let rampHue = ramp.stops.first?.value.h ?? 0
            return rampHue >= hue
        } ?? 0

        let lowerIndex = upperIndex == 0 ? ramps.count - 1 : upperIndex - 1
        return (ramps[lowerIndex], ramps[upperIndex])
    }

    /// Interpolates between corresponding color stops of two ramps
    /// - Parameters:
    ///   - from: Starting color ramp
    ///   - to: Ending color ramp
    ///   - t: Interpolation factor (0-1)
    /// - Returns: Array of interpolated LCHColors
    private func interpolateStops(from: ColorRamp, to: ColorRamp, t: Double) -> [LCHColor] {
        // Get sorted stops from both ramps
        let fromStops = from.stops.sorted { Int($0.key) ?? 0 < Int($1.key) ?? 0 }
        let toStops = to.stops.sorted { Int($0.key) ?? 0 < Int($1.key) ?? 0 }

        // Create evenly spaced indices for the requested number of steps
        let stepSize = 1.0 / Double(ColorConstants.rampStops - 1)

        return (0 ..< ColorConstants.rampStops).map { step in
            // Round progress to 4 decimal places for consistency
            let progress = ((Double(step) * stepSize) * 10000).rounded() / 10000

            // Instead of rounding, find the bounding indices and interpolate between them
            let fromFloatIndex = Double(fromStops.count - 1) * progress
            let fromLowerIndex = Int(floor(fromFloatIndex))
            let fromUpperIndex = Int(ceil(fromFloatIndex))
            // Round fraction to 4 decimal places for consistency
            let fromFraction = ((fromFloatIndex - Double(fromLowerIndex)) * 10000).rounded() / 10000

            let toFloatIndex = Double(toStops.count - 1) * progress
            let toLowerIndex = Int(floor(toFloatIndex))
            let toUpperIndex = Int(ceil(toFloatIndex))
            // Round fraction to 4 decimal places for consistency
            let toFraction = ((toFloatIndex - Double(toLowerIndex)) * 10000).rounded() / 10000

            // Get the bounding colors from both ramps
            let fromLower = fromStops[fromLowerIndex].value
            let fromUpper = fromStops[min(fromUpperIndex, fromStops.count - 1)].value
            let toLower = toStops[toLowerIndex].value
            let toUpper = toStops[min(toUpperIndex, toStops.count - 1)].value

            // Interpolate within each ramp first
            let fromInterpolated = LCHColor(
                l: lerp(fromLower.l, fromUpper.l, fromFraction),
                c: lerp(fromLower.c, fromUpper.c, fromFraction),
                h: lerpHue(fromLower.h, fromUpper.h, fromFraction)
            )

            let toInterpolated = LCHColor(
                l: lerp(toLower.l, toUpper.l, toFraction),
                c: lerp(toLower.c, toUpper.c, toFraction),
                h: lerpHue(toLower.h, toUpper.h, toFraction)
            )

            // Then interpolate between the ramps
            return LCHColor(
                l: lerp(fromInterpolated.l, toInterpolated.l, t),
                c: lerp(fromInterpolated.c, toInterpolated.c, t),
                h: lerpHue(fromInterpolated.h, toInterpolated.h, t)
            )
        }
    }

    /// Linear interpolation between two values
    /// - Parameters:
    ///   - a: Starting value
    ///   - b: Ending value
    ///   - t: Interpolation factor (0-1)
    /// - Returns: Interpolated value
    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        // Normalize t to ensure consistent results
        let normalizedT = (t * 1000).rounded() / 1000
        let result = a + ((b - a) * normalizedT)
        
        // Round to 2 decimal places for consistency
        return (result * 100).rounded() / 100
    }

    /// Interpolates between two hue angles, taking the shortest path around the color wheel
    /// - Parameters:
    ///   - h1: Starting hue angle (0-360)
    ///   - h2: Ending hue angle (0-360)
    ///   - t: Interpolation factor (0-1)
    /// - Returns: Interpolated hue angle
    private func lerpHue(_ h1: Double, _ h2: Double, _ t: Double) -> Double {
        // Normalize inputs to ensure consistent results
        let normalizedH1 = (h1.truncatingRemainder(dividingBy: 360) * 100).rounded() / 100
        let normalizedH2 = (h2.truncatingRemainder(dividingBy: 360) * 100).rounded() / 100
        let normalizedT = (t * 1000).rounded() / 1000
        
        let diff = (normalizedH2 - normalizedH1 + 360).truncatingRemainder(dividingBy: 360)
        let shortestPath = diff <= 180 ? diff : diff - 360
        let result = (normalizedH1 + shortestPath * normalizedT + 360).truncatingRemainder(dividingBy: 360)
        
        // Round to 2 decimal places for consistency
        return (result * 100).rounded() / 100
    }
}
