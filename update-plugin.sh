#!/usr/bin/env bash
# Clear all plugin caches and reinstall from GitHub.
# Run this after a new release (bash release.sh) has been pushed.
set -euo pipefail

PLUGIN="orchestration-core@synobotix"
CACHE="$HOME/.claude/plugins/cache/synobotix/orchestration-core"
MARKETPLACE="$HOME/.claude/plugins/marketplaces/synobotix"
INSTALLED="$HOME/.claude/plugins/installed_plugins.json"

echo "Clearing caches..."
rm -rf "$CACHE" "$MARKETPLACE"

echo "Removing installed_plugins.json entry..."
tmp=$(mktemp)
jq 'del(.plugins["orchestration-core@synobotix"])' "$INSTALLED" > "$tmp" && mv "$tmp" "$INSTALLED"

echo "Done. In Claude Code, run:"
echo "  /plugin marketplace update synobotix"
echo "  /plugin install $PLUGIN"
echo "  /reload-plugins"
