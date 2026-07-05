# Usage Widget

See Claude Code and Codex limits on your iPhone — inspired by [shuangzi-xubei](https://github.com/wgjuan2314/shuangzi-xubei), rewritten in Swift.

Shows **5-hour** and **weekly** remaining quota with reset times. Tokens live on your phone; the widget fetches usage directly, even when your Mac is off.

## Setup

### 1. Export tokens on Mac

```bash
bash export-tokens.sh | pbcopy
```

Requires Claude Code and/or Codex logged in on the Mac.

### 2. Import on iPhone

1. Open `UsageWidget.xcodeproj` in Xcode and run on your iPhone (or install a build).
2. Copy the JSON to your iPhone clipboard (Universal Clipboard, AirDrop, etc.).
3. Open the app → **Import from Clipboard**.

### 3. Add widget

Long-press Home Screen → add **AI Usage** (medium size).

The widget refreshes about every 12 minutes.

## Build

```bash
open UsageWidget.xcodeproj
```

Select **UsageWidget-iOS**, set your Development Team, run on device.

App Group: `group.dev.awaishashar.usage-widget`

## How it works

- Tokens stored in the shared App Group (same idea as Keychain in the Scriptable version)
- Claude: `GET https://api.anthropic.com/api/oauth/usage`
- Codex: `GET https://chatgpt.com/backend-api/wham/usage`
- Failed fetches fall back to cached data and show a ⚠ marker

MIT
