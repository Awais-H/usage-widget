import Foundation

enum ClaudeUsageService {
    private static let usageURL = URL(string: "https://api.anthropic.com/api/oauth/usage")!
    private static let refreshURL = URL(string: "https://platform.claude.com/v1/oauth/token")!

    static func fetchSnapshot() async -> UsageSnapshot {
        guard let credentials = ClaudeCredentialReader.read() else {
            #if os(macOS)
            return demoSnapshot(message: "Sign in to Claude Code on this Mac to load live usage.")
            #else
            return demoSnapshot(message: "Run the Mac app once to sync Claude usage to this device.")
            #endif
        }

        do {
            let accessToken = try await validAccessToken(from: credentials)
            let payload = try await requestUsage(accessToken: accessToken)
            return mapResponse(payload, subscriptionType: credentials.subscriptionType)
        } catch {
            return demoSnapshot(message: "Could not load Claude usage: \(error.localizedDescription)")
        }
    }

    private static func validAccessToken(from credentials: ClaudeOAuthCredentials) async throws -> String {
        if let expiresAt = credentials.expiresAt, expiresAt > Date().addingTimeInterval(60) {
            return credentials.accessToken
        }

        guard let refreshToken = credentials.refreshToken else {
            return credentials.accessToken
        }

        return try await refreshAccessToken(refreshToken)
    }

    private static func refreshAccessToken(_ refreshToken: String) async throws -> String {
        var request = URLRequest(url: refreshURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.userAuthenticationRequired)
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let accessToken = json["access_token"] as? String
        else {
            throw URLError(.cannotParseResponse)
        }

        return accessToken
    }

    private static func requestUsage(accessToken: String) async throws -> [String: Any] {
        var request = URLRequest(url: usageURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("claude-code/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }

        return json
    }

    private static func mapResponse(_ json: [String: Any], subscriptionType: String?) -> UsageSnapshot {
        var windows: [UsageWindow] = []

        if let bucket = json["five_hour"] as? [String: Any] {
            windows.append(makeWindow(id: "five_hour", label: "Session (5h)", bucket: bucket))
        }

        if let bucket = json["seven_day"] as? [String: Any] {
            windows.append(makeWindow(id: "seven_day", label: "Week (7d)", bucket: bucket))
        }

        if let bucket = json["seven_day_sonnet"] as? [String: Any] {
            windows.append(makeWindow(id: "seven_day_sonnet", label: "Sonnet (7d)", bucket: bucket))
        }

        if let bucket = json["seven_day_opus"] as? [String: Any] {
            windows.append(makeWindow(id: "seven_day_opus", label: "Opus (7d)", bucket: bucket))
        }

        return UsageSnapshot(
            provider: .claude,
            plan: subscriptionType?.capitalized,
            windows: windows,
            updatedAt: .now,
            source: .live,
            message: nil
        )
    }

    private static func makeWindow(id: String, label: String, bucket: [String: Any]) -> UsageWindow {
        let utilization = bucket["utilization"] as? Double ?? 0
        let resetsAt = parseDate(bucket["resets_at"])

        return UsageWindow(
            id: id,
            label: label,
            usedPercent: utilization,
            resetsAt: resetsAt
        )
    }

    private static func parseDate(_ value: Any?) -> Date? {
        guard let string = value as? String else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }

    private static func demoSnapshot(message: String) -> UsageSnapshot {
        UsageSnapshot(
            provider: .claude,
            plan: "Pro",
            windows: [
                UsageWindow(id: "five_hour", label: "Session (5h)", usedPercent: 38, resetsAt: Date().addingTimeInterval(7_200)),
                UsageWindow(id: "seven_day", label: "Week (7d)", usedPercent: 22, resetsAt: Date().addingTimeInterval(432_000))
            ],
            updatedAt: .now,
            source: .demo,
            message: message
        )
    }
}
