import Foundation

enum UsageProviderKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case claude
    case codex

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .claude: "Claude Code"
        case .codex: "Codex"
        }
    }

    var systemImage: String {
        switch self {
        case .claude: "sparkles"
        case .codex: "terminal"
        }
    }
}
