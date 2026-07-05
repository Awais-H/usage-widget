import WidgetKit
import SwiftUI

struct QuotaEntry: TimelineEntry {
    let date: Date
    let snapshot: QuotaSnapshot
}

struct QuotaTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuotaEntry {
        QuotaEntry(date: .now, snapshot: placeholderSnapshot)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuotaEntry) -> Void) {
        completion(QuotaEntry(date: .now, snapshot: QuotaCache.load() ?? placeholderSnapshot))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<QuotaEntry>) -> Void) {
        Task {
            let snapshot: QuotaSnapshot
            if TokenStore.hasAnyToken {
                snapshot = await QuotaFetcher.refreshSnapshot()
            } else {
                snapshot = QuotaCache.load() ?? placeholderSnapshot
            }

            let entry = QuotaEntry(date: .now, snapshot: snapshot)
            let nextRefresh = Calendar.current.date(byAdding: .minute, value: 12, to: .now) ?? .now.addingTimeInterval(720)
            completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
        }
    }

    private var placeholderSnapshot: QuotaSnapshot {
        QuotaSnapshot(
            claude: PlatformQuota(
                fiveHour: QuotaWindow(remainingPercent: 60, resetsAt: nil),
                sevenDay: QuotaWindow(remainingPercent: 80, resetsAt: nil)
            ),
            codex: PlatformQuota(
                fiveHour: QuotaWindow(remainingPercent: 45, resetsAt: nil),
                sevenDay: QuotaWindow(remainingPercent: 90, resetsAt: nil)
            ),
            updatedAt: .now,
            isOffline: false
        )
    }
}

struct QuotaWidget: Widget {
    let kind = "QuotaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuotaTimelineProvider()) { entry in
            QuotaWidgetView(snapshot: entry.snapshot)
                .containerBackground(for: .widget) {
                    Color(red: 0.11, green: 0.11, blue: 0.12)
                }
        }
        .configurationDisplayName("AI Usage")
        .description("Claude Code and Codex limits with reset times.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    QuotaWidget()
} timeline: {
    QuotaEntry(
        date: .now,
        snapshot: QuotaSnapshot(
            claude: PlatformQuota(
                fiveHour: QuotaWindow(remainingPercent: 62, resetsAt: .now.addingTimeInterval(3_600)),
                sevenDay: QuotaWindow(remainingPercent: 78, resetsAt: .now.addingTimeInterval(500_000))
            ),
            codex: PlatformQuota(
                fiveHour: QuotaWindow(remainingPercent: 41, resetsAt: .now.addingTimeInterval(5_000)),
                sevenDay: QuotaWindow(remainingPercent: 85, resetsAt: .now.addingTimeInterval(600_000))
            ),
            updatedAt: .now,
            isOffline: false
        )
    )
}
