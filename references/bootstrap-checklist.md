# Bootstrap checklist (`.claude/` from scratch)

Procedure for introducing Claude Code to a project with no `.claude/`. Two shapes:

- **Default — production-grade bootstrap:** root `CLAUDE.md` + `settings.json` + offered
  practice baseline (Phase 2b, operator decides) + the shipped workflow distillation in
  `.claude/docs/` (Phase 2c) +
  `docs/ARCHITECTURE.md` & `docs/CODE-MAP.md` written from the code actually read. Projects are
  written for production releases from day 0 **regardless of size** — a full professional flow
  is cheaper to lay down at bootstrap than to retrofit (operator directive, 2026-06; the
  retrofit that motivated it cost a full session). For a product built feature-by-feature
  across many sessions, also establish the long-running spine in Phase 5 (Anthropic's
  published long-running-harness playbook).
- **Minimal (MVH) — only on explicit operator request:** root `CLAUDE.md` + `settings.json`,
  nothing else. Use when the operator explicitly asks for a minimal setup (throwaway
  experiment, one-off script) — not as a silent default.

Custom subagents / hooks / pipelines stay out of both shapes until a trigger earns them
(see `harness-discipline.md`) — "production-grade" means conventions + documents, not machinery.

Stack-agnostic. Re-verify the environment with `claude --version`.

## Phase 0 — Read the room (no writes)

```bash
claude --version            # confirm the line; primitives drift by minor version
# Built-in subagent TYPES you must NOT recreate (Explore / Plan / general-purpose /
# statusline-setup / claude-code-guide) are catalogued in references/native-capabilities.md.
# Live: /context ("Custom Agents") or ls .claude/agents/ — the /agents wizard was removed in
# v2.1.198. NOT `claude agents` (that CLI lists running sessions, not types).
ls -la                      # repo shape
ls -la .claude/ 2>/dev/null # confirm empty / absent
git log --oneline 2>/dev/null | wc -l             # project age (0 + stderr-fatal on a fresh repo is fine)
git log --oneline --since="3 months ago" 2>/dev/null | wc -l  # active vs dormant
ls ~/.claude/               # operator-level config already present
```

Detect the stack from manifests (`package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` …),
the test/lint commands, the task runner, CI presence. **Also read the project's intent** (README /
the operator's stated goal): is this a *sustained, multi-session product build* (→ default shape
+ Phase 5 kit) or a small/one-off/library (→ default shape without Phase 5)? A capable model reads
all this itself — you are confirming, not teaching it. **Write nothing in Phase 0.**

## Phase 1 — Propose the default shape

Present this and get approval before writing. **Headless / fire-and-forget flow** (operator said
"set up and go", `--print` run, no one to ask): don't stall — proceed with the minimum table below
and *record the plan you would have presented* in your output; the approval gate is for interactive
sessions where the operator is present.

| File | Create now? |
|---|---|
| `CLAUDE.md` (root) | **yes** — project entry-point indexer |
| `.claude/settings.json` | **yes** — permissions + minimal env |
| practice baseline (Phase 2b) | **offer, operator decides** — global `~/.claude/CLAUDE.md` merge (preferred) or `.claude/rules/practice-baseline.md`; skip if already present |
| `.claude/docs/` (Phase 2c) | **yes** — shipped distillation: `workflow.md` + `testing.md` + `docs-discipline.md`, copied verbatim from the kit |
| `docs/ARCHITECTURE.md` + `docs/CODE-MAP.md` | **yes** — real content from the code read in Phase 0, never boilerplate (MVH-on-request: skip) |
| `.claude/agents/` | **no** — built-ins cover it; defer until evidence |
| `.claude/hooks/` | **no** — defer until a recurring pain |
| `.claude/skills/` | **no** — defer until a workflow repeats ≥3× |
| `.claude/commands/` | **no** — defer until requested |
| `.mcp.json` | only if there is a clear external-tool need |

Defaulting to "no" on the machinery rows is the discipline, not timidity. (Phase 5 adds a small,
named, opt-in set of *conventions + artifacts* — not hooks/pipelines — and only for a sustained
build.)

## Phase 2 — Write `CLAUDE.md` (root), ≤ 200 lines

