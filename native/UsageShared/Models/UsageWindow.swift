import Foundation

struct UsageWindow: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let label: String
    let usedPercent: Double
    let resetsAt: Date?

    var remainingPercent: Double {
        max(0, min(100, 100 - usedPercent))
    }
}
