# Changelog

All notable changes to the **claude-code-harness** plugin are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versions up to and including 1.12.2 were released from the maintainer's `dot-claude`
practice layer, before the kit was extracted into this standalone repository.

## [1.13.0] — 2026-07-15

First release from the standalone repository.

### Changed
- Re-centered all internal narrative on the new source of truth — this public repo,
  installed via `/plugin marketplace add nikitaCodeSave/claude-code-harness` — instead of
  the previous `dot-claude`-embedded delivery (`operator-playbook`, `harness-evolution`,
  `external-audit`).
- `version` is now the single source of truth in `plugin.json`; removed from the marketplace
  entry (per Anthropic guidance — `plugin.json` silently wins, so duplication only risks the
  desync a prior external audit caught).
- Release ritual moved into the repo as `scripts/release.sh` (was `~/.claude/scripts/`,
  bound to `dot-claude`); it now guards against version drift instead of syncing two manifests.

### Added
- `plugin.json`: correct `$schema` (json.schemastore.org), `keywords`, `homepage`.
- `README.md`, `LICENSE` (MIT), and this `CHANGELOG.md`.

### Fixed
- Dropped the redundant `skills: ["./"]` manifest field that contradicted single-skill-plugin
  auto-loading (Claude Code v2.1.142+).

## [1.12.2] — binary-verifier enrichments (Claude Code 2.1.199–2.1.210 deltas)
## [1.12.1] — retire the last stale `/agents`-wizard instruction in Bootstrap Phase 0
## [1.12.0] — external-audit fold: currency to 2.1.210, scripted release mechanics
## [1.10.1] — docs-discipline rule 7 (current-state, not changelog) + version sync
## [1.10.0] — campaign scoped-delivery + `paths:` reliability
## [1.9.2] — staleness-guard (content-gate + orphan-sweep)
## [1.9.1] — retire the stale Plan-Mode → Auto-Mode caveat
## [1.9.0] — D-cycle fold of dialog-analyzer practices into the shipped workflow
## [1.8.0] — production-grade default + shipped workflow distillation in `.claude/docs/`
## [1.7.0] — write-through of practices (practice baseline / workflow ladder / docs bootstrap)
## [1.6.1] — external-audit debt fold (review availability, index-regen dependency)
## [1.6.0] — operator handoff footer
## [1.5.1] — clean fair-copy edition
## [1.5.0] — full first-party re-ground (Fable 5, nested subagents, ultrareview)
## [1.4.1] — Monitor/Cron documented as first-party; fix profile-blind claims
## [1.4.0] — review ladder, execution spine, maintainer/consumer split
