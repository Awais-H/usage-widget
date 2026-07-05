import SwiftUI
import WidgetKit

struct UsageWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: UsageWidgetEntry

    var body: some View {
        UsageWidgetContentView(snapshot: entry.snapshot, compact: family == .systemSmall)
            .containerBackground(for: .widget) {
                LiquidGlassWidgetBackground(tint: providerTint)
            }
    }

    private var providerTint: Color {
        switch entry.snapshot.provider {
        case .claude: DesignTokens.claudeTint
        case .codex: DesignTokens.codexTint
        }
    }
}

struct UsageWidget: Widget {
    let kind = "UsageWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: UsageWidgetConfigurationIntent.self,
            provider: UsageTimelineProvider()
        ) { entry in
            UsageWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AI Usage")
        .description("Shows Claude Code or Codex session and weekly limits with reset times.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    UsageWidget()
} timeline: {
    UsageWidgetEntry(date: .now, snapshot: .placeholder(for: .claude))
    UsageWidgetEntry(date: .now, snapshot: .placeholder(for: .codex))
}
