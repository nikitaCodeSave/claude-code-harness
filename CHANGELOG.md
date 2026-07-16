# Changelog

All notable changes to the **claude-code-harness** plugin are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versions up to and including 1.12.2 were released from the maintainer's `dot-claude`
practice layer, before the kit was extracted into this standalone repository.

## [1.14.3] — 2026-07-16

Micro external-intake pass — the refresh ledger drifted one CC patch behind live
(`claude --version` = 2.1.211 vs the ledger's 2.1.210), which is a standalone strip-revision
trigger. Swept the changelog delta 2.1.210→2.1.211, folded the one canon-relevant finding, and
re-stamped the ledger. Not a full strip revision: only the changelog was re-checked; the
docs/blog/binary sweep stays grounded at 2.1.210 until the next calendar revision.

### Changed
- **`native-capabilities.md` current to CC v2.1.211** — the inventory version line advanced from
  2.1.210, and the auto-mode-classifier note now records that a **PreToolUse hook `ask` floors the
  auto-mode decision at a prompt** for unsandboxed Bash (v2.1.211): the classifier can no longer
  silently downgrade a hook `ask`, so a guard hook stays authoritative over auto mode. This is the
  only 2.1.211 delta that touches harness design — the rest of the release is bug/UX fixes and
  niche SDK flags (`--forward-subagent-text`), which the D-cycle gate correctly rejects as
  non-canon.
- **Refresh ledger re-stamped** (`harness-evolution.md`) to CC v2.1.211 / 2026-07-16, honestly
  scoped to "changelog delta only" so the next strip revision still knows the full multi-source
  sweep is grounded at 2.1.210.

## [1.14.2] — 2026-07-16

Canon evolution — two D-cycle folds distilled from a real consumer project's usage, each verified
against that project's on-disk evidence before folding. Prose only; no code changes. Project name
kept out of the shipped surface (anonymized as in `evidence-base` / `practice-baseline`).

### Changed
- **Independent verification repositioned into two tiers** — the operator surfaces
  (`operator-playbook §5` + Layer map, the `SKILL.md` handoff footer) and the discipline ladder
  (`harness-discipline.md`) now lead with the lightweight per-change fresh-context refute (the
  `code-refuter` role solo) as the workhorse, and frame the full 3-role `/external-audit` as the
  rare milestone/irreversible escalation. This matches observed usage: the heavy audit ran once at
  a milestone while the refuter role alone carried per-change verification. No new command or
  agent — the workhorse reuses the already-shipped `code-refuter` role.

### Added
- **"The spec's own premise is a claim, not a fact"** — a new rule in `operator-playbook §3`
  (the "claim, not fact" cluster): measure whether a requirement's assumption holds before building
  to it; an oracle sweep can refute the requirement itself, and when it does, trust the measurement
  over the spec.

## [1.14.1] — 2026-07-15

Locale standardization and unified versioning. The kit's shipped **prompts** are now
uniformly English (matching the agents, README, and project-docs); the **devlog** companion
stays in the operator's language because its artifacts — devlog entries — are written in the
user's language, and its machinery is now language-agnostic rather than Russian-only.

### Changed
- **Harness-plugin prompt surfaces translated to English** — the `/external-audit` command,
  `operator-playbook`, `harness-evolution`, and the operator-handoff footer in `SKILL.md` were
  the last Russian-language files on the shipped harness surface; they now match the rest of
  the plugin. No behavioral change — prose only.
- **`devlog` preview extraction is now language-agnostic** — `rebuild-index.py` anchors on the
  first `## ` section instead of a hardcoded `## Контекст`, so `## Context`, `## Контекст`, and
  any-language headings all resolve. Devlog entries can now be written in the user's language
  (RU/EN and beyond) from one machinery; slugs were already bilingual via transliteration.
- **Both plugins share one version, bumped in lockstep** — `harness` and `devlog` are now both
  `1.14.1`; `scripts/release.sh` versions and stages both plugin trees under one number
  (previously it touched only the harness plugin, leaving devlog to a manual bump).

### Fixed
- `operator-playbook` referenced `.claude/audit/<slug>/` (singular) while `/external-audit`
  writes `.claude/audits/<slug>/` (plural). Aligned the doc to the command, which is the
  source of truth.

### Added
- Two regression tests for language-agnostic preview extraction (RU/EN/DE headings + first-
  section anchoring that fails under the old hardcoded heading).

## [1.14.0] — 2026-07-15

Multi-plugin marketplace: the harness kit gains a `devlog` companion so the continuity
guidance it already ships becomes runnable for the public, without a second copy of the
maintainer's global skill.

### Added
- **`devlog` companion plugin** (`plugins/devlog/`) — a `/devlog:devlog` skill plus a
  `devlog-reindex` command (shipped in `bin/`, on the Bash tool's `PATH` when enabled) that
  regenerates `.claude/devlog/{index.json,tldr.md}` from markdown entries. Install with
  `/plugin install devlog@claude-code-harness`. Verified against Claude Code 2.1.210
  (`claude plugin validate` + `--plugin-dir` load + the script's own pytest suite).

### Changed
- **Repository restructured into the idiomatic multi-plugin layout** — the harness plugin
  moved from the repo root to `plugins/harness/`; the marketplace manifest stays at the root
  and now lists both plugins with explicit `./plugins/<name>` sources (the `metadata.pluginRoot`
  shorthand is rejected by `claude plugin validate`, so paths are spelled out). The install
  command is unchanged — `claude-code-harness@claude-code-harness` resolves by name, not path.
- `scripts/release.sh` and the dogfood symlink re-pointed to the new `plugins/harness/` paths;
  `.gitignore` whitelist updated for the `plugins/` tree.

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
