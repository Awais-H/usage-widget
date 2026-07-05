import SwiftUI

struct ProviderBadgeView: View {
    let provider: UsageProviderKind

    var body: some View {
        Label(provider.displayName, systemImage: provider.systemImage)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(tint.opacity(0.18))
            }
            .foregroundStyle(tint)
            .accessibilityLabel("\(provider.displayName) provider")
    }

    private var tint: Color {
        switch provider {
        case .claude: DesignTokens.claudeTint
        case .codex: DesignTokens.codexTint
        }
    }
}

#Preview {
    ProviderBadgeView(provider: .claude)
        .padding()
}
