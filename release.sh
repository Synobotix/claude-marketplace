#!/usr/bin/env bash
# Cut a new release: bump version in marketplace.json, commit, tag, push.
#
# Usage:
#   bash release.sh patch   # 0.2.0 → 0.2.1
#   bash release.sh minor   # 0.2.0 → 0.3.0
#   bash release.sh major   # 0.2.0 → 1.0.0
#   bash release.sh 1.2.3   # explicit version
set -euo pipefail

MARKETPLACE=".claude-plugin/marketplace.json"

current=$(jq -r '.metadata.version' "$MARKETPLACE")
major=$(echo "$current" | cut -d. -f1)
minor=$(echo "$current" | cut -d. -f2)
patch=$(echo "$current" | cut -d. -f3)

case "${1:-patch}" in
  major) new="$((major + 1)).0.0" ;;
  minor) new="${major}.$((minor + 1)).0" ;;
  patch) new="${major}.${minor}.$((patch + 1))" ;;
  [0-9]*) new="$1" ;;
  *) echo "Usage: $0 [major|minor|patch|x.y.z]" >&2; exit 1 ;;
esac

echo "Releasing $current → $new"

tmp=$(mktemp)
jq --arg v "$new" '
  .metadata.version = $v |
  .plugins[].version = $v
' "$MARKETPLACE" > "$tmp" && mv "$tmp" "$MARKETPLACE"

git add "$MARKETPLACE"
git commit -m "chore: release v${new}"
git tag "v${new}"
git push origin main "v${new}"

echo "Released v${new} — run 'bash update-plugin.sh' on client machines."
