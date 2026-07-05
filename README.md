# Usage Widget

<img width="350" alt="Agent Usage widget showing Claude and Codex limits on an iPhone Home Screen" src="https://github.com/user-attachments/assets/6b51bf19-5f6e-4cae-a2ec-de2847d92ef8" />

Claude Code and Codex usage on your iPhone Home Screen. Medium widget — **5h** and **Week** bars show **% used** with reset times.

## Setup

1. **Build on iPhone** — Open `UsageWidget.xcodeproj` in Xcode (free). Scheme **UsageWidget-iOS**, select your iPhone, set **Team** under Signing, Run (⌘R).
2. **Export tokens (Mac)** — `bash export-tokens.sh | pbcopy` (needs Claude Code and/or Codex logged in).
3. **Import (iPhone)** — Copy JSON to phone → open **Usage Widget** → **Import from Clipboard**.
4. **Add widget** — Home Screen → **Add Widget** → **Agent Usage** (medium).

Re-run from Xcode about once a week if using a free Apple ID (install expires ~7 days).

## Widget

| | |
|---|---|
| **% / bar** | Used (90% = 90% of limit consumed) |
| **Color** | Green <50% · Orange 50–80% · Red >80% |
| **Reset line** | `14:30 reset` (5h) or `Jan 19 reset` (week) |
| **No token** | 0%, no reset line |

MIT
