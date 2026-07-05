# Usage Widget

Track AI coding assistant usage limits on Mac and iPhone.

## Native widgets (Claude Code & Codex)

SwiftUI + WidgetKit app with liquid glass UI. Shows 5-hour session and 7-day weekly limits with reset times.

```bash
cd native && brew install xcodegen && xcodegen generate && open UsageWidget.xcodeproj
```

1. Set your Development Team in Xcode.
2. Run **UsageWidget-macOS** or **UsageWidget-iOS**.
3. Add the **AI Usage** widget and pick a provider.

Requires Xcode 26. Sign in locally first: `claude /login` and/or `codex login`.

App Group (change in entitlements + `UsageSharedStore.swift`): `group.dev.awaishashar.usage-widget`

## Menu bar app (Cursor)

Electron tray app for Cursor subscription usage.

```bash
npm install && npm run dev
```

Requires macOS, Node 18+, and Cursor signed in.

## Layout

```text
native/   iPhone + Mac widgets
src/      Cursor menu bar app
```

MIT
