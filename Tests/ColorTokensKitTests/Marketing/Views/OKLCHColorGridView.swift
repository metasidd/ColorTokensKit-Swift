import ColorTokensKit
import SwiftUI

struct OKLCHColorGridView: View {
    private let hueSteps = 19
    private let stopCount = 20

    /// Generates an OKLCH ramp natively in OKLCH space for a given hue.
    /// Lightness goes from near-white to near-black with a bell-curve chroma profile.
    private func generateOKLCHRamp(hue: CGFloat, isGrayscale: Bool = false) -> [OKLCHColor] {
        (0..<stopCount).map { step in
            let t = CGFloat(step) / CGFloat(stopCount - 1)

            // Lightness: 0.97 (lightest) → 0.15 (darkest)
            let l = 0.97 - t * 0.82

            // Chroma: bell curve peaking around t=0.45 (slightly above midpoint)
            // This mimics how hand-tuned palettes have peak saturation in the mid-tones
            let peakChroma: CGFloat = isGrayscale ? 0.0 : 0.15
            let chromaT = exp(-pow((t - 0.45) / 0.28, 2))
            let c = peakChroma * chromaT

            return OKLCHColor(l: l, c: c, h: isGrayscale ? 0 : hue)
        }
    }

    private var colorRows: [(name: String, stops: [OKLCHColor])] {
        var rows: [(name: String, stops: [OKLCHColor])] = [
            (name: "Gray", stops: generateOKLCHRamp(hue: 0, isGrayscale: true))
        ]

        let hueRows = (0..<hueSteps).map { step in
            let hue = CGFloat(step) * (360.0 / CGFloat(hueSteps))
            return (name: "H\(Int(hue))", stops: generateOKLCHRamp(hue: hue))
        }

        rows.append(contentsOf: hueRows)
        return rows
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(colorRows, id: \.name) { row in
                OKLCHColorColumn(name: row.name, stops: row.stops)
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
    let stops: [OKLCHColor]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack {
                    Text(name)
                        .font(.system(size: 10, weight: .bold))
                }
                .frame(minWidth: 60, maxHeight: .infinity)

                ForEach(Array(stops.enumerated()), id: \.offset) { _, stop in
                    let stopRGB = stop.toRGB()
                    let whiteContrast = stopRGB.contrastRatio(to: RGBColor(r: 1, g: 1, b: 1, alpha: 1))
                    let blackContrast = stopRGB.contrastRatio(to: RGBColor(r: 0, g: 0, b: 0, alpha: 1))
                    VStack(spacing: 2) {
                        Text("L:\(String(format: "%.2f", stop.l))")
                        Text("C:\(String(format: "%.2f", stop.c))")
                        Text("H:\(Int(stop.h))")
                    }
                    .foregroundStyle(blackContrast >= whiteContrast ? Color.black : Color.white)
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
