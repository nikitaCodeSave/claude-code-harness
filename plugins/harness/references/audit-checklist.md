# Audit checklist (existing `.claude/`)

Walk top-down. For each finding write a one-line gap + a proposed remediation; **do not edit
until the operator approves** the items they want fixed. Output uses the report template in
`SKILL.md`. Grounded for the Claude 5 family / Opus 4.8 generation, Claude Code v2.1.210 (July 2026).

## 0. Live machinery vs completed-run artifact (ask this first)

Before classifying any finding, check whether the harness's machinery describes a **live, ongoing**
task or a **completed run** — look for a done-marker, an all-goals-complete state, or a
progress/build ledger showing closure. This question is generic to ask; its answer is
project-specific — read the project's state, don't assume. It reframes disposition: loop scripts,
a phase critic, model/config pins, and runbooks for a *finished* run are **provenance plus a
retire-or-rerun decision for the operator** — not fix-in-place targets. De-staling or "modernizing"
a completed run's records falsifies history. When the task is still live, the sections below apply
normally; when it is complete (or you're unsure), say so and ask whether the loop is being retired
or re-run before proposing edits to its machinery.

## 1. Stale model / version pins

- Does any file pin a **specific model version in behavioral prose** (e.g. "under Opus 4.X the
  model does Y", "Opus 4.X picks a sane stack")? De-version it to "a capable model" — a
  behavioral invariant must not bind to a release, or it goes stale every upgrade. A major model
  release is the canonical re-grounding trigger: re-test such invariants before they survive.
- **But keep version refs that are provenance, not behavior** — stripping them loses information:
  dated grounding stamps ("grounded for Opus 4.8 / CC vX, late May 2026"), un-re-measured findings
  ("4.7-era eval, not re-run"), config facts (effort default per version, model-assignment IDs),
  historical notes ("survived the 4.7→4.8 transition"), source citations, verbatim user quotes.
  Rule of thumb: *behavioral binding → de-version; honest "when/against-what" sourcing → keep.*
- **When de-staling, edit only the ACTIVE layer — never frozen records.** A grep for the stale
  string typically hits three kinds of file: (a) **active** harness components and live docs
  (`.claude/skills|rules|agents`, root `CLAUDE.md`, `docs/ARCHITECTURE.md` etc.) — fix these;
  (b) **frozen** point-in-time records (`docs/archive/**`, `docs/research/**`, `.claude/**/archive/**`,
  devlog/changelog entries, audit-record JSON) — **do NOT edit**: they are provenance, and rewriting
  them falsifies history (the project's own `docs-discipline` "live vs archive" rule governs this).
  Classify every hit before editing; when unsure whether a path is frozen, ask rather than rewrite.
- Are built-in inventories current? (5 subagents incl. `claude-code-guide`; effort default
  `high`; dynamic workflows exist.) An inventory pinned to an old version is the weakest
  provenance in a harness.

## 2. Duplicates & shadowing

- The same skill in both `~/.claude/skills/` and `<project>/.claude/skills/` — which is
  authoritative? Forks drift; the project copy often hardcodes paths the global one parameterized.
- Two skills with overlapping missions (e.g. two bootstrap skills) — one should be canonical.
- A reachability trap: a skill whose description says "skip when already configured" living
  inside the very repo that is already configured → it can never fire there.

## 3. Built-in duplication

- Any custom subagent that duplicates `Explore` / `Plan` / `general-purpose` / `statusline-setup`
  / `claude-code-guide`? The classic offender is a custom `orchestrator` — the main thread is the
  orchestrator; `general-purpose` is the deep delegate.
- Any custom hook/skill/command reimplementing something now native (dynamic workflows,
  `/goal`, auto memory, `/deep-research`)?
- A custom `code-reviewer` subagent or hand-rolled review pipeline — review is shipped:
  `/code-review` (working diff, the local default), `/review` (PR), `/security-review`,
  `claude ultrareview` (cloud, high-stakes). Retire the custom agent; route to the built-ins
  (see `native-capabilities.md`, "Code review"). **Carve-out:** the kit's own
  `/claude-code-harness:external-audit` roles (`evidence-executor` / `process-auditor` /
  `code-refuter`) are not a review pipeline to retire — they are the verification ladder's
  external-audit rung (executed evidence + process audit + adjudication, wider than diff
  review); don't flag them under this item.

## 4. CLAUDE.md altitude

- Over 200 lines? Storing content that belongs in `docs/` or `.claude/rules/`?
- Lines that don't change behavior (would removing them cause a mistake?) → cut.
- Rules Claude already follows without instruction → delete; rules that must hold every time →
  convert to a hook.
- **Evidence-backed keeps, not cruft**: the kit's own deliverables — `.claude/rules/practice-baseline.md`
  (Phase 2b embed), the shipped `.claude/docs/{workflow,testing,docs-discipline}.md` (Phase 2c)
  and the Working style proposal-duty lines (plan-mode self-entry, verification ladder) — are
  transcript-grounded (sessions without them proposed zero ladder rungs and coded nontrivial
  work plan-free). Don't flag them under §4/§5; their retire triggers: embed → global baseline
  installed; duty lines → a target model proposes these steps unprompted.
- **Shipped-docs re-sync**: compare the `shipped-by: claude-code-harness vX.Y.Z` header in
  `.claude/docs/*` against the installed plugin version. Plugin newer → offer re-sync, but
  **diff the project copy against the current canon and show the diff to the operator before
  overwriting** — any non-header delta is a potential hand-edit (incl. translations) that a
  verbatim re-copy would destroy; propose moving such content to CLAUDE.md (and features.json,
  if present) first. Header newer than the plugin → update the plugin, don't downgrade the
  files. Shipped docs **absent** on a non-MVH project (pre-v1.8 bootstrap or skipped Phase 2c)
  → finding; offer to ship them (bootstrap Phase 2c).
- **Orphan sweep on a corrective re-sync**: when a re-sync **removes or corrects** baseline
  content (not just bumps the header), `git diff` the superseded lines and grep the project tree
  (`skills/`, `rules/`, `CLAUDE.md`, `docs/`) for references to the now-dead content. A corrected
  upstream claim can leave **orphaned project structure** built on it (a skill/rule that the dead
  claim justified — e.g. a planning skill premised on a since-fixed bug); the re-sync isn't clean
  until those orphans are surfaced and triaged. The downstream grep is the lever, not an
  upstream "impact" note — the auditor runs inside the project, where the orphans live.

## 5. Stale "model-can't-do-X" assumptions

- Prescriptive stack/tooling presets the model didn't need (a capable model picks a sane stack).
- Defensive "remember to run X" nagging (modern models trigger the right tool — use a hook if it
  must happen).
- Thinking-budget management (thinking is adaptive — don't manage it).
- A **blocking** Stop hook stamped in by default rather than earned by a recurring false-completion.
- **Resolving a suspected-stale component — empirically, not by argument** (this is also §1's
  re-grounding disposition): disable it (`--safe-mode`, or remove the component) and re-run a
  representative task; if the output doesn't materially degrade, retire it. Judge with a
  **fresh-context** reviewer, not self-assessment — the author is anchored. Retire on
  evidence-of-no-lift, not on taste.

## 6. Hook hygiene

- `PreToolUse` hooks that block writes mid-thought (corrosive) vs enforcement at `Stop` /
  `UserPromptSubmit`.
- Hooks that fail closed without a fallback (no `jq`, missing tool) and break sessions.
- Hooks added "for hygiene" before any pain proved the need.

## 7. Skill shape

- Skills that re-describe the main thread's role (duplicate CLAUDE.md) vs genuine action/reference skills.
- Side-effecting skills missing `disable-model-invocation: true`.

## 8. Multi-agent over-reach

- A PM→Architect→Dev→QA pipeline, or a Generator/Evaluator contract per task.
- Custom orchestration machinery where a dynamic workflow (built-in) would do.

## 9. Lab-vs-starter conflation

- R&D machinery (self-improvement loops, benchmark rigs, experiment telemetry) that would leak
  if the repo were copied as a template. Remediation: fence it explicitly ("this repo is a lab,
  not a starter — do not copy `.claude/` wholesale"), keep it project-scoped, never ship it at
  user level.
- Dev cruft (`_archive/`, `_backups/`, `_test_logs/`, caches) shipped inside a user-level skill.
- **Sweep the repo root for `.claude`-sibling snapshots** (`.claude.original/`, `.claude.bak/`,
  `.claude_old/`, `_backups/` at root …) — a parked copy of a retired harness *outside* `.claude/`
  is invisible to a `.claude/`-scoped walk, yet it is untracked history waiting to be committed
  or copied. Remediation: delete (the history belongs in git), or fence + gitignore it explicitly.

## 10. Permissions & secrets

- Destructive commands in `allow` rather than `ask`/`deny`; secret paths not denied for `Read`.
- `--dangerously-skip-permissions` or bypass mode baked into committed settings.
- API-only features assumed (managed-agents, beta headers, `--bare`) on a CLI subscription.

## Refresh execution hygiene (when applying approved findings)

Findings name *what* to change; these procedures keep the *application* clean — a native session
refreshing its own harness needs them, not just the maintainer:

- **Deleting/retiring a component → grep for dangling references first, then re-route them.**
  Removing a skill/agent/command leaves orphan refs that the delete itself won't surface: skill
  counts and "canonical per name" notes in `GUIDE.md`/`CLAUDE.md`, rows in skill/agent
  acceptance-test docs, entries in indexes. After the removal, `grep -rn <name>` the whole repo;
  fix the **active**-layer hits (re-point to the built-in or replacement, decrement counts) and
  leave frozen records alone. "Done" = grep shows zero *live* references.
- **Shipping the distillation → copy verbatim, verify byte-identical.** `.claude/docs/*` must
  `diff` clean against `references/project-docs/*`; the `shipped-by:` header is the re-sync key,
  don't hand-edit it. Add the CLAUDE.md pointer noting the project's `.claude/rules/` *extend* the
  baseline.
- **After any refresh → run the project's oracle** (`init.sh`/test suite) green before declaring
  done; a harness edit that breaks a hook or a referenced path shows up there, not in the diff.

## Severity ordering for the report

Rank fixes lowest-risk-first: stale pins & dead duplicates (safe) → CLAUDE.md pruning →
hook/skill reshape → multi-agent consolidation → permission tightening. Flag anything
irreversible (deleting accumulated experiment data, removing an actively-used skill) as
**confirm-before-acting**, not autonomous.
