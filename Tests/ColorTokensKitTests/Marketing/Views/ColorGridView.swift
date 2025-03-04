import ColorTokensKit
import SwiftUI

struct ColorGridView: View {
    private let hueSteps = 19
    
    private var colorRamps: [(name: String, color: LCHColor)] {
        // First, add the Gray color
        var ramps: [(name: String, color: LCHColor)] = [
            (name: "Gray", color: LCHColor.getPrimaryColor(forHue: 0, isGrayscale: true))
        ]
        
        // Then add generated colors from 0-360 degrees
        let generatedRamps = (0..<hueSteps).map { step in
            let hue = Double(step) * (360.0 / Double(hueSteps))
            let stops = ColorRampGenerator().getColorRamp(forHue: hue)
            
            // Safely get middle stop or use default
            let midPoint = stops.count > 0 ?
                stops[Int(stops.count / 2)] :
                LCHColor(lchString: "lch(70% 30 \(hue))")
            
            return (
                name: "H\(Int(hue))",
                color: LCHColor(l: 70, c: midPoint.c, h: midPoint.h)
            )
        }.sorted { $0.color.h < $1.color.h }
        
        // Combine Gray with the sorted hue ramps
        ramps.append(contentsOf: generatedRamps)
        return ramps
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(colorRamps, id: \.name) { ramp in
                ColorColumn(name: ramp.name, color: ramp.color)
            }
        }
    }
}

private struct ColorColumn: View {
    let name: String
    let color: LCHColor

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(color.allStops.enumerated()), id: \.offset) { index, stop in
                    VStack(spacing: 2) {
                        Text("L:\(Int(stop.l))")
                        Text("H:\(Int(stop.h))")
                    }
                    .font(.system(size: 8))
                    .foregroundStyle(stop.l > 50 ? Color.black : Color.white)
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
