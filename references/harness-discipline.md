# Harness discipline

The reduced, Claude Code-specific rules for growing a `.claude/` without bloating it. Read in
**Bootstrap** and **Extend** modes. Each rule has a first-party basis (see `evidence-base.md`).
Grounded for the Claude 5 family / Opus 4.8 generation, Claude Code v2.1.210 (July 2026).

## The one principle everything else serves

**Find the simplest setup that works; add a component only when a simpler approach
demonstrably underperforms.** (*Building effective agents*, T1.) Most coding needs no custom
harness — the built-in tools cover it. "The harness is hard to grow" almost always means the
harness has outgrown the model's real gaps. If a component encodes "the model can't do X" and
a capable model already does X (pick a sane stack, verify before claiming done, honor permissions,
trigger the right tool), the component should not exist.

## Build over time, on a recognizable trigger

Anthropic's own escalation ladder (*Extend Claude Code*, T1) — never set everything up front:

| Trigger | Add |
|---|---|
| A convention Claude gets wrong **twice** | a line in CLAUDE.md |
| The same multi-step prompt typed repeatedly / a playbook pasted a **3rd** time | a skill |
| Something must happen **every time without asking** | a hook |
| A side task floods the conversation with output you won't reuse | route through a subagent |
| External tool surface (DB, browser, monitoring) | an MCP server |

Single-incident does not become an invariant. Reactive rule-piling is the most common failure
mode of a growing harness.

## The execution spine: Plan → Work → Review

The default shape of a nontrivial task (trivial — typo, formatting, one-liner — skips Plan):

- **Plan** — read-only recon before any write: plan mode (`Shift+Tab`×2 or
  `--permission-mode plan`); the built-in `Plan` agent for heavier design. Output: explicit
  acceptance criteria (what = "done"), critical files, alternatives if the choice is
  nontrivial. The acceptance criteria are the oracle Review runs against.
- **Work** — one main thread end-to-end; verification per the ladder below.
- **Review** — self-review + tests/lint always; `/code-review` on substantive change;
  fresh-context evaluator for high-stakes.

A working rhythm, not machinery: no phase-subagents, no PM→Architect→Dev→QA.

## CLAUDE.md is an indexer, not a store (≤ 200 lines)

"CLAUDE.md is loaded every session, so only include things that apply broadly." "Bloated
CLAUDE.md files cause Claude to ignore your actual instructions." (*Best practices*, T1.) For
each line ask: *would removing it cause a mistake?* If not, cut it — or, if Claude already does
the thing correctly, delete the instruction; if it must hold every time, **convert it to a
hook**. Reference content goes to skills (loaded on demand) or `.claude/rules/` (path-scoped).
Treat CLAUDE.md like code: prune it, and test a change by observing whether behavior shifts.

## Mechanical invariants belong in hooks, not prompts

"An instruction like 'never edit `.env`' is a request, not a guarantee. A `PreToolUse` hook
that blocks the edit is enforcement." (*Extend Claude Code*, T1.) Prompts are advisory (~70%);
hooks are deterministic (100%). But: **block at submit, not mid-thought.** `Stop` and
`UserPromptSubmit` are good enforcement points; a `PreToolUse` that blocks on every write is
corrosive. Note Claude Code overrides a Stop hook after 8 consecutive blocks — a blocking gate
is a backstop, not a cage.

## Action-skills vs reference-skills

A skill encodes either a *workflow the main thread executes* (action: "write a devlog entry")
or *knowledge loaded on demand* (reference). Both are legitimate. What is **not** legitimate is
a skill that re-describes the main thread's own role — that duplicates CLAUDE.md. Side-effect
skills you only trigger yourself should set `disable-model-invocation: true` (zero context cost
until invoked).

## Subagents are for context isolation / parallelism — not ownership

"Subagents run in their own context… useful for tasks that read many files without cluttering
your main conversation." (*Extend Claude Code*, T1.) The main thread owns the task end-to-end
through verification. Spawn only for: (a) context isolation (search-heavy work whose output
would pollute main context), (b) parallelism (independent searches converging back), or
(c) auto-compact rescue. **Built-ins first**: `Explore` / `Plan` / `general-purpose` cover
nearly all delegation — never clone `general-purpose` into a custom "orchestrator".

When you do spawn: **brief the subagent like a new colleague** — concrete goal, output format
(structured, length-limited), tool/source preferences, boundaries, and what's already known.
Short briefs produce duplicated and gapped work (*Multi-agent research system*, T1). Scale the
fan-out to the task — over-spawning is a documented failure mode — and assign models by role:
highest-capability tier for the lead, mid-tier for reasoning delegates, fastest/cheapest tier
for grunt scans (current mapping: Fable 5/Opus-class lead, Sonnet-class reasoning,
Haiku-class grunt — a config fact, re-map at each model generation; Fable ≈2× Opus price,
so no blanket lead-switch without evidence of lift).

