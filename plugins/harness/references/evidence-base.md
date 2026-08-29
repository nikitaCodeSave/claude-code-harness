# Evidence base — where the discipline comes from

Read this when someone challenges a recommendation or asks "where does this come from".
Every core harness principle has a **first-party (T1)** citation — the discipline is grounded,
not idiosyncratic. Verified against current docs July 2026; the currency pin lives in
`references/native-capabilities.md`.

## Trust rubric

| Tier | Meaning |
|---|---|
| **T1** | Anthropic first-party docs / engineering (`code.claude.com`, `platform.claude.com`, `anthropic.com/engineering`) |
| **T2** | Anthropic blog / release notes |
| **T3** | Named practitioner / Anthropic staff |
| **T4–T5** | Reputable community (research labs, established practitioners) |
| **T6–T7** | Anecdotal (single blog post, forum) — never the sole basis for an invariant |

A new invariant requires multi-source evidence or repeated empirical observation. A single
T6–T7 anecdote does not earn a rule (see `harness-discipline.md`, single-incident≠invariant).

## Source catalog

| Source | URL | Tier | Supports |
|---|---|---|---|
| Best practices for Claude Code | `code.claude.com/docs/en/best-practices` | T1 | CLAUDE.md ≤200 lines, prune-like-code, verify-loop ladder, adversarial-review-but-don't-over-engineer |
| Extend Claude Code ("match features to your goal") | `code.claude.com/docs/en/features-overview` | T1 | built-ins-first, hook-vs-skill determinism, action-vs-reference skills, subagent isolation, build-over-time triggers |
| Orchestrate subagents at scale with dynamic workflows | `code.claude.com/docs/en/workflows` | T1 | "who holds the plan" boundary; concurrency caps; cost gate |
| What's new in Claude Opus 5 | `platform.claude.com/docs/en/about-claude/models/whats-new-opus-5` | T1 | effort default `high`; 1M context default+max; thinking on by default, effort as the depth dial; literal instruction-following |
| Prompting Claude Opus 5 | `platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5` | T1 | do not over-instruct verification ("use a subagent to verify" causes over-verification); give the full spec up front; filter review severity in a second pass |
| The new rules of context engineering for Claude 5 | `claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models` | T1 | >80% of Claude Code's system prompt removed with no measurable loss; conflicting instructions as the harm mechanism; CLAUDE.md budget goes to gotchas; progressive disclosure; `/doctor` rightsizes |
| How Anthropic secures its AI-native SDLC | `claude.com/blog/how-anthropic-secures-its-ai-native-software-development-lifecycle` | T1 | boundaries around access and actions, not around instructions; an agent's boundary must include its access to other agents |
| How we contain Claude across products | `anthropic.com/engineering/how-we-contain-claude` | T1 | contain at the environment layer first, steer at the model layer second; approval fatigue is measured, not hypothetical |
| Agent harness design: 3 patterns | `claude.com/blog/harnessing-claudes-intelligence` | T1 | lean on the model not the harness; strip it down as capability grows; boundaries are the part you keep |
| Effective context engineering for AI agents | `anthropic.com/engineering/effective-context-engineering-for-ai-agents` | T1 | context as finite/degrading resource; smallest high-signal token set; just-in-time retrieval; tool minimalism |
| Building effective agents | `anthropic.com/research/building-effective-agents` | T1 | simplest solution first; add complexity only when simpler demonstrably underperforms |
| Writing effective tools for AI agents | `anthropic.com/engineering/writing-tools-for-agents` | T1 | high-leverage, namespaced, token-efficient, prompt-engineered tools |
| Effective harnesses for long-running agents | `anthropic.com/engineering/effective-harnesses-for-long-running-agents` | T1 | progress-file (`claude-progress.txt`) pattern, feature-spec-as-JSON, one-feature-at-a-time, env init, browser/human verification |
| Harness Design for Long-Running Application Development | `anthropic.com/engineering/harness-design-long-running-apps` | T1 | Planner→Generator→Evaluator; sprint-contracts; evaluator with a live app; "strip scaffolding as the model improves" (grounds the headline principle) |
| A harness for every task: dynamic workflows in Claude Code | `claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code` | T2 | canonical dynamic-workflows source (first-party blog); `ultracode` trigger word; the 3 failure-modes (agentic laziness / self-preferential bias / goal drift) that ground "fresh-context Evaluator ≠ in-context self-recheck" |
| Introducing dynamic workflows in Claude Code | `claude.com/blog/introducing-dynamic-workflows-in-claude-code` | T2 | why bounded fan-out now; convergence/adversarial pattern; cost caveat |
| Multi-agent research system | `anthropic.com/engineering/multi-agent-research-system` | T1 | brief-subagents-like-a-new-colleague; effort scaling; token economics (single-agent ~4×, multi-agent ~15× chat; 80% of variance = token usage) |
| Code review in Claude Code | `code.claude.com/docs/en/code-review` | T1 | review surfaces (`/code-review` for the working diff or a PR, `/review` as its alias, `ultrareview` for the cloud pass); REVIEW.md tunes the managed service only, effort tunes the local review |
| Orchestrate teams of Claude Code sessions | `code.claude.com/docs/en/agent-teams` | T1 | "check whether a lighter option does the job" before a team; subagents-vs-teams comparison; teams cost more tokens and suit research/review/independent-ownership work, not sequential or same-file work |
| Claude Code release notes | `code.claude.com/docs/en/changelog` | T2 | the shipped-surface record the inventory is grounded on. One entry is worth citing on its own: **v2.1.232 removed the startup tip suggesting you create custom subagents** (and the matching `/powerup` nudge) — the vendor retiring its own "write a custom agent" prompt is first-party corroboration of built-ins-first, not just our reading of it |
| AGENTS.md (spec + site) | `agents.md` | T4 | the cross-vendor instruction-file standard (Agentic AI Foundation; read by Codex/Cursor/Copilot). Grounds the bridge pattern: one authoritative file, `@AGENTS.md` import or symlink for Claude Code, never a paraphrased second copy |
| GitHub — how to write a great AGENTS.md (2,500+ repos) | `github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/` | T4 | the section order that changed agent behavior in the wild: executable commands early, three-tier boundaries (Always / Ask first / Never), stack with versions, code examples over prose, explicit "done". Also the negative finding: most files fail by being vague |
| Fowler / Böckeler — harness engineering | `martinfowler.com/articles/harness-engineering.html` | T4 | harness as two control systems — **guides** (feedforward: conventions, specs, rules files) and **sensors** (feedback: linters, tests, review), each in a computational and an inferential mode. Names the human's job as *iterating on the harness itself* when failures recur, which is what this kit's strip revision does |
| Empirical: generated instruction files can hurt | reported across 2026 studies (see `native-capabilities.md`, Memory §) | T3 | LLM-authored AGENTS.md/CLAUDE.md measured at −2% success / +23% cost in one study and reduced success in 5 of 8 settings (+2.45–3.92 steps) in another; mechanism is restating what the repo already shows. Grounds "generate, then cut everything derivable" |
| Chroma — Context Rot | `trychroma.com/research/context-rot` | T4 | universal pre-overflow degradation (corroborates context-engineering; vendor-bias caveat) |
| GitHub Spec Kit (README, command table) | `github.com/github/spec-kit` | T4 | another vendor's spec-first flow placing `/speckit.clarify` (resolve underspecification) and `/speckit.checklist` (requirements completeness) **before** `/speckit.plan` — corroborates that the pre-implementation ambiguity gate is a real gap, not a local preference. Not a source for the kit's disposition wording |

