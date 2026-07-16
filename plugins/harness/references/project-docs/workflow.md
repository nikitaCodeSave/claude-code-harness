<!-- shipped-by: claude-code-harness v1.16.1 — do not hand-evolve in the project;
     improvements flow through the plugin (re-synced on audit). Project-specific
     facts live in CLAUDE.md (and features.json, if present), not here. -->

# Workflow — the professional development flow

Operational depth behind the duty lines in CLAUDE.md. Read the section you need
when the trigger fires; this file is on-demand, not per-turn context.

## Session start (every working session)

1. `git log --oneline -10` + read `.claude/progress/` — restore state.
2. Read `.claude/features.json` (if present) — take **one** highest-priority open feature;
   skip `blocked: true` entries — they wait on what `blocked_reason` names, not on another attempt.
3. Run the oracle — the verification command CLAUDE.md names (`make check` / the test suite /
   `scripts/init.sh`). Confirm the baseline is green *before* changing code.
4. A handoff note is a **claim, not a fact**: "verified" written by a past session must be
   re-executed before you rely on it. Phrase queued fixes as "reproduce → close".

## Size the change before you build

Match upstream effort to blast-radius; default DOWN. Most work is trivial/small/medium and
goes almost straight to Plan — the full gate set is the exception, not a ritual.

- **trivial** (1-line, typo) → straight to Work. **small** (one file, clear spec) → acceptance
  criteria only. **medium** (multi-file or one real design choice) → a design-lite paragraph in
  the plan (data model + the one real alternative you rejected). **large** (crosses a shared
  invariant, migration, irreversible, or an unfamiliar brownfield subsystem) → the gates below.
- **NON-GOALS**: a large change freezes scope with an explicit "what we deliberately do NOT do"
  line before Work — the always-skipped item that stops scope drift. (Hygiene, not a halting gate.)
- **Brownfield recon**: before touching a shared invariant on an existing subsystem, do read-only
  recon with the built-in **Explore** agent (map · invariants · blast-radius) and state what
  breaks. Keep it in context — persist it only if the operator asks; no per-feature doc.
- **Design before you freeze**: for a large, irreversible decision, grill the design with a
  fresh-context pass BEFORE committing — same refuter as the verification ladder, aimed upstream,
  with the mandate "kill ≥1 alternative with a concrete failure scenario or cost." Then record the
  winner in an ADR. Anything smaller: skip this — a rejected-alternative sentence in the plan is enough.

## Plan before code

- Nontrivial task (multi-file, architectural, ambiguous spec) → do read-only recon and produce
  a plan decomposed into **independently verifiable slices**, each with its own check. Use plan
  mode for the recon **unless the project defines its own planning ritual** (e.g. a planning
  skill) — then follow that, it overrides this default. Skip in headless runs.
- Before writing code, grep for an analogous pattern already in the codebase and the
  dependencies of what you'll touch — extend the existing approach instead of duplicating it.
- State assumptions explicitly; if multiple readings exist, present them — don't pick silently.
- If you are already mid-implementation and realize the task is nontrivial — say so and stop
  coding until a plan exists.

## Work (one feature at a time)

- Work test-first by default: write the failing test, commit it, then implement until green
  (red→green is the default, not dogma — see `testing.md` rule 2 for what actually matters).
  Never weaken or delete a test to get green.
- One feature per cycle; `passes: true` in the ledger only after **every** verify step ran,
  negative cases included. When verify hits a wall outside your reach (missing creds, an
  operator-only service, a third-party dependency), record `blocked: true` +
  `blocked_reason: "<what unblocks it, and who>"` beside `passes: false` — a bare
  `passes: false` cannot tell "cannot proceed here" from "not done yet", and the next
  session will burn a cycle rediscovering the wall. Never flip `passes` on partial verify.
  Before recording `blocked`, verify every layer you *can* reach below the wall (unit /
  service-layer / stubbed-boundary dispatch) — `blocked` describes the last mile, not the
  whole feature. Route the narrative (what ran green, what stays quarantined for whom) to
  the feature's `notes` or the progress file — never invent ad-hoc ledger fields or root
  handoff files.
- Git commit per feature with a descriptive message. Doc-with-code: the same commit updates
  the docs its diff touches (mapping table — `docs-discipline.md`).
