import Foundation

struct CodexOAuthCredentials: Sendable {
    let accessToken: String
    let refreshToken: String?
    let accountID: String?
}

enum CodexCredentialReader {
    static func read() -> CodexOAuthCredentials? {
        #if os(macOS)
        guard
            let data = try? Data(contentsOf: authFileURL),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let tokens = json["tokens"] as? [String: Any],
            let accessToken = tokens["access_token"] as? String,
            !accessToken.isEmpty
        else {
            return nil
        }

        return CodexOAuthCredentials(
            accessToken: accessToken,
            refreshToken: tokens["refresh_token"] as? String,
            accountID: tokens["account_id"] as? String
        )
        #else
        return nil
        #endif
    }

    #if os(macOS)
    private static let authFileURL: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".codex/auth.json")
    }()
    #endif
}
