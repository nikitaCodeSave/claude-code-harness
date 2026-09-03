# Operator playbook — the lifecycle of a project with Claude Code

A document for the **human operator**: what to tell the agent, what to prepare between sessions,
when to commission an audit, and when to trim the harness. The agent does not preload it — this is
the entry point into the discipline, not an instruction to the model. Details of each step are
behind the links, not here.

The principle above everything: **under a capable model, less harness yields more productivity**.
Each step below adds exactly what has proven its worth — and not before its trigger.

## Layer map

| Layer | Where | What it is |
|---|---|---|
| Kit (this plugin) | source of truth — repo `nikitaCodeSave/claude-code-harness`; on the machine — the installed plugin in `~/.claude/plugins/` | Bootstrap / Audit / Extend / Explain |
| Independent verification | nothing shipped — native surfaces + a fresh session | a new session told to refute is the per-change workhorse; `/code-review ultra` (paid cloud fleet) or a cross-vendor reviewer is the rare escalation |
| Workflow distillation | `<repo>/.claude/docs/{workflow,testing,docs-discipline}.md` | shipped by bootstrap verbatim from the kit (`references/project-docs/`); refreshed by a re-sync at audit time keyed on the `shipped-by` version |
| Continuity companion | the `devlog` plugin (same marketplace, optional) | `/devlog:devlog` skill + `devlog-reindex` + a SessionStart digest that surfaces recent devlog & active progress (silent in projects without them) |
| Project layer | `<repo>/CLAUDE.md` + `<repo>/.claude/` + `<repo>/docs/` | created by step 1, grows by triggers |

How the pieces reach the machine:
- **The plugin (kit)** — `/plugin marketplace add nikitaCodeSave/claude-code-harness`, then
  `/plugin install claude-code-harness@claude-code-harness`; carries SKILL.md and its references —
  no agents, no commands, no hooks.
  (For a maintainer developing the plugin itself — symlink its checkout into `~/.claude/skills/`:
  a directory with `.claude-plugin/plugin.json` is auto-loaded as `claude-code-harness@skills-dir`,
  with no install step. This is the **only** dogfooding path that stays live: a marketplace
  install *copies* the plugin into `~/.claude/plugins/cache/`, so edits need a reinstall, and
  `--plugin-dir` is per-invocation. Symlink the **plugin directory itself** — not its `skills/`
  subfolder — or you get the skill without the plugin's `hooks/` and `bin/`. Do this for every
  plugin you maintain: a hand-kept copy of one you also ship is a fork that drifts —
  `audit-checklist.md` §2.)
- **The continuity machinery** is the optional `devlog` companion
  (`/plugin install devlog@claude-code-harness`): the `/devlog:devlog` skill, `devlog-reindex`,
  and a SessionStart digest that auto-surfaces recent devlog + active progress in projects that
  keep them (silent elsewhere). Neither plugin writes into your `~/.claude/` profile.

## 1. New project — bootstrap (first session)

1. Open `claude` at the root of the empty/new repo.
2. Say: **"set up Claude Code harness in this project"** — this triggers the skill in Bootstrap
   mode (`references/bootstrap-checklist.md`).
3. The default is **production-grade regardless of project size**: a root `CLAUDE.md`
   (≤200 lines, an indexer, including a Working style with a verification ladder) +
   `.claude/settings.json` (the deny list matters more than allow) + the workflow distillation in
   `.claude/docs/` (3 files, verbatim from the kit) + `docs/ARCHITECTURE.md` as a decision record
   + `.claude/rules/` for the prohibitions the repo actually has. The minimal MVH (CLAUDE.md +
   settings only) — via a
   separate phrase: **"set up a minimal harness"**. There are no custom agents/hooks/skills in
   either variant — this is discipline, not an omission.
4. The contract (stack / acceptance of the first feature / verify mechanism / sensitive paths)
   surfaces from the conversation as you go — no upfront questionnaire is needed; just make sure
   the dangerous paths land in `permissions.deny` as soon as they're named. The one class that does
   *not* settle itself is a question whose answer changes what "correct" means — product semantics,
   a trade-off with a real cost. Answer those explicitly and dated, because a session that guesses
   one of them ships something plausible and wrong. The answer lands in an ADR or the devlog entry
   for the change — wherever this project keeps decisions.

Step check: `claude --print "what is the project's stack?"` answers from CLAUDE.md.

## 2. A multi-session product — three things worth having

The kit used to ship a "long-running build kit" (a feature ledger, a generated oracle script, a
session-start ritual). It was retired in v1.23.0: the parts that mattered are a line in CLAUDE.md
and a plugin, and the rest was scaffolding the model no longer needs. What is actually worth
setting up for a product built feature-by-feature:

