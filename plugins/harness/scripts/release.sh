#!/usr/bin/env bash
# Release ritual for this standalone repo — versions the harness plugin and stages the
# shippable tree.
# Usage: scripts/release.sh <version>        e.g. scripts/release.sh 1.14.1
#
# Mechanizes what two manual releases in a row got wrong (external audit 2026-07-15):
# desynced plugin.json vs marketplace.json and releases announced but never committed/pushed.
#
# What it does: (1) writes the version into plugin.json — the single source of truth and
# canonical update cache key (code.claude.com/docs/en/plugins-reference: consumers never
# receive changes unless it bumps; version must NOT be duplicated in the marketplace entry,
# where plugin.json silently wins — nothing to sync); (2) stages the shippable surface and prints the exact commit/tag/push commands.
# It deliberately does NOT auto-commit: the summary line is the maintainer's.
set -euo pipefail

V="${1:?usage: scripts/release.sh <version, e.g. 1.14.0>}"
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
# The plugin lives under plugins/harness/; the marketplace manifest stays at the repo root.
PLUGIN=plugins/harness/.claude-plugin/plugin.json
MARKET=.claude-plugin/marketplace.json

command -v jq >/dev/null || { echo "jq required"; exit 1; }

# 1. Write the version into plugin.json (sole source of truth) and guard against a stray
#    version field creeping back into the marketplace entry.
jq --arg v "$V" '.version=$v' "$PLUGIN" > "$PLUGIN.tmp" && mv "$PLUGIN.tmp" "$PLUGIN"
if [ "$(jq -r '[.plugins[] | select(has("version"))] | length' "$MARKET")" != "0" ]; then
  echo "MARKETPLACE DRIFT: a plugin entry in $MARKET declares 'version' — remove it (plugin.json is authoritative)."
  exit 1
fi
echo "version: harness=$(jq -r .version "$PLUGIN")  (marketplace carries no version, by design)"

# 2. Tag must not already exist.
git rev-parse -q --verify "refs/tags/v$V" >/dev/null && {
  echo "tag v$V already exists"; exit 1; }

# 3. Stage the release surface and hand off the conscious step.
git add -A "$PLUGIN" "$MARKET" \
  plugins/ docs/ \
  README.md CHANGELOG.md AGENTS.md
echo
git status --short
cat <<EOF

Staged. A release exists only when committed, TAGGED and PUSHED (consumers install
from origin/main — an unpushed release ships nothing). Finish with:

  git commit -m "harness v$V: <one-line summary>"
  git tag v$V
  git push origin main --tags
EOF
