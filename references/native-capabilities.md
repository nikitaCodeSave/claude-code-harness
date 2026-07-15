# Native capabilities — what Claude Code already does

Working inventory as of **Claude Code v2.1.210 / the Claude 5 family (Fable 5, Sonnet 5) +
Opus 4.8 model generation** (July 2026). Default model is account-type-dependent [FP,
`model-config`]: Opus 4.8 on Max / Team Premium / Enterprise PAYG; **Sonnet 5** (v2.1.197+)
on Pro / Team Standard / Enterprise seats; Fable 5 is the default on no account type.
The point of this file: a harness must not reinvent a built-in. Before writing
any custom subagent, hook, skill, or command, confirm the need is not already covered here.
Re-verify with `claude --version` and `/help` — versions drift, and **a tool's absence from
your session's live inventory is an env/profile fact, not product truth** (gating: provider,
telemetry flags, experimental env vars).

Trust legend: **[FP]** first-party docs (code.claude.com / platform.claude.com / anthropic.com),
**[BLOG]** Anthropic blog. Everything below is usable on the CLI subscription (Max/Team/Pro/
Enterprise) unless flagged **API-only** or plan-gated.

## Built-in subagents (5)

The five built-in subagent **types** you must not recreate (source:
`code.claude.com/docs/en/sub-agents`). Since **v2.1.198 `/agents` no longer opens the
interactive wizard** — running it prints a reminder to ask Claude or edit `.claude/agents/`
directly; inspect configured agents via **`/context`** ("Custom Agents"; `/doctor` flags
duplicate names, v2.1.205+). Do **not** confuse either with the CLI subcommand
`claude agents` ("Manage background agents" = list running *sessions*), which does not
enumerate types:

- **Explore** [FP] — read-only codebase search; **since v2.1.198 inherits the main
  conversation's model (capped at Opus)** instead of always running on Haiku; thoroughness
  level (quick / medium / very thorough); skips CLAUDE.md + git status. Use for broad
  fan-out searches.
- **Plan** [FP] — read-only research agent used in plan mode; inherits the main model.
  Plan mode itself (`Shift+Tab`×2 or `--permission-mode plan`) is the read-only-recon
  surface; the Plan agent is its research delegate.
- **general-purpose** [FP] — full-tool, multi-step explore + modify; loads CLAUDE.md + git.
  This is the orchestrator-grade delegate; do **not** clone it into a custom "orchestrator".
- **statusline-setup** [FP] — Sonnet; runs on `/statusline`.
- **claude-code-guide** [FP] — Haiku; answers questions about Claude Code itself.

A sixth *surface* exists but is not a specialist to recreate: the built-in catch-all
**`claude`** agent — the default type for background dispatch / agent view when no agent
name is given (`code.claude.com/docs/en/agent-view`); a dispatch default, not a role.

Subagents can nest — up to 5 levels deep (v2.1.172+, per changelog; the sub-agents docs page
may lag on this). Only Explore and Plan omit CLAUDE.md + git context; both are one-shot (no
resume). First-party subagent primitives you should not rebuild by hand: **forked subagents**
(`/fork`, v2.1.161+ — inherits the full conversation, reuses the prompt cache), frontmatter
`maxTurns`, `isolation: worktree` (auto-cleaned branch-off), and `memory: user|project|local`
(**persistent per-agent memory** under `~/.claude/agent-memory/`). Disable a built-in via
`permissions.deny: ["Agent(Explore)"]`; `Agent(x,y)` allowed-type lists are **enforced**, and
background subagents **prompt for permission in the main session** rather than auto-denying (v2.1.186).

## Dynamic workflows — the bounded fan-out primitive [FP/BLOG]

The `ultracode` keyword (or `/effort ultracode`, or simply asking) makes Claude write a JS
orchestration **script** the runtime executes in the background. The script holds the plan,
the loop, the branching, and intermediate results; **only the final answer enters Claude's
context.** Requires v2.1.154+; available on all paid plans — **on Pro it is off by default**,
enable via the `/config` "Dynamic workflows" row. The trigger keyword is `ultracode` — the
bare word "workflow" does not trigger a run (asking in your own words does); a `/config`
"Ultracode keyword trigger" toggle exists.

