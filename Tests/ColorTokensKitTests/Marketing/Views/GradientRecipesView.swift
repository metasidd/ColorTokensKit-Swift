import ColorTokensKit
import SwiftUI

extension ProGradient.Recipe {
    /// The custom recipe shown in the last tile.
    static var deepen: Self {
        Self { [$0, $0.darken(by: 4)] }
    }
}

/// README image: every gradient recipe, shown where you'd typically use it.
struct GradientRecipesView: View {
    private let brand = Color.proViolet
    private var accent: Color { brand._500.toColor() }

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text("🎨 Gradient recipes")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(Color.foregroundPrimary)
                Text("One color in, a gradient out")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color.foregroundTertiary)
            }

            Grid(horizontalSpacing: 28, verticalSpacing: 32) {
                GridRow {
                    tile(".subtle", "accent.proGradient()") {
                        Text("Continue")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 48)
                            .padding(.vertical, 20)
                            .background(accent.proGradient(), in: Capsule())
                    }
                    tile(".fade", "accent.proRadialGradient(.fade)") {
                        Circle()
                            .fill(accent.proRadialGradient(.fade))
                            .frame(width: 200, height: 200)
                    }
                    tile(".tonal", "brand.proGradient(.tonal)") {
                        card(fill: AnyShapeStyle(brand.proGradient(.tonal)), text: .white)
                    }
                    tile(".analogous", "brand.proGradient(.analogous, …)") {
                        card(fill: AnyShapeStyle(brand.proGradient(.analogous, from: .leading, to: .trailing)), text: .white)
                    }
                }
                GridRow {
                    tile(".wash", "brand.proGradient(.wash)") {
                        card(fill: AnyShapeStyle(brand.proGradient(.wash)), text: brand._900.toColor())
                    }
                    tile(".sheen", "Color.white.proGradient(.sheen, …)") {
                        Text("Upgrade")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 48)
                            .padding(.vertical, 20)
                            .background(accent, in: Capsule())
                            .overlay(Capsule().fill(Color.white.proGradient(.sheen, from: .topLeading, to: .bottomTrailing)))
                    }
                    tile(".edgeHighlight", "accent.proGradient(.edgeHighlight, …)") {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .strokeBorder(accent.proGradient(.edgeHighlight, from: .leading, to: .trailing), lineWidth: 5)
                            )
                            .frame(width: 300, height: 170)
                    }
                    tile("Your own", "brand.proGradient(.deepen)") {
                        card(fill: AnyShapeStyle(brand.proGradient(.deepen)), text: .white)
                    }
                }
            }
        }
        .fontDesign(.monospaced)
        .padding(MarketingStyle.pagePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    private func tile(_ name: String, _ code: String, @ViewBuilder preview: () -> some View) -> some View {
        VStack(spacing: 18) {
            preview()
                .frame(width: 360, height: 230)
                .background(Color.proGray._100.toColor(), in: RoundedRectangle(cornerRadius: 32))
            VStack(spacing: 6) {
                Text(name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.foregroundPrimary)
                Text(code)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.foregroundTertiary)
            }
        }
    }

    private func card(fill: AnyShapeStyle, text: Color) -> some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(fill)
            .frame(width: 300, height: 170)
            .overlay(alignment: .bottomLeading) {
                Text("Mega")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(text)
                    .padding(24)
            }
    }
}

#Preview {
    GradientRecipesView()
        .frame(width: ImageSize.width, height: ImageSize.height)
}
