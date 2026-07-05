# Native Usage Widget

SwiftUI + WidgetKit app for iPhone and Mac that shows **Claude Code** or **Codex** usage limits in a liquid glass layout, including when each window resets.

## Requirements

- Xcode 26 or later
- iOS 26 / macOS 26 SDK
- Signed in locally to Claude Code (`claude /login`) and/or Codex (`codex login`)

## Generate the Xcode project

```bash
cd native
brew install xcodegen   # once
xcodegen generate
open UsageWidget.xcodeproj
```

Select the **UsageWidgetApp** scheme, choose an iPhone or My Mac destination, then run.

## Widget setup

1. Run the app once so it can fetch usage and write snapshots to the shared App Group.
2. Add the **AI Usage** widget to your Home Screen (iPhone) or Notification Center (Mac).
3. Edit the widget and pick **Claude Code** or **Codex**.

The same widget extension works on both platforms. The companion app refreshes usage and reloads widget timelines.

## Data sources

| Provider | Credentials | API |
| --- | --- | --- |
| Claude Code | `~/.claude/.credentials.json` or Keychain `Claude Code-credentials` | `GET https://api.anthropic.com/api/oauth/usage` |
| Codex | `~/.codex/auth.json` | `GET https://chatgpt.com/backend-api/codex/usage` |

Both providers expose rolling **5-hour session** and **7-day weekly** windows with `resets_at` timestamps.

## App Group

Update the App Group identifier in:

- `UsageShared/Store/UsageSharedStore.swift`
- `UsageWidgetApp/UsageWidget.entitlements`
- `UsageWidgetExtension/UsageWidgetExtension.entitlements`

Default: `group.dev.awaishashar.usage-widget`

## Notes

- Undocumented provider APIs may change; the app falls back to demo data when live usage cannot be loaded.
- The macOS app reads local CLI credentials from your user home directory.
- Set your Apple Development Team in Xcode before running on device.
