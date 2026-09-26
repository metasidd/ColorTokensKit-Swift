@testable import ColorTokensKit
import SwiftUI

/// README image: SwiftUI's own gradient, then every easing, with its curve and the gradient it makes.
struct GradientEasingView: View {
    private struct Row {
        let name: String
        let note: String
        let easing: ProGradient.Easing
    }

    private let rows: [Row] = [
        Row(name: ".smooth", note: "The default: lingers a little at both ends", easing: .smooth),
        Row(name: ".linear", note: "Changes evenly, like LinearGradient", easing: .linear),
        Row(name: ".easeIn", note: "Lingers on the first color", easing: .easeIn),
        Row(name: ".easeOut", note: "Lingers on the last color", easing: .easeOut),
        Row(name: ".easeInOut", note: "Lingers longer at both ends", easing: .easeInOut),
        Row(name: ".timingCurve(0.8, 0, 0.2, 1)", note: "Your own curve", easing: .timingCurve(0.8, 0, 0.2, 1)),
    ]

    private let colors = [Color.proViolet._700.toColor(), Color.proPink._200.toColor()]

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text("📈 Gradient easing")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(Color.foregroundPrimary)
                Text("Where along the gradient the colors change")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color.foregroundTertiary)
            }

            VStack(spacing: 16) {
                row(
                    "LinearGradient",
                    note: "SwiftUI's own, for comparison",
                    easing: .linear,
                    fill: LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                )
                Divider()
                ForEach(rows, id: \.name) { item in
                    row(
                        item.name,
                        note: item.note,
                        easing: item.easing,
                        fill: colors.proGradient(from: .leading, to: .trailing, easing: item.easing)
                    )
                }
            }
        }
        .fontDesign(.monospaced)
        .padding(MarketingStyle.pagePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    private func row(_ name: String, note: String, easing: ProGradient.Easing, fill: some ShapeStyle) -> some View {
        HStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.foregroundPrimary)
                Text(note)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color.foregroundTertiary)
            }
            .frame(width: 500, alignment: .leading)
            curve(easing)
            RoundedRectangle(cornerRadius: 24)
                .fill(fill)
                .frame(height: 96)
        }
    }

    /// The easing's curve over a dashed line for `.linear`.
    private func curve(_ easing: ProGradient.Easing) -> some View {
        ZStack {
            EasingCurve(easing: .linear)
                .stroke(Color.proGray._300.toColor(), style: StrokeStyle(lineWidth: 2, dash: [5, 6]))
            EasingCurve(easing: easing)
                .stroke(Color.foregroundPrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
        }
        .padding(14)
        .frame(width: 96, height: 96)
        .background(Color.proGray._100.toColor(), in: RoundedRectangle(cornerRadius: 20))
    }
}

/// An easing's curve: along the gradient left to right, how far the color has changed bottom to top.
private struct EasingCurve: Shape {
    let easing: ProGradient.Easing

    func path(in rect: CGRect) -> Path {
        Path { path in
            for step in 0 ... 100 {
                let progress = Double(step) / 100
                let point = CGPoint(
                    x: rect.minX + easing.location(forProgress: progress) * rect.width,
                    y: rect.maxY - progress * rect.height
                )
                if step == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
    }
}

#Preview {
    GradientEasingView()
        .frame(width: ImageSize.width, height: ImageSize.height)
}
