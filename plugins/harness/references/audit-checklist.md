# Audit checklist (existing `.claude/`)

Walk top-down. For each finding write a one-line gap + a proposed remediation; **do not edit
until the operator approves** the items they want fixed. Output uses the report template in
`SKILL.md`. Grounded for a capable Claude Code / Opus-class generation; the currency pin lives
in `references/native-capabilities.md`.

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
- **Target form: exactly one file carries the currency pin; every other live doc is
  version-free and points at it.** The *currency* pin is the "what generation is this written
  against" claim — the CC version and model generation the docs assume. Duplicated across two
  live docs it goes stale in one of them *silently*: nothing fails, the two just disagree, and
  the reader believes whichever they opened. Name the project's single version-carrying
  document (in this kit: `references/native-capabilities.md`). A dated "since vX this behaves
  like Y" attribution elsewhere is sourcing, not a currency pin — it stays (previous bullet).
- **Run the drift detector — the class, not the case.** Manual proofreading has now missed this
  across three consecutive model upgrades, so audit it mechanically (also after every model / CC
  upgrade). The allowlist is the inventory itself plus the frozen layers:

  ```bash
  grep -rnE "Opus 4\.[0-9]|Opus [0-9]|Sonnet [0-9]|v?2\.1\.[0-9]{3}" \
    --include="*.md" . \
    | grep -vE "(archive/|devlog/|/reports/|/audits/|CHANGELOG\.md|native-capabilities\.md)"
  ```

  Classify each survivor by the rule above — behavioral binding → de-version; honest
  when/against-what sourcing → keep — and adapt the allowlist to the project's own frozen paths
  and its own inventory filename. **A rising hit count between audits is the drift signal**, so
  record the number. Deliberately *not* a hook: block-at-write is corrosive (§6), and the
  detector's output needs a human classification pass, which is what an audit is.

## 2. Duplicates & shadowing

- The same skill in both the user-level `skills/` and `<project>/.claude/skills/` — which is
  authoritative? Forks drift; the project copy often hardcodes paths the global one parameterized.
  (User-level paths in this checklist live in the **active config dir** — `CLAUDE_CONFIG_DIR` if
  set and non-empty, else `<home>/.claude`; resolve it with whatever your shell supports and hand file tools
  the resolved literal, they don't expand `$VAR`. Auditing the default path while the variable
  points elsewhere audits someone else's profile; an absent dir is a valid "empty layer".)
- **A hand-kept copy of something a plugin already ships.** Plugin skills are namespaced
  (`plugin:skill`), so they never *collide* with a personal one — which is exactly the trap:
  no error, no shadowing warning, just two skills with the same description and a model
  picking either. Same for a personal hook beside the plugin's on one event. The tell is a
  fix that must be applied twice. Replace the copy with a **symlink to the plugin directory**
  (`<config-dir>/skills/<name>` → `<repo>/plugins/<name>`): a dir with `.claude-plugin/plugin.json`
  loads `@skills-dir`, in place, so the repo stays the single source
  (`code.claude.com/docs/en/plugins-reference`). Observed here: a personal devlog skill drifted
  a month from the shipped one — a stale script path and a language-pinned parser — while a
  personal SessionStart hook duplicated the plugin's digest in every session.
- Two skills with overlapping missions (e.g. two bootstrap skills) — one should be canonical.
- A reachability trap: a skill whose description says "skip when already configured" living
  inside the very repo that is already configured → it can never fire there.
- **Two hooks on one event doing the same job.** Hooks from every layer (user settings,
  project settings, plugin `hooks.json`) **merge — they never override**, so a plugin that
  ships a `SessionStart` digest lands *alongside* a personal hook that already surfaces the
  same devlog/progress, and both fire. The operator sees no error; the model just gets the
  same state twice, in two formats, before turn one. Check `settings.json` hooks against
  every enabled plugin's `hooks.json` per event; when both exist, keep one and say which.
  (Observed: this kit's own devlog companion vs the maintainer's personal hook.)

## 3. Built-in duplication

- Any custom subagent that duplicates `Explore` / `Plan` / `general-purpose` / `statusline-setup`
  / `claude-code-guide`? The classic offender is a custom `orchestrator` — the main thread is the
  orchestrator; `general-purpose` is the deep delegate.
- Any custom hook/skill/command reimplementing something now native (dynamic workflows,
  `/goal`, auto memory, `/deep-research`)?
- A hand-rolled `sync-docs` skill/agent (classify the diff → update the matching docs)
  duplicates the **kit-shipped** docs-discipline rule 1 ("doc-with-code") rather than a native
  surface — same disposition as the custom code-reviewer below: retire toward the rule, moving
  any project-specific doc-map into CLAUDE.md. (Observed pattern: the skill gets built only
  where the rule is absent, and gets retired once the rule arrives — the main thread does
  this natively.)
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
  and the Working style duty lines (**plan-mode self-entry · verification ladder · change-sizing ·
  continuity · doc-with-code**) — are transcript-grounded (sessions without them proposed zero ladder
  rungs and coded nontrivial work plan-free). Don't flag them under §4/§5 — and note the neighbouring
  bullets above ("lines that don't change behavior → cut", "rules Claude already follows → delete")
  read like a licence to cut exactly these; they are not, because the duty is the *project-side*
  write-through the bootstrap's Phase 7 greps for. Their retire triggers: embed → global baseline
  installed; duty lines → a target model proposes these steps unprompted.
- **Continuity duty absent from CLAUDE.md** — `grep -ciE '^#{0,4} *-? *\*{0,2}Continuity' CLAUDE.md`
  → 0. **Use that anchored form, not a bare `grep -ci continuity`:** the kit's own Reference-materials
  block ends a line with the word ("…verification ladder, continuity"), so the bare grep scores 1 on a
  CLAUDE.md that has the pointer and no duty — it misses most of the population it is meant to find.
  The anchor demands the word as a label at line start (duty bullet or a `## Continuity` heading).
  The project may keep a devlog, ship `.claude/docs/workflow.md`, and carry the baseline's §6 — and
  still never tell a working session that a feature/fix/config change/decision closes with an episodic
  entry, or name the carrier. Finding: the layer then holds only while the operator watches; entries
  stop the first session nobody reminds. **Common on projects bootstrapped before v1.17.0** — the
  checklist described the layer in Phase 5 and never asked CLAUDE.md to name it, while the
  write-through grep tested three other tokens (found by a clean-environment bootstrap run,
  2026-07-17). Remediation: add the duty line from `bootstrap-checklist.md` Phase 2 — trigger +
  carrier + `.claude/progress/<slug>.md` + pointer to `.claude/docs/workflow.md`, three lines. Do
  **not** restate the depth `workflow.md` §Continuity and the baseline §6 already ship; a 14-line
  continuity section in CLAUDE.md is this finding's over-correction, not its fix (a heading-shaped
  section passes the anchored grep — it has the duty, in the wrong shape; that is a §4 altitude
  finding, not this one).
