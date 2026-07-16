---
name: claude-code-harness
description: "Use this skill when introducing, auditing, refactoring, or extending the Claude Code harness of a project — i.e. its `.claude/` directory (CLAUDE.md, settings.json, hooks/, agents/, skills/, commands/) and root CLAUDE.md. Activates on phrases like 'set up Claude Code in this project', 'design my .claude/', 'audit my Claude Code harness', 'add a hook/skill/subagent', 'how should I organize CLAUDE.md', 'what built-ins does Claude Code already have', 'should I write a custom orchestrator subagent', 'when should I use a dynamic workflow', 'why is my harness slow / brittle / token-heavy', 'extend Claude Code with X', 'set up the long-running build kit (Phase 5)', 'refresh my practice baseline'. Claude Code 2.x / Opus-class-specific — does NOT cover provider-neutral patterns for OpenAI/Codex/other frameworks. Skip when the project's `.claude/` already encodes this discipline."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls:*), Bash(tree:*), Bash(cat:*), Bash(find:*), Bash(grep:*), Bash(claude --help), Bash(claude agents:*), Bash(claude --version), Bash(claude --print:*), Bash(claude plugin list:*), Bash(git log:*), Bash(git status:*), Bash(wc:*)
---

# Claude Code Harness

Designs, bootstraps, audits, and extends the harness around Claude Code — the `.claude/`
directory and root `CLAUDE.md` that turn a fresh repository into a high-leverage agentic
workspace. Opinionated, and the opinion is one line:

> **Under a capable model, less harness yields more productivity.** Find the simplest setup that
> works; add a component only when a simpler approach demonstrably underperforms. If a
> component encodes "the model can't do X" and the model already does X natively, it should
> not exist. (Model-agnostic principle — don't re-pin it to a version; evidence in
`references/evidence-base.md`.)

## When to use

- A project has no `.claude/` and wants its harness now → **Bootstrap** (production-grade
  default; minimal on explicit request).
- A project has a `.claude/` that has accumulated cruft (custom orchestrator subagent, multi-stage
  pipeline, 500-line CLAUDE.md, mid-thought blocking hooks, prescriptive stack presets, stale
  model-version pins, duplicate skills) → **Audit**.
- About to add a hook/skill/subagent/command and want to confirm a built-in doesn't already
  cover it → **Extend**.
- Someone asks how Claude Code differs from generic agentic frameworks, or when to use a
  dynamic workflow → **Explain**.

**Do NOT use when**: the operator's own harness already encodes this discipline (this skill is
transmittable knowledge, not a self-description for a mature setup); the question is
provider-neutral (OpenAI/Codex/MCP-without-Claude) → point to `references/evidence-base.md`
external sources; the question is general programming/debugging.

## The four modes

