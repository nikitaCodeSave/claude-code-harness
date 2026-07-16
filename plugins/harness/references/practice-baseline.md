# Practice baseline — transmittable behavioral layer

The kit's project artifacts (CLAUDE.md, settings.json, Phase 5 conventions) configure *one
repository*. The practice baseline below configures *the model's working behavior in every
project* — it is the layer that, in the maintainer's lab, lives in the operator's global
`~/.claude/CLAUDE.md` and is the layer under which the discipline the kit assumes was observed
(red→green commits, devlog/progress trails, fresh-context verification — attribution is
confounded with the lab's hooks and rules, but it is the only transmittable carrier of that
behavior). A plugin install does not carry
the operator's personal global file, so **Bootstrap transmits this baseline explicitly** —
otherwise consumers get the artifacts without the behavior that animates them.

## Delivery procedure (Bootstrap, after Phase 2)

Detect-then-prescribe, and confirm before touching anything outside the repo:

1. **Detect.** Read `~/.claude/CLAUDE.md` (if it exists). If it already encodes the substance
   of the baseline (think-before-coding, simplicity/surgical rules, runnable-oracle testing,
   continuity layers, fresh-context verification) — **skip entirely**; duplicating it into the
   project wastes context budget. Partial overlap → offer only the missing sections.
2. **Offer global install (preferred).** Propose appending/merging the baseline into
   `~/.claude/CLAUDE.md`. It is the operator's personal file — **never write it without
   explicit approval in this conversation**. Global install benefits every project on the
   machine and keeps project CLAUDE.md an indexer.
3. **Fallback: project embed.** If the operator declines the global write — or the run is
   headless (no one to approve a personal-file write: skip the offer) — embed the baseline
   verbatim as `.claude/rules/practice-baseline.md` in the project and reference it from
   CLAUDE.md's `Reference materials`. (A rules file, not a CLAUDE.md section — it is ~60
   lines and CLAUDE.md must stay an indexer; the Phase 4 ≤30-line cap names this file as its
   one sanctioned exception.)
4. Either way, record in the bootstrap summary which path was taken.

## The baseline (canonical text — copy as-is, adapt only the bracketed parts)

```markdown
# Personal behavioral baseline for Claude Code

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific
instructions as needed. Tradeoff: biased toward caution over speed — for trivial tasks,
use judgment.

## 1. Think Before Coding
Don't assume. Don't hide confusion. Surface tradeoffs.
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- A negative search result is a claim, not a fact: before concluding "X doesn't
  exist", validate the method on a known-present needle (e.g. `strings` a packed
  binary, not raw `grep`; `jq` for structured data, not line-grep).

## 2. Simplicity First
Minimum code that solves the problem. Nothing speculative.
- No features beyond what was asked; no abstractions for single-use code; no
  "flexibility" that wasn't requested; no error handling for impossible scenarios.
- Ask: "Would a senior engineer call this overcomplicated?" If yes, simplify.
- The same filter applies to recommendations you *receive*: audits and checklists
  emit the generic list by construction — adopt a component on evidence of a
  recurring, real need, not by default (single incident ≠ recurring need).

## 3. Surgical Changes
Touch only what you must. Clean up only your own mess.
- Don't "improve" adjacent code, comments, or formatting; match existing style.
- Remove imports/variables YOUR change orphaned; leave pre-existing dead code (mention it).
- The test: every changed line traces directly to the request.

## 4. Goal-Driven Execution
Define success criteria. Loop until verified.
- "Fix the bug" → "write a test that reproduces it, then make it pass".
- For multi-step tasks, state a brief plan with a verify-check per step.

## 5. Tests Verify Behavior — and You Run Them
The lever is a runnable oracle you iterate against.
- Assert observable behavior through the public interface — not prints, not privates.
- Run tests + build/type-check and iterate; "tests pass" is evidence to open, not a
  done-claim — verify end-to-end ("looks done" vs "is done").
- Commit failing tests before implementing; never weaken a test to make it pass.
- Mock only the genuinely external boundary. Red→green is a useful default, not dogma.

## 6. Continuity — Leave a Trail Across Sessions
Future sessions inherit only what you write down. The lever is state-on-disk, not a
specific file layout — meet continuity where it already lives (descriptive git
commits, existing notes/memory) before adding a parallel store. Three roles, whatever
the carrier:
- episodic "what changed and why" — e.g. a devlog (`.claude/devlog/entries/`) or
  disciplined commit messages; record after a feature / fix / config change / decision.
- in-flight state of one long task — e.g. `.claude/progress/<slug>.md`: what's done,
  what's stuck; close it out (fold into the episodic record, then delete) when the
  task ends — an open journal for a finished task misleads the next session.
- atemporal facts (auto-memory / CLAUDE.md) — preferences and constraints, not history.

## 7. Guardrails — Encode "What Not to Do" Mechanically
- When you hit a path/command costly to get wrong (prod config, real DB, deploy
  script, secret file), add a `permissions.deny` rule to `.claude/settings.json`
  and a one-line "never touch X" note in CLAUDE.md — reactively, not via interview.
- Prefer a mechanical guard over prompt-compliance for anything irreversible.

## 8. Independent Verification — Fresh Context, Not Self-Recheck
For high-stakes deliverables, the lever is an independent fresh context (separate
session or subagent prompted to REFUTE, not confirm) — not a second pass in the same
context: the author anchors on its own solution. Opt-in for most work — but
per-change, not occasional, for silent-wrong-prone components (parsers/rewriters of
untrusted input, guards/validators, invariant-preserving refactors): output there
passes the author's own tests while being wrong, and in-context self-checks miss the
class. Overhead for trivial work.
```

## Provenance

Distilled from the maintainer's production global baseline (lab: Harnesses-Claude). The
discipline is empirically grounded, not stylistic: §5/§6 produced the observed red→green +
devlog/progress discipline in a real product build with zero per-session prompting, and §8 is
the fresh-context-critic result (an in-context premortem added ~0 recall; a fresh-context
critic recovered a real bug every native pass missed) — see `evidence-base.md` for the wider
citation set. References to personal machinery (a global system-guard hook, a devlog skill)
are deliberately omitted so the baseline is self-sufficient on a bare plugin install; the
kit's Phase 5 conventions supply the devlog/progress file formats.
