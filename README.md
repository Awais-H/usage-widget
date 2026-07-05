# Usage Widget

See Claude Code and Codex limits on your iPhone — inspired by [shuangzi-xubei](https://github.com/wgjuan2314/shuangzi-xubei), rewritten in Swift.

Shows **5-hour** and **weekly** remaining quota with reset times. Tokens live on your phone; the widget fetches usage directly, even when your Mac is off.

## Setup

### 1. Export tokens on Mac

```bash
bash export-tokens.sh | pbcopy
```

This reads Claude and Codex tokens from your Mac, merges them into **one JSON object**, and copies it to your clipboard. You need Claude Code and/or Codex logged in on the Mac — if only one is logged in, that side is included and the other is skipped.

### 2. Import on iPhone

1. Open `UsageWidget.xcodeproj` in Xcode and run on your iPhone (or install a build).
2. Copy the JSON to your iPhone clipboard (Universal Clipboard, AirDrop, Notes, etc.).
3. Open the app → **Import from Clipboard**.

You only import once (or again when tokens expire and auto-refresh fails). The app stores Claude and Codex separately on your phone, but they arrive in a **single paste**.

### 3. Add widget

Long-press Home Screen → add **AI Usage** (medium size).

The widget refreshes about every 12 minutes.

## Token JSON

Same idea as [shuangzi-xubei](https://github.com/wgjuan2314/shuangzi-xubei): **one JSON file for both platforms**, with a `claude` object and a `codex` object. You paste it once; the app saves each side independently.

### Shape

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

| Field | Platform | Required | Notes |
| --- | --- | --- | --- |
| `accessToken` | both | yes | OAuth access token used to fetch usage |
| `refreshToken` | both | yes | Used to renew expired tokens on the phone |
| `expiresAt` | Claude only | yes | Milliseconds since epoch (from Claude Code credentials) |
| `accountId` | Codex only | optional | ChatGPT account id; included when exported from `~/.codex/auth.json` |

If a platform is missing or has an empty `accessToken`, import still works — only the platforms with valid tokens are saved. The widget then shows one or two columns accordingly.

### Where the values come from (Mac)

| Platform | Source on Mac |
| --- | --- |
| Claude | macOS Keychain entry `Claude Code-credentials` → `claudeAiOauth` |
| Codex | `~/.codex/auth.json` → `tokens` |

`export-tokens.sh` reads both and prints the combined JSON above. You do not need to hand-edit it unless you are on Windows/Linux.

### Manual export (Windows / Linux)

Build the same JSON structure yourself from your local Claude Code and Codex auth files, then copy it to your iPhone and tap **Import from Clipboard**. Field names must match exactly (`accessToken`, not `access_token`).

### Security

- Tokens stay on **your iPhone** (App Group storage shared with the widget).
- The JSON is only for one-time import — treat it like a password while copying it.
- Usage APIs are unofficial; they only return percentages and reset times for your own account.

## Reading the widget

Each column is one tool. Each column has **two bars**.

### Columns

| Label | What it is |
| --- | --- |
| **Claude** | Claude Code subscription usage |
| **Codex** | OpenAI Codex subscription usage |

If you only imported one token, you will only see that column.

### Bars (per column)

| Bar | Meaning |
| --- | --- |
| **5h** | Rolling **5-hour session limit** — how much of your current window is left. Resets on a rolling timer (not at midnight). |
| **Week** | **Weekly limit** — how much of your 7-day quota is left. This is separate from the 5-hour window. |

### How to read a bar

- **Percentage** = **remaining** quota (not used). For example, `62%` means about 62% left and ~38% used.
- **Bar fill** = the same thing visually.
- **Color**
  - Green: more than 50% left
  - Orange: 20–50% left
  - Red: less than 20% left
- **Reset line** under each bar = when that window refills
  - **5h**: a time like `14:30 reset`
  - **Week**: a date like `7/12 reset`

### Example

**Claude → 5h → 62%** with **`14:30 reset`** means you still have about 62% of your current 5-hour Claude window left, and that window refills around 2:30 PM. The **Week** bar below it is your separate weekly cap.

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
