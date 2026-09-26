//
//  StopLadder.swift
//  ColorTokensKit
//
//  The lightness of each stop, _50 … _1000. Every chromatic hue shares one ladder
//  (UniformRamp.lightness); the gray ramp has its own, running from white to black.
//  Color functions move along it, so "one stop lighter" is the same visual step
//  for a palette color and for any other color.
//

import Foundation

struct StopLadder {
    /// CIELab L* per stop, lightest (_50) first.
    let lightness: [Double]

    /// The ladder every chromatic ramp is built on.
    static let chromatic = StopLadder(lightness: UniformRamp.lightness)

    /// The gray ramp's own ladder, from white to black.
    static let gray = StopLadder(
        lightness: ColorRampGenerator.shared.getOKLCHColorRamp(forHue: 0, isGrayscale: true).map(\.lightnessStar)
    )

    /// The ladder a color belongs to: gray for colors without a visible hue.
    static func ladder(for color: OKLCHColor) -> StopLadder {
        color.isAchromatic ? gray : chromatic
    }

    var lastIndex: Int {
        lightness.count - 1
    }

    /// Fractional stop position of a CIELab L*: 0 is _50, `lastIndex` is _1000.
    /// Lightness beyond either end extends the ladder at its end spacing, so white sits just above _50.
    func position(ofLightnessStar lightnessStar: Double) -> Double {
        if lightnessStar >= lightness[0] {
            return -(lightnessStar - lightness[0]) / (lightness[0] - lightness[1])
        }
        for index in 0 ..< lastIndex where lightnessStar >= lightness[index + 1] {
            return Double(index) + (lightness[index] - lightnessStar) / (lightness[index] - lightness[index + 1])
        }
        let endSpacing = lightness[lastIndex - 1] - lightness[lastIndex]
        return Double(lastIndex) + (lightness[lastIndex] - lightnessStar) / endSpacing
    }

    /// CIELab L* at a fractional stop position, extended past the ends and clamped to 0…100.
    func lightnessStar(atPosition position: Double) -> Double {
        let value: Double
        if position <= 0 {
            value = lightness[0] - position * (lightness[0] - lightness[1])
        } else if position >= Double(lastIndex) {
            value = lightness[lastIndex] - (position - Double(lastIndex)) * (lightness[lastIndex - 1] - lightness[lastIndex])
        } else {
            let index = Int(position)
            value = lightness[index] + (lightness[index + 1] - lightness[index]) * (position - Double(index))
        }
        return min(max(value, 0), 100)
    }

    /// The stop closest in lightness to this L*.
    func nearestStop(toLightnessStar lightnessStar: Double) -> Int {
        lightness.indices.min { abs(lightness[$0] - lightnessStar) < abs(lightness[$1] - lightnessStar) } ?? 0
    }

    /// The stop within `tolerance` of this L*, if there is one.
    func stop(atLightnessStar lightnessStar: Double, tolerance: Double) -> Int? {
        let nearest = nearestStop(toLightnessStar: lightnessStar)
        return abs(lightness[nearest] - lightnessStar) <= tolerance ? nearest : nil
    }
}
