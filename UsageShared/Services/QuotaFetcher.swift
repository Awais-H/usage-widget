import Foundation
import WidgetKit

enum QuotaFetcher {
    static func refreshSnapshot() async -> QuotaSnapshot {
        let cache = QuotaCache.load()
        var offline = false

        async let claudeResult = fetchClaude()
        async let codexResult = fetchCodex()

        let claude = resolve(await claudeResult, cached: cache?.claude, offline: &offline)
        let codex = resolve(await codexResult, cached: cache?.codex, offline: &offline)

        let snapshot = QuotaSnapshot(
            claude: claude,
            codex: codex,
            updatedAt: offline ? (cache?.updatedAt ?? .now) : .now,
            isOffline: offline
        )

        if !offline || cache == nil {
            QuotaCache.save(snapshot)
        }

        WidgetCenter.shared.reloadAllTimelines()
        return snapshot
    }

    private static func resolve(
        _ result: Result<PlatformQuota?, Error>,
        cached: PlatformQuota?,
        offline: inout Bool
    ) -> PlatformQuota? {
        switch result {
        case .success(let quota):
            return quota
        case .failure:
            offline = true
            return cached
        }
    }

    private static func fetchClaude() async -> Result<PlatformQuota?, Error> {
        guard var tokens = TokenStore.loadClaude() else {
            return .success(nil)
        }

        do {
            if tokens.expiresAt > 0, Date.now.timeIntervalSince1970 * 1_000 > Double(tokens.expiresAt - 60_000) {
                tokens = try await refreshClaude(tokens)
            }

            do {
                return .success(try await requestClaude(tokens))
            } catch FetchError.unauthorized {
                tokens = try await refreshClaude(tokens)
                return .success(try await requestClaude(tokens))
            }
        } catch {
            return .failure(error)
        }
    }

    private static func fetchCodex() async -> Result<PlatformQuota?, Error> {
        guard var tokens = TokenStore.loadCodex() else {
            return .success(nil)
        }

        do {
            do {
                return .success(try await requestCodex(tokens))
            } catch FetchError.unauthorized {
                tokens = try await refreshCodex(tokens)
                return .success(try await requestCodex(tokens))
            }
        } catch {
            return .failure(error)
        }
    }

    private static func refreshClaude(_ tokens: ClaudeTokens) async throws -> ClaudeTokens {
        var request = URLRequest(url: APIConfig.claudeRefreshURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode([
            "grant_type": "refresh_token",
            "refresh_token": tokens.refreshToken,
            "client_id": APIConfig.claudeClientID
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let accessToken = json["access_token"] as? String
        else {
            throw FetchError.invalidResponse
        }

        let updated = ClaudeTokens(
            accessToken: accessToken,
            refreshToken: json["refresh_token"] as? String ?? tokens.refreshToken,
            expiresAt: Int64(Date.now.timeIntervalSince1970 * 1_000) + Int64((json["expires_in"] as? Int ?? 3_600) * 1_000)
        )
        TokenStore.saveClaude(updated)
        return updated
    }

    private static func refreshCodex(_ tokens: CodexTokens) async throws -> CodexTokens {
        var request = URLRequest(url: APIConfig.codexRefreshURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode([
            "grant_type": "refresh_token",
            "refresh_token": tokens.refreshToken,
            "client_id": APIConfig.codexClientID
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let accessToken = json["access_token"] as? String
        else {
            throw FetchError.invalidResponse
        }

        let updated = CodexTokens(
            accessToken: accessToken,
            refreshToken: json["refresh_token"] as? String ?? tokens.refreshToken,
            accountId: tokens.accountId
        )
        TokenStore.saveCodex(updated)
        return updated
    }

    private static func requestClaude(_ tokens: ClaudeTokens) async throws -> PlatformQuota {
        var request = URLRequest(url: APIConfig.claudeUsageURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 6
        request.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("claude-cli", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode == 401 {
            throw FetchError.unauthorized
        }
        try validate(response)

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let fiveHour = json["five_hour"] as? [String: Any]
        else {
            throw FetchError.invalidResponse
        }

        let sevenDay = json["seven_day"] as? [String: Any] ?? [:]
        return PlatformQuota(
            fiveHour: makeWindow(from: fiveHour),
            sevenDay: makeWindow(from: sevenDay)
        )
    }

    private static func requestCodex(_ tokens: CodexTokens) async throws -> PlatformQuota {
        var request = URLRequest(url: APIConfig.codexUsageURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 6
        request.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("codex-cli", forHTTPHeaderField: "User-Agent")

        if let accountId = tokens.accountId, !accountId.isEmpty {
            request.setValue(accountId, forHTTPHeaderField: "chatgpt-account-id")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode == 401 {
            throw FetchError.unauthorized
        }
        try validate(response)

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let rateLimit = json["rate_limit"] as? [String: Any]
        else {
            throw FetchError.invalidResponse
        }

        let primary = rateLimit["primary_window"] as? [String: Any] ?? [:]
        let secondary = rateLimit["secondary_window"] as? [String: Any] ?? [:]
        return PlatformQuota(
            fiveHour: makeCodexWindow(from: primary),
            sevenDay: makeCodexWindow(from: secondary)
        )
    }

    private static func makeWindow(from json: [String: Any]) -> QuotaWindow {
        let used = json["utilization"] as? Double ?? 0
        let resetsAt = parseISO8601(json["resets_at"])
        return QuotaWindow(remainingPercent: max(0, 100 - used), resetsAt: resetsAt)
    }

    private static func makeCodexWindow(from json: [String: Any]) -> QuotaWindow {
        let used = json["used_percent"] as? Double ?? 0
        let resetsAt: Date?
        if let timestamp = json["reset_at"] as? TimeInterval {
            resetsAt = Date(timeIntervalSince1970: timestamp)
        } else if let timestamp = json["reset_at"] as? Int {
            resetsAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            resetsAt = nil
        }
        return QuotaWindow(remainingPercent: max(0, 100 - used), resetsAt: resetsAt)
    }

    private static func parseISO8601(_ value: Any?) -> Date? {
        guard let string = value as? String else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }

    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw FetchError.invalidResponse
        }
    }
}

private enum FetchError: Error {
    case unauthorized
    case invalidResponse
}