- **Shipped-docs re-sync**: compare the `shipped-by: claude-code-harness vX.Y.Z` header in each
  `.claude/docs/*` file against the header of the **same file in the installed plugin's
  `references/project-docs/`** — content-version vs content-version, never vs the plugin's
  package version (headers advance only when a file's content changes, so a package bumped for
  unrelated reasons would read as a permanent false "re-sync available"). Canon header newer →
  offer re-sync, but **diff the project copy against the current canon and show the diff to the
  operator before overwriting** — any non-header delta is a potential hand-edit (incl.
  translations) that a verbatim re-copy would destroy; propose moving such content to CLAUDE.md
  (and features.json, if present) first. Project header newer than the canon's → update the
  plugin, don't downgrade the files.
- **Shipped docs absent — audit coverage per file, not presence.** On a non-MVH project (pre-v1.8
  bootstrap or skipped Phase 2c) their absence is a finding **only where that file's duty areas are
  uncovered** — `workflow.md`: session ritual · change sizing · verification ladder · continuity;
  `docs-discipline.md`: doc-with-code mapping · ADR threshold · glossary · current-state discipline;
  `testing.md`: the five invariants. A mature project may already carry all of a file's areas in its
  own `CLAUDE.md` / `AGENTS.md` / process docs — then shipping that copy adds a competing instruction
  for no coverage gain. Judge the files independently: one covered elsewhere doesn't excuse another.
- **A shipped line that contradicts the project's own canon is always a finding — and the operator
  adjudicates it, you don't.** Observed: `workflow.md`'s "session start = git log + progress" inside
  a project whose CLAUDE.md forbids reconstructing status from Git; there the project's rule was the
  stronger one and removing the shipped copy was right. The reverse also exists — a project rule that
  waives a kit invariant (say, "small fixes need no test") is a *finding against the project*, and
  deleting `testing.md` would ratify the regression. Present both readings and let the operator pick;
  never silently resolve toward whichever text is local. Uncovered area → offer to ship that one file
  (bootstrap Phase 2c). This governs whether a file *exists*, not whether a project may hand-evolve a
  shipped copy — those still flow through the plugin, and the invariants they carry are extended by
  project rules, not replaced by them.
