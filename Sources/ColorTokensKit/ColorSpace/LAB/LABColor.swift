//
//  LABColor.swift
//
//
//  Original repo: https://github.com/timrwood/ColorSpaces
//

import Foundation

public struct LABColor: Hashable, Sendable {
    public let l: CGFloat //    0..100
    public let a: CGFloat // -128..128
    public let b: CGFloat // -128..128
    public let alpha: CGFloat //    0..1

    public init(l: CGFloat, a: CGFloat, b: CGFloat, alpha: CGFloat) {
        self.l = l
        self.a = a
        self.b = b
        self.alpha = alpha
    }

    func xyzCompand(_ v: CGFloat) -> CGFloat {
        let v3 = v * v * v
        return v3 > ColorConstants.LAB_E ? v3 : (v - ColorConstants.LAB_16_116) / ColorConstants.LAB_K_116
    }
}
