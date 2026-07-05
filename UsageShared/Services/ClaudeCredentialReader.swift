import Foundation
import Security

struct ClaudeOAuthCredentials: Sendable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date?
    let subscriptionType: String?
}

enum ClaudeCredentialReader {
    private static let credentialsFileURL: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/.credentials.json")
    }()

    private static let keychainService = "Claude Code-credentials"

    static func read() -> ClaudeOAuthCredentials? {
        if let credentials = readFromFile() {
            return credentials
        }
        return readFromKeychain()
    }

    private static func readFromFile() -> ClaudeOAuthCredentials? {
        guard
            let data = try? Data(contentsOf: credentialsFileURL),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let oauth = json["claudeAiOauth"] as? [String: Any],
            let accessToken = oauth["accessToken"] as? String,
            !accessToken.isEmpty
        else {
            return nil
        }

        return makeCredentials(from: oauth)
    }

    private static func readFromKeychain() -> ClaudeOAuthCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let oauth = json["claudeAiOauth"] as? [String: Any],
            let accessToken = oauth["accessToken"] as? String,
            !accessToken.isEmpty
        else {
            return nil
        }

        return makeCredentials(from: oauth)
    }

    private static func makeCredentials(from oauth: [String: Any]) -> ClaudeOAuthCredentials {
        let refreshToken = oauth["refreshToken"] as? String
        let subscriptionType = oauth["subscriptionType"] as? String

        let expiresAt: Date?
        if let milliseconds = oauth["expiresAt"] as? Double {
            expiresAt = Date(timeIntervalSince1970: milliseconds / 1_000)
        } else if let milliseconds = oauth["expiresAt"] as? Int {
            expiresAt = Date(timeIntervalSince1970: Double(milliseconds) / 1_000)
        } else {
            expiresAt = nil
        }

        return ClaudeOAuthCredentials(
            accessToken: oauth["accessToken"] as? String ?? "",
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            subscriptionType: subscriptionType
        )
    }
}
