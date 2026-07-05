import SwiftUI

struct QuotaColumnView: View {
    let title: String
    let accent: Color
    let quota: PlatformQuota
    let showsResetTimes: Bool

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
                    tint: barColor(for: window.remainingPercent)
                )

                WidgetTypography.percentage(Int(window.remainingPercent.rounded()))
            }

            if showsResetTimes,
               let resetText = QuotaFormatting.resetText(for: window.resetsAt, weekly: weekly) {
                WidgetTypography.resetTime(resetText)
                    .padding(.leading, WidgetDesign.rowLabelWidth + 8)
            }
        }
    }

    private func barColor(for remaining: Double) -> Color {
        guard showsResetTimes else { return WidgetDesign.progressBarTrack }
        return WidgetDesign.progressColor(for: remaining)
    }
}

struct QuotaWidgetView: View {
    let snapshot: QuotaSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: WidgetDesign.headerSpacing) {
            header
            dualColumnContent
        }
        .padding(WidgetDesign.contentPadding)
    }

    private var header: some View {
        WidgetTypography.title(WidgetDesign.title)
    }

    private var dualColumnContent: some View {
        HStack(alignment: .top, spacing: WidgetDesign.columnSpacing) {
            QuotaColumnView(
                title: "Claude",
                accent: WidgetDesign.claudeAccent,
                quota: snapshot.claude ?? .empty,
                showsResetTimes: snapshot.claude != nil
            )
            Rectangle()
                .fill(WidgetDesign.divider)
                .frame(width: 1)
            QuotaColumnView(
                title: "Codex",
                accent: WidgetDesign.codexAccent,
                quota: snapshot.codex ?? .empty,
                showsResetTimes: snapshot.codex != nil
            )
        }
    }
}

#Preview("With data") {
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

#Preview("No data") {
    QuotaWidgetView(
        snapshot: QuotaSnapshot(
            claude: nil,
            codex: nil,
            updatedAt: .now,
            isOffline: false
        )
    )
    .background {
        WidgetGlassBackground()
    }
}
