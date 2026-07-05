import Foundation
import WidgetKit

public enum UsageSyncService {
    public static func refreshAllProviders() async {
        async let claude = ClaudeUsageService.fetchSnapshot()
        async let codex = CodexUsageService.fetchSnapshot()

        let snapshots = await [claude, codex]
        for snapshot in snapshots {
            UsageSharedStore.save(snapshot)
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    public static func refresh(provider: UsageProviderKind) async -> UsageSnapshot {
        let snapshot: UsageSnapshot
        switch provider {
        case .claude:
            snapshot = await ClaudeUsageService.fetchSnapshot()
        case .codex:
            snapshot = await CodexUsageService.fetchSnapshot()
        }

        UsageSharedStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
        return snapshot
    }
}