```markdown
# <project> — instructions for Claude Code

## Project context (3–5 lines)
<What it is, who uses it, what "done" usually looks like. No marketing prose.>

## Stack
- Language / framework / package manager / test runner / lint — one line each.

## Conventions
<Only project-specific divergences from stack defaults. "We use PEP 8" is useless;
"we mock HTTP with respx, not unittest.mock" is useful.>

## Working style
- Think first: state assumptions; if multiple readings exist, ask; if unclear, stop and name it.
- Nontrivial task (multi-file, architectural, or ambiguous spec) → switch to plan mode yourself
  for read-only recon before any write — don't wait for the operator to ask (skip in headless
  runs). If already mid-task, say "this deserves a plan first" and stop coding.
- Size the change before you build (default DOWN): trivial→just do · small→acceptance criteria ·
  medium→design-lite paragraph · large (shared invariant / migration / irreversible / unfamiliar
  brownfield) → NON-GOALS line + brownfield recon + upstream design grill — `.claude/docs/workflow.md`.
- Simplicity first: minimum code that solves it; no speculative abstraction or config.
- Surgical changes: touch only what's needed; don't refactor what isn't broken; every changed
  line traces to the request.
- Verify: turn "fix the bug" into "write a failing test, then make it pass"; state a brief plan
  with per-step checks for multi-step work.
- Verification ladder — at the end of a substantive change, run `/code-review` yourself; the higher
  rungs you *propose* instead of just stopping: fresh-context second opinion (separate
  session/subagent prompted to refute — high-stakes or "looks done") → external audit
  (irreversible / security-critical). Recommend one; the operator decides. Rung semantics
  and the full flow — `.claude/docs/workflow.md`.
- Doc-with-code: a change updates its matching doc in the same commit — mapping table in
  `.claude/docs/docs-discipline.md`.
- Big/long tasks: give the full task spec up front in one well-specified turn, decompose into
  independently-verifiable slices, and run at `high`/`xhigh` effort for long-horizon / async work.
```

MVH-on-request: drop the two `.claude/docs/` pointer lines (ladder semantics, doc-with-code)
and the two `.claude/docs/` Reference-materials lines — rules pointing at files that don't
exist are noise (detect-then-prescribe).

The `## Working style` block stays even though the system prompt overlaps it — target model
versions vary and the ~16-line cost buys resilience. Do **not** inflate it to a 60-line treatise.
The plan-mode and verification-ladder lines are **proposal duties, not silent rituals**: their
value is that the *session* surfaces the workflow to the operator (transcript evidence: without
them, sessions never proposed a single ladder rung and coded nontrivial integrations plan-free).

**Front-load full paths.** Whenever CLAUDE.md names a file, give its full repo-relative path —
`apps/web/src/app/page.tsx`, not "the homepage component". Concrete paths save a discovery
tool-call; this applies to `Critical commands` and `Reference materials` too.

Then add these sections (kept short):

```markdown
## Critical commands
​```bash
<install> / <test> / <lint> / <dev server if any>
​```

## What NOT to do
- <specific recurring trap, e.g. "don't edit migrations after merge">

## Reference materials
- docs/ARCHITECTURE.md / docs/CODE-MAP.md / docs/ADR/ / .claude/rules/ (only those that exist)
- .claude/docs/workflow.md — flow: session ritual, plan, verification ladder, continuity
- .claude/docs/testing.md · .claude/docs/docs-discipline.md — invariants (shipped by the kit)
```

**Root `docs/` is part of the default shape**: write `docs/ARCHITECTURE.md` (module map, data
flow, external services — from the code actually read in Phase 0, never boilerplate) and
`docs/CODE-MAP.md` (one line per module: path → responsibility) at bootstrap. Do not wait for
docs to "emerge" — that inverts causality (no docs → no doc rules → docs never appear;
observed in a real bootstrapped product: zero documentation after 8 features). The ongoing
docs rules (doc-with-code mapping, ADR threshold, glossary first-use, owner/last-updated
frontmatter) ship as `.claude/docs/docs-discipline.md` in Phase 2c — CLAUDE.md carries only
the one-line duty pointer, not the rules themselves. `GLOSSARY.md` / `ADR/` / `RUNBOOKS/`
are created on first real entry, not empty. MVH-on-request: skip `docs/` entirely.

## Phase 2b — Transmit the practice baseline

Read `references/practice-baseline.md` and follow its delivery procedure: detect whether the
operator's global `~/.claude/CLAUDE.md` already encodes the behavioral baseline; if not, offer
a global install (confirm first — personal file) or embed it as `.claude/rules/practice-baseline.md`.
The kit's artifacts assume this behavior layer exists; a plugin install alone does not carry it.
Three guards:
- **Dedupe against Working style.** If the global install lands (or the baseline already exists),
  trim the project Working style block to the project-specific deltas (plan-mode duty +
  verification-ladder lines) — don't double-load the same prose from two layers.
