//
//  OKLabColor.swift
//  ColorTokensKit
//
//  OKLab color space by Björn Ottosson.
//  Reference: https://bottosson.github.io/posts/oklab/
//

import Foundation

public struct OKLabColor: Hashable, Sendable {
    public let l: CGFloat  // 0..1  Perceptual lightness
    public let a: CGFloat  // ~-0.4..+0.4  Green-red axis
    public let b: CGFloat  // ~-0.4..+0.4  Blue-yellow axis
    public let alpha: CGFloat // 0..1

    public init(l: CGFloat, a: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.l = l
        self.a = a
        self.b = b
        self.alpha = alpha
    }
}
