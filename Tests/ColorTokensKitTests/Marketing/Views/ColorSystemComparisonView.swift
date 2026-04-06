import ColorTokensKit
import SwiftUI

struct ColorSystemComparisonView: View {
    private let hueSteps = 20

    // Generate interpolated colors around the color wheel
    var hues: [(name: String, color: LCHColor)] {
        (0 ... hueSteps).map { step in
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
    }

    // Generate OKLCH colors at the same hues for comparison
    var oklchHues: [Color] {
        (0 ... hueSteps).map { step in
            let hue = Double(step) * (360.0 / Double(hueSteps))
            return OKLCHColor(l: 0.7, c: 0.15, h: CGFloat(hue)).toColor()
        }
    }

    var body: some View {
        VStack(spacing: 48) {
            HStack(spacing: 64) {
                lchGradientView
                oklchGradientView
                rgbGradientView
            }
            .font(.system(.title, design: .monospaced))

            descriptionText
        }
        .padding(MarketingStyle.pagePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    private var lchGradientView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("LCH Color System")

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: hues.map { $0.color.toColor() },
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: 32))
        }
    }

    private var oklchGradientView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("OKLCH Color System")

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: oklchHues,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: 32))
        }
    }

    private var rgbGradientView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("RGB Color System")

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: 32))
        }
    }

    private var descriptionText: some View {
        Text("LCH and OKLCH maintain consistent brightness and saturation across hues.\nOKLCH improves hue linearity — blues stay blue instead of shifting purple.\nRGB shows uneven brightness and saturation changes.")
            .font(.system(.title2, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.trailing, 256)
    }
}

#Preview {
    ColorSystemComparisonView()
        .frame(width: ImageSize.width, height: ImageSize.height)
}
