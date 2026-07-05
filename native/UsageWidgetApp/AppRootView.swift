import SwiftUI

struct AppRootView: View {
    @Bindable var viewModel: UsageDashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.sectionSpacing) {
                    providerPicker

                    LiquidGlassPanel(tint: providerTint) {
                        UsageWidgetContentView(snapshot: viewModel.snapshot, compact: false)
                    }

                    if viewModel.snapshot.source == .demo {
                        ContentUnavailableView {
                            Label("Demo Data", systemImage: "exclamationmark.triangle")
                        } description: {
                            Text(viewModel.snapshot.message ?? "Live usage is unavailable.")
                        }
                    }

                    metadataSection
                }
                .padding()
            }
            .navigationTitle("Usage Widget")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh", systemImage: "arrow.clockwise", action: refresh)
                        .disabled(viewModel.isRefreshing)
                }
            }
            .task {
                await viewModel.refreshAllProviders()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private var providerPicker: some View {
        Picker("Provider", selection: $viewModel.selectedProvider) {
            ForEach(UsageProviderKind.allCases) { provider in
                Text(provider.displayName).tag(provider)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Usage provider")
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Updated \(viewModel.snapshot.updatedAt.formatted(date: .omitted, time: .shortened))", systemImage: "clock")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Add the widget to your Home Screen or Notification Center to keep limits visible.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var providerTint: Color {
        switch viewModel.selectedProvider {
        case .claude: DesignTokens.claudeTint
        case .codex: DesignTokens.codexTint
        }
    }

    private func refresh() {
        Task {
            await viewModel.refresh()
        }
    }
}

#Preview {
    AppRootView(viewModel: UsageDashboardViewModel())
}
