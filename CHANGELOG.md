# Changelog

All notable changes to the **claude-code-harness** plugin are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versions up to and including 1.12.2 were released from the maintainer's `dot-claude`
practice layer, before the kit was extracted into this standalone repository.

## [1.16.0] — 2026-07-16

Consumer-journey fold. A fresh-context external audit of how the kit lands on a machine that
is *not* the maintainer's (no personal hooks, no lab rules) found the delivery layer
inconsistent enough that adoption could read net-negative next to bare Claude Code: the
practice baseline claimed a discipline whose machinery didn't ship, the global-merge
procedure carried weaker guards than the kit demands for in-repo operations, and README gave
a fresh installer no entry phrase. This release makes the two consumer flows — first contact
and staying current — coherent end-to-end. Docs + one plugin hook; the kit's component set
(skills/agents/commands) is unchanged — existing texts, including `SKILL.md`'s description
and Mode 1, are edited in place.

### Added
- **`devlog` companion now ships a SessionStart continuity digest** (`hooks/hooks.json` +
  `hooks/session-start-digest.sh`): surfaces the last 3 devlog entries + up to 3 active
  (non-CLOSED) progress journals at session start; silent (exit 0, no output) in projects
  that keep neither; read-only, POSIX + bash-3.2 portable, no dependencies. This closes the
  dogfooding asymmetry the audit led with: the zero-prompting continuity empirics in
  `practice-baseline.md` Provenance were observed under the lab's personal session-start
  hook, which consumers never got — the equivalent machinery is now installable
  (`/plugin install devlog@claude-code-harness`), and Provenance + delivery step 4 say so
  directly instead of burying the confound in a subordinate clause.
- **Practice-baseline content-version stamp** — the canonical block now opens with an HTML
  comment stamp (stripped before context injection — zero runtime cost) with the same
  semantics as the project-docs `shipped-by` headers: it advances only when the block's
  text changes. `audit-checklist.md` §4 gains the matching re-sync check (embed vs canon,
  diff-first, unstamped copy = hand-edit, a global copy is never auto-edited);
  `practice-baseline.md` gains "Keeping installed copies current"; `operator-playbook.md`
  gains §5 "Keeping the kit and the baseline current" (the `/plugin update` → audit →
  offered-re-syncs ritual; former §§5–7 renumbered to 6–8).
- **README "First session (start here)"** — the trigger-phrase table (bootstrap / minimal /
  audit / Phase 5 / external-audit), an explicit what-bootstrap-touches contract (inside
  repo / outside repo / profile), and a direct link to `operator-playbook.md` — previously
  the only human-facing map was a table-cell mention with no path.