- Constructs: loops, conditionals, `pipeline()`, `parallel()`, `phase()`, `agent()` (with
  output schemas), arguments, budgets, retries.
- Caps: **up to 16 concurrent agents** (fewer on low-CPU machines), **1,000 agents total per run**.
- Spawned agents always run in `acceptEdits` and inherit your tool allowlist. The script
  itself has no filesystem/shell access — only the agents do.
- Resumable **within the same session** (cached agent results); a fresh session restarts it.
- Manage with `/workflows`; bundled `/deep-research <question>` (needs WebSearch). Saved
  workflows live in `.claude/workflows/` (project) or `~/.claude/workflows/` (user), run as `/<name>`.
- A `/config` "Dynamic workflow size" setting (small / medium / large, advisory) tunes
  fan-out appetite (v2.1.202).
- Disable: `/config`, `"disableWorkflows": true`, or `CLAUDE_CODE_DISABLE_WORKFLOWS=1`.

**When to reach for it** (`code.claude.com/docs/en/workflows`, "who holds the plan"): scope
exceeds one conversation's coordination; you want the orchestration codified + rerunnable; or
you need a repeatable quality pattern (adversarial cross-review, multi-angle convergence). It
costs **meaningfully more tokens** than the same task in conversation — it is not the everyday
default. See `harness-discipline.md` for the single-agent-first boundary.

## Agent teams — experimental, off by default [FP]

`TeamCreate` / `TeamDelete` / `SendMessage` + the shared task list, gated behind
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (v2.1.32+). Multiple coordinating Claude Code
instances, one fixed lead, peer mailbox. Token cost "significantly more than a single
session" (community: ~7×). Shared list at `~/.claude/tasks/{team}/`, config at
`~/.claude/teams/{team}/config.json` (machine-local, auto-generated). Quality-gate hooks:
`TeammateIdle`, `TaskCreated`, `TaskCompleted`. Limits: one team per lead, no nested teams,
no `/resume` mid-flight. **Document, route on explicit opt-in; do not enable by default.**
Source: `code.claude.com/docs/en/agent-teams`.

## Tasks / scheduling [FP]

`TaskCreate` / `TaskUpdate` / `TaskList` / `TaskGet` — the structured session task list
(`TodoWrite` is disabled by default in its favor). Scheduling is first-party documented
(`code.claude.com/docs/en/tools-reference`, `/en/scheduled-tasks`): `CronCreate` /
`CronList` / `CronDelete` schedule a recurring or one-shot prompt **within the current
session** (session-scoped; restored on `--resume`/`--continue` if unexpired) — not a
machine-level cron. `ScheduleWakeup` paces the next iteration of a self-paced `/loop`
(Claude calls it itself; not on Bedrock/Vertex/Foundry). The **`/loop`** skill is the
operator surface for recurring runs. For **durable, cross-session scheduling** the
first-party surface is **`/schedule`** (the `RemoteTrigger` tool) managing **Routines** on
claude.ai — Anthropic-hosted, survives sessions, min interval 1 h; Pro/Max/Team/Enterprise,
not on Bedrock/Vertex/Foundry. Don't hand-roll a persistent cron around the session-scoped one.

## Background waiting — no sleep-polling

Waiting on a long build/test/deploy with `bash sleep` loops is an explicit first-party
anti-pattern. Two shipped mechanics:

- **Background Bash** (`run_in_background`): the task returns its output-file path and the
  agent is **re-invoked with a task notification on completion** — no polling needed.
- **`Monitor` tool** [FP] (v2.1.98+, `code.claude.com/docs/en/tools-reference#monitor-tool`):
  watches a command in the background and feeds each output line back as it arrives — tail a
  log, poll CI/PR status, watch a directory. Shares Bash permission rules; plugins can declare
  auto-start monitors. **Availability is profile-dependent**: absent on Bedrock/Vertex/Foundry
  and whenever `DISABLE_TELEMETRY` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is set.

