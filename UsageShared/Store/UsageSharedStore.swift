import Foundation

enum AppGroupConfiguration {
    static let identifier = "group.dev.awaishashar.usage-widget"
    static let selectedProviderKey = "selectedProvider"
    static let snapshotKeyPrefix = "usageSnapshot."
}

enum UsageSharedStore {
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: AppGroupConfiguration.identifier)
    }

    static func save(_ snapshot: UsageSnapshot) {
        guard let defaults else { return }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(snapshot) else { return }
        defaults.set(data, forKey: AppGroupConfiguration.snapshotKeyPrefix + snapshot.provider.rawValue)
    }

    static func load(provider: UsageProviderKind) -> UsageSnapshot? {
        guard
            let defaults,
            let data = defaults.data(forKey: AppGroupConfiguration.snapshotKeyPrefix + provider.rawValue)
        else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(UsageSnapshot.self, from: data)
    }

    static func loadAll() -> [UsageSnapshot] {
        UsageProviderKind.allCases.compactMap { load(provider: $0) }
    }

    static var selectedProvider: UsageProviderKind {
        get {
            guard
                let defaults,
                let rawValue = defaults.string(forKey: AppGroupConfiguration.selectedProviderKey),
                let provider = UsageProviderKind(rawValue: rawValue)
            else {
                return .claude
            }
            return provider
        }
        set {
            defaults?.set(newValue.rawValue, forKey: AppGroupConfiguration.selectedProviderKey)
        }
    }
}
