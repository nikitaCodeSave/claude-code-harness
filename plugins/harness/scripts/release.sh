#!/usr/bin/env bash
# Release ritual for this standalone repo — versions BOTH plugins (harness + the devlog
# companion) in lockstep under one number, and stages both shippable trees.
# Usage: scripts/release.sh <version>        e.g. scripts/release.sh 1.14.1
#
# Mechanizes what two manual releases in a row got wrong (external audit 2026-07-15):
# desynced plugin.json vs marketplace.json, shipped-by stamps pointing at versions that
# exist in no commit, releases announced in devlog but never committed/pushed.
#
# What it does: (1) writes the version into BOTH plugins' plugin.json — each is the single
# source of truth and canonical update cache key for its plugin (code.claude.com/docs/en/
# plugins-reference: consumers never receive changes unless it bumps; version must NOT be
# duplicated in the marketplace entry, where plugin.json silently wins — nothing to sync).
# The two plugins are kept on one version by design (simple, unified releases);
# (2) verifies every project-docs file modified in this release carries the new
# shipped-by stamp (untouched files keep their old stamp — per-file provenance);
# (3) stages the shippable surface and prints the exact commit/tag/push commands.
# It deliberately does NOT auto-commit: the summary line is the maintainer's.
set -euo pipefail

V="${1:?usage: scripts/release.sh <version, e.g. 1.14.0>}"
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
# Multi-plugin marketplace: harness plugin lives under plugins/harness/, the devlog
# companion under plugins/devlog/; the marketplace manifest stays at the repo root.
# Both plugins are versioned in lockstep under one number (this script bumps both).
PLUGIN=plugins/harness/.claude-plugin/plugin.json
DEVLOG_PLUGIN=plugins/devlog/.claude-plugin/plugin.json
MARKET=.claude-plugin/marketplace.json

command -v jq >/dev/null || { echo "jq required"; exit 1; }

# 1. Write the version into plugin.json (sole source of truth) and guard against a stray
#    version field creeping back into the marketplace entry.
for pj in "$PLUGIN" "$DEVLOG_PLUGIN"; do
  jq --arg v "$V" '.version=$v' "$pj" > "$pj.tmp" && mv "$pj.tmp" "$pj"
done
if [ "$(jq -r '[.plugins[] | select(has("version"))] | length' "$MARKET")" != "0" ]; then
  echo "MARKETPLACE DRIFT: a plugin entry in $MARKET declares 'version' — remove it (plugin.json is authoritative)."
  exit 1
fi
echo "version: harness=$(jq -r .version "$PLUGIN")  devlog=$(jq -r .version "$DEVLOG_PLUGIN")  (lockstep; marketplace carries no version, by design)"

# 2. shipped-by stamp check: modified project-docs must be stamped with THIS version.
fail=0
for f in plugins/harness/references/project-docs/*.md; do
  if ! git diff --quiet HEAD -- "$f" 2>/dev/null || ! git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
    head -1 "$f" | grep -q "shipped-by: claude-code-harness v$V" || {
      echo "STAMP MISMATCH: $f is modified but its header is not 'shipped-by: claude-code-harness v$V'"
      fail=1
    }
  fi
done
[ "$fail" -eq 0 ] || { echo "Fix the stamps above, then re-run."; exit 1; }

# 3. Tag must not already exist.
git rev-parse -q --verify "refs/tags/v$V" >/dev/null && {
  echo "tag v$V already exists"; exit 1; }

# 4. Stage the release surface and hand off the conscious step.
git add "$PLUGIN" "$DEVLOG_PLUGIN" "$MARKET" \
  plugins/harness/SKILL.md plugins/harness/references/ plugins/harness/agents/ \
  plugins/harness/commands/ plugins/harness/scripts/ plugins/devlog/ \
  README.md CHANGELOG.md
echo
git status --short
cat <<EOF

Staged. A release exists only when committed, TAGGED and PUSHED (consumers install
from origin/main — an unpushed release ships nothing). Finish with:

  git commit -m "claude-code-harness v$V: <one-line summary>"
  git tag v$V
  git push origin main --tags
EOF