## Empirical grounding notes (current model generation)

- **Capable-model baseline (current frontier generation)**: strong native tool triggering — defensive
  "remember to run X" prompting is low-value; if it must happen every time, use a hook.
  Long-context and post-compaction recovery are reliable, but context rot still holds:
  bigger ≠ free. Thinking is adaptive — don't manage budgets from the harness.
- **Single-agent first remains the default**; dynamic workflows are the *built-in*
  bounded-fan-out primitive — per built-ins-first the harness routes to them (for
  scope-exceeds-context, codified repeatability, or trust-critical adversarial verification,
  gated on higher token cost) rather than reimplementing orchestration.
- **Harness swing ≈ model swing** (Harness-Bench, arXiv 2605.27922) — empirically corroborates the
  headline principle: harness quality moves the score about as much as a model tier, and a stronger
  model narrows harness variance. Supports "less harness, but the right harness."
- **The harness-swing claim now has a cross-vendor data point** (T4, vendor engineering claim —
  not independently replicated, and the benchmark is not coding): OpenAI open-sourced the engine
  behind Codex under Apache-2.0 (August 2026) and reported that changing **only** harness settings
  — inference retention and compaction — moved its model from 13.3% to 38.3% on ARC-AGI-3 while
  cutting token use roughly sixfold, with the model held fixed. Read it as corroboration of
  Harness-Bench above (same shape: model constant, harness varied, large swing), and as evidence
  the "strip the scaffolding" conversation is now industry-wide rather than an Anthropic house
  style. It earns no new invariant here — a vendor's own headline number is not the tier that
  grounds a rule.
