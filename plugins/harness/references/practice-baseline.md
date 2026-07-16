# Practice baseline — transmittable behavioral layer

The kit's project artifacts (CLAUDE.md, settings.json, Phase 5 conventions) configure *one
repository*. The practice baseline below configures *the model's working behavior in every
project* — it is the layer that, in the maintainer's lab, lives in the operator's global
`~/.claude/CLAUDE.md` and is the layer under which the discipline the kit assumes was observed
(red→green commits, devlog/progress trails, fresh-context verification — attribution is
confounded with the lab's hooks and rules; this block is the prose carrier, and the machinery
half now ships too, as the devlog companion's session-start digest — delivery step 4). A plugin
install does not carry the operator's personal global file, so **Bootstrap transmits this
baseline explicitly** — otherwise consumers get the artifacts without the behavior that
animates them.

## Delivery procedure (Bootstrap, after Phase 2)

Detect-then-prescribe; files outside the repo are touched only with explicit approval, and
only through the guarded merge in step 3.

1. **Detect — across every layer, not one file.** The substance can already arrive from any
   memory layer the session loads (order: managed policy → user `~/.claude/CLAUDE.md` →
   project `CLAUDE.md` / `.claude/rules/*.md` → auto-memory; `native-capabilities.md`,
   Memory §). Check them all — an org-managed policy file or an existing project embed counts
   the same as the user file. Four outcomes:
   - **Substance present** (think-before-coding, simplicity/surgical rules, runnable-oracle
     testing, continuity layers, fresh-context verification) → **skip entirely**; duplicating
     it into another layer wastes context budget.
   - **Partial overlap** → offer only the missing sections.
   - **Absent** → offer the install (steps 2–3).
   - **Conflict** — a layer encodes a rule the baseline contradicts (e.g. "don't stop to
     ask" vs §1's "if uncertain, ask"; "prototypes skip tests" vs §5) → **name the conflict
     to the operator and stop**; they pick a side or scope the baseline down. Never merge
     contradictory rules into co-loaded layers: both load every turn, and the model gets
     told X and not-X.
2. **Default: project embed.** Write the canonical block verbatim (including its
   content-version stamp) as `.claude/rules/practice-baseline.md` and reference it from
   CLAUDE.md's `Reference materials`. This is the first-contact default because its blast
   radius is one repo, it lives in git (reviewable, revertible, removable), and Audit
   re-syncs it by the stamp. In a headless run this is the only path — no one is present to
   approve a personal-file write, so skip the global offer entirely. (A rules file, not a
   CLAUDE.md section — it is ~80 lines and CLAUDE.md must stay an indexer; the Phase 4
   ≤30-line cap names this file as its one sanctioned exception.)
3. **Global merge — explicit opt-in, guarded.** Offer it as the wider-radius alternative,
   stating the radius in the offer itself: *this changes Claude's working behavior in every
   project on this machine — ~80 lines loaded into every session*. It is the operator's
   personal file — **never write it without explicit approval in this conversation**. When
   approved:
   - **Show the diff first** — the exact block to be appended/merged, plus anything the merge
     dedupes out of the project layer.
   - **Back up before writing** — `~/.claude/CLAUDE.md` is usually not under version control,
     so the backup is the rollback: copy it to `~/.claude/CLAUDE.md.bak-<YYYY-MM-DD>` first.
   - **Respect the file's budget** — the ≤200-line discipline that governs project CLAUDE.md
     applies here with machine-wide radius. If the merge would push the file past it,
     say so and recommend keeping the project embed instead.
   - Keep the content-version stamp with the merged block; retire any project embeds it
     supersedes (now duplicate context).
4. **Name the machinery the numbers came from.** The zero-prompting discipline in Provenance
   was observed with session-start state surfacing. The devlog companion ships the equivalent
   (a SessionStart digest of recent devlog + active progress —
   `/plugin install devlog@claude-code-harness`); without it, the CLAUDE.md session-start
   ritual is the carrier. Say this in the offer, so the operator knows what they are opting
   into.
5. Either way, record in the bootstrap summary which path was taken.

## The baseline (canonical text — copy as-is, adapt only the bracketed parts)

```markdown
<!-- practice-baseline content-version: claude-code-harness v1.16.0 — Audit's re-sync key;
     advances only when this block's text changes. HTML comments are stripped before context
     injection, so this line costs nothing at runtime. -->
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
  what's stuck; when the task ends, fold it into the episodic record and mark it
  CLOSED (or delete it) — a finished task's journal left looking active misleads the
  next session. A long-lived workstream may instead keep a rolling current-state
  snapshot (episodic history → devlog; prune, don't append).
- atemporal facts (auto-memory / CLAUDE.md) — preferences and constraints, not history.

## 7. Guardrails — Encode "What Not to Do" Mechanically
- Claude Code's native layer is the floor: destructive git/IaC commands are blocked
  out of the box and everything else rides the permission flow — don't re-encode
  that floor; build the project-specific layer above it.
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

## Keeping installed copies current

The canonical block carries a **content-version stamp** (an HTML comment — stripped before
context injection, so it costs nothing at runtime and is visible only when the file is Read
from disk). It advances **only when the block's text changes**, never on an unrelated plugin
release — the same content-version semantics as the project-docs `shipped-by` headers.

- **Project embed** — Audit compares the embed's stamp against the canonical block's and
  offers a re-sync; the diff is shown before any overwrite, and a non-stamp delta is a
  potential hand-edit to preserve (`audit-checklist.md` §4).
- **Global merge** — no automation touches the personal file. When an audit finds the global
  stamp older than the canon (or the operator asks to "refresh my practice baseline"), the
  refresh runs the same guarded merge as delivery step 3: diff first, timestamped backup,
  explicit approval.
- **Unstamped copy** (installed before v1.16.0, or hand-adapted) — treat the whole copy as a
  hand-edit: diff it against the current block, show the delta, and offer a stamped
  re-install that preserves deliberate adaptations.

## Provenance

Distilled from the maintainer's production global baseline (lab: Harnesses-Claude). The
discipline is empirically grounded, not stylistic: §5/§6 produced the observed red→green +
devlog/progress discipline in a real product build with zero per-session prompting, and §8 is
the fresh-context-critic result (an in-context premortem added ~0 recall; a fresh-context
critic recovered a real bug every native pass missed) — see `evidence-base.md` for the wider
citation set. Attribution honesty: those observations ran under the lab's session-start
state-surfacing hook, so the zero-prompting part is confounded with that machinery — which is
why the devlog companion now ships the equivalent digest (delivery step 4) rather than the kit
claiming prose alone carries it. The remaining personal machinery is deliberately not
referenced in the block: the catastrophic-command floor the lab's guard hook provided is now
largely native (destructive-command block + permission flow — `native-capabilities.md`,
Settings §), which §7 names directly, and the devlog/progress file formats come with the
kit's Phase 5 conventions.
