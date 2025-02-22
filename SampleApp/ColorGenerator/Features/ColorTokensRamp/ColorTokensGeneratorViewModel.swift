//
//  ColorTokensGeneratorViewModel.swift
//  ColorGeneratorViewModel
//
//  Created by Siddhant Mehta on 2024-06-08.
//

import ColorTokensKit
import Foundation
import SwiftUI
import UIKit

@Observable
class ColorTokensGeneratorViewModel: ObservableObject {
    var lchColor: LCHColor
    var steps: Int = Color.allProHues.count
    var colors: [String: LCHColor] = [:]

    init(lchColor: LCHColor) {
        self.lchColor = lchColor
        updateColors()
    }

    func updateColors() {
        colors = Color.allProHues
    }
}