- **Practice-baseline re-sync**: if `.claude/rules/practice-baseline.md` exists, compare its
  `practice-baseline content-version` stamp against the canonical block's stamp in the
  installed plugin's `references/practice-baseline.md` — same content-version semantics as
  shipped-docs (the stamp advances only when the block's text changes). **Read both files
  from disk**: the stamp is an HTML comment, stripped from the context-injected copy. Canon
  newer → offer re-sync, diff-first (a non-stamp delta is a potential hand-edit to preserve).
  Unstamped embed (pre-v1.16 install, or hand-adapted) → treat the copy as a hand-edit: diff
  against the current block, show the delta, offer a stamped re-install. A **global** copy in
  the user CLAUDE.md (`<config-dir>/CLAUDE.md`, §2's active-config-dir resolution) is never
  edited by an audit — if its stamp is older than the canon,
  report it and offer the guarded refresh (diff + timestamped backup + explicit approval;
  `practice-baseline.md`, "Keeping installed copies current").
- **`codex-peer` re-sync — only if a copy already exists.** If `skills/codex-peer/SKILL.md` is
  present (project, or the user profile at `<config-dir>/skills/`), compare its `codex-peer
  content-version` stamp against the canonical block in `references/codex-peer-skill.md` and offer
  the same diff-first re-sync; a hand-adapted copy (pinned model/effort/local defaults) is
  deliberate, preserve it. The profile copy is reported, never edited by an audit. **An existing
  copy is itself the opt-in**, so re-sync it on its stamp whether or not a server is registered
  right now — a temporarily unregistered server is not a reason to let the file rot, and removing
  it is the operator's call, not the audit's. **Absent is not a finding**: delivery is gated by the
  single condition `bootstrap-checklist.md` Phase 2b states in full (**a Codex MCP server is
  already registered**, per `claude mcp list`; `codex` on PATH alone does not count). Offer
  delivery only on a positive; on a negative, say nothing about it at all and do not load the
  reference. It is an optional upgrade for operators who already run a second vendor, never a gap
  to close by acquiring one.
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
- **Context-injecting hooks (`SessionStart` / `UserPromptSubmit` / `Stop`) with unbounded
  stdout.** Whatever they print is injected verbatim — no downstream trim, no size warning,
  and it lands *before* the operator's first turn. A hook that echoes a project file, a `git
  log` with no `-n`, or a field lifted from a file whose size nothing guarantees will flood
  the window on the one repo that violates the assumption. Two independent caps: per field on
  the way in, whole-digest on the way out; announce truncation rather than trimming silently.
  Then verify against a hostile fixture, not a tidy repo — the failure is invisible until the
  file is large. (Observed: a devlog digest read a *derived* `tldr.md` whose headings carried
  no cap — a 10 MB file became 10 MB of context, ~2.5M tokens, in 0.6 s. Its own
  source-of-truth path capped correctly; only the "fast path" skipped the guard.)
- **A derived file read as a fast path.** Caching an `index.json` / `tldr.md` / digest to save
  a few reads buys milliseconds and inherits two silent-wrong modes: it goes stale the moment
  its generator lags (reporting old state as current), and its pre-joined fields skip the
  validation the source-of-truth path applies. Read the source unless a measurement — not an
  intuition — says you can't.

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
- **Dead file rules — a line that reads as a guard and enforces nothing.** The file-permission checks
  match only `Read(path)` and `Edit(path)`: `Glob(path)`, `Write(path)` and `NotebookEdit(path)` are
  parsed, never matched, and warn at startup (v2.1.210+); `Grep(path)` never warns at all. Run the
  Phase 7 dead-rule check from `bootstrap-checklist.md` and read its output — *including* the
  untrusted-workspace line, without which the check reports clean while every `allow` rule is inert.
  Two blind spots it cannot cover, so grep for them by hand: `Grep(` in the settings file, and a
  typo'd tool name in `allow` (only deny/ask are typo-checked). Remediation is a **fold, not a
  delete** — `Glob(p)`/`Grep(p)` → `Read(p)`, `Write(p)`/`NotebookEdit(p)` → `Edit(p)`; a **bare**
  `Write` / `Glob` with no parens is a working whole-tool rule, leave it. Grade a dead **deny** rule
  as the harness's most expensive defect class — the operator believes a path is fenced and it is not.
- `--dangerously-skip-permissions` or bypass mode baked into committed settings.
- API-only features assumed (managed-agents, beta headers, `--bare`) on a CLI subscription.

## 11. Ledger & intake (skip entirely when the project keeps no ledger)

Only for a project running the Phase 5 kit — an absent `features.json` is a valid shape, not a
finding. Two checks, both cheap:

- **The ritual names an order the ledger cannot express.** CLAUDE.md says "highest-priority
  incomplete feature" and no entry carries `priority` → the session picks by array order and calls
  it priority. Remediation: add the field (`bootstrap-checklist.md` Phase 5 item 2), or reword the
  ritual to say array order — either is honest, the mismatch is not.
- **An open entry whose acceptance hangs on an unmade decision.** Falsifiable form: its `verify` or
  `description` names a choice between readings ("either … or …", "TBD", "assuming X") and no
  answer exists — not in `notes`, not in the tracker the ledger points at, not in an ADR. Check the
  named external canon before flagging; a project that keeps decisions in Jira is compliant, not
  undocumented. Remediation: surface the question to the operator for the *open* entries only. Do
  **not** back-fill history — closed work's provenance lives in git and the devlog.

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
- **After any refresh → run the project's oracle** (the command CLAUDE.md names) green before declaring
  done; a harness edit that breaks a hook or a referenced path shows up there, not in the diff.

## Severity ordering for the report

Rank fixes lowest-risk-first: stale pins & dead duplicates (safe) → CLAUDE.md pruning →
hook/skill reshape → multi-agent consolidation → permission tightening. Flag anything
irreversible (deleting accumulated experiment data, removing an actively-used skill) as
**confirm-before-acting**, not autonomous.
