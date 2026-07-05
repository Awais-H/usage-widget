import WidgetKit
import SwiftUI

struct UsageWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: UsageSnapshot
}

struct UsageTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> UsageWidgetEntry {
        UsageWidgetEntry(date: .now, snapshot: .placeholder(for: .claude))
    }

    func snapshot(for configuration: UsageWidgetConfigurationIntent, in context: Context) async -> UsageWidgetEntry {
        let provider = configuration.provider.provider
        let snapshot = UsageSharedStore.load(provider: provider) ?? .placeholder(for: provider)
        return UsageWidgetEntry(date: .now, snapshot: snapshot)
    }

    func timeline(for configuration: UsageWidgetConfigurationIntent, in context: Context) async -> Timeline<UsageWidgetEntry> {
        let provider = configuration.provider.provider
        let snapshot = UsageSharedStore.load(provider: provider) ?? .placeholder(for: provider)
        let entry = UsageWidgetEntry(date: .now, snapshot: snapshot)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(900)

        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }
}
