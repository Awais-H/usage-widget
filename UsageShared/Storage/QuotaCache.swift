import Foundation

enum QuotaCache {
    private static let snapshotKey = "quota.snapshot"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: AppGroupConfiguration.identifier)
    }

    static func save(_ snapshot: QuotaSnapshot) {
        guard let defaults else { return }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
    }

    static func load() -> QuotaSnapshot? {
        guard
            let defaults,
            let data = defaults.data(forKey: snapshotKey)
        else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(QuotaSnapshot.self, from: data)
    }
}