- **Headless run:** skip the global offer (no one to approve a personal-file write); embed in
  `.claude/rules/` and record that choice in the output.
- **Retire trigger:** drop the project embed when the global baseline is installed; drop the
  proposal-duty lines if a target model demonstrably proposes plan-mode/ladder steps unprompted.

## Phase 2c — Ship the workflow distillation (`.claude/docs/`)

Copy the kit's three project-docs **verbatim** (including the `shipped-by` provenance header)
from `references/project-docs/` into the project:

- `.claude/docs/workflow.md` — the full flow: session ritual, plan-before-code, red→green work
  cycle, verification-ladder semantics, continuity layers, production posture.
- `.claude/docs/testing.md` — the five stack-agnostic testing invariants + cross-cutting rules.
- `.claude/docs/docs-discipline.md` — doc-with-code mapping table, ADR threshold, glossary,
  frontmatter rules.

Why files in the project and not knowledge in the plugin: skills are a pull channel — a working
session never reads the kit's references; project files are the push channel every session can
open without any skill trigger (transcript-grounded: sessions with the knowledge only in the
plugin proposed zero ladder rungs). Division of labor: CLAUDE.md carries the ~per-turn duty
lines; `.claude/docs/` carries the on-demand depth; the plugin remains the canon.

Rules: copy verbatim — do **not** hand-adapt the content to the project (project facts belong
in CLAUDE.md/features.json; verbatim copies keep re-sync a trivial diff). The provenance header
is the update channel: Audit compares the `shipped-by` version against the installed plugin and
offers a re-sync when the plugin is newer. MVH-on-request: skip this phase.

## Phase 3 — Write `.claude/settings.json`

The deny list matters more than the allow list. Goal: freedom inside a sandbox — most ops
auto-allowed, dangerous ones denied or gated, no blanket `--dangerously-skip-permissions`.

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)", "Bash(ls:*)",
      "Bash(<test-runner>:*)", "Bash(<lint-runner>:*)",
      "Read(./**)", "Edit(./**)", "Glob(./**)", "Grep(./**)"
    ],
    "ask":  [ "Bash(git push:*)", "Bash(git commit --amend:*)", "Bash(git rebase:*)" ],
    "deny": [ "Edit(./secrets/**)", "Edit(./.git/**)",
              "Bash(rm -rf /:*)", "Bash(git push --force:*)" ]
  }
}
```

Tune to what actually exists. If the project uses MCP, gate it via `enabledMcpjsonServers`.

**`.env` — distinguish secret-bearing from dev-only before denying it.** A blanket
`deny: Edit(./.env*)` looks safe but, in a dev-only project, it blocks the agent from creating
the very `.env` its integration tests need — the agent ends up smuggling creds through env-var
prefixes on every command (worse ergonomics, no real safety gain). Decide per project: if `.env`
would hold *production* secrets → deny it; if it holds *dev-only* creds (local DB container, a
local LLM) → **allow it, gitignore it, and add a one-line "no prod creds in `.env`" rule** instead.
The mechanical guard that matters most is `.gitignore` + the secret never reaching a shared remote,
not blocking the file the agent legitimately needs to run.

**Rewrite-with-donors:** when the project rewrites an existing system, pin donor/reference
repos read-only *mechanically* — `allow: Read(//abs/path/**)` plus `deny: Edit(//abs/path/**)`,
`Write(//abs/path/**)` (`//` = absolute path). A deny rule survives context loss; in live use
the same mechanism also blocked a credential-file write that prompt-discipline had missed.

## Phase 4 — (Optional) `.claude/rules/` for hard invariants

Only if there are *non-negotiable* invariants the model must respect even when inconvenient
(e.g. "PII fields must never be logged"). Each rule ≤ 30 lines, prescriptive, referenced from
CLAUDE.md. If it needs more than 30 lines it is guidance — put it in `docs/CONVENTIONS.md`.
One sanctioned exception: `.claude/rules/practice-baseline.md` (Phase 2b fallback, ~60 lines) —
a transmitted behavioral layer, not a project invariant; retired if the baseline goes global.

## Phase 5 — Long-running build kit (only for a sustained, multi-session product build)

Skip this for libraries, scripts, and short tasks — deploying it there is the over-scaffolding the
headline principle forbids. Deploy it when the project is a product built feature-by-feature over
many sessions: this is the regime where a capable model's lead is largest, and where "looks done",
context anxiety, and loss of coherence (the three failure modes in *Harness design for long-running
apps*, T1) actually bite. It is **conventions + a few prepared artifacts**, not hooks or pipelines.
Source: *Effective harnesses for long-running agents* (T1) and *Harness design for long-running
apps* (T1). Set up:

1. **Runnable oracle + env init** — an `init.sh` (or documented one-liner) that starts the app and
   runs basic end-to-end / test verification. The single most important long-horizon enabler: the
   agent closes its own loop against it instead of "looks done". *"Run verification tests at session
   start to catch undocumented bugs."* For web apps, wire **browser automation** (Playwright/Puppeteer
   MCP) so the evaluator can *"click through the running application the way a user would."*
   For non-web products define a **domain oracle** instead: golden inputs → expected outputs,
   **negative cases included** (a negative golden case has caught a latent donor-code bug that
   every positive test missed).
   **Session 0 establishes a green baseline:** add any missing test/lint config + one trivial passing
   test (and a no-empty-tests guard, **per runner**: vitest — `--passWithNoTests`; pytest has no such
   flag and **exits 5 on an empty suite** — that exit 5 is non-zero, so a naive `pytest || fail` in
   init.sh mis-reports an empty suite as a failure; the guard *is* the one trivial smoke test that
   makes the suite non-empty; jest — `--passWithNoTests`) so the oracle runs *green* from the first
   session — an oracle that is red on day 0 emits false-alarm signal until fixed.
   **Python venv — resolve each tool independently, never a blanket `.venv/bin/` prefix on the whole
   command.** For each of `pytest` / `ruff` / `mypy` / `pip`: use `.venv/bin/<tool>` if it exists, else
   the tool on `PATH` (`PYTEST=.venv/bin/pytest; [ -x "$PYTEST" ] || PYTEST=pytest`). A blanket prefix
   breaks the moment one tool is installed global-only or venv-only; per-tool resolution survives both.