- **Exercise runtime-critical paths on real input before fixing the design.** For
  probabilistic / IO-heavy / data-shape-dependent code (LLM calls, pipelines, aggregation,
  parsers), a green test on mocked data does not cover real-corpus edge cases — run the path
  on representative real input *before* committing to a design, not after a deploy surfaces
  the edge case. The project CLAUDE.md names the concrete command for this stack.
- **When stuck, stop at 2–3 failed iterations** and surface the blocker rather than thrashing.
  Read the full error and understand the cause before retrying; a change that breaks many
  things is a signal the approach is wrong, not that it needs more patches.

## Verification ladder (after each substantive change)

Run the rungs in order; escalate by stakes — and **name the chosen rung to the operator**:

| Rung | When | How |
|---|---|---|
| Self-verify | always | oracle green + lint/types + end-to-end check of the actual behavior ("looks done" ≠ "is done") |
| `/code-review` | substantive diff | run it yourself at the end of the change (it reviews the working diff; `/review` is PR-review — verify the surface exists in your session's `/`-autocomplete) |
| Fresh-context second opinion | high-stakes, "looks done", silent-wrong-is-costly; **per-change** for silent-wrong-prone components (parsers/rewriters of untrusted input, guards/validators, invariant refactors) | separate session or subagent prompted to **refute**, not confirm — the author anchors on its own solution. For the silent-wrong class, prefer a refuter **initiated outside the authoring session** (fresh session / external audit) over a subagent you spawn: a self-commissioned evaluator partly inherits your framing (one passed a denylist that an external pass then broke with Unicode-obfuscated input). Also usable UPSTREAM on a large/irreversible design decision before you freeze it — grill it to kill ≥1 alternative with a concrete failure scenario or cost |
| External audit | milestone closed / security-correctness-critical / irreversible | operator opens a **new** session and runs `/claude-code-harness:external-audit <scope>` (requires the claude-code-harness plugin; without it — a fresh session prompted to refute, the rung above); executed evidence beats read evidence |

Periodically worth running on *accepted* features too — fresh-context audits have caught
HIGH defects in already-green code. For guard/validator/parser features, "verify passed" and
"the invariant holds" are different claims: the suite proves the cases it encodes, while the
invariant lives in adversarial input space — a ledger has stood at all-green while an external
audit refuted the invariant with an input class the suite never encoded. The refuter's mandate
is the invariant, not the diff.

## Continuity (what survives the session)

The lever is **state-on-disk, not a specific file layout** — if the project already keeps
continuity elsewhere (descriptive git commits, a workspace/notes convention, structured
memory), meet it there instead of adding a parallel store. The conventions below are the
kit's default carriers, not a mandate:

- `.claude/progress/<slug>.md` — the in-flight layer, in either of two legitimate shapes:
  **task-scoped** (state of one bounded task: what's done, what's stuck, next steps — closes
  when the task does) or a **workstream snapshot** (a long-lived rolling picture of one
  workstream's *current* state + open threads; episodic history goes to the devlog, and the
  file is pruned, not appended, so it stays a snapshot). Update before ending a session;
  one-line `Quick state — <facts>` heading on top.
- `.claude/devlog/entries/NNNN-<slug>.md` — one entry per feature/fix/decision: what changed
  and why. Episodic layer, distinct from progress; written when the change lands, converted
  from the progress file when a long task closes.
- Durable knowledge lives in artifacts (ADR / docs / devlog), never only in chat.

**Closing a long task** (task-scoped progress; a workstream snapshot doesn't close — it gets
pruned back to current state):
1. Verify every closed feature has its episodic record (devlog entry or equivalent) — it
   outlives the progress file.
2. Confirm features.json (if present) marks them done (passes:true).
3. Make the terminal state legible: set `Quick state → CLOSED` or delete the file — both are
   valid ends (closed history lives in devlog + git); what matters is that a finished task's
   file no longer reads as active work.

## Production posture (day 0, not "later")

- Secrets: never committed, never echoed into code/logs/tests/replies; secret-bearing paths
  get `permissions.deny` entries the moment they are named.
- Known limitations (retention, scale ceilings, missing hardening) are **written down** in
  `docs/ARCHITECTURE.md` as conscious decisions — an undocumented limitation is a future
  incident, a documented one is a backlog item.
- Every feature's verify contract includes negative cases and degradation paths (service
  down, malformed input, missing system dependency) — a bot that "works on the happy path"
  is not releasable.
- Operational entry points (run, logs, read-only data access) are documented in CLAUDE.md /
  RUNBOOKS so an incident doesn't start with archaeology.
