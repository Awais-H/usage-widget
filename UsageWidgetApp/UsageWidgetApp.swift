import SwiftUI

@main
struct UsageWidgetApp: App {
    @State private var viewModel = UsageDashboardViewModel()

    var body: some Scene {
        WindowGroup {
            AppRootView(viewModel: viewModel)
        }
        #if os(macOS)
        .defaultSize(width: 420, height: 560)
        #endif
    }
}