2. **Feature spec as a checkable list** — a `features.json` (or `.md`) of small features. **Copy this
   canonical shape verbatim** — don't reinvent field names (the recurring drift is
   `{description, steps, passes}` vs `{title, acceptance, verify}`; the one canon is `title` = one-line
   handle, `description` = the contract prose, `verify[]` = the single verification-array, never
   `steps`/`acceptance`):

   ```json
   {"project": "acme-api", "milestone": "v1-auth",
    "rules": ["one feature at a time; flip passes only when verified e2e", "never edit/delete a test for green"],
    "features": [{"id": "F1", "title": "Login with email + password",
      "description": "POST /auth/login returns a signed JWT; a wrong password returns 401 without leaking which field failed.",
      "verify": ["pytest tests/test_auth.py::test_login_success", "pytest tests/test_auth.py::test_login_wrong_password asserts 401"],
      "passes": false, "preconditions": ["postgres up: docker compose up -d db", "TEST_DB_URL exported"]}]}
   ```

   All features seed at `passes: false`. Work **one feature at a time**; flip
   `passes` only when verified. *"It is unacceptable to remove or edit tests."* Write verification
   steps as **explicit contracts** (what is required vs defaulted, negative cases included) —
   vague steps make each session take silent micro-decisions. Add `preconditions` (services/env
   the operator must provide, e.g. a live DB container) so a session checks them before starting.
   **Keep kit artifacts under `.claude/`** (`.claude/features.json`, `.claude/harness-journal.md`,
   `.claude/progress/`, `.claude/devlog/`) — only genuine product files (`CLAUDE.md`, `init.sh`,
   build manifests) belong at the repo root. A root cluttered with control files reads as mess to
   the operator and obscures what's product vs harness; point CLAUDE.md at the `.claude/` paths.
