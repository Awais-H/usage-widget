import Foundation

enum CodexUsageService {
    private static let usageURL = URL(string: "https://chatgpt.com/backend-api/codex/usage")!
    private static let refreshURL = URL(string: "https://auth.openai.com/oauth/token")!
    private static let clientID = "app_EMoamEEZ73f0CkXaXp7hrann"

    static func fetchSnapshot() async -> UsageSnapshot {
        guard let credentials = CodexCredentialReader.read() else {
            return demoSnapshot(message: "Run `codex login` on this Mac to load live usage.")
        }

        do {
            let accessToken = try await fetchUsage(accessToken: credentials.accessToken, credentials: credentials)
            return accessToken
        } catch {
            return demoSnapshot(message: "Could not load Codex usage: \(error.localizedDescription)")
        }
    }

    private static func fetchUsage(accessToken: String, credentials: CodexOAuthCredentials) async throws -> UsageSnapshot {
        do {
            let json = try await requestUsage(accessToken: accessToken, accountID: credentials.accountID)
            return mapResponse(json)
        } catch UsageFetchError.unauthorized {
            guard let refreshToken = credentials.refreshToken else {
                throw UsageFetchError.unauthorized
            }

            let refreshedToken = try await refreshAccessToken(refreshToken)
            let json = try await requestUsage(accessToken: refreshedToken, accountID: credentials.accountID)
            return mapResponse(json)
        }
    }

    private static func requestUsage(accessToken: String, accountID: String?) async throws -> [String: Any] {
        var request = URLRequest(url: usageURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        if let accountID, !accountID.isEmpty {
            request.setValue(accountID, forHTTPHeaderField: "chatgpt-account-id")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if http.statusCode == 401 || http.statusCode == 403 {
            throw UsageFetchError.unauthorized
        }

        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }

        return json
    }

    private static func refreshAccessToken(_ refreshToken: String) async throws -> String {
        var request = URLRequest(url: refreshURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type=refresh_token",
            "refresh_token=\(refreshToken)",
            "client_id=\(clientID)"
        ].joined(separator: "&")
        request.httpBody = Data(body.utf8)

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

    private static func mapResponse(_ json: [String: Any]) -> UsageSnapshot {
        let plan = json["plan_type"] as? String
        let rateLimit = json["rate_limit"] as? [String: Any] ?? [:]
        var windows: [UsageWindow] = []

        if let primary = rateLimit["primary_window"] as? [String: Any] {
            windows.append(makeWindow(id: "primary", label: "Session (5h)", bucket: primary))
        }

        if let secondary = rateLimit["secondary_window"] as? [String: Any] {
            windows.append(makeWindow(id: "secondary", label: "Week (7d)", bucket: secondary))
        }

        return UsageSnapshot(
            provider: .codex,
            plan: plan?.capitalized,
            windows: windows,
            updatedAt: .now,
            source: .live,
            message: nil
        )
    }

    private static func makeWindow(id: String, label: String, bucket: [String: Any]) -> UsageWindow {
        let usedPercent = bucket["used_percent"] as? Double ?? 0
        let resetAt: Date?

        if let timestamp = bucket["reset_at"] as? TimeInterval {
            resetAt = Date(timeIntervalSince1970: timestamp)
        } else if let timestamp = bucket["reset_at"] as? Int {
            resetAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            resetAt = nil
        }

        return UsageWindow(
            id: id,
            label: label,
            usedPercent: usedPercent,
            resetsAt: resetAt
        )
    }

    private static func demoSnapshot(message: String) -> UsageSnapshot {
        UsageSnapshot(
            provider: .codex,
            plan: "Plus",
            windows: [
                UsageWindow(id: "primary", label: "Session (5h)", usedPercent: 41, resetsAt: Date().addingTimeInterval(5_160)),
                UsageWindow(id: "secondary", label: "Week (7d)", usedPercent: 15, resetsAt: Date().addingTimeInterval(516_600))
            ],
            updatedAt: .now,
            source: .demo,
            message: message
        )
    }
}

private enum UsageFetchError: Error {
    case unauthorized
}
