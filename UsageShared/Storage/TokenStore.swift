import Foundation

enum AppGroupConfiguration {
    static let identifier = "group.dev.awaishashar.usage-widget"
}

enum TokenStore {
    private static let claudeKey = "tokens.claude"
    private static let codexKey = "tokens.codex"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: AppGroupConfiguration.identifier)
    }

    static func saveClaude(_ tokens: ClaudeTokens) {
        save(tokens, key: claudeKey)
    }

    static func saveCodex(_ tokens: CodexTokens) {
        save(tokens, key: codexKey)
    }

    static func loadClaude() -> ClaudeTokens? {
        load(key: claudeKey)
    }

    static func loadCodex() -> CodexTokens? {
        load(key: codexKey)
    }

    static var hasAnyToken: Bool {
        loadClaude() != nil || loadCodex() != nil
    }

    @discardableResult
    static func importFromClipboardJSON(_ json: String) throws -> [String] {
        guard let data = json.data(using: .utf8) else {
            throw TokenImportError.invalidJSON
        }

        let payload = try JSONDecoder().decode(ImportTokensPayload.self, from: data)
        var imported: [String] = []

        if let claude = payload.claude, !claude.accessToken.isEmpty {
            saveClaude(claude)
            imported.append("Claude")
        }

        if let codex = payload.codex, !codex.accessToken.isEmpty {
            saveCodex(codex)
            imported.append("Codex")
        }

        if imported.isEmpty {
            throw TokenImportError.nothingImported
        }

        return imported
    }

    private static func save<T: Encodable>(_ value: T, key: String) {
        guard
            let defaults,
            let data = try? JSONEncoder().encode(value)
        else {
            return
        }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(key: String) -> T? {
        guard
            let defaults,
            let data = defaults.data(forKey: key)
        else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

enum TokenImportError: LocalizedError {
    case invalidJSON
    case nothingImported

    var errorDescription: String? {
        switch self {
        case .invalidJSON:
            "Clipboard does not contain valid token JSON."
        case .nothingImported:
            "No Claude or Codex tokens were found in the JSON."
        }
    }
}