3. **Progress + checkpoint discipline** — a progress file, **preferably `.claude/progress/<slug>.md`**
   (keeping it under `.claude/` means any state-surfacing automation the operator may have —
   e.g. a personal SessionStart hook, which this kit does **not** ship — finds it; a root
   `claude-progress.txt` stays invisible to such tooling), updated each session (state, decisions,
   remaining work, next steps); a one-line `Quick state — <facts>` heading keeps it scannable
   at session start. **Also keep an episodic record** — a project devlog
   (`.claude/devlog/entries/`, one entry per feature/decision) or, where the project already
   keeps "what changed and why" in disciplined commit messages, lean on that: the layer is the
   requirement, the carrier is a default, not a mandate. The episodic layer is separate from
   in-flight progress and is what makes state legible to the human operator, not only to the
   agent. Number sessions sequentially. **Git commit per feature** with a descriptive message. Files are the authoritative
   handoff state — they survive compaction and a fresh-session reset (which the long-running-apps
   guidance prefers over compaction alone). **A handoff note is a claim, not a fact: re-verify it.**
   When a progress/next-step note asserts "verified" or names a ready fix, the consuming session
   must re-run it before relying on it — a fix asserted but never executed is a looks-done trap
   (a handoff "NFKC closes both cases" once proved wrong on execution: it missed zero-width chars).
   Phrase queued fixes as *"reproduce → close"*, not as finished solutions.
4. **Session-start ritual** (put in CLAUDE.md or `init.sh`): `pwd` → read git log + progress file →
   read feature list, pick the highest-priority incomplete feature → run init/e2e → work that one
   feature.
5. **Fresh-context Evaluator for high-stakes verification** — for silent-wrong-is-costly work, judge
   with a *separate* context (new session or subagent) that tests the running app, not an in-context
   self-recheck. *Self-preferential bias* — "models confidently praise their own work" — is exactly
   why author ≠ evaluator. Opt-in; skip for typo/single-file/doc work. Name this option in CLAUDE.md
   in one line so it's discoverable when a high-stakes feature lands. Per-change, not occasional,
   for silent-wrong-prone components (parsers, guards, invariant refactors); opt-in elsewhere.
   Worth running periodically
   on *accepted* features too, not only flagged ones — a fresh-context audit of an already-green
   feature has caught a HIGH defect the author's oracle missed; have the audit write its findings
   as actionable items straight into the progress file's next steps (they then close in one
   red→green cycle). Two refinements learned the hard way:
   - **External beats self-ordered.** An Evaluator the author session spawns itself partially
     inherits that session's framing — it closed the holes *it* was thinking about but missed a
     whole class (a self-ordered security Evaluator passed a denylist that a fully-external audit
     then broke via Unicode-obfuscated input). For security/correctness-critical features, prefer
     an evaluator initiated *outside* the author session (a fresh operator session or a separate
     audit pass), not a subagent the author orchestrates.
   - **The auditor must execute, not just read.** A reader-only audit (git + files) reached a
     harsher, partly-wrong verdict than one that ran the live stack: it flagged golden test
     numbers as "unproven" while an executing audit re-derived them against the real system and
     they matched exactly. So (a) the verifying audit should run the artifact, and (b) capture
     **provenance** for golden/e2e expectations — store the source query's actual output beside
     the test, so correctness is legible from the artifact instead of requiring a live re-run.

6. **Docs depth for the long build** — `docs/ARCHITECTURE.md` + `docs/CODE-MAP.md` already
   exist from the default shape (Phase 2); for a sustained build additionally keep them
   load-bearing: deep architecture prose lives there (CLAUDE.md stays an indexer and links it),
   conscious limitations are recorded as decisions, and the first operational procedure
   (deploy / recovery / data migration) opens `docs/RUNBOOKS/`.

7. **Scope a campaign's protocol to its directory (multi-campaign / large-feature regime).** When
   a project runs more than one multi-session campaign — or one big feature area — do **not** grow
   root CLAUDE.md with every campaign's conventions (that taxes every turn project-wide). Give the
   campaign its own directory with a **nested `CLAUDE.md`** carrying its protocol; it is delivered
   **deterministically and scoped** — only when a session works on files in that directory (reliable
   mechanism, not `paths:` frontmatter — see `native-capabilities.md` Memory §). Skeleton:
   `campaigns/<slug>/{CLAUDE.md, spec.md, backlog.md, archive/}`. The campaign `CLAUDE.md` states:
   the **single entry-point** (point at `.claude/progress/<slug>.md` from item 3 — do **not** invent
   a second progress file), backlog discipline, the one-feature-at-a-time + verify cycle, and the
   **lifecycle rule** below. Write it as a legitimate convention, never an injection-shaped imperative.
   - **Lifecycle live→archive (anti-fragmentation).** Superseded specs/audits/execution-prompts move
     into `<campaign>/archive/`; the live layer stays small. Accumulated dead weight + duplicate
     editable canons are exactly what makes a multi-session campaign illegible (real case: campaign
     state fragmented across 4–6 places and formats, two hand-edited backlog canons that drifted).
   - **Don't force a single backlog canon.** Keeping the task-list in one editable file is simpler,
     but it is *not* a required invariant: under a capable model a markdown canon + a generated/mirror
     JSON stay consistent **when the protocol is reliably delivered** (A/B: drift=0 across N=3 dual-canon
     runs, even without re-stating the rule each session). The lever is reliable scoped delivery, not
     the data structure — pick one editable canon for simplicity and move on; don't build mirror-sync
     machinery.

