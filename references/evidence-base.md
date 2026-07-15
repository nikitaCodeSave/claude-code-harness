# Evidence base — where the discipline comes from

Read this when someone challenges a recommendation or asks "where does this come from".
Every core harness principle has a **first-party (T1)** citation — the discipline is grounded,
not idiosyncratic. Verified against current docs July 2026 (Claude 5 family / Opus 4.8
generation, Claude Code v2.1.210).

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
| What's new in Claude Opus 4.8 | `platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-8` | T1 | effort default `high`; compaction/long-context reliability; tool triggering; adaptive thinking |
| Effective context engineering for AI agents | `anthropic.com/engineering/effective-context-engineering-for-ai-agents` | T1 | context as finite/degrading resource; smallest high-signal token set; just-in-time retrieval; tool minimalism |
| Building effective agents | `anthropic.com/research/building-effective-agents` | T1 | simplest solution first; add complexity only when simpler demonstrably underperforms |
| Writing effective tools for AI agents | `anthropic.com/engineering/writing-tools-for-agents` | T1 | high-leverage, namespaced, token-efficient, prompt-engineered tools |
| Effective harnesses for long-running agents | `anthropic.com/engineering/effective-harnesses-for-long-running-agents` | T1 | progress-file (`claude-progress.txt`) pattern, feature-spec-as-JSON, one-feature-at-a-time, env init, browser/human verification |
| Harness Design for Long-Running Application Development | `anthropic.com/engineering/harness-design-long-running-apps` | T1 | Planner→Generator→Evaluator; sprint-contracts; evaluator with a live app; "strip scaffolding as the model improves" (grounds the headline principle) |
| A harness for every task: dynamic workflows in Claude Code | `claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code` | T2 | canonical dynamic-workflows source (first-party blog); `ultracode` trigger word; the 3 failure-modes (agentic laziness / self-preferential bias / goal drift) that ground "fresh-context Evaluator ≠ in-context self-recheck" |
| Introducing dynamic workflows in Claude Code | `claude.com/blog/introducing-dynamic-workflows-in-claude-code` | T2 | why bounded fan-out now; convergence/adversarial pattern; cost caveat |
| Multi-agent research system | `anthropic.com/engineering/multi-agent-research-system` | T1 | brief-subagents-like-a-new-colleague; effort scaling; token economics (single-agent ~4×, multi-agent ~15× chat; 80% of variance = token usage) |
| Code review in Claude Code | `code.claude.com/docs/en/code-review` | T1 | review surfaces (`/code-review` for the working diff, `/review` for PRs, `ultrareview`); REVIEW.md severity calibration |
| Chroma — Context Rot | `trychroma.com/research/context-rot` | T4 | universal pre-overflow degradation (corroborates context-engineering; vendor-bias caveat) |

## Empirical grounding notes (current model generation)

- **Capable-model baseline (Fable 5 / Opus 4.8)**: strong native tool triggering — defensive
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
- **Harness ROI ∝ exploration cost** (lab empirics, 22 runs / 5 tasks, May 2026): context preload
  pays off when non-obvious structure × ambiguous spec × ≥1k LoC coincide; on low-exploration
  tasks a harness is pure overhead. Grounds "skip the Phase 5 kit for libraries/one-offs."
- **The headline principle holds on the strongest available model.** Fable 5 (Mythos-class, a
  tier above Opus — `anthropic.com/news/claude-fable-5-mythos-5`, T1) was tested against every
  "under a capable model" invariant (a major model release is the canonical re-grounding
  trigger, SKILL.md Maintenance): a more capable model still needs the *right* harness — the
  long-running spine (runnable oracle + progress/handoff + feature ledger, from *Effective
  harnesses for long-running agents*, T1), not *more* machinery. This is the published
  progressive-simplification stance — *"find the simplest solution possible, and only increase
  complexity when needed"*; strip scaffolding as models improve (*Harness design for
  long-running apps*, T1). The Bootstrap **long-running build kit** (checklist Phase 5)
  encodes that spine as opt-in conventions for sustained builds.
