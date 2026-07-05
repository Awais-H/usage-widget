import SwiftUI

struct QuotaColumnView: View {
    let title: String
    let tint: Color
    let quota: PlatformQuota

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(tint)

            quotaRow(label: "5h", window: quota.fiveHour, weekly: false)
            quotaRow(label: "Week", window: quota.sevenDay, weekly: true)
        }
    }

    private func quotaRow(label: String, window: QuotaWindow, weekly: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, alignment: .leading)

                ProgressView(value: window.remainingPercent, total: 100)
                    .tint(color(for: window.remainingPercent))

                Text("\(Int(window.remainingPercent.rounded()))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.primary)
            }

            Text(QuotaFormatting.resetText(for: window.resetsAt, weekly: weekly))
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.leading, 38)
        }
    }

    private func color(for remaining: Double) -> Color {
        if remaining > 50 { return .green }
        if remaining > 20 { return .orange }
        return .red
    }
}

struct QuotaWidgetView: View {
    let snapshot: QuotaSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("AI Usage Left")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)

                Spacer()

                Text((snapshot.isOffline ? "⚠ " : "") + QuotaFormatting.agoText(since: snapshot.updatedAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            content
        }
        .padding(14)
    }

    @ViewBuilder
    private var content: some View {
        if snapshot.claude == nil && snapshot.codex == nil {
            Text("Import tokens on your Mac, paste JSON here once, then add this widget.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else if snapshot.claude != nil && snapshot.codex != nil,
                  let claude = snapshot.claude,
                  let codex = snapshot.codex {
            HStack(alignment: .top, spacing: 12) {
                QuotaColumnView(title: "Claude", tint: Color(red: 0.85, green: 0.47, blue: 0.34), quota: claude)
                Divider().overlay(Color.white.opacity(0.15))
                QuotaColumnView(title: "Codex", tint: Color(red: 0.06, green: 0.64, blue: 0.50), quota: codex)
            }
        } else if let claude = snapshot.claude {
            HStack {
                Spacer()
                QuotaColumnView(title: "Claude", tint: Color(red: 0.85, green: 0.47, blue: 0.34), quota: claude)
                Spacer()
            }
        } else if let codex = snapshot.codex {
            HStack {
                Spacer()
                QuotaColumnView(title: "Codex", tint: Color(red: 0.06, green: 0.64, blue: 0.50), quota: codex)
                Spacer()
            }
        }
    }
}

#Preview {
    QuotaWidgetView(
        snapshot: QuotaSnapshot(
            claude: PlatformQuota(
                fiveHour: QuotaWindow(remainingPercent: 62, resetsAt: Date().addingTimeInterval(3_600)),
                sevenDay: QuotaWindow(remainingPercent: 78, resetsAt: Date().addingTimeInterval(500_000))
            ),
            codex: PlatformQuota(
                fiveHour: QuotaWindow(remainingPercent: 41, resetsAt: Date().addingTimeInterval(5_000)),
                sevenDay: QuotaWindow(remainingPercent: 85, resetsAt: Date().addingTimeInterval(600_000))
            ),
            updatedAt: .now,
            isOffline: false
        )
    )
    .background(Color(red: 0.11, green: 0.11, blue: 0.12))
}
