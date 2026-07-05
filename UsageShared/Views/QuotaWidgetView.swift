import SwiftUI

struct QuotaColumnView: View {
    let title: String
    let accent: Color
    let quota: PlatformQuota

    var body: some View {
        VStack(alignment: .leading, spacing: WidgetDesign.columnTitleSpacing) {
            WidgetTypography.columnTitle(title, accent: accent)

            VStack(alignment: .leading, spacing: WidgetDesign.rowSpacing) {
                quotaRow(label: "5h", window: quota.fiveHour, weekly: false)
                quotaRow(label: "Week", window: quota.sevenDay, weekly: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func quotaRow(label: String, window: QuotaWindow, weekly: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                WidgetTypography.rowLabel(label)
                    .frame(width: WidgetDesign.rowLabelWidth, alignment: .leading)

                WidgetGlassProgressBar(
                    value: window.remainingPercent,
                    tint: WidgetDesign.progressColor(for: window.remainingPercent)
                )

                WidgetTypography.percentage(Int(window.remainingPercent.rounded()))
            }

            WidgetTypography.resetTime(QuotaFormatting.resetText(for: window.resetsAt, weekly: weekly))
                .padding(.leading, WidgetDesign.rowLabelWidth + 8)
        }
    }
}

struct QuotaWidgetView: View {
    let snapshot: QuotaSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: WidgetDesign.headerSpacing) {
            header
            content
        }
        .padding(WidgetDesign.contentPadding)
    }

    private var header: some View {
        WidgetTypography.title(WidgetDesign.title)
    }

    @ViewBuilder
    private var content: some View {
        if snapshot.claude == nil && snapshot.codex == nil {
            WidgetTypography.body("Import tokens on your Mac, paste JSON here once, then add this widget.")
        } else if snapshot.claude != nil && snapshot.codex != nil,
                  let claude = snapshot.claude,
                  let codex = snapshot.codex {
            HStack(alignment: .top, spacing: WidgetDesign.columnSpacing) {
                QuotaColumnView(title: "Claude", accent: WidgetDesign.claudeAccent, quota: claude)
                Rectangle()
                    .fill(WidgetDesign.divider)
                    .frame(width: 1)
                QuotaColumnView(title: "Codex", accent: WidgetDesign.codexAccent, quota: codex)
            }
        } else if let claude = snapshot.claude {
            QuotaColumnView(title: "Claude", accent: WidgetDesign.claudeAccent, quota: claude)
        } else if let codex = snapshot.codex {
            QuotaColumnView(title: "Codex", accent: WidgetDesign.codexAccent, quota: codex)
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
