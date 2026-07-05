# Usage Widget

Track AI coding assistant usage limits on Mac and iPhone.

## Native widgets (Claude Code & Codex)

SwiftUI + WidgetKit app with liquid glass UI. Shows 5-hour session and 7-day weekly limits with reset times.

```bash
cd native && brew install xcodegen && xcodegen generate && open UsageWidget.xcodeproj
```

Run the app once, then add the **AI Usage** widget. Details: [`native/README.md`](native/README.md).

Requires Xcode 26, and local sign-in via `claude /login` and/or `codex login`.

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
