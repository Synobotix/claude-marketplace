#!/usr/bin/env bash
# Check for orchestration-core updates at most once per day.
# Runs via UserPromptSubmit hook — exits 0 always (never blocks).
set -euo pipefail

STAMP="$HOME/.claude/plugins/.synobotix_update_check"
NOW=$(date +%s)

# Rate-limit to once per 24h
if [ -f "$STAMP" ]; then
  last=$(cat "$STAMP")
  if [ $((NOW - last)) -lt 86400 ]; then
    exit 0
  fi
fi

echo "$NOW" > "$STAMP"

INSTALLED=$(jq -r '
  .plugins["orchestration-core@synobotix"][]
  | select(.scope=="user")
  | .version
' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null | tail -1)

[ -z "$INSTALLED" ] && exit 0

LATEST=$(curl -sf --max-time 5 \
  "https://raw.githubusercontent.com/Synobotix/claude-marketplace/main/.claude-plugin/marketplace.json" \
  | jq -r '.plugins[] | select(.name=="orchestration-core") | .version' 2>/dev/null || true)

[ -z "$LATEST" ] && exit 0
[ "$LATEST" = "$INSTALLED" ] && exit 0

echo "orchestration-core update available: v${INSTALLED} → v${LATEST}"
echo "To update: bash update-plugin.sh && /plugin marketplace update synobotix && /plugin install orchestration-core@synobotix && /reload-plugins"