### Mode 1: Bootstrap (empty `.claude/`)
Read `references/bootstrap-checklist.md`. Run `claude --version` first (the built-in subagent
types you must not recreate are catalogued in `references/native-capabilities.md`; since
v2.1.198 `/agents` no longer opens a wizard — inspect configured agents via `/context`
("Custom Agents") or `.claude/agents/` directly; the CLI `claude agents` lists running
background sessions, not types). Default shape is **production-grade regardless of project size** — which means
conventions + documents, not machinery, so it does not contradict the headline principle:
root `CLAUDE.md` ≤ 200 lines + `settings.json` with sane permissions + the shipped workflow distillation
`.claude/docs/{workflow,testing,docs-discipline}.md` (Phase 2c, verbatim copies from
`references/project-docs/`) + `docs/ARCHITECTURE.md` & `docs/CODE-MAP.md` with real content.
No custom subagents, hooks, or skills until justified; minimal MVH only on explicit operator
request. **Transmit the practice baseline** (checklist Phase 2b /
`references/practice-baseline.md`): the behavioral layer the kit's artifacts assume does not
travel with a plugin install — detect across memory layers, then offer a project embed
(default) or a guarded global merge (explicit opt-in). **For a
sustained, multi-session product build, also set up the long-running build kit** (runnable
oracle / feature-spec ledger / progress-handoff conventions — checklist Phase 5; Anthropic's
long-running-harness playbook, files+conventions not machinery; still no custom
subagents/hooks). **Greenfield (0 files, 0 commits) is a valid detected state, not a reason to
stall**: an explicit request for the full harness on an empty repo is informed consent — deploy it
with honestly-labelled stubs (never invented facts); on a *sustained* greenfield an `F0` ledger
feature closes them in the loop, and where Phase 5 is skipped the stub marker carries its own fill
trigger (never cite a `features.json` the project won't have). **Close every bootstrap by recording
it** (Phase 8: the run writes its own first episodic entry, in whatever carrier the project's
continuity duty names — the layer starts live instead of as a convention nobody has exercised).
Then stop.

### Mode 2: Audit (existing `.claude/`)
Read `references/audit-checklist.md`. Walk it top-down; produce a gap statement + remediation
per finding. **Do not edit until the operator approves.** Flag anything irreversible (deleting
accumulated experiment data, removing an actively-used skill) as confirm-before-acting.

### Mode 3: Extend (add a primitive)
First load `references/native-capabilities.md` and confirm Claude Code doesn't already provide
it. If it does, point to the built-in and stop. If a custom primitive is justified, load
`references/harness-discipline.md`, then pick the right one:

| Need | Primitive |
|---|---|
| Reusable workflow template the main thread runs | **action-skill** in `.claude/skills/<name>/SKILL.md` |
| Knowledge loaded on demand | **reference-skill** (`disable-model-invocation` if you only trigger it) |
| Search-heavy work that would pollute main context | **subagent** — `Explore` / `general-purpose` first; custom only with evidence |
| Invariant that must fire even when the model "forgets" | **hook** (enforce at `Stop` / `UserPromptSubmit`, not mid-write) |
| Operator-facing shortcut for a frequent ritual | **slash command** in `.claude/commands/<name>.md` |
| Codebase-scale sweep / migration / trust-critical audit exceeding one context | **dynamic workflow** (keyword `ultracode`) — built-in; never hand-roll a pipeline |
| Cross-session knowledge | **memory** (CLAUDE.md / auto memory) |
| External tool surface | **MCP server** in `.mcp.json` |

### Mode 4: Explain (no edits)
Read the relevant reference and answer concisely. Do not write files.

## Operator handoff (end of every Bootstrap / Audit run)

The kit's machinery is opt-in by design, so the operator can't discover it from one run.
End every Bootstrap and Audit run — and any first use of this skill in a project — with a
compact operator map (a footer, not a lecture; skip it when the operator demonstrably
already knows the kit):

> **What else the kit does** (trigger phrases):
> - "audit my Claude Code harness" — audit `.claude/` (gap report, edits after approval)
> - "set up Claude Code harness in this project" — bootstrap a production-grade harness
>   (minimal via "set up a minimal harness")
> - "set up the long-running build kit (Phase 5)" — oracle / feature-ledger / progress for a
>   multi-session product build
> - Independent verification (fresh context, not self-recheck) — by default a **single
>   `code-refuter`** on each silent-wrong-prone change; escalate to the full 3-role
>   `/claude-code-harness:external-audit <scope>` in a **fresh** session only at a
>   milestone / irreversible delivery
> - Full lifecycle map — `references/operator-playbook.md`

## Reference map (load on demand — never preload all)

- `references/native-capabilities.md` — current Claude Code built-ins. Read first in **Extend** / **Explain**.
- `references/harness-discipline.md` — the rules, spawn/workflow policy, anti-patterns. Read in **Bootstrap** / **Extend**.
- `references/bootstrap-checklist.md` — canonical layout + templates (default shape / MVH-on-request). Read in **Bootstrap**.
- `references/practice-baseline.md` — transmittable behavioral baseline (§1–8) + delivery procedure. Read in **Bootstrap** (Phase 2b).
- `references/project-docs/` — shipped distillation (`workflow.md` / `testing.md` / `docs-discipline.md`), copied verbatim into the project's `.claude/docs/` in **Bootstrap** (Phase 2c); re-synced by version in **Audit**.
- `references/audit-checklist.md` — structured gap analysis. Read in **Audit**.
- `references/evidence-base.md` — first-party + community sources with a T1–T7 rubric. Read when challenged or asked "where does this come from".
- `references/operator-playbook.md` — **human-facing** lifecycle entry point (what the operator says/prepares at each stage). Point the operator to it; don't preload it as a mode input.
- `references/harness-evolution.md` — D-cycle (fold journal/audit findings into the canon) + strip revision procedure. Read when running a harness-evolution session.

## Non-negotiable principles (all modes)

1. **Built-ins first.** Never duplicate the built-in subagent types `Explore` / `Plan` /
   `general-purpose` / `statusline-setup` / `claude-code-guide` (catalogued in
   `references/native-capabilities.md`). The orchestrator is the main thread.
2. **Main thread owns the task end-to-end.** Subagents are for context isolation / parallelism, not ownership.
3. **Single-agent first; bounded fan-out only when scope exceeds one context.** Dynamic
   workflows are a built-in — route to them; don't reimplement orchestration. No PM→Architect→Dev→QA pipelines.
4. **CLAUDE.md is an indexer, not a store (≤ 200 lines).** Every line taxes every turn; bloat makes the model ignore it.
5. **Mechanical invariants beat prompt advice.** A repeated correction becomes a hook, validator,
   or denied permission — enforced at submit, not mid-thought.
6. **Single-incident does not become invariant.** New rules need multi-source evidence or repeated empirics.
7. **Give Claude a verification loop it can close** (prompt check → `/goal` → Stop hook →
   `/code-review` → fresh-context second opinion); tell adversarial reviewers to flag only
   correctness/requirement gaps.
8. **Durable knowledge lives in artifacts** (ADRs / progress file / devlog), not chat.
9. **CLI-subscription only.** No managed-agents, beta headers, `--bare`, `--max-budget-usd`, API-key flows.

## Output template — Audit report

```markdown
# Claude Code harness audit — <repo>
## Summary — <1–2 sentences: posture + top-3 gaps>
## Findings
### F1: <one-line gap>
- Where: <file:line> · Why it matters: <token cost / false trigger / duplicates built-in / stale>
- Remediation: <delete X / replace with built-in Y / refactor into hook>
- Principle violated: <which non-negotiable>
## Out of scope — <intentional choices that look like findings>
## Recommended order — <lowest-risk first; mark irreversible items confirm-before-acting>
```

## Output template — Bootstrap plan

```markdown
# Claude Code harness bootstrap — <repo>
## Detected state — stack / age / existing docs / existing `.claude/` (greenfield = 0 files/0 commits is a state, not a blocker)
## Default shape (production-grade, any project size)
| File | Purpose | ~size |
| CLAUDE.md (root) | entry-point indexer (incl. Working style + verification ladder + continuity duty) | ~80 lines |
| .claude/settings.json | permissions + minimal env | ~20 lines |
| .claude/docs/{workflow,testing,docs-discipline}.md | shipped distillation (verbatim, versioned) | 3 files |
| docs/ARCHITECTURE.md + docs/CODE-MAP.md | real content from the code read | 2 files |
| (no custom subagents/hooks/skills) | built-ins cover it | — |
## Offered — practice baseline (Phase 2b): project embed `.claude/rules/practice-baseline.md` (~80 lines, default) or guarded user-global CLAUDE.md merge (opt-in); operator decides
## Sustained build (Phase 5) adds — oracle (reuse the project's entry point; author scripts/init.sh only if none exists) · .claude/features.json · progress+devlog conventions
## Greenfield (no code yet) — ARCHITECTURE/CODE-MAP ship as labelled stubs, never invented facts; on a sustained build the ledger seeds `F0` "get the brief → fill Stack / ARCHITECTURE / CODE-MAP / name the oracle", `passes: false` (no Phase 5 → no ledger: the stub marker carries the trigger)
## Minimal MVH (CLAUDE.md + settings only) — explicit operator request only
## Deferred until justified — subagents (evidence) · hooks (recurring pain) · skills (≥3× repeat)
## Closes with — Phase 8: the bootstrap records itself as episodic entry #1, in the carrier the continuity duty names (live layer + a carrier smoke test)
```

## Gotchas

- Don't preload every reference — load only the active mode's file (inflating the system prompt
  contradicts principle 4).
- Don't redesign the operator's own harness mid-conversation if their `.claude/` already encodes this.
- Don't propose API-only features.
- Don't produce generic agentic advice — refer provider-neutral questions to external sources.
- Don't generate skills/hooks/subagents speculatively in Bootstrap.

## Maintenance

Version this skill with the primitives: new built-in / hook event → update
`native-capabilities.md`; new Anthropic essay → add to `evidence-base.md` with a tier; a major
model release → re-test every "under Opus <version>" invariant. Single anecdotes don't earn
updates (principle 6). On every version bump that touches `references/project-docs/*`, update
their `shipped-by:` headers to the new version — Audit's re-sync check keys on them.

**Release mechanics are scripted, not manual** — run `scripts/release.sh <version>` from the
repo root (writes `plugin.json`'s `version` — the sole source of truth and update cache key,
never duplicated in the marketplace entry — verifies shipped-by stamps, stages, prints the
commit/tag/push finish). Two manual releases in a row shipped desynced manifests and
uncommitted content (external audit 2026-07-15), so the ritual is mechanical now. A release
exists only when committed, tagged **and pushed**: consumers install from origin/main via
`/plugin marketplace add nikitaCodeSave/claude-code-harness`, and without a `version` bump
users never receive changes.
When the operator's global baseline (`~/.claude/CLAUDE.md` §1–8) gains a rule, re-distill
`references/practice-baseline.md` in the same release — it is a snapshot and drifts silently otherwise.

**Content-gate for `project-docs/*`** (they ship **verbatim** into projects that cannot
re-verify upstream facts): state durable principles and stable affordances only. A claim bound
to a ticket number (`#NNNNN`) or a specific Claude Code version belongs in `native-capabilities.md`
(dated, re-grounded, never shipped verbatim) or is omitted — never embed a perishable
platform-fact here. The lever against staleness is *not shipping the volatile claim*, not
badging it: an inline expiry marker is inert without a runner (evidence: a dated "re-check
after X" note rots silently once X passes).
