import SwiftUI

struct ImportView: View {
    @State private var message = "Run export-tokens.sh on your Mac, copy the JSON, then import here."
    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("1. On Mac: bash export-tokens.sh | pbcopy")
                Text("2. Paste JSON on iPhone and tap Import")
                Text("3. Add the medium widget to your Home Screen")

                Button("Import from Clipboard", action: importFromClipboard)

                Button {
                    refresh()
                } label: {
                    if isRefreshing {
                        ProgressView()
                    } else {
                        Text("Refresh Widget Now")
                    }
                }
                .disabled(isRefreshing)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Usage Widget")
            .task {
                if TokenStore.hasAnyToken {
                    await refreshSnapshot()
                }
            }
        }
    }

    private func importFromClipboard() {
        #if os(iOS)
        guard let json = UIPasteboard.general.string else {
            message = "Clipboard is empty."
            return
        }

        do {
            let imported = try TokenStore.importFromClipboardJSON(json)
            message = "Imported \(imported.joined(separator: " + ")). Refreshing widget…"
            refresh()
        } catch {
            message = error.localizedDescription
        }
        #endif
    }

    private func refresh() {
        Task {
            await refreshSnapshot()
        }
    }

    @MainActor
    private func refreshSnapshot() async {
        isRefreshing = true
        defer { isRefreshing = false }

        let snapshot = await QuotaFetcher.refreshSnapshot()
        let parts = [snapshot.claude != nil ? "Claude" : nil, snapshot.codex != nil ? "Codex" : nil].compactMap { $0 }
        if parts.isEmpty {
            message = snapshot.isOffline
                ? "Could not fetch usage. Showing cached data if available."
                : "No usage data yet. Import tokens first."
        } else {
            message = "Updated \(parts.joined(separator: " + "))" + (snapshot.isOffline ? " (offline cache)" : ".")
        }
    }
}

#Preview {
    ImportView()
}
