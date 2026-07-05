import SwiftUI

struct QuotaColumnView: View {
    let title: String
    let tint: Color
    let quota: PlatformQuota

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetTypography.columnTitle(title, tint: tint)

            quotaRow(label: "5h", window: quota.fiveHour, weekly: false)
            quotaRow(label: "Week", window: quota.sevenDay, weekly: true)
        }
    }

    private func quotaRow(label: String, window: QuotaWindow, weekly: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                WidgetTypography.rowLabel(label)
                    .frame(width: 36, alignment: .leading)

                WidgetGlassProgressBar(
                    value: window.remainingPercent,
                    tint: color(for: window.remainingPercent)
                )

                WidgetTypography.percentage(Int(window.remainingPercent.rounded()))
            }

            WidgetTypography.resetTime(QuotaFormatting.resetText(for: window.resetsAt, weekly: weekly))
                .padding(.leading, 44)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                WidgetTypography.title("AI Usage Left")
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                WidgetTypography.timestamp(
                    (snapshot.isOffline ? "⚠ " : "") + QuotaFormatting.agoText(since: snapshot.updatedAt)
                )
            }

            content
        }
        .padding(WidgetDesign.contentPadding)
    }

    @ViewBuilder
    private var content: some View {
        if snapshot.claude == nil && snapshot.codex == nil {
            WidgetTypography.body("Import tokens on your Mac, paste JSON here once, then add this widget.")
        } else if snapshot.claude != nil && snapshot.codex != nil,
                  let claude = snapshot.claude,
                  let codex = snapshot.codex {
            HStack(alignment: .top, spacing: 14) {
                QuotaColumnView(title: "Claude", tint: WidgetDesign.claudeTint, quota: claude)
                Divider().overlay(Color.primary.opacity(0.12))
                QuotaColumnView(title: "Codex", tint: WidgetDesign.codexTint, quota: codex)
            }
        } else if let claude = snapshot.claude {
            HStack {
                Spacer()
                QuotaColumnView(title: "Claude", tint: WidgetDesign.claudeTint, quota: claude)
                Spacer()
            }
        } else if let codex = snapshot.codex {
            HStack {
                Spacer()
                QuotaColumnView(title: "Codex", tint: WidgetDesign.codexTint, quota: codex)
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
    .background {
        WidgetGlassBackground()
    }
}
