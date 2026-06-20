#!/usr/bin/env bash
# Update orchestration-core plugin to latest GitHub version.
# Run this after pushing changes to the marketplace repo.
set -euo pipefail

PLUGIN="orchestration-core@synobotix"
CACHE="$HOME/.claude/plugins/cache/synobotix/orchestration-core"
INSTALLED="$HOME/.claude/plugins/installed_plugins.json"

echo "Clearing plugin cache..."
rm -rf "$CACHE"

echo "Removing installed_plugins.json entry..."
tmp=$(mktemp)
jq 'del(."orchestration-core@synobotix")' "$INSTALLED" > "$tmp" && mv "$tmp" "$INSTALLED"

echo "Done. In Claude Code, run:"
echo "  /plugin marketplace update synobotix"
echo "  /plugin install $PLUGIN"
echo "  /reload-plugins"
