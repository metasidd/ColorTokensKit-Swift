//
// ColorRampGenerator.swift
// ColorTokensKit
//
// Builds and caches 20-stop ramps. Chromatic ramps are keyed by OKLCH hue and
// built by UniformRamp (shared lightness and chroma per stop); gray is listed
// at the end of this file.
//

import Foundation

public class ColorRampGenerator {
    /// Shared instance to avoid redundant allocations
    static let shared = ColorRampGenerator()

    private static var interpolatedRamps: [String: [LCHColor]] = [:]
    private static var oklchInterpolatedRamps: [String: [OKLCHColor]] = [:]
    private static let cacheLock = NSLock()

    /// Creates a ramp generator. Ramps are cached and shared by every generator.
    public init() {}

    /// Generates a color ramp for a given hue value
    /// - Parameters:
    ///   - targetHue: The target OKLCH hue (0-360 degrees)
    ///   - steps: Optional number of steps in the ramp (defaults to palette's step count)
    ///   - isGrayscale: Whether to generate a grayscale ramp (ignoring hue)
    /// - Returns: Array of LCHColors representing the color ramp
    public func getColorRamp(forHue targetHue: Double, steps: Int? = nil, isGrayscale: Bool = false) -> [LCHColor] {
        if isGrayscale {
            return Self.grayRamp
        }

        let steps = steps ?? ColorConstants.rampStops
        let normalizedTargetHue = targetHue.normalizedHue
        let cacheKey = "H\(normalizedTargetHue)-\(steps)"

        // Check static cache first
        ColorRampGenerator.cacheLock.lock()
        if let cached = ColorRampGenerator.interpolatedRamps[cacheKey] {
            ColorRampGenerator.cacheLock.unlock()
            return cached
        }
        ColorRampGenerator.cacheLock.unlock()

        // Chromatic ramps are keyed by OKLCH hue and built uniformly (see UniformRamp).
        let result = UniformRamp.ramp(hue: normalizedTargetHue)

        // Cache in static dictionary
        ColorRampGenerator.cacheLock.lock()
        ColorRampGenerator.interpolatedRamps[cacheKey] = result
        ColorRampGenerator.cacheLock.unlock()

        return result
    }

    /// Generates a color ramp in OKLCH space for a given hue value.
    /// Converts each stop of `getColorRamp(forHue:)` to OKLCH.
    /// Results are cached to avoid repeated conversion.
    public func getOKLCHColorRamp(forHue targetHue: Double, steps: Int? = nil, isGrayscale: Bool = false) -> [OKLCHColor] {
        let steps = steps ?? ColorConstants.rampStops
        let normalizedTargetHue = targetHue.normalizedHue
        let cacheKey = isGrayscale ? "Gray-\(steps)" : "H\(normalizedTargetHue)-\(steps)"

        ColorRampGenerator.cacheLock.lock()
        if let cached = ColorRampGenerator.oklchInterpolatedRamps[cacheKey] {
            ColorRampGenerator.cacheLock.unlock()
            return cached
        }
        ColorRampGenerator.cacheLock.unlock()

        let result = getColorRamp(forHue: targetHue, steps: steps, isGrayscale: isGrayscale).map { $0.toRGB().toOKLCH() }

        ColorRampGenerator.cacheLock.lock()
        ColorRampGenerator.oklchInterpolatedRamps[cacheKey] = result
        ColorRampGenerator.cacheLock.unlock()

        return result
    }

    /// The gray ramp, white to black. Gray has its own lightness ladder, tuned by eye, so it is
    /// listed rather than generated.
    private static let grayRamp: [LCHColor] = [
        LCHColor(l: 99.9, c: 0.1, h: 246.48),
        LCHColor(l: 96.41, c: 0.1, h: 246.03),
        LCHColor(l: 92.45, c: 0.1, h: 245.98),
        LCHColor(l: 88.08, c: 0.1, h: 245.64),
        LCHColor(l: 83.03, c: 0.1, h: 245.49),
        LCHColor(l: 77.66, c: 0.1, h: 245.49),
        LCHColor(l: 72.1, c: 0.1, h: 245.49),
        LCHColor(l: 66.16, c: 0.1, h: 245.49),
        LCHColor(l: 59.97, c: 0.1, h: 245.49),
        LCHColor(l: 54.13, c: 0.1, h: 245.52),
        LCHColor(l: 47.87, c: 0.1, h: 245.96),
        LCHColor(l: 41.61, c: 0.1, h: 245.99),
        LCHColor(l: 35.34, c: 0.1, h: 245.99),
        LCHColor(l: 29.4, c: 0.1, h: 246.31),
        LCHColor(l: 23.58, c: 0.1, h: 246.49),
        LCHColor(l: 17.97, c: 0.1, h: 246.49),
        LCHColor(l: 12.76, c: 0.1, h: 246.5),
        LCHColor(l: 7.95, c: 0.1, h: 246.5),
        LCHColor(l: 3.59, c: 0.1, h: 246.5),
        LCHColor(l: 0.1, c: 0.1, h: 246.5),
    ]
}
