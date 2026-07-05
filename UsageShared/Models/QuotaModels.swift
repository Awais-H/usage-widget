import Foundation

struct ClaudeTokens: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Int64
}

struct CodexTokens: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let accountId: String?
}

struct ImportTokensPayload: Codable, Sendable {
    let claude: ClaudeTokens?
    let codex: CodexTokens?
}

struct QuotaWindow: Codable, Sendable, Hashable {
    let remainingPercent: Double
    let resetsAt: Date?
}

struct PlatformQuota: Codable, Sendable, Hashable {
    let fiveHour: QuotaWindow
    let sevenDay: QuotaWindow

    static let empty = PlatformQuota(
        fiveHour: QuotaWindow(remainingPercent: 0, resetsAt: nil),
        sevenDay: QuotaWindow(remainingPercent: 0, resetsAt: nil)
    )
}

struct QuotaSnapshot: Codable, Sendable {
    let claude: PlatformQuota?
    let codex: PlatformQuota?
    let updatedAt: Date
    let isOffline: Bool
}

enum APIConfig {
    static let claudeUsageURL = URL(string: "https://api.anthropic.com/api/oauth/usage")!
    static let claudeRefreshURL = URL(string: "https://console.anthropic.com/v1/oauth/token")!
    static let claudeClientID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e"
    static let codexUsageURL = URL(string: "https://chatgpt.com/backend-api/wham/usage")!
    static let codexRefreshURL = URL(string: "https://auth.openai.com/oauth/token")!
    static let codexClientID = "app_EMoamEEZ73f0CkXaXp7hrann"
}