Background tasks are **never restored on resume**. Recurring checks are the `/loop` skill
(see Tasks / scheduling). To have external events *pushed* into a session instead of polled
(e.g. CI failures), see **Channels** (`/en/channels` — research preview, claude.ai auth).
**`PushNotification`** sends a desktop (and phone, via Remote Control) notification so a
long-running or scheduled task can reach the operator who stepped away (Anthropic-hosted;
not on Bedrock/Vertex/Foundry).

## Hooks — 30 events [FP]

Far more than the five most projects use. Full list (`code.claude.com/docs/en/hooks`):

- Session: `SessionStart`, `Setup`, `SessionEnd`
- Per-turn: `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `StopFailure`
- Tool loop: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`,
  `PermissionRequest`, `PermissionDenied`
- Subagent/task: `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`
- File/config: `FileChanged`, `CwdChanged`, `ConfigChange`, `InstructionsLoaded`
- Context/display: `PreCompact`, `PostCompact`, `MessageDisplay`, `Notification`
- Worktree: `WorktreeCreate`, `WorktreeRemove`
- MCP elicitation: `Elicitation`, `ElicitationResult`

Exit code 2 = blocking error (stderr is fed back to Claude). Hooks are deterministic
enforcement; CLAUDE.md instructions are advisory requests. A Stop hook that keeps blocking
is overridden by Claude Code after **8 consecutive blocks** (cap configurable via
`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`).

`Stop` / `SubagentStop` hooks can return `hookSpecificOutput.additionalContext` to **feed
Claude context and keep the turn going** without the hook being treated as an error — prefer
this "feed-and-continue" shape over hard block-at-stop when the goal is to nudge, not gate.

## Effort, fast, thinking [FP] (`code.claude.com/docs/en/model-config`)

- Tiers: `low`, `medium`, `high`, `xhigh`, `max` — effort is supported on Fable 5,
  Opus 4.7+ and Sonnet 5 (live `/effort` dialog, verified 2026-07-15). **Default = `high`**
  (`xhigh` on Opus 4.7).
- **Fable 5 specifics** (v2.1.170+): not the default model on any plan (`/model fable`,
  alias `best`); ~2× Opus price; thinking cannot be disabled; `/fast` does not run on it;
  safety classifiers can auto-fall back to Opus mid-session.
- `ultracode` is a **setting, not a tier**: sends `xhigh` *plus* auto dynamic-workflow
  orchestration for substantive tasks; session-only.
- `/fast` — faster output (up to ~2.5×), **not** an effort downgrade; Opus only; research
  preview (`code.claude.com/docs/en/fast-mode`), billed **via usage credits outside
  subscription rate limits** ($10/$50 MTok on Opus 4.8) — never "free on the plan".
- `ultrathink` — one-turn deeper-reasoning keyword (in-context only).
- Adaptive thinking (Opus 4.7+; always-on for Fable 5) triggers reasoning only when the turn
  needs it — do **not** try to manage a thinking budget from the harness.

## /goal [FP] (`code.claude.com/docs/en/goal`)

A shipped slash command. `/goal <condition>` sets a completion condition; a small fast model
re-checks after every turn (judging only what Claude surfaced) and Claude keeps working
across turns until met. `/goal clear`, `/goal` for status. An early rung of the verification
ladder (prompt check → `/goal` → Stop hook → `/code-review` → fresh-context second opinion).

## Code review — built-in surfaces [FP]

Review is a shipped capability — never scaffold a custom `code-reviewer` subagent (the
classic audit offender, see `audit-checklist.md` §3). The surfaces:

- **`/code-review`** — bundled skill: review the **current working diff** for correctness
  bugs and simplification cleanups at a chosen effort level; `--comment` posts inline PR
  comments, `--fix` applies findings to the working tree. Local, free, codebase-aware —
  **the default rung for any substantive change** [FP, `/en/commands`].
