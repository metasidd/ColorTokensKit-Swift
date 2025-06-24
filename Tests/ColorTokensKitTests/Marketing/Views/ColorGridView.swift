import ColorTokensKit
import SwiftUI

struct ColorGridView: View {
    private let generator = ColorRampGenerator()
    private let hueSteps = 19
    
    private var colorRamps: [(name: String, color: LCHColor)] {
        // First, add the Gray color
        var ramps: [(name: String, color: LCHColor)] = [
            (name: "Gray", color: LCHColor.getPrimaryColor(forHue: 0, isGrayscale: true))
        ]
        
        // Then add generated colors from 0-360 degrees
        let generatedRamps = (0..<hueSteps).map { step in
            let hue = Double(step) * (360.0 / Double(hueSteps))
            
            // Create a color ramp generator and explicitly pass the hue
            let stops = generator.getColorRamp(forHue: hue)
            
            let midPoint = stops[Int(stops.count / 2) - 1]
            
            // Add the original hue to the name for clarity
            return (
                name: "H\(Int(hue))",
                color: midPoint
            )
        }
        
        // Combine Gray with the generated ramps (no sorting)
        ramps.append(contentsOf: generatedRamps)
        return ramps
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(colorRamps, id: \.name) { ramp in
                ColorColumn(name: ramp.name, color: ramp.color)
            }
        }
        .font(.system(size: 10))
        .fontDesign(.monospaced)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

private struct ColorColumn: View {
    let name: String
    let color: LCHColor

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Left column showing the original hue
                VStack {
                    Text(name)
                        .font(.system(size: 10, weight: .bold))
                }
                .frame(minWidth: 60, maxHeight: .infinity)
                
                // Color stops with chroma and lightness values
                ForEach(Array(color.allStops.enumerated()), id: \.offset) { index, stop in
                    VStack(spacing: 2) {
                        Text("L:\(Int(stop.l))")
                        Text("C:\(Int(stop.c))")
                        Text("H:\(Int(stop.h))")
                    }
                    .foregroundStyle(Int(stop.l) >= 50 ? Color.black : Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(stop.toColor())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ColorGridView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
}
