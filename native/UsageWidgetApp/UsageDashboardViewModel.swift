import SwiftUI

@MainActor
@Observable
final class UsageDashboardViewModel {
    var selectedProvider: UsageProviderKind {
        didSet {
            UsageSharedStore.selectedProvider = selectedProvider
            loadCachedSnapshot()
        }
    }

    private(set) var snapshot: UsageSnapshot
    private(set) var isRefreshing = false

    init() {
        selectedProvider = UsageSharedStore.selectedProvider
        snapshot = UsageSharedStore.load(provider: UsageSharedStore.selectedProvider)
            ?? .placeholder(for: UsageSharedStore.selectedProvider)
    }

    func loadCachedSnapshot() {
        snapshot = UsageSharedStore.load(provider: selectedProvider)
            ?? .placeholder(for: selectedProvider)
    }

    func refresh() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        defer { isRefreshing = false }

        snapshot = await UsageSyncService.refresh(provider: selectedProvider)
    }

    func refreshAllProviders() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        defer { isRefreshing = false }

        await UsageSyncService.refreshAllProviders()
        loadCachedSnapshot()
    }
}