- **Harness ROI ∝ exploration cost** (lab empirics, 22 runs / 5 tasks, May 2026): context preload
  pays off when non-obvious structure × ambiguous spec × ≥1k LoC coincide; on low-exploration
  tasks a harness is pure overhead. Grounds "add nothing a library or one-off will not use."
- **Cross-vendor refuter — an upgrade of the fresh-context rung, not a new rule** (lab empirics,
  2026-08-01; the lab's artifacts are not shipped with the kit — this distillation is): a reviewer
  from another model family (Codex CLI attached as an MCP server) found **5 real holes in a
  defensive Bash guard that 109 tests, three fix commits and every same-family pass had missed** —
  16 raw findings triaged down to those 5, across 7 find→fix→refute rounds on one target. Bounded
  honestly: **n=1** — one component, one vendor, one episode. The second layer is the maintainer's
  **current** practice (daily use, reported as a substantial quality/throughput gain), which is
  practitioner preference rather than a track record: it starts at that same episode, so it is
  days old, not months. Practice, not measurement — no control, no A/B; ~T3, the tier that already
  grounds a named practitioner's preference. What this supports is the *discipline* — refute-framed prompt,
  read-only sandbox, triage rather than relay, reproduce each finding with your own failing test,
  stop when findings stop being regressions, keep an objective differential layer beside the
  reviewer. What it does **not** support is "always call a second vendor", nor any claim that a
  harness without one is deficient. Delivered on consent only, behind a single mechanical gate:
  `references/codex-peer-skill.md`, `operator-playbook.md` §6.
- **The headline principle holds on the strongest available model.** Fable 5 (Mythos-class, a
  tier above Opus — `anthropic.com/news/claude-fable-5-mythos-5`, T1) was tested against every
  "under a capable model" invariant (a major model release is the canonical re-grounding
  trigger, SKILL.md Maintenance): a more capable model still needs the *right* harness — the
  long-running spine (runnable oracle + progress/handoff, from *Effective harnesses for
  long-running agents*, T1), not *more* machinery. That source also names a feature ledger. The kit
  no longer ships one, and the honest framing is that the guarantees were **split, not replaced**:
  a runnable command answers "does what exists behave", while completeness, priority and blocked
  state belong to whatever tracker the project already keeps. The generated ledger was retired in
  v1.23.0 as a second store the kit had to maintain, not because a verification command subsumes
  it. This is the published
  progressive-simplification stance — *"find the simplest solution possible, and only increase
  complexity when needed"*; strip scaffolding as models improve (*Harness design for
  long-running apps*, T1). The kit encodes that spine as two lines an operator acts on — name a
  real verification command, keep continuity on disk — not as a set of files it generates
  (`operator-playbook.md` §2).
