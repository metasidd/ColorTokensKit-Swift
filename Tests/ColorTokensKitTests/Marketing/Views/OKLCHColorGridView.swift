import ColorTokensKit
import SwiftUI

struct OKLCHColorGridView: View {
    private let generator = ColorRampGenerator()
    private let hueSteps = 19

    private var colorRamps: [(name: String, color: LCHColor)] {
        var ramps: [(name: String, color: LCHColor)] = [
            (name: "Gray", color: LCHColor.getPrimaryColor(forHue: 0, isGrayscale: true))
        ]

        let generatedRamps = (0..<hueSteps).map { step in
            let hue = Double(step) * (360.0 / Double(hueSteps))
            let stops = generator.getColorRamp(forHue: hue)
            let midPoint = stops[Int(stops.count / 2) - 1]
            return (name: "H\(Int(hue))", color: midPoint)
        }

        ramps.append(contentsOf: generatedRamps)
        return ramps
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(colorRamps, id: \.name) { ramp in
                OKLCHColorColumn(name: ramp.name, color: ramp.color)
            }
        }
        .font(.system(size: 10))
        .fontDesign(.monospaced)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

private struct OKLCHColorColumn: View {
    let name: String
    let color: LCHColor

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack {
                    Text(name)
                        .font(.system(size: 10, weight: .bold))
                }
                .frame(minWidth: 60, maxHeight: .infinity)

                ForEach(Array(color.allStops.enumerated()), id: \.offset) { _, stop in
                    let oklch = stop.toRGB().toOKLCH()
                    VStack(spacing: 2) {
                        Text("L:\(String(format: "%.2f", oklch.l))")
                        Text("C:\(String(format: "%.2f", oklch.c))")
                        Text("H:\(Int(oklch.h))")
                    }
                    .foregroundStyle(oklch.l >= 0.5 ? Color.black : Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(stop.toColor())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OKLCHColorGridView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
}
