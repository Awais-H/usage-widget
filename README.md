# Usage Widget

Track AI coding assistant usage limits from your Mac or iPhone.

This repo contains two clients:

1. **Native widgets (recommended)** — SwiftUI + WidgetKit for iPhone and Mac with liquid glass UI, Claude Code and Codex limits, and reset times.
2. **Electron menu bar app** — Cursor subscription usage in the menu bar.

## Native widgets (iPhone + Mac)

Shows rolling **5-hour session** and **7-day weekly** usage for:

- **Claude Code** — reads local OAuth credentials and calls Anthropic's usage endpoint
- **Codex** — reads `~/.codex/auth.json` and calls OpenAI's Codex usage endpoint

See [`native/README.md`](native/README.md) for Xcode setup.

```bash
cd native
brew install xcodegen
xcodegen generate
open UsageWidget.xcodeproj
```

Run the app once, then add the **AI Usage** widget to your Home Screen or Notification Center.

## Electron menu bar app (Cursor)

A lightweight macOS menu bar app that shows Cursor subscription usage at a glance.

### Requirements

- macOS
- Node.js 18+
- Cursor installed and signed in

### Getting started

```bash
npm install
npm run dev
```

### Scripts

| Command | Description |
| --- | --- |
| `npm run dev` | Start the app in development mode |
| `npm run build` | Build main, preload, and renderer bundles |
| `npm run preview` | Preview the production build |
| `npm run typecheck` | Run TypeScript checks |

## Project structure

```text
native/          SwiftUI app + WidgetKit extension (iPhone + Mac)
src/             Electron menu bar app for Cursor usage
```

## License

MIT