- **`/review`** — bundled skill: fast single-pass, **read-only review of a GitHub pull
  request** (no argument → lists PRs via `gh` and asks which to review). It does *not*
  review your working diff — the binary itself redirects: "for your working diff use
  /code-review". The multi-agent PR review at a chosen effort is also `/code-review
  <level> <pr#>` (v2.1.202).
- **`/security-review`** — bundled skill: security review of the pending changes on the
  current branch.
- **`/code-review ultra`** (alias `/ultrareview`; CLI: `claude ultrareview [target]`,
  `--json`, `--timeout` default 30 min) — cloud-hosted multi-agent review of the current
  branch or a PR. First-party economics (`code.claude.com/docs/en/ultrareview`, Jun 2026):
  typically **5–10 min, ~$5–20/run via usage credits**; 3 free runs on Pro/Max (one-time).
  Reserve it for high-stakes gates (security-sensitive change, migration, payment path);
  `/code-review` covers the everyday case. Boundary vs the kit's `/external-audit`:
  `ultrareview` is a paid cloud **diff/PR review** — reach for it when the change itself is
  the risk; the kit's 3-role external audit is subscription-local and audits a
  **deliverable** (executed evidence + process audit + adjudication) — reach for it at
  milestone close / irreversible gates. They compose; neither replaces the other.
- A `REVIEW.md` at the repo root customizes severity calibration
  (`code.claude.com/docs/en/code-review`; tags: Important / Nit / Pre-existing).

Review surfaces are profile-dependent like any tool: bundled skills/plugins can be disabled
or blocklisted per-user (`~/.claude/plugins/blocklist.json`). **Verify a surface exists in
the live session (`/`-autocomplete) before routing a remediation to it** — detect, then
prescribe. Where review sits in the verification ladder — see `harness-discipline.md`.

## Memory [FP] (`code.claude.com/docs/en/memory`)

Two systems, both loaded every session: **CLAUDE.md** (you write) and **Auto memory** (Claude
writes). CLAUDE.md load order broad→specific: managed policy → user `~/.claude/CLAUDE.md` →
project `./CLAUDE.md` or `./.claude/CLAUDE.md` → local `./CLAUDE.local.md`; plus `.claude/rules/*.md`,
`@import` (depth ≤4). Auto memory lives
in `~/.claude/projects/<project>/memory/` with a `MEMORY.md` index (first 200 lines / 25 KB
loaded each session). Command is **`/memory`** (lists loaded files, toggles auto memory).
**There is no built-in `/remember`** — "remember X" is natural-language behavior writing to
auto memory.

**What loads when — and the silent-error surface (verified 2026-06-24, FP `code.claude.com/docs/en/memory`).**
CLAUDE.md is delivered as a **user message after the system prompt**, not in the system prompt
itself — which is why output styles / `--append-system-prompt` carry more weight than CLAUDE.md
(see Output styles below). Loading model:
- **At launch, in full, every session:** all CLAUDE.md + CLAUDE.local.md from root→cwd; `.claude/rules/*.md`
  **without** `paths:` (same priority as `.claude/CLAUDE.md`); `@import`s (expanded at launch — splitting
  into imports does **not** save context tokens); `MEMORY.md` first 200 lines / 25 KB only (excess silently
  not loaded).
- **On-demand:** nested subdir CLAUDE.md (when a tool touches a file in that subtree); path-scoped rules
  (on **read** of a matching file — not on Write, not every tool use); skill bodies; auto-memory topic files.
- **After `/compact`:** project-root CLAUDE.md is **re-read from disk and re-injected**; nested subdir
  CLAUDE.md is **NOT** re-injected until the next file read in that subtree; conversation-only instructions
  are **lost**. ⇒ a subdir-scoped convention you relied on can silently vanish mid-long-session after a
  compact. Make must-not-miss rules always-on (root) or deliver via `SessionStart`/`CwdChanged` hook.
- `--add-dir` dirs do **not** load their CLAUDE.md unless `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`.
- HTML block comments in CLAUDE.md are **stripped** before injection (visible only on direct Read) — fine
  for maintainer notes, but don't hide active instructions there.