1. **Name one verification command in CLAUDE.md** — the existing `make check` / `npm test` /
   `pytest -q`, not a new script wrapping them. A session that can close its own loop against a
   real command is the whole of what the ledger was protecting; a second entry point re-running
   the same gates is drift.
2. **Install the devlog companion** (`/plugin install devlog@claude-code-harness`): its
   SessionStart digest surfaces recent entries and any active `.claude/progress/<slug>.md`, so a
   new session starts informed instead of re-deriving state. Detect first — an operator who
   already runs a personal digest hook gets both, with no error to signal it.
3. **Track commitments wherever the project already tracks them** (issues, a backlog file, the
   devlog). Keep it in the repo the work ships from — the session task list is machine-local and
   is not that register.

**harness-journal — opt-in, off by default**: ask for `.claude/harness-journal.md` (1–3
"kit-fell-short" observations per session) only if you plan to run D-cycles (step 7). Without
D-cycles the journal is dead weight.

## 3. The build ritual — what the operator does between sessions

- **Preconditions before starting a session**: bring up the services the work needs (DB docker
  container, local LLM, …) — a session that discovers them missing burns the turn on diagnosis.
- **Session start**: with the devlog digest installed there is nothing to say — recent entries and
  active progress are already in view; the session acts on that state instead of rediscovering it.
- **Session end**: check by eye — a commit per unit of work, progress updated, and the
  verification command actually run rather than asserted.
- **Ratify what only you can decide.** Sessions surface questions whose answer changes what
  "correct" means — product semantics, a trade-off with a cost. Answer them explicitly: pick one of
  the options the session laid out (by its code, where it wrote a coded table), date it, say what
  your answer rests on. Three answers are legitimate, and two of them create no work: `wontfix`
  (deciding is not a promise to build) and "this only ratifies what the code already does". Deciding
  nothing is also a choice, priced as a session that stalls or guesses. The one thing the agent must
  not do is read your silence as agreement — it leaves the question open and works something else.
- **A handoff note is a claim, not a fact**: if the previous session wrote "verified" — the next
  one must re-execute before relying on it.
- **The spec's own premise is a claim, not a fact**: before building to a requirement's assumption
  ("the model can't do X", "we need a blanket abstain here"), measure whether the assumption holds
  — an oracle sweep can refute the requirement itself; when it does, trust the measurement over the
  spec and record why.
- **Contract/docs vs disk**: on a mismatch (a path doesn't exist, a file isn't where expected) the
  truth is the disk: detect-then-prescribe, fix by the facts and record an observation in
  journal/progress, don't follow the contract blindly. Resolve commands per-tool (`.venv` first,
  PATH fallback) — and **watch what actually resolved**: an inherited PATH may substitute another
  project's venv (the oracle is "green" but the interpreter isn't from this project); have
  the oracle print resolved paths.

## 4. An existing project — bring it to the canon

