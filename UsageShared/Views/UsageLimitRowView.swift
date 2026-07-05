import SwiftUI

struct UsageLimitRowView: View {
    let window: UsageWindow
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(window.label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                Text(UsagePercentFormatter.string(for: window.usedPercent))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(progressTint)
            }

            ProgressView(value: window.usedPercent, total: 100)
                .tint(progressTint)
                .scaleEffect(x: 1, y: 1.4, anchor: .center)
                .accessibilityLabel("\(window.label) usage")
                .accessibilityValue(UsagePercentFormatter.string(for: window.usedPercent))

            Text(UsageResetFormatter.relativeResetDescription(until: window.resetsAt))
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel(UsageResetFormatter.relativeResetDescription(until: window.resetsAt))
        }
    }

    private var progressTint: Color {
        if window.usedPercent >= 90 {
            return DesignTokens.criticalTint
        }
        if window.usedPercent >= 70 {
            return DesignTokens.warningTint
        }
        return tint
    }
}

#Preview {
    UsageLimitRowView(
        window: UsageWindow(
            id: "five_hour",
            label: "Session (5h)",
            usedPercent: 72,
            resetsAt: Date().addingTimeInterval(5_400)
        ),
        tint: DesignTokens.claudeTint
    )
    .padding()
}
