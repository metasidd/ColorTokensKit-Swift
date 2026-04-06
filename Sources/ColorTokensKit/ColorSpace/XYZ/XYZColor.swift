//
//  XYZColor.swift
//
//  Original repo: https://github.com/timrwood/ColorSpaces
//

import Foundation

public struct XYZColor: Hashable, Sendable {
    public let x: CGFloat // 0..0.95047
    public let y: CGFloat // 0..1
    public let z: CGFloat // 0..1.08883
    public let alpha: CGFloat // 0..1

    public init(x: CGFloat, y: CGFloat, z: CGFloat, alpha: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
        self.alpha = alpha
    }

    func sRGBCompand(_ v: CGFloat) -> CGFloat {
        let absV = abs(v)
        let out = absV > 0.0031308 ? 1.055 * pow(absV, 1 / 2.4) - 0.055 : absV * 12.92
        return v > 0 ? out : -out
    }

    func labCompand(_ v: CGFloat) -> CGFloat {
        return v > ColorConstants.LAB_E ? pow(v, 1.0 / 3.0) : (ColorConstants.LAB_K_116 * v) + ColorConstants.LAB_16_116
    }
}
