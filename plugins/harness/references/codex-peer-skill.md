# Cross-vendor refuter — the `codex-peer` skill the kit delivers on consent

The verification ladder's top rung is a fresh context that judges the deliverable
(`harness-discipline.md`, `project-docs/workflow.md`). A same-family refuter is *fresh* but not
*foreign*: it was trained the way the author was, so a share of the author's blind spots travels
with it. A reviewer from **another vendor** carries neither the author's code nor the author's
notion of "an accepted residual".

Codex CLI can run as an MCP server, and Claude Code can be its client — which makes that reviewer
reachable from an ordinary session, on the operator's own subscription, with no API key and no
managed agents (so principle 9, "CLI-subscription only", is untouched: it governs how Anthropic
models are reached, not which CLIs exist on the machine).

**This is an upgrade of an existing rung for operators who already run a second vendor — never a
reason to acquire one.** The rung that ships is the native `code-refuter`; it is the default and
it is sufficient. The material below is therefore *not* a live skill inside the plugin: a plugin
skill's description loads into every consumer's session, including the majority who have no Codex,
and that reads as "install another CLI" while costing them tokens. It is delivered to disk only
after a positive detection and an explicit yes — the same channel as `practice-baseline.md` and
`project-docs/*`.

## Delivery procedure

1. **One gate, evaluated before this file is opened.** `bootstrap-checklist.md` Phase 2b states it
   in full so the majority case never loads these pages: **a Codex MCP server is already
   registered** — it is named by `claude mcp list`. One probe, and it is the authoritative one:
   registrations do not all live in one file, so grepping a config path answers the wrong question.
   - **`codex` merely present on PATH does not open the gate.** An unwired CLI means the operator
     has not chosen this; offering to wire it is the recommendation the gate exists to prevent.
     They can still ask by name — `operator-playbook.md` §6 carries the phrase and the one-line
     `claude mcp add` for a human who decides to.
   - **Negative → do not raise any of this.** Not as a suggestion, not as a "you could also", not
     in the run summary. (What a human finds by reading the playbook end to end is their own
     business — the gate governs what a session *says*, which is the part that reads as advice.)
   - Already installed (a `codex-peer` skill on disk) → the operator opted in at some point, so
     this is a re-sync question and the gate does not apply: see *Keeping installed copies
     current*.
2. **Offer, stating the radius.** Two homes, and the operator picks:
   - `<config-dir>/skills/codex-peer/SKILL.md` — **recommended**, because the MCP server itself is
     wired at user scope; a project embed would have to be re-delivered in every repo. It is the
     operator's personal profile, so it is written **only on explicit approval in this
     conversation**: show the text, back up any existing file to `SKILL.md.bak-<YYYY-MM-DD>`
     first. In a headless run this path does not exist — nobody is present to approve it.
   - `.claude/skills/codex-peer/SKILL.md` — the zero-blast-radius alternative: in git, reviewable,
     deletable, scoped to one repo.
3. **Write the canonical block verbatim**, including its content-version stamp — which belongs
   **below** the closing `---`, never above the frontmatter. YAML frontmatter is only recognised at
   the very start of the file: a comment placed first makes the loader take *that line* as the
   skill's description, so the skill keeps loading, keeps counting, and never triggers, with the
   comment showing where the description should be (reproduced live, 2026-08-01 — this is why the
   `practice-baseline.md` stamp convention could not simply be copied here: its target file has no
   frontmatter). Then say which path was taken in the run summary.
4. **Never wire, rewire, or reconfigure the MCP server.** The gate already required it to exist;
   its configuration is the operator's, and a session that "fixes" it is editing user-scope config
   nobody asked it to touch.

**Why this one is allowed to carry a vendor's call shape when `project-docs/*` may not.** The
content-gate in `SKILL.md` (durable principles and stable affordances only, no perishable
platform facts) governs files that ship **unconditionally, to everyone, verbatim, into projects
that cannot re-verify the claim** — the reader may not even have the thing the fact is about. This
block inverts every one of those conditions: it reaches only an operator who already runs the tool
locally, so a stale line is falsifiable by them in one command, not a mystery. The exemption is
that difference, not convenience — and it is paid for with a real maintenance trigger
(`SKILL.md`, Maintenance), because the kit's own finding stands: an inline expiry badge with no
runner behind it rots silently.

## The canonical block (copy as-is)

````markdown
---
name: codex-peer
description: >-
  Use Codex CLI, attached to Claude Code as an MCP server, as an independent
  cross-vendor reviewer of your own work. Trigger when a deliverable needs a
  fresh context that does not share the author's priors — a second opinion, an
  independent check of an implementation, "let Codex look at this" — and
  proactively, without being asked, for the silent-wrong class: parsers and
  rewriters of untrusted input, guards and validators, invariant-preserving
  refactors. Also when stuck: a different vendor instead of another attempt in
  the same context. Covers the call shape (sandbox, effort, threads), what to do
  with the output, and why the loop does not converge on its own.
---
<!-- codex-peer content-version: claude-code-harness v1.20.0 — the re-sync key; advances only
     when this block's text changes. It sits BELOW the frontmatter on purpose: a comment placed
     above it is taken as the description itself, and the skill loses its whole trigger surface. -->

# Codex as a cross-vendor refuter

