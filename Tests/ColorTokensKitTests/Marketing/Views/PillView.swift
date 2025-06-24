import SwiftUI
import ColorTokensKit

struct PillView: View {
    private let nativeColors: [(name: String, color: Color)] = [
        ("Gray", .gray),
        ("Red", .red),
        ("Brown", .brown),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Mint", .mint),
        ("Cyan", .cyan),
        ("Teal", .teal),
        ("Blue", .blue),
        ("Indigo", .indigo),
        ("Purple", .purple),
        ("Black", .black)
    ]
    
    private var colorRamps: [(name: String, color: LCHColor)] {
        Color.allProHues.map { (name: $0.key, color: $0.value) }
            .sorted { lhs, rhs in
                if lhs.name == "Gray" { return true }
                if rhs.name == "Gray" { return false }
                return lhs.color.h < rhs.color.h
            }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 128) {
            VStack(alignment: .center, spacing: 48) {
                VStack(spacing: 12) {
                    Text("👎 SwiftUI Colors")
                        .font(.system(size: 32, weight: .black))
                        .foregroundStyle(Color.foregroundPrimary)
                    Text("Limited, inconsistent brightness, not customizable")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color.foregroundTertiary)
                }
                
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ForEach(nativeColors.prefix(nativeColors.count / 2), id: \.name) { colorInfo in
                            makePill(text: "\(colorInfo.name)",
                                     color: colorInfo.color)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        ForEach(nativeColors.suffix(nativeColors.count / 2), id: \.name) { colorInfo in
                            makePill(text: "\(colorInfo.name)",
                                     color: colorInfo.color)
                        }
                    }
                }
            }
            
            VStack(alignment: .center, spacing: 48) {
                VStack(spacing: 12) {
                    Text("🔥 ColorTokensKit")
                        .foregroundStyle(Color.foregroundPrimary)
                        .font(.system(size: 32, weight: .black))
                    
                    Text("Unlimited colors, uniform brightness, dark mode support,  customizable")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color.foregroundTertiary)
                }
                
                VStack(spacing: 16) {
                    let numberOfItemsPerRow = Int(ceil(Double(colorRamps.count) / 3.0))
                    
                    HStack(spacing: 16) {
                        ForEach(colorRamps.prefix(numberOfItemsPerRow), id: \.name) { colorInfo in
                            makeThemedPill(text: "\(colorInfo.name)",
                                     theme: colorInfo.color)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        ForEach(colorRamps.dropFirst(numberOfItemsPerRow).prefix(numberOfItemsPerRow), id: \.name) { colorInfo in
                            makeThemedPill(text: "\(colorInfo.name)",
                                     theme: colorInfo.color)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        ForEach(colorRamps.dropFirst(numberOfItemsPerRow * 2), id: \.name) { colorInfo in
                            makeThemedPill(text: "\(colorInfo.name)",
                                     theme: colorInfo.color)
                        }
                    }
                }
            }
        }
        .fontDesign(.monospaced)
        .padding(MarketingStyle.pagePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.white)
    }
    
    private func makePill(text: String, color: Color) -> some View {
        return Text(text)
            .font(.title)
            .foregroundColor(Color.primary)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(color.quinary)
            .clipShape(Capsule())
    }
    
    private func makeThemedPill(text: String, theme: LCHColor) -> some View {
        Text(text)
            .font(.title)
            .foregroundColor(theme.foregroundSecondary)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(theme.backgroundSecondary)
            .clipShape(Capsule())
    }
}

#Preview {
    PillView()
        .frame(width: ImageSize.width, height: ImageSize.height)
} 
