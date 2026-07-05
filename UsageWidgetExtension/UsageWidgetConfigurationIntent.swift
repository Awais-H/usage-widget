import AppIntents
import SwiftUI

struct UsageProviderEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Provider")
    static var defaultQuery = UsageProviderQuery()

    var id: String
    var displayName: String

    var provider: UsageProviderKind {
        UsageProviderKind(rawValue: id) ?? .claude
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayName)")
    }
}

struct UsageProviderQuery: EntityQuery {
    func entities(for identifiers: [UsageProviderEntity.ID]) async throws -> [UsageProviderEntity] {
        UsageProviderKind.allCases
            .filter { identifiers.contains($0.rawValue) }
            .map(makeEntity)
    }

    func suggestedEntities() async throws -> [UsageProviderEntity] {
        UsageProviderKind.allCases.map(makeEntity)
    }

    private func makeEntity(_ provider: UsageProviderKind) -> UsageProviderEntity {
        UsageProviderEntity(id: provider.rawValue, displayName: provider.displayName)
    }
}

struct UsageWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Usage Provider"
    static var description = IntentDescription("Choose whether to show Claude Code or Codex limits.")

    @Parameter(title: "Provider", default: UsageProviderEntity(id: "claude", displayName: "Claude Code"))
    var provider: UsageProviderEntity
}