1. At the project root, say: **"audit my Claude Code harness"** — this triggers Audit mode
   (`references/audit-checklist.md`; the gap-report template is in the kit's `SKILL.md`).
2. You get a gap report (finding → why it matters → remediation). **Edits happen only after your
   approval**, anything irreversible is flagged separately; before a strip — a branch/backup.
3. The audit also compares the `shipped-by` version of the workflow distillation (`.claude/docs/*`)
   against the same files in the installed plugin (content-version vs content-version — not the
   plugin's package number) and offers a re-sync when the canon copy is newer — so the factory
   distillation in projects doesn't fall behind the canon.

## 5. Keeping the kit and the baseline current

Updates flow through the plugin: `/plugin update claude-code-harness` (and `devlog`). A new
version changes only the plugin itself — copies that live in your projects or profile are
re-synced deliberately, never silently:

1. **Kit skill and references** — current the moment the plugin updates; nothing to do.
2. **Workflow distillation** (`.claude/docs/*` in each project) — at the next
   **"audit my Claude Code harness"** the audit compares `shipped-by` headers and offers a
   re-sync (diff shown first; hand-edits surfaced, not overwritten).
3. **The devlog companion's digest and commands** live inside that plugin — they update with
   it; nothing is copied into your profile or projects.

The whole maintenance ritual: `/plugin update` → in each active project, say
**"audit my Claude Code harness"** when convenient → approve or decline the offered re-syncs.

## 6. Independent verification — two tiers (fresh context, not self-recheck)

The lever is an independent *fresh context* that judges the deliverable — not a second pass in the
authoring one, which anchors on its own solution. It comes in two weights; reach for
the light one by default and the heavy one rarely. Both beat a self-orchestrated Evaluator (one the
author commissions inherits the author's framing). A fresh-context check earns its keep even on
*accepted* code — it has caught HIGH defects in features that were already green.

**Tier 1 — the per-change refute (the workhorse).** For a silent-wrong-prone change (a
parser/rewriter of untrusted input, a guard/validator, an invariant-preserving refactor), open a
**fresh session** at the project root and tell it to *refute*, not confirm: name the invariant,
point at the change, and ask for a failing input rather than an opinion. Cheap enough to run
per-change — which is exactly where it earns its place, because that class passes the author's own
tests while being wrong. **The kit ships no role file for this, deliberately** (it did until
v1.23.0): the lever is the fresh context and the refute-framing, both of which a sentence supplies,
while a shipped role file is one more thing to keep in sync with the review surfaces.

**Cross-vendor variant of Tier 1 — only if you already run a second-vendor CLI.** A same-family
refuter is fresh but not foreign: trained as the author was, it inherits a share of the author's
blind spots. A reviewer from another vendor does not. Codex CLI can act as an MCP server, so one
user-scope line reaches it —
`claude mcp add -s user -t stdio codex_peer -- "$(command -v codex)" mcp-server` — after which the
kit delivers the discipline for using it as a skill, on request: **"set up the cross-vendor
refuter"** (`references/codex-peer-skill.md`; your profile is written only with your explicit
approval).

Two questions that are easy to conflate, kept apart deliberately:

- **Should you get a second vendor for this? No.** A fresh same-family session is sufficient, and
  nothing in the kit's evidence justifies a second subscription. (Nor is any of this an exception to "CLI-subscription only" — that principle
  governs how *Anthropic* models are reached, not which CLIs exist on your machine.)
- **If one is already wired, how often should it run? As the routine executor of Tier 1, not as a
  rare escalation** — that is where the maintainer's own practice has settled, and it is reported
  as practice, not measured. Weigh it as you would a colleague's strong recommendation: the
  standing evidence behind it is one controlled episode (lab devlog #127, n=1 — one component, one
  vendor, 2026-08-01) plus daily use that began at that same episode, so it is days old, not a
  track record. It grounds *the discipline of how to use such a reviewer*; it is not a
  demonstration that every project needs one.

**Tier 2 — the milestone gate (rare escalation).** Reserve for a closed milestone · a
security/correctness-critical feature · an expensive irreversible delivery that "looks done". Two
shipped surfaces, picked by what carries the risk:
- **The change is the risk** → **`/code-review ultra`** (alias `/ultrareview`, CLI `claude
  ultrareview [target]`): a cloud fleet of bug-hunting agents over the branch or PR. Paid via
  usage credits (~$5–25/run, 3 free runs on Pro/Max as a one-time allotment).
- **The deliverable is the risk** → a **fresh session** at the project root, told to audit the
  scope and, crucially, to **execute the live stack** rather than read it — the one rule worth
  carrying over from the retired 3-role command is *executed evidence beats read evidence*: a
  reader-only pass once called golden numbers "unproven" that an executing pass then re-derived
  exactly. Have it write findings straight into `.claude/progress/<slug>.md` next steps as
  "reproduce → close", and fix them in a separate red→green cycle rather than in the audit.

Empirically the two tiers settle this way: in a sustained real-product build the heavy gate ran
**once**, at a milestone; per-change verification was a single fresh refuter. Default to the light
tier; the heavy one is the exception.

## 7. D-cycle — evolving the canon (role: canon maintainer)

When: a milestone closed, or the journal has accumulated ≥5 substantive observations.
How: a separate session following `references/harness-evolution.md` (classify observations →
gate "single-incident ≠ invariant" → a surgical fold into the canon → commit + devlog).

"Canon" = this plugin's repository (`nikitaCodeSave/claude-code-harness`) at its maintainer's.
A plugin consumer does not edit the canon — they update the plugin version (`/plugin update`) and
pass findings/journal observations to the maintainer.

## 8. Strip revision — when to trim the harness

Once every 3–6 months or on a major model release: re-test each component "does the model already
do this natively?" (a quick test — `claude --safe-mode`: if it's no worse without the harness, the
component is obsolete). The procedure is the second half of `references/harness-evolution.md`.

## Cross-cutting operator rules

- (maintainer) Every kit edit = a commit to the plugin repo (`nikitaCodeSave/claude-code-harness`)
  + a devlog entry there; the empirical provenance (experiments) goes in the maintainer's lab repo.
- The harness grows **only by triggers** (the "Optional next steps" table in
  `references/bootstrap-checklist.md`), never speculatively.
- The project code is not touched through harness rituals: the scope of audits and Audit mode is
  `.claude/`, `CLAUDE.md`, `docs/`.
