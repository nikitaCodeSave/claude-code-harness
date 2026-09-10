<!-- shipped-by: claude-code-harness v1.28.0 — do not hand-evolve in the project;
     improvements flow through the plugin (re-synced on audit). Project-specific
     facts live in CLAUDE.md, not here. -->

# Workflow — the spec is the unit of work

Operational depth behind the duty lines in CLAUDE.md. Read the section you need
when the trigger fires; this file is on-demand, not per-turn context.

## The agreement, written with the operator

Truth is the code plus the spec you wrote together. Before non-trivial work,
write `specs/<slug>.md` **with** the operator — ask only the questions whose
answers change the work, then record five things and nothing else:

- **Why** — whose problem, what changes. The reason is what settles the details
  nobody specified.
- **What** — observable behavior, not implementation.
- **Constraints** — each marked `[hard]` (non-negotiable) or `[soft]` (may be
  traded away for simplicity — that mark is an explicit licence to simplify, not
  decoration). State them as invariants, not steps: "the operation is
  idempotent", never "add a dedup table".
- **Done when** — an executable command with its expected result. **If it isn't
  executable, the spec isn't ready to work from.** This is the one gate.
- **Not doing** — explicit non-goals, so scope cannot drift silently.

**Specify *what* and *why*; leave *how* to the implementer.** Detector: a detail
that moves business risk or architecture goes in; class names, file paths, table
schemas, library choices stay out — those are the implementer's call and beat a
guess frozen into the spec. The conversation a spec grows out of always carries
implementation asides; without the detector they settle into the binding
sections and start standing in for the requirement.

**Phase lists and step-by-step plans do not belong in a spec.** Planning against
the real code beats a plan written in advance for it. A spec that accretes a
journal stops being an agreement: measured on a production repository, the
declared acceptance section drifted 970 lines away from the threshold actually
in force, and new ratified scope was written *into* the journal because the file
had nowhere else to put it.

Match effort to blast radius, default DOWN. Trivial (typo, one line) → just do
it. Small (one file, clear ask) → acceptance criteria, no file. Anything that
crosses a shared invariant, migrates data, is irreversible, or lands in an
unfamiliar brownfield subsystem → a spec.

**Brownfield recon before touching a shared invariant**: read-only mapping with
the built-in **Explore** agent (map · invariants · blast radius), stated in the
answer. Keep it in context; persist it only if the operator asks.

## Work

- One unit at a time. Call it done only after **every** verification step ran,
  negative cases included.
- Work test-first by default; red→green is the default, not dogma — see
  `testing.md` rule 2 for what actually matters.
- **A handoff note is a claim, not a fact.** "Verified" written by a past session
  is re-executed before you rely on it. Phrase queued fixes as "reproduce →
  close".
- **Exercise runtime-critical paths on real input before you freeze the design.**
  For probabilistic / IO-heavy / data-shape-dependent code (model calls,
  pipelines, aggregation, parsers), a green test on mocked data does not cover
  real-corpus edge cases. Run the path on representative real input *before*
  committing to a design, not after a deploy surfaces the edge case.
- **Stop at 2–3 failed iterations on one hypothesis and escalate — don't
  improvise.** Say what you tried, what failed, and what you need: a decision
  only the owner can make, a credential, a service that is down. An agent with
  no escalation route invents a workaround, and a workaround for a missing
  permission is the expensive kind.
- Doc-with-code: the same commit updates the **oracle** its diff touches — the
  test, the type, the schema — and a document only where the claim has no oracle
  (`docs-discipline.md`, rules 0–1).

## Verification ladder (after each substantive change)

Run the rungs in order; escalate by stakes — and **name the chosen rung to the
operator**:

| Rung | When | How |
|---|---|---|
| Self-verify | always | oracle green + lint/types + end-to-end check of the actual behavior ("looks done" ≠ "is done") |
| `/code-review` | substantive diff | run it yourself at the end of the change |
| Fresh-context second opinion | high-stakes, "looks done", silent-wrong-is-costly; **per-change** for silent-wrong-prone components (parsers/rewriters of untrusted input, guards/validators, invariant refactors) | a separate session or subagent prompted to **refute**, not confirm — the author anchors on its own solution. Prefer a refuter initiated **outside** the authoring session: a self-commissioned evaluator partly inherits your framing. Also usable UPSTREAM on a large irreversible design decision before you freeze it |
| External audit | milestone closed / correctness-critical / irreversible | by what carries the risk: **the change** → `/code-review ultra`; **the deliverable** → a new session that audits the scope and **executes** the live stack. Executed evidence beats read evidence |

Triage what a refuter returns, don't relay it: findings arrive mixed with
accepted residuals and with adversarial angles the component is not built to
resist. Reproduce each one yourself as a failing test before fixing it — the
reviewer's output is a hypothesis. For guard/validator/parser work, "verify
passed" and "the invariant holds" are different claims: the suite proves the
cases it encodes, the invariant lives in adversarial input space.

## Where things stand between sessions

**The open spec is the continuity layer.** It states what must become true and
what is still missing; a closed spec is history in git. Report a stopped unit as
**"blocked on X, and here is who unblocks it"** — a different state from "not
done yet", and a tracker that cannot tell them apart makes the next session burn
a cycle rediscovering the wall.

Do **not** add a parallel journal. Where the project already keeps one —
descriptive commits, a devlog, a tracker, a workspace convention — meet it
there. A carrier that is not already earning its keep is not introduced: measured
across a live estate, prescriptive journal formats were adopted in a minority of
projects and, where continuity was genuinely valued, it had been reinvented more
cheaply. What survives the session is state on disk, not a specific layout.

Durable knowledge lives in artifacts (spec / ADR / the project's own carrier),
never only in chat.

## Production posture (day 0, not "later")

- Secrets are **never echoed into code, logs, tests or replies** — not even for a
  debug line, because the line outlives the debugging session. Secret-bearing
  paths get `permissions.deny` entries the moment they are named.
- Known limitations (retention, scale ceilings, missing hardening) are written
  down in `docs/ARCHITECTURE.md` as conscious decisions — an undocumented
  limitation is a future incident, a documented one is a backlog item.
- Every unit's verify contract includes negative cases and degradation paths
  (service down, malformed input, missing system dependency).
- Operational entry points (run, logs, read-only data access) are documented in
  CLAUDE.md / RUNBOOKS so an incident doesn't start with archaeology.
