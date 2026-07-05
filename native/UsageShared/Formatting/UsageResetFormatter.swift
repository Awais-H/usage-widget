import Foundation

enum UsageResetFormatter {
    static func relativeResetDescription(until date: Date?, reference: Date = .now) -> String {
        guard let date else { return "Reset time unavailable" }

        let interval = date.timeIntervalSince(reference)
        if interval <= 0 {
            return "Resets now"
        }

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = interval >= 86_400 ? [.day, .hour] : [.hour, .minute]
        formatter.maximumUnitCount = 2

        let formatted = formatter.string(from: interval) ?? "soon"
        return "Resets in \(formatted)"
    }

    static func absoluteResetDescription(at date: Date?) -> String {
        guard let date else { return "—" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum UsagePercentFormatter {
    static func string(for percent: Double) -> String {
        "\(Int(percent.rounded()))%"
    }
}
