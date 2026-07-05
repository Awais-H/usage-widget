import SwiftUI

struct LiquidGlassPanel<Content: View>: View {
    let tint: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(DesignTokens.contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius, style: .continuous)
                    .fill(.clear)
                    .glassEffect(.regular.tint(tint.opacity(0.35)))
            }
    }
}

struct LiquidGlassWidgetBackground: View {
    let tint: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [tint.opacity(0.35), tint.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: DesignTokens.cornerRadius, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.tint(tint.opacity(0.25)))
        }
    }
}

#Preview {
    LiquidGlassPanel(tint: DesignTokens.claudeTint) {
        Text("Liquid glass panel")
            .font(.headline)
    }
    .padding()
}
