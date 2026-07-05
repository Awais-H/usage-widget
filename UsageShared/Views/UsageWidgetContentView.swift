import SwiftUI

public struct UsageWidgetContentView: View {
    let snapshot: UsageSnapshot
    let compact: Bool

    public init(snapshot: UsageSnapshot, compact: Bool) {
        self.snapshot = snapshot
        self.compact = compact
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.sectionSpacing) {
            header

            if compact {
                compactRows
            } else {
                fullRows
            }

            if let message = snapshot.message {
                Text(message)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(compact ? 2 : 3)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            ProviderBadgeView(provider: snapshot.provider)

            Spacer(minLength: 8)

            if let plan = snapshot.plan {
                Text(plan)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var fullRows: some View {
        ForEach(snapshot.windows) { window in
            UsageLimitRowView(window: window, tint: providerTint)
        }
    }

    @ViewBuilder
    private var compactRows: some View {
        ForEach(snapshot.windows.prefix(2)) { window in
            HStack {
                Text(window.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                Text(UsagePercentFormatter.string(for: window.usedPercent))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.primary)
            }

            Text(UsageResetFormatter.relativeResetDescription(until: window.resetsAt))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var providerTint: Color {
        switch snapshot.provider {
        case .claude: DesignTokens.claudeTint
        case .codex: DesignTokens.codexTint
        }
    }
}

#Preview {
    UsageWidgetContentView(snapshot: .placeholder(for: .claude), compact: false)
        .padding()
}
