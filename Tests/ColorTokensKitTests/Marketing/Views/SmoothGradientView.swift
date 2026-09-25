import ColorTokensKit
import SwiftUI

/// README image: SwiftUI's two gradient color spaces next to `proGradient()`.
struct SmoothGradientView: View {
    private struct Row {
        let name: String
        let colors: [Color]
        var hue: ProGradient.HuePath = .shorter
    }

    private let rows: [Row] = [
        Row(name: "Blue → Yellow", colors: [Color(red: 0, green: 0, blue: 1), Color(red: 1, green: 1, blue: 0)]),
        Row(name: "Complement", colors: [Color.proBlue._400.toColor(), Color.proBlue._400.toColor().complement]),
        Row(name: "Triad", colors: Color.proPink._450.toColor().triad),
        Row(name: "hue: .longer", colors: [Color.proRed._450.toColor(), Color.proOrange._450.toColor()], hue: .longer),
    ]

    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 12) {
                Text("🌈 Smooth gradients")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(Color.foregroundPrimary)
                Text("In-between colors in OKLCH: the same on every OS and on the web")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color.foregroundTertiary)
            }

            Grid(horizontalSpacing: 32, verticalSpacing: 28) {
                GridRow {
                    Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                    header("SwiftUI .device")
                    header("SwiftUI .perceptual")
                    header("proGradient()")
                }
                ForEach(rows, id: \.name) { row in
                    GridRow {
                        Text(row.name)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color.foregroundSecondary)
                            .gridColumnAlignment(.leading)
                        bar(.linearGradient(Gradient(colors: row.colors).colorSpace(.device), startPoint: .leading, endPoint: .trailing))
                        bar(.linearGradient(Gradient(colors: row.colors).colorSpace(.perceptual), startPoint: .leading, endPoint: .trailing))
                        bar(row.colors.proGradient(from: .leading, to: .trailing, hue: row.hue))
                    }
                }
            }
        }
        .fontDesign(.monospaced)
        .padding(MarketingStyle.pagePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    private func header(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(Color.foregroundPrimary)
    }

    private func bar(_ style: some ShapeStyle) -> some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(style)
            .frame(width: 440, height: 120)
    }
}

#Preview {
    SmoothGradientView()
        .frame(width: ImageSize.width, height: ImageSize.height)
}
