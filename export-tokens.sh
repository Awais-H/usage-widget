#!/bin/bash
# Export Claude Code and Codex OAuth tokens from your Mac.
# Copy the JSON to your iPhone and tap Import in the Usage Widget app.
#
# Usage: bash export-tokens.sh | pbcopy

set -euo pipefail

CLAUDE_JSON=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || echo "{}")
CODEX_JSON=$(cat "$HOME/.codex/auth.json" 2>/dev/null || echo "{}")

CLAUDE_JSON="$CLAUDE_JSON" CODEX_JSON="$CODEX_JSON" python3 <<'PY'
import json, os, sys

claude_src = json.loads(os.environ["CLAUDE_JSON"] or "{}").get("claudeAiOauth", {})
codex_src = json.loads(os.environ["CODEX_JSON"] or "{}").get("tokens", {})

out = {
    "claude": {
        "accessToken": claude_src.get("accessToken", ""),
        "refreshToken": claude_src.get("refreshToken", ""),
        "expiresAt": claude_src.get("expiresAt", 0),
    },
    "codex": {
        "accessToken": codex_src.get("access_token", ""),
        "refreshToken": codex_src.get("refresh_token", ""),
        "accountId": codex_src.get("account_id", ""),
    },
}

missing = [name for name, payload in out.items() if not payload["accessToken"]]
if missing:
    print(f"# warning: missing accessToken for {missing}", file=sys.stderr)

print(json.dumps(out, ensure_ascii=False))
PY