### Changed
- **Baseline delivery inverted: project embed is the default, global merge is a guarded
  opt-in** (`practice-baseline.md` delivery procedure; synced in `bootstrap-checklist.md`
  Phase 1/2b/4, `SKILL.md` Mode 1 + plan template, `operator-playbook.md` layer map + §1).
  First contact lands the baseline in-repo (git-tracked, reviewable, removable); the global
  merge is offered with its radius stated in the offer ("every project on this machine,
  ~80 lines per session") and executes only after a shown diff, a timestamped backup
  (`~/.claude/CLAUDE.md.bak-<date>` — the file is usually not under git, so the backup IS
  the rollback), and a budget check against the same ≤200-line discipline as project
  CLAUDE.md. Detection now spans **all** memory layers (managed policy → user → project →
  auto-memory), and a fourth outcome is specified: a rule the baseline contradicts is named
  to the operator and never silently merged — co-loaded contradictions tell the model X and
  not-X every turn.
- **Baseline §7 names the native floor** — destructive-command block + the permission flow
  are the platform's out-of-the-box floor; the baseline's reactive `permissions.deny` layer
  builds above it. Previously §7 implicitly assumed a machine-level guard hook that only
  the maintainer's machine had.
- Continuity texts (`bootstrap-checklist.md` Phase 5 items 3–4) no longer describe
  state-surfacing automation as "which this kit does not ship" — the companion ships it;
  the CLAUDE.md session-start ritual remains the carrier without it. The block's line-count
  quotes corrected to the measured ~80 (were "~60").
- **Audit checklist gained two hook items** the shipped digest's own defects earned:
  context-injecting hooks (`SessionStart` / `UserPromptSubmit` / `Stop`) with unbounded
  stdout (§6), and a derived file (`index.json` / `tldr.md`) read as a fast path — stale
  and unvalidated for a few saved milliseconds (§6). §2 gained the hook-merge case below.
- **Detect before installing the companion** (`bootstrap-checklist.md` Phase 5 item 3):
  hooks and skills from every layer *merge, never override* (verified against the 2.1.211
  bundle: hook sources are concatenated, not replaced — modulo `allowManagedHooksOnly` /
  `disableAllHooks`), so an operator who already runs a personal SessionStart digest gets
  the same state twice, in two formats, before turn one. The kit gated ~80 lines of prose
  behind a four-outcome detect while waving through a hook that fires every session.

- **The digest line now carries the entry's date** (`#id · date · title`): the id alone
  doesn't answer "was this yesterday or in March?", and the date costs ~12 bytes per line.
  Optional — an entry without one still surfaces. Order stays `latest last` (recency).
- **Two duplication items the maintainer's own machine earned.** `audit-checklist.md` §2:
  a hand-kept copy of something a plugin already ships. Plugin skills are namespaced
  (`plugin:skill`), so a personal copy never *collides* — no error, no shadow warning, just
  two skills with one description and a model picking either; the tell is a fix you must
  apply twice. `operator-playbook.md`: symlinking the checkout is the **only** dogfooding
  path that stays live (a marketplace install *copies* into `~/.claude/plugins/cache/`;
  `--plugin-dir` is per-invocation) — and it must point at the **plugin directory**, not its
  `skills/` subfolder, or you get the skill without the plugin's `hooks/` and `bin/`.

### Fixed
- **The SessionStart digest could flood the context window** (`session-start-digest.sh`).
  Its stdout is injected verbatim ahead of the operator's first turn, in every project
  including a freshly cloned untrusted one, with no downstream trim — so boundedness is the
  component's core invariant. Two fresh-context refuter rounds found it broken in four ways,
  all now closed and covered by a 36-case suite (`test-session-start-digest.sh`, new — the
  hook shipped with none) green under bash, dash, `bash --posix` and busybox sh:
  - **Frontmatter is now cut by its fence pair, not by a sed range.** A `/^---/,/^---/`
    range re-opens on the next `---`, so a horizontal rule or setext underline in an entry
    body — both idiomatic markdown — started a second "frontmatter" whose lines forged
    `id`/`title`. An explicit `41q` also makes the read genuinely bounded: a whole-file scan
    on an absent field previously read 402 MB (straced); a 382 MB entry now reads 65 KB.
  - **`CLOSED` is matched as a status marker, not a substring.** `*CLOSED*` hid
    `# Migrate CLOSED-account archive to S3` — an *active* journal — which is the exact
    continuity loss the digest exists to prevent. Word boundaries alone then leaked
    `CLOSED-2026-07-16` back in as active, so the tail rule distinguishes a status suffix
    from an identifier; the residual (`CLOSED-shipped` reads as active) is signed in-file
    as the cheap direction — noise beats a hidden active task.
  - **CRLF entries** no longer emit a stray quote and CR into the context.
  - **A whole-digest `MAX_BYTES` backstop** (4096, overridable via `DEVLOG_DIGEST_MAX_BYTES`)
    now sits under the per-field caps, announcing truncation rather than silently dropping a
    tail. It is deliberately unreachable in normal operation — and, being overridable, is
    actually exercised by the suite: a guard no test fires is a guard nobody should trust.

## [1.15.0] — 2026-07-16

Drift-remediation fold. A cross-project fresh-context audit of consumer projects (4 adversarial
harvest agents over 37 `.claude/` projects; provenance in the maintainer's lab) showed the canon's
prescriptive FORMAT diverging from what operators actually needed in two layers — continuity and
verification — with almost every operator deviation better than the canon. Every fold below is
multi-source-evidenced, passed a two-refuter adopt gate (two independent fresh-context refuters,
verdicts converged 6/6), and was behaviorally A/B-verified on temp fixtures (kit-before vs
kit-after, headless fresh-context runs, 3/3 fixtures with a visible delta) before landing.
Text/schema only — no new machinery, zero always-on cost. Two further candidates (an optional
4th `state/` continuity layer; a guard-heavy CLAUDE.md ≤200 carve-out) were **rejected** at the
refuter gate as N=1-evidenced and already covered by existing canon — recorded as lab watch-items.

### Changed
- **Continuity: the progress layer now has two legitimate shapes** (`workflow.md` Continuity,
  `practice-baseline.md` §6) — **task-scoped** (closes with the task; terminal = `CLOSED` marker
  *or* delete, both valid — what matters is the file no longer reads as active work) and the
  **workstream snapshot** (a long-lived rolling picture of one workstream's current state + open
  threads; episodic history → devlog; prune, don't append). The hard "convert→devlog, then
  delete" mandate is gone: across three audited projects the delete never once happened, and the
  strongest operator practice was exactly the rolling snapshot the canon didn't recognize.
- **Verification ladder: externally-initiated refute for the silent-wrong class**
  (`workflow.md`) — for parsers/guards/validators prefer a refuter **initiated outside the
  authoring session** (fresh session / external audit) over a subagent the author spawns: a
  self-commissioned evaluator partly inherits the author's framing (a real one passed a denylist
  that an external pass then broke with Unicode-obfuscated input). And "verify passed" ≠ "the
  invariant holds": a consumer ledger stood at 6/6 green while an external audit refuted the
  invariant with an input class the suite never encoded — the refuter's mandate is the
  invariant, not the diff.
- **features.json canon: `blocked` / `blocked_reason` / `notes`** (`bootstrap-checklist.md`
  Phase 5 + `workflow.md`) — externally-gated verify is now expressible in the ledger. A bare
  `passes: false` can't distinguish "not done yet" from "cannot proceed here", so sessions
  re-attempted walls and invented ad-hoc carriers (a consumer project and a fixture run
  independently invented `notes`-like fields and root handoff files). Now: verify every
  reachable layer below the wall first, record `blocked` + `blocked_reason` (what unblocks it,
  and who), route the narrative to `notes`/progress, skip blocked features at session start,
  never flip `passes` on partial verify. Plus the campaign fork: a multi-initiative campaign
  keeps **one** roadmap carrier — not a ledger per initiative with a mirror roadmap.
- **Shipped-docs re-sync keys on content-versions** (`audit-checklist.md` §4,
  `operator-playbook.md` §4) — the project copy's `shipped-by` header is compared against the
  canon file's own header, never the plugin package version (which advances on unrelated
  releases and turned "re-sync available" into a permanent false positive).

### Added
- **Skills invocation-control facts** (`native-capabilities.md` Skills §, verified against
  first-party docs 2026-07-16): `user-invocable: false` (background knowledge, hidden from the
  `/` menu; exact spelling — the `user-invokable` variant seen in the wild is silently ignored)
  vs `disable-model-invocation: true`; `context: fork` + `agent:` for forked knowledge lookups.
  `harness-discipline.md` names the proven reference-skill species: the **project-knowledge
  skill** (background domain knowledge out of CLAUDE.md), pointing at those mechanics.
- **Audit checklist §3: hand-rolled `sync-docs` skill/agent** — duplicates the *kit-shipped*
  docs-discipline rule 1 ("doc-with-code") rather than a native surface; observed built only in
  projects that lacked the rule and retired once the rule arrived. Retire toward the rule.

### Fixed
- `operator-playbook.md` install command now matches README:
  `/plugin install claude-code-harness@claude-code-harness`.

## [1.14.4] — 2026-07-16

Docs hygiene — strip decorative edit-log meta from the reference surface, keeping the
functional staleness machinery intact. The kit's own `docs-discipline` rule 7 ("current-state,
not changelog") and practice-baseline §6 ("atemporal facts, not history") apply to the kit's
own references: a date that drives a future action (re-verify / re-sync / delta-compare) is
load-bearing and stays; a date that only records "this file was edited" is a log and goes.

### Removed
- **Decorative edit-log meta** — the dated "re-distilled on DATE (added §1/§2/§6/§8…)" changelog
  narration from `practice-baseline.md`'s Provenance, and two `<!-- last-updated -->` HTML
  comments (`harness-evolution.md`, `operator-playbook.md`) that only stamped a file-edit date
  and pointed at unshipped lab artifacts.

### Changed
- **`practice-baseline.md` Provenance rewritten to current-state** — keeps the load-bearing
  empirical anchor (§5/§6 zero-prompt red→green, §8 fresh-context-critic result) and now
  cross-references `evidence-base.md` for the wider citation set, instead of narrating what was
  added when.
- **`evidence-base.md` grounding stamp synced to CC v2.1.211** — was left at 2.1.210 after the
  1.14.3 bump; this is a functional "verified against docs on X" stamp, so it tracks live.

Untouched (functional provenance, deliberately kept): the `harness-evolution.md` refresh ledger,
`native-capabilities.md`'s version line + `verified DATE` / `re-ground on bump` markers, and the
`shipped-by:` headers that key the project-docs re-sync.

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