## Single-agent first; bounded fan-out only when scope exceeds one context

The default for typical coding is one main thread. For bounded fan-out, **dynamic workflows**
are the first-party primitive — per built-ins-first, **route to them; do not reimplement
orchestration in a custom subagent pipeline.** The boundary is *who holds the plan* (T1,
`/workflows`):

- Plan fits in 2–3 steps Claude holds in its head → subagents / skills, in-conversation.
- Plan becomes code, repeatable, scalable to hundreds of independent operations → a workflow
  (the `ultracode` keyword, `/effort ultracode`, or simply asking — the bare word "workflow"
  does not trigger).

Sanctioned only for: scope exceeding one conversation, codified rerunnable orchestration, or
trust-critical adversarial verification (find → refute → converge). It costs meaningfully more
tokens — start scoped, drop back to `/effort high` for routine work.

**Untrusted input in a fan-out → quarantine.** Subagents that read untrusted content (web
pages, issues, email) are separated from subagents that take high-privilege actions —
privilege separation against prompt injection (*A harness for every task*, first-party).
Apply whenever a workflow ingests content you didn't write.

Agent teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`) remain experimental and off by
default; document, don't enable. **No PM→Architect→Dev→QA pipelines** — that is the anti-pattern, not the goal.

## Give Claude a verification loop it can close itself

"Claude stops when the work looks done. Without a check it can run, 'looks done' is the only
signal, and you become the verification loop." (*Best practices*, T1.) Enforcement ladder,
cheapest first: in-prompt check → `/goal` condition (re-checked every turn) → **Stop hook**
(deterministic gate) → **`/code-review`** (built-in, local, free — run it on substantive
changes; it reviews the working diff, while `/review` is PR-review — surfaces catalogued in
`native-capabilities.md`) → fresh-context second opinion (subagent,
new session, or `/external-audit`) or workflow. This top rung is opt-in for most work but
**per-change, not occasional, for silent-wrong-prone components** — output that looks plausible
and passes the author's own tests yet is wrong under edge/adversarial input (parsers,
guards/validators, invariant-preserving refactors); in-context self-check systematically misses
this class. When using an adversarial reviewer,
tell it to **flag only gaps affecting correctness or the stated requirements** — a reviewer
prompted to find gaps will invent them, and chasing every finding causes over-engineering.

## Durable knowledge lives in artifacts, not chat

Decisions → ADRs; ongoing long task → a progress file (`.claude/progress/<slug>.md`; the
`claude-progress.txt` pattern, T1); completed changes → a devlog. **The lever is state-on-disk,
not a specific file layout — offer these conventions, don't mandate them; a project that keeps
continuity in git-commit prefixes or structured memory meets the same goal, and prescribing one
format is friction projects route around.** Not ephemeral scrollback. Context is a degrading resource: rot
sets in well before the hard window limit (Chroma "Context Rot", T4; operational reports put
it around ~256K on 1M-window models, 2025–26 figures) — keep state on disk and compact before
the degradation zone, not at the ceiling.

## Before any extension: layer and retire trigger

Two questions every new component must answer:

1. **Laziest layer that still works.** Always-on (CLAUDE.md / rules — taxes every turn) →
   session-start hook (once per session) → event hook → skill (loads on trigger) →
   agent/command (loads on invocation) → on-demand doc (free until read). An invariant placed
   in a skill may not load when it matters; situational knowledge in CLAUDE.md taxes every
   turn. The lazier the layer, the less it costs in tokens, latency, and operator attention.
2. **What will retire it.** Name the observable trigger that marks the component as no longer
   earning its place ("no advisory fired in N sessions"). A component without a retire trigger
   is parasitic by default; retire-bias ≥ add-bias.

## Anti-patterns (do not do these)

- A custom `orchestrator` subagent "because all frameworks have one" — `general-purpose` is it.
- A multi-stage PM→Architect→Dev→QA pipeline by default.
- Five hooks "for hygiene" before any pain occurred.
- A `PreToolUse` hook that blocks writes mid-thought.
- Copying a 600-line CLAUDE.md from another project; inlining architecture into CLAUDE.md.
- A `coding` skill "so Claude codes well"; a skill that re-describes the main thread's role.
- `--dangerously-skip-permissions` "to avoid prompts".
- Proposing API-only features (managed-agents, beta headers, `--bare`) on a CLI subscription.
- Reimplementing dynamic-workflow orchestration as custom subagent machinery.
- Encoding "the model can't pick a stack / won't admit it's not done" as prescriptive config —
  a capable model does both natively.
