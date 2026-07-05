# Usage Widget

<img width="350" alt="Agent Usage widget showing Claude and Codex limits on an iPhone Home Screen" src="https://github.com/user-attachments/assets/6b51bf19-5f6e-4cae-a2ec-de2847d92ef8" />

Claude Code and Codex usage on your iPhone Home Screen.

Medium widget, two columns, **5h** + **Week** bars. Each bar shows **how much you’ve used**

## Requirements

| | |
|---|---|
| **Mac** | Claude Code and/or Codex logged in (for one-time token export) |
| **iPhone** | iOS 26+ |
| **Xcode** | 26+ — **free** from the Mac App Store |

## Run

### Simulator (quick test)

1. Open the project:
   ```bash
   open UsageWidget.xcodeproj
   ```
2. Select scheme **UsageWidget-iOS** and a simulator (e.g. iPhone 17 Pro).
3. **UsageWidgetApp-iOS** target → **Signing & Capabilities** → set your **Team** (free Apple ID works).
4. **Product → Clean Build Folder** (⇧⌘K), then **Run** (⌘R).

> **Simulator won’t launch?** The scheme runs without the debugger (Xcode 26 workaround). If you still see *preflight checks* errors: erase the simulator (**Device → Erase All Content and Settings**), clean build, run again. Or use **Product → Run Without Debugging**.

### Physical iPhone

1. Same as above, but pick your **iPhone** as the run destination.
2. Enable **Developer Mode** on the phone if prompted (Settings → Privacy & Security).
3. Trust the Mac when the phone asks.
4. Run (⌘R). The **Usage Widget** app installs on your phone.

### Keeping it on your iPhone

**Yes — but only by building and signing it yourself.** There is no App Store install for this repo. **Xcode is free**; the optional **Apple Developer Program** ($99/year) only affects how long the install lasts.

| Method | Cost | How long it lasts | What you do when it expires |
|---|---|---|---|
| **Free Apple ID** (Personal Team in Xcode) | Free | ~**7 days** | Plug iPhone into Mac → open project → **Run** (⌘R) again |
| **Apple Developer Program** | $99/year | Up to **1 year** per install | Re-run from Xcode, or **Product → Archive** → install to device |
| **TestFlight** | Dev account required | **90 days** per uploaded build | Maintainer uploads a new build; you update in TestFlight |

**What “expires” means:** iOS stops opening the app (and the widget stops updating) when the development signature runs out. Your imported tokens are still on the phone, but you may need to **re-import** if iOS clears app data on reinstall.

**What does *not* expire:** Once installed and signed, the widget keeps refreshing on its own (~every 12 min). You do **not** need your Mac connected for daily use — only for the initial build and occasional re-sign.

**Not supported out of the box:** Permanent install with zero maintenance on a free account, or install without a Mac at all. Tools like AltStore still hit the same 7-day / 1-year signing limits.

**Practical recommendation:** Use your **free Apple ID** to try it (re-sign weekly from Xcode), or pay for a **Developer account** if you want to set-and-forget for a year.

### Add the widget

1. Long-press Home Screen → **Edit** → **Add Widget**.
2. Search **Usage Widget** → choose **Agent Usage** (medium).
3. Place it and tap **Done**.

The widget refreshes about every **12 minutes**. Open the app and tap **Refresh Widget Now** to force an update.

---

## First-time setup (tokens)

You only do this once (again if refresh fails after tokens expire).

### 1. Export on Mac

```bash
bash export-tokens.sh | pbcopy
```

Reads Claude from Keychain (`Claude Code-credentials`) and Codex from `~/.codex/auth.json`, merges into one JSON, copies to clipboard. If only one tool is logged in, that side is included.

### 2. Import on iPhone

1. Get the JSON onto your phone (Universal Clipboard, AirDrop, Notes, etc.).
2. Open **Usage Widget** → **Import from Clipboard**.

### Token JSON shape

```json
{
  "claude": {
    "accessToken": "…",
    "refreshToken": "…",
    "expiresAt": 1234567890123
  },
  "codex": {
    "accessToken": "…",
    "refreshToken": "…",
    "accountId": "…"
  }
}
```

| Field | Platform | Notes |
|---|---|---|
| `accessToken` | both | required |
| `refreshToken` | both | required |
| `expiresAt` | Claude | ms since epoch |
| `accountId` | Codex | optional |

On Windows/Linux, build this JSON manually from your auth files. Field names must be camelCase (`accessToken`, not `access_token`).

---

## Reading the widget

| | |
|---|---|
| **Claude / Codex** | One column per imported token |
| **5h** | Rolling 5-hour session limit |
| **Week** | 7-day quota |
| **%** | **Used** — share of the limit you’ve consumed |
| **Bar** | Fills to the same used % (full bar ≈ limit reached) |
| **Bar color** | Green <50% used · Orange 50–80% · Red >80% |
| **Reset line** | When that window refills — `14:30 reset` (5h) or `Jan 19 reset` (week) |
| **No token** | Bar stays at **0%**, no reset line |

**Example:** `5h` at **38%** with a green bar means you’ve used about 38% of your current 5-hour window. The **Week** row below is the separate weekly cap.

---

## Project layout

```
UsageWidgetApp/          Import app
UsageWidgetExtension/    WidgetKit extension
UsageShared/               Models, fetcher, UI
export-tokens.sh         Mac token export
project.yml              XcodeGen spec (optional)
```

### Regenerate Xcode project

Only needed after editing `project.yml`:

```bash
brew install xcodegen   # once
xcodegen generate
```

### Signing notes

- App Group: `group.dev.awaishashar.usage-widget` (app + extension targets).
- Extension bundle ID must be a child of the app: `dev.awaishashar.UsageWidget.widget`.
- Enable **App Groups** capability for your Team in the Apple Developer portal if signing fails.

MIT
