import Foundation

enum QuotaFormatting {
    static func resetText(for date: Date?, weekly: Bool) -> String? {
        guard let date else { return nil }

        if date.timeIntervalSinceNow <= 0 {
            return "Resets soon"
        }

        if weekly {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("MMMd")
            return "\(formatter.string(from: date)) reset"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: date)) reset"
    }

    static func agoText(since date: Date) -> String {
        let minutes = Int(Date.now.timeIntervalSince(date) / 60)
        if minutes <= 0 { return "just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        return "\(minutes / 60)h ago"
    }

    static func barColor(for remaining: Double) -> String {
        if remaining > 50 { return "green" }
        if remaining > 20 { return "orange" }
        return "red"
    }
}
