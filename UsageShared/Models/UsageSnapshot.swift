import Foundation

public struct UsageSnapshot: Codable, Sendable {
    public let provider: UsageProviderKind
    public let plan: String?
    public let windows: [UsageWindow]
    public let updatedAt: Date
    public let source: UsageSnapshotSource
    public let message: String?

    public init(
        provider: UsageProviderKind,
        plan: String?,
        windows: [UsageWindow],
        updatedAt: Date,
        source: UsageSnapshotSource,
        message: String?
    ) {
        self.provider = provider
        self.plan = plan
        self.windows = windows
        self.updatedAt = updatedAt
        self.source = source
        self.message = message
    }

    public static func placeholder(for provider: UsageProviderKind) -> UsageSnapshot {
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

public enum UsageSnapshotSource: String, Codable, Sendable {
    case live
    case demo
    case cached
}