Keep it minimal and **strip as the model improves**: *"find the simplest solution possible, and only
increase complexity when needed"* (T1). On a major model release, re-test whether each kit component
still earns its place (e.g. Opus 4.6 removed sprint-decomposition that 4.5 needed) before keeping it.

## Phase 6 — Stop

No hooks, agents, skills, or commands yet. The default shape (indexer + settings + offered
baseline + shipped `.claude/docs/` + `docs/ARCHITECTURE.md`/`CODE-MAP.md`) is the harness most
projects need forever; for a sustained build, Phase 5's conventions are the spine — still no
custom subagents/hooks until a trigger earns them.

## Phase 7 — Verify

```bash
claude --print "what is the project's stack?"  # pass = answer matches CLAUDE.md, not a guess
claude --print "what files are you not allowed to touch here?"  # pass = names the deny/ask rules from settings.json
grep -ci "plan mode" CLAUDE.md && grep -ci "fresh-context" CLAUDE.md && grep -ci "size the change" CLAUDE.md
ls .claude/docs/workflow.md .claude/docs/testing.md .claude/docs/docs-discipline.md docs/ARCHITECTURE.md docs/CODE-MAP.md
# pass = greps all ≥1 (plan-mode duty + verification ladder + change-sizing landed in CLAUDE.md) and all five
# shipped/authored docs exist. This is the write-through check — it catches instructions that
# stayed in the kit's references instead of landing in the project (e.g. a skipped evaluator
# line). It is mechanical on purpose: a behavioral probe (`claude --print "what happens next
# after a feature?"`) is contaminated by the operator's global baseline once Phase 2b installs
# it — the union of layers answers correctly even when the project file is missing the lines.
# MVH-on-request projects: only the two greps apply.
```

Each check has a crisp criterion — "command produced output" is not a pass.

If a test/lint command or `init.sh` was named, **run it once and confirm it actually executes**
(the oracle must be real, not aspirational) — a runnable check the agent can close the loop against
is the difference between long-horizon autonomy and drift. Running it will prompt for permission
on first use — expected first-run approval; don't skip the run because of the prompt.

## Optional next steps (only after the trigger fires)

| Trigger | Add |
|---|---|
| A convention Claude gets wrong twice | a line in CLAUDE.md |
| The same multi-step ritual typed 3×+ | a skill (`disable-model-invocation` if side-effecting) |
| Something must happen every time | a hook (block at submit, never mid-write) |
| "Claude claims done when it isn't" | verification ladder: in-prompt check → `/goal` → Stop hook (deterministic gate on mechanical tests/lint/types) → `/code-review` on substantive change → fresh-context second opinion (next row) |
| High-stakes deliverable where silent-wrong is costly (security, migration, untrusted-input parser, invariant refactor) | a **fresh-context** Evaluator (separate subagent or a new session) — see Phase 5, item 5. The lever is the fresh, un-anchored context, not an in-context "re-check yourself" pass — per-change for this class, not one-time |
| Codebase-scale sweep / migration / trust-critical audit that exceeds one context | route to a **dynamic workflow** (keyword `ultracode`) — do not build a custom pipeline |
| External service (DB, browser, monitoring) | an MCP server in `.mcp.json` |

## Anti-patterns in bootstrap

❌ a custom orchestrator subagent · ❌ five hooks "for hygiene" · ❌ a 600-line copied CLAUDE.md ·
❌ a prescriptive language/stack preset the model didn't need · ❌ a blocking Stop hook on day one ·
❌ `--dangerously-skip-permissions` · ❌ deploying the Phase 5 kit on a library/one-off (over-scaffolding) ·
❌ treating bootstrap as one-shot (the harness evolves; the starting state is the default shape —
documents and conventions, no machinery — and the kit is stripped back as the model improves).
