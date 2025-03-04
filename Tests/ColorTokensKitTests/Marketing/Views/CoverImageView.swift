import ColorTokensKit
import SwiftUI

struct CoverImageView: View {
    private let hueSteps: Int = 12
    private let gridSpacing: Double = 0
    private let colorSize: Double = 80
    
    var hues: [(name: String, colors: [LCHColor])] {
        (0 ... hueSteps).map { step in
            let hue = Double(step) * (360.0 / Double(hueSteps))
            let stops = ColorRampGenerator().getColorRamp(forHue: hue)

            // Safely get middle stop or use default
            let midPoint = stops.count > 0 ?
                stops[Int(stops.count / 2)] :
                LCHColor(lchString: "lch(70% 30 \(hue))")

            return (
                name: "H\(Int(hue))",
                colors: LCHColor(l: 70, c: midPoint.c, h: midPoint.h).allStops
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: gridSpacing) {
            let sortedRamp = hues.sorted { $0.colors.first?.h ?? 0 < $1.colors.first?.h ?? 0 }
            
            ForEach(Array(sortedRamp.enumerated()), id: \.offset) { index, element in
                colorRow(for: element.colors, rowIndex: index)
            }
        }
        .padding(0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func colorRow(for colors: [LCHColor], rowIndex: Int) -> some View {
        HStack(spacing: gridSpacing) {
            // Create a seed value based on both the first color's hue and the row index
            // This ensures each row has a different pattern even if hues are similar
            let patternSeed = (rowIndex * 23) + 73 // Using a prime number multiplier for better distribution
            
            let shuffledColors = deterministicShuffle(colors, seed: patternSeed)
            
            // Create an alternating pattern of shapes as the starting point
            // This ensures we don't start with all circles in first half and all squares in second half
            var shapes = [Bool]()
            for i in 0..<shuffledColors.count {
                // Start with alternating pattern but with some variation based on row
                shapes.append((i + rowIndex) % 3 != 1) // Creates a pattern like [true, false, true, true, false, true, ...]
            }
            
            shapes = deterministicShuffleShapes(shapes, seed: patternSeed)
            
            return HStack(spacing: gridSpacing) {
                ForEach(shuffledColors.indices, id: \.self) { index in
                    let isCircle = shapes[index]
                    colorBlock(for: shuffledColors[index], isCircle: isCircle)
                }
            }
        }
    }

    private func colorBlock(for color: LCHColor, isCircle: Bool) -> some View {
        return RoundedRectangle(cornerRadius: isCircle ? colorSize/2 : colorSize/4)
            .fill(color.toColor())
            .frame(
                maxWidth: isCircle ? colorSize : colorSize * 1.5,
                maxHeight: colorSize
            )
    }

    /// Deterministic version of slightlyShuffle that uses a fixed pattern
    /// - Parameters:
    ///   - colors: The array of colors to shuffle
    ///   - seed: A seed value to create different but deterministic patterns
    /// - Returns: A deterministically shuffled array of colors
    private func deterministicShuffle(_ colors: [LCHColor], seed: Int) -> [LCHColor] {
        var shuffledColors = colors
        
        for i in shuffledColors.indices {
            // Use the seed to create a different but deterministic pattern for each row
            let patternValue = (i + seed) % 4
            
            // Different shift patterns based on the combination of index and seed
            let shift: Int
            switch patternValue {
            case 0:
                shift = 1  // Shift right by 1
            case 1:
                shift = -1 // Shift left by 1
            case 2:
                shift = 2  // Shift right by 2
            case 3:
                shift = -2 // Shift left by 2
            default:
                shift = 0  // No shift (shouldn't happen)
            }
            
            let swapIndex = i + shift
            if swapIndex >= 0 && swapIndex < shuffledColors.count {
                shuffledColors.swapAt(i, swapIndex)
            }
        }
        
        return shuffledColors
    }
    
    /// Deterministic shuffle for shapes array
    /// - Parameters:
    ///   - shapes: The array of shape flags (true = circle, false = square)
    ///   - seed: A seed value to create different but deterministic patterns
    /// - Returns: A deterministically shuffled array of shape flags
    private func deterministicShuffleShapes(_ shapes: [Bool], seed: Int) -> [Bool] {
        var result = shapes
        
        // First pass: Apply pattern transformations
        for i in 0..<result.count {
            // Use multiple pattern factors to create more variation
            let patternOffset1 = seed % 7  // Prime number for better distribution
            let patternOffset2 = (seed * 13) % 11  // Another prime factor
            
            // Create different patterns based on position and seed
            if i % 2 == 0 {
                // Even positions get one pattern
                result[i] = ((i + patternOffset1) % 4 != 1)
            } else {
                // Odd positions get a different pattern
                result[i] = ((i + patternOffset2) % 5 != 2)
            }
            
            // Add more variation with additional pattern rules
            if i > 0 && i < result.count - 1 {
                // Avoid three squares in a row
                if !result[i-1] && !result[i] && i+1 < result.count && !result[i+1] {
                    result[i] = true
                }
                
                // Avoid three circles in a row
                if result[i-1] && result[i] && i+1 < result.count && result[i+1] {
                    result[i] = false
                }
            }
        }
        
        // Second pass: Ensure no more than two of the same shape appear consecutively
        for i in 1..<result.count-1 {
            if result[i-1] == result[i] && result[i] == result[i+1] {
                result[i] = !result[i]
            }
        }
        
        return result
    }
}

private struct AnyShape: Shape {
    private let path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        self.path = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        path(rect)
    }
}

#Preview {
    CoverImageView()
        .frame(width: ImageSize.width, height: ImageSize.height)
} 