- **`claudeMdExcludes`** (settings, any layer incl. local; absolute-path globs, arrays merge) skips ancestor
  CLAUDE.md/rules in monorepos. **Managed-policy CLAUDE.md cannot be excluded** (org instructions always apply).

**Scoped rule delivery — reliability ranking (verified 2026-06-23, re-ground on bump).** To put
a rule "only where it's needed" instead of taxing every turn in root CLAUDE.md, prefer
**nested `<subdir>/CLAUDE.md`**: lazy-loaded **deterministically** when a tool touches a file in
that subtree (native, `code.claude.com/docs/en/large-codebases`) — empirically read and obeyed by
fresh subagents (a directory convention overrode an explicit contrary instruction in test). This is
the reliable mechanism for scoping a campaign / large-feature-area protocol. Do **not** rely on
`.claude/rules/*.md` `paths:` frontmatter for this: it is heuristic and carries an open bug cluster
(#16853 not-loaded-on-matching-read, #16299 loads-globally, #21858 user-level ignored, #23478
Read-only-not-Write, #17204 documented-syntax-wrong) — unfixed on 2.1.x; use it only for nice-to-have
narrowing, make critical rules always-on. Guaranteed delivery for must-not-miss → a `SessionStart` /
`CwdChanged` hook reading `cwd` → `additionalContext`. **A scoped rule must read as a legitimate
project convention, not an imperative** ("always append token X") — a security-conscious model
correctly refuses injection-shaped instructions found in a working directory.

## Skills, commands, MCP, plugins [FP]

- **Skills** — `.claude/skills/` (+ `~/.claude/`), load on demand by description; descriptions
  cost context at start, full body only when used; `disable-model-invocation: true` → zero cost
  until you trigger it. Reference-skills (knowledge) vs action-skills (do something).
- **Slash commands** — `.claude/commands/*.md`; appear in `/`-autocomplete.
- **MCP** — external tools appear as normal tools; `Elicitation`/`ElicitationResult` support input flows.
- **Plugins** — marketplaces `anthropics/claude-plugins-official` (auto-registered) and
  `anthropics/claude-plugins-community` (`@claude-community`); can ship subagents/hooks/skills/
  commands. A plugin directory under `~/.claude/skills/<name>/` auto-loads without any
  marketplace (`claude plugin init <name>` scaffolds one; inspect with `claude plugin list`).
  **Version semantics** [FP, `/en/plugins-reference#version-management`]: the version in the
  plugin's own `plugin.json` is canonical (it wins over the marketplace entry) and acts as
  the **update cache key** — pushing new commits without bumping it ships nothing to
  installed users. Releases pin via `{name}--v{version}` git tags; `claude plugin validate`
  requires plugin.json and the marketplace entry to agree, and installs record the resolved
  `gitCommitSha` (binary-verified, 2.1.210).

## Output styles [FP] (`code.claude.com/docs/en/output-styles`)

Files in `.claude/output-styles/` (or `~/.claude/`, or managed policy) that **modify the system prompt
directly** — set role/tone/format for *every* response. Activated via `/config` → Output style (saved to
`settings.local.json` `outputStyle`); the standalone `/output-style` command was removed in v2.1.91. Read
**once at session start** — a change takes effect only after `/clear` or a new session. Built-ins:
**Default / Proactive / Explanatory / Learning**.

**Silent-error trap — the one reason this is in the kit.** A custom output style's instructions are appended
to the end of the system prompt, and it **omits Claude Code's built-in software-engineering instructions
(how to scope changes, write comments, verify work, security) unless `keep-coding-instructions: true`** is
in frontmatter. The flag **defaults to `false`** — so a custom style authored for "still coding, just
different voice" will silently strip the §5/§8 verification & scoping disciplines unless the author sets it.
Rule: any custom output style used while still doing software work **must** carry `keep-coding-instructions: true`;
omit it only for genuinely non-coding roles (writing/data assistant). Before authoring one, check the built-ins
cover the need. Frontmatter: `name`, `description`, `keep-coding-instructions` (default `false`),
`force-for-plugin` (plugin-only, auto-applies, default `false`).

Comparison of the system-prompt-touching mechanisms: **output style** modifies the system prompt (every turn);
**CLAUDE.md** adds a user message after it (project context); **`--append-system-prompt`** appends without
removing anything (one-off per invocation); **subagent** = own system prompt; **skill** = loaded on invoke.

## Settings, permissions, resilience [FP]

Native enforcement worth knowing before writing manual rules or guard hooks:

- The "default" permission mode is named **Manual** since v2.1.200 (`--permission-mode
  manual` / `"defaultMode": "manual"`; the old `default` spelling is still accepted).
- Deny rules accept a glob in the tool-name position (`"*"` denies all tools);
  `WebFetch(domain:...)` deny/ask/allow overrides the built-in preapproved hosts;
  `~`/`$HOME`-path deny rules also block Bash commands referencing them; Read deny rules
  hide files from Glob/Grep; `acceptEdits` prompts before writing code-executing config
  files (`.npmrc` / `.bazelrc` / `.pre-commit-config.yaml` / `.devcontainer/` …) and shell
  startup files.
- Cross-session `SendMessage` relays carry no user authority — receivers refuse relayed
  permission requests.
- `fallbackModel` setting (ordered list) / `--fallback-model` — automatic model fallback,
  including interactive sessions. Managed settings can pin an allowed version range
  (`requiredMinimumVersion` / `requiredMaximumVersion`).
- **`--safe-mode`** / `CLAUDE_CODE_SAFE_MODE` — start with all customizations (CLAUDE.md,
  plugins, skills, hooks, MCP) disabled: the clean A/B baseline for "model vs harness"
  questions (used by the audit and strip rituals). `disableBundledSkills` /
  `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` hides bundled skills, workflows, and built-in slash
  commands from the model (context-budget control).
- **Native destructive-command block + auto-mode classifier (v2.1.183/193).** Destructive git
  and IaC are blocked **out of the box** — `git reset --hard` / `checkout -- .` / `clean -fd` /
  `stash drop`, `commit --amend` of another author's commit, `terraform` / `pulumi` / `cdk destroy`.
  **Do not re-encode these as custom DENY rules** — §7 is covered natively; a manual guard here is
  redundant obvyazka. The auto-mode classifier is now **diagnosable and configurable**: the denial
  reason surfaces in the transcript, a toast, and `/permissions` → recent denials (v2.1.193); keys
  `autoMode.classifyAllShell` + `autoMode.{allow, soft_deny, hard_deny, environment}` with
  `$defaults` inheritance; the classifier defaults to Sonnet 5 for external sessions,
  pinned per session (v2.1.210). **Since v2.1.207 `autoMode` is no longer read from the
  repo-resident `.claude/settings.local.json`** — put these keys in `~/.claude/settings.json`. `!`-commands now auto-provoke a model response by default — revert with
  `respondToBashCommands: false`.

## Out of scope (API-only — never propose for a CLI-subscription harness)

managed-agents (Memory stores, Dreams, Outcomes), beta headers, `--bare`, `--max-budget-usd`,
prompt-caching / batch / files / citations API, mid-conversation `role:"system"` cache control,
`ANTHROPIC_API_KEY`-dependent flows. (`--bare` is API-only because it **skips OAuth entirely** —
auth must come from `ANTHROPIC_API_KEY` / `apiKeyHelper`, per the headless doc.)

**Watch (re-checked 2026-06-17 first-party; still true 2026-07-15):** the announced
June 15, 2026 move of subscription `claude -p` / Agent SDK usage onto a separate monthly
**Agent SDK credit** was **paused the day it was to take effect** ("nothing changes for
now" — Anthropic Help Center; third split attempt). Headless `claude --print` on an OAuth
subscription (CI, verify-phases) is **fully intact** and draws from normal subscription
limits. `--bare` remains slated as a future default for `-p` (the one mode that skips
OAuth → needs an API key). Re-verify on the next Anthropic advance notice — this watch
item is open, not closed.
