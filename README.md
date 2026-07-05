# Usage Widget

SwiftUI + WidgetKit for iPhone and Mac. Shows **Claude Code** or **Codex** session and weekly limits with reset times in a liquid glass layout.

## Setup

```bash
brew install xcodegen
xcodegen generate
open UsageWidget.xcodeproj
```

1. Set your Development Team in Xcode.
2. Run **UsageWidget-macOS** or **UsageWidget-iOS**.
3. Add the **AI Usage** widget and pick a provider.

Requires Xcode 26. Sign in locally first: `claude /login` and/or `codex login`.

App Group (change in entitlements + `UsageShared/Store/UsageSharedStore.swift`): `group.dev.awaishashar.usage-widget`

MIT
