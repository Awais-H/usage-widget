import Foundation

struct UsageSnapshot: Codable, Sendable {
    let provider: UsageProviderKind
    let plan: String?
    let windows: [UsageWindow]
    let updatedAt: Date
    let source: UsageSnapshotSource
    let message: String?

    static func placeholder(for provider: UsageProviderKind) -> UsageSnapshot {
        UsageSnapshot(
            provider: provider,
            plan: nil,
            windows: [
                UsageWindow(id: "session", label: "Session (5h)", usedPercent: 0, resetsAt: nil),
                UsageWindow(id: "weekly", label: "Week (7d)", usedPercent: 0, resetsAt: nil)
            ],
            updatedAt: .now,
            source: .demo,
            message: "Sign in to \(provider.displayName) on this Mac to load live usage."
        )
    }
}

enum UsageSnapshotSource: String, Codable, Sendable {
    case live
    case demo
    case cached
}