Codex CLI runs as an MCP server (`codex mcp-server`); Claude Code is the client. The tools appear
as `mcp__<server>__codex` (new session) and `mcp__<server>__codex-reply` (continue a thread) —
`<server>` is whatever name the server was registered under. If they are deferred, load them with
`ToolSearch` before calling.

This is the verification ladder's top rung executed by a different model family. It does not
replace your own testing, and it does not replace `/code-review`.

## The review call

```json
{
  "prompt": "Review the implementation of X and list the ways it can be wrong. The goal is to refute correctness, not to confirm it.",
  "cwd": "/absolute/path/to/the/project",
  "sandbox": "read-only",
  "config": { "model_reasoning_effort": "high" }
}
```

- **Parameter names are hyphenated**, not camelCase (`approval-policy`, `base-instructions`).
- **`sandbox: "read-only"` for every review.** Not distrust — a reviewer has no need to write, so
  the narrowest sandbox is free.
- **Effort has no dedicated parameter**: it goes through `config` as
  `model_reasoning_effort`. `config` accepts any `config.toml` key, so it is also the escape hatch
  for anything else the tool schema does not surface.
- **Prompt for refutation, not confirmation.** Asked to confirm, it agrees politely and you learn
  nothing.
- **Continue in-thread with `codex-reply`** (`prompt` + `threadId`; the id comes back in the
  previous call's `structuredContent`). A thread already holding the task context is cheaper and
  better than restating it. The `conversationId` field is deprecated — don't use it.
- **A long call is auto-backgrounded** and returns as a notification; the session is not blocked.
  Don't retry it because it "hung", and don't ask for a timeout to be set — you will cut the call
  off mid-work.
- **Keep the output small.** For anything large, have it write files and return a short summary —
  a big result is spent from the *reading* session's context.

## Phrasing: moderation rejects security vocabulary

A request written in attack terms — "bypasses", "destructive commands", "holes" — can be rejected
wholesale by the other vendor's moderation before it runs. The same question phrased neutrally —
"parsing errors", "cases where the two versions disagree", "where the new version answers more
permissively" — goes through, and loses nothing: the reviewer still hunts for the same misses.
This bites hardest on exactly the components most worth reviewing, because they are defensive ones.

## What to do with the answer

- **Triage; do not relay.** Real defects arrive mixed with residuals the project already accepted
  and with adversarial cases the component's threat model deliberately excludes. Passing the list
  on as-is manufactures work: in the grounding episode, 16 raw findings were 5 real ones.
- **Reproduce every finding yourself, with a failing test, before fixing.** Another vendor's agent
  is wrong in the same ways yours is. Its output is a hypothesis, and an unreproduced hypothesis
  is not a defect.
- **The find→fix→refute loop does not converge on its own.** Each round finds something new,
  including regressions introduced by the previous round's fixes. The stop signal is not "it said
  clean" — it will not say that. Stop when findings stop being regressions and hangs.
- **Keep an objective layer beside it.** A differential run of the old and new versions over a
  real input corpus terminates and gives a countable answer; a reviewer does neither. Use the
  reviewer to *find* candidates and the objective layer to *decide*.
- **Ask it directly** whether this pass's findings are of the same order as the last one's or
  already rare corners. It answers that honestly instead of playing along.

## Surface drift — check it, don't trust it

The call-shape section above describes another vendor's tool, which moves on its own schedule and
is tracked by nobody on this side. The discipline sections are durable; that one is not.

**On the first rejected or ignored argument, stop guessing and read the live schema** — the server
answers `tools/list` with the current parameter names and enums, and that answer outranks this
file. Then correct the file: it is yours now, on your disk. A call that fails on an argument name
is the trigger; there is nothing to check on a schedule.
````

## Keeping installed copies current

The block carries a content-version stamp with the same semantics as the `project-docs`
`shipped-by` headers: it advances **only** when the block's text changes, never on an unrelated
plugin release.

- **Project embed** — Audit compares the stamp against the canonical block's and offers a re-sync,
  showing the diff first; a non-stamp delta is a potential hand-edit to preserve.
- **Global copy** — no automation touches the personal profile. Refresh it on request, through the
  same guarded path as delivery: diff first, dated backup, explicit approval.
- **A hand-adapted copy is a feature, not drift.** Operators pin their own defaults (model, effort,
  local config) into it; preserve those on any re-sync.

## Provenance

Grounded in the maintainer's lab, honestly bounded: **one controlled episode** (2026-08-01, lab
devlog #127 — a defensive Bash guard, 7 find→fix→refute rounds, 60+ defects closed; the first
round's 16 findings triaged to 5 real holes that 109 tests, three fix commits and every
same-family pass had missed), plus the maintainer's **current standing practice** — daily use,
reported as a substantial quality and throughput gain. The second layer is practice, not
measurement (no control, no A/B), and it is *current*, not longitudinal: it began at the episode
above, so read it as a strong practitioner preference rather than a track record. That places it
at the same tier as the practice baseline's own grounding. The lab's artifacts do not ship with
the kit; what ships is this distillation.

What the evidence supports is the **discipline** above — refute-framed prompt, read-only sandbox,
triage rather than relay, reproduce each finding with your own failing test, stop when findings
stop being regressions, keep an objective layer beside the reviewer. **How often to reach for it
is not an evidence claim**: running it as the routine executor of Tier 1 is the maintainer's own
preference, offered as such. And nothing here supports "always call a second vendor", or any
reading in which a harness without one is deficient — that would need more than one target and
more than one vendor.
