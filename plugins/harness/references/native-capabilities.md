# Native capabilities — what Claude Code already does

Working inventory as of **Claude Code v2.1.220 / the Claude 5 family (Fable 5, Sonnet 5,
Opus 5) model generation** (July 2026). Default model is account-type-dependent [FP,
`model-config`]: **Opus 5** (`claude-opus-5`, v2.1.219+ — now *the* default Opus model;
1M context, $5/$25 MTok, knowledge cutoff May 2026) on Max / Team Premium / Enterprise PAYG;
**Sonnet 5** (v2.1.197+) on Pro / Team Standard / Enterprise seats; Fable 5 is the default on
no account type.

The point of this file: a harness must not reinvent a built-in. Before writing
any custom subagent, hook, skill, or command, confirm the need is not already covered here.
Re-verify with `claude --version` and `/help` — versions drift, and **a tool's absence from
your session's live inventory is an env/profile fact, not product truth** (gating: provider,
telemetry flags, experimental env vars).

**This file is the kit's single version-pinned document.** Every other live doc states
behavior without binding it to a release and points here — a currency pin duplicated in two
places goes stale in one of them silently (`audit-checklist.md` §1 carries the detector).

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

Subagents can nest — **depth 3 by default** (v2.1.219; nesting was turned *off* by default in
v2.1.217, and the older 5-level figure predates that), tunable via
`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` (`=1` disables nesting). Fan-out has **native caps** —
do not re-encode them as a guard hook: **20 concurrent subagents**
(`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, v2.1.217), **200 spawns per session**
(`CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`, v2.1.212 — reset by `/clear`), **200 WebSearch calls
per session** (`CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`, v2.1.212). Only Explore and Plan
omit CLAUDE.md + git context; both are one-shot (no resume). First-party subagent primitives
you should not rebuild by hand: the **in-session forked subagent `/subtask`** (inherits the
full conversation, reuses the prompt cache) — **`/fork` is no longer this**: since v2.1.212 it
copies the conversation into a *background* session with its own row in `claude agents`, so a
harness step that expected an in-session fork must say `/subtask` — frontmatter
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
- Manage with `/workflows`; bundled `/deep-research <question>` (needs WebSearch) — **invoke-only
  since v2.1.218: Claude no longer starts it on its own.** Saved workflows live in
  `.claude/workflows/` (project) or `~/.claude/workflows/` (user), run as `/<name>`.
- Size guideline (advisory) — **default `medium` since v2.1.219** ("aim for fewer than 15
  agents"); values `small` / `medium` / `large` / `unrestricted`. Settable from **any** settings
  file via the **`workflowSizeGuideline`** key (which then *hides* the `/config` row), or
  interactively via `/config` → "Dynamic workflow size" (v2.1.202).
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

## Hooks — 31 events [FP]

Far more than the five most projects use. Full list (`code.claude.com/docs/en/hooks`):

- Session: `SessionStart`, `Setup`, `SessionEnd`
- Per-turn: `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `StopFailure`
- Tool loop: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`,
  `PermissionRequest`, `PermissionDenied`
- Subagent/task: `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`
- File/config: `FileChanged`, `CwdChanged`, `DirectoryAdded` (v2.1.219 — fires when `/add-dir`
  registers a new working directory mid-session), `ConfigChange`, `InstructionsLoaded`
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
- **How to set it — session-wide** (binary- and schema-verified 2026-07-25 on v2.1.220):
  - `effortLevel` in settings — enum `low` | `medium` | `high` | `xhigh` **only**. `max` is
    session-only (use `/effort`); an out-of-enum value here is swallowed by a `.catch()` rather
    than rejected, so a typo costs the level silently while leaving the file valid. `ultracode`
    *is* a settings key (boolean) — a `--settings` layer carrying it starts an `xhigh` session
    (verified 2026-07-26); only the interactive toggle refuses to persist it.
  - `CLAUDE_CODE_EFFORT_LEVEL` — same values **plus `auto`** (= the current model's default).
  - CLI: `claude --effort <level>` for the session (a *launch pin*: `/effort` then reports
    "the launch-effort pin holds effort at X"), `claude agents --effort <level>` as the default
    for dispatched background sessions.
  - **Precedence, measured 2026-07-26 on v2.1.220** (org ceiling ▸ env ▸ launch pin ▸ settings ▸
    model default). `CLAUDE_CODE_EFFORT_LEVEL` wins over everything user-side — including the
    `--effort` flag: with the env set to `auto`, `--effort low` vs `--effort xhigh` produced
    911/953 vs 798/533 output tokens (no effect), while with the env unset the same pair gave
    722 vs 1053 (median, N=3) and `effortLevel` in settings gave 427/493 vs 692/994. The org
    ceiling sits above all of it ("Effort 'X' exceeds your organization's limit …; set to 'Y'").
  - **The trap this creates**: an `env: { "CLAUDE_CODE_EFFORT_LEVEL": … }` block in
    `settings.json` is *still the env var* — it silently outranks that same file's `effortLevel`
    key, the `--effort` flag, and `/effort`, which then answers "Not applied". Pinning effort by
    env in settings is how a harness ends up permanently unable to raise it. Prefer the
    `effortLevel` key. (Project-level `settings.json` is also ignored in an untrusted workspace —
    the setting being present is not evidence it applied.) **Verifying that a level took hold is
    itself hard**: token spend separates tiers only on a task long enough to spend on, and only
    across several runs — on a short prompt, `--effort low` and `--effort xhigh` overlapped
    completely (n=3 each, 2026-07-26), and on a heavy reasoning task the medians parted by ~25%
    while the ranges still crossed. Interactively, `/effort` reports the active level directly;
    that is the answer, not an inference.
- **How to set it per delegate — this is the harness lever.** `effort:` in the frontmatter of
  `.claude/agents/*.md` (also accepted in skill and command frontmatter): a named level, an
  integer, or `inherit`. The **Agent tool overrides only `model` per call, never effort** — the
  level comes from the agent's definition; a dynamic workflow is the surface that *does* take it
  per call (`agent(prompt, {effort})`). Measured 2026-07-26 on v2.1.220, same prompt and same
  parent session: `effort: low` → 862 / 656 output tokens, `effort: xhigh` → 3358 / 3452 (N=2).
  So pinning a cheap level on a mechanical subagent, and a high one on a verifier, is a real
  dial and not decoration. **A delegate that declares no `effort:` inherits the session's
  level** — measured with a hard binary oracle instead of token spend, **varying the session**
  so that inheritance and a fixed default are distinguishable: an agent declaring no `effort:`
  produced the server-tool 400 quoting `'xhigh'` from an `xhigh` session (2/2) and searched
  cleanly from a `high` session (2/2). A fixed model default could not produce that difference.
  An earlier reading here — "an ad-hoc delegate stays at the model default" — rested
  on token spend from a `low` and an `xhigh` parent (937/1550 vs 1043/746): ranges that never
  separated, on the oracle this file marks as weak two bullets above. Declare the level
  explicitly whenever it matters; do not assume a delegate starts cheap.
- **`CLAUDE_EFFORT` reports whoever reads it — session or delegate — at its own level.** It is
  read-only and exported into Bash subprocesses and hook commands (the same value arrives as the
  hook-input field `effort.level` on tool-context hooks); the binary describes it as the active
  level for the current turn *after any silent downgrade for the selected model*. Re-measured on
  v2.1.220 in `claude --print`, each cell read back as set and matched the tier the server-tool
  400 quotes: `high` via the `--effort` flag, `xhigh` via `effortLevel` in settings, `max` via
  the flag. The env path was not re-tested. Inside a **delegate** it reports the *delegate's*
  level, not the parent's — an agent pinned `effort: high` inside an `xhigh` session read back
  `high` and searched cleanly, 2/2. Both earlier readings here — "always `high`, however the
  level was set" and "inside a subagent it read the parent's" — rested on token spend and did
  not survive. The other real channel is the interactive statusline:
  `StatusLineCommandInput.effort.level`, plus **per-agent `effort` in the `subagentStatusLine`
  payload** (v2.1.214, added precisely so agent rows can render model + effort) — the cheap way
  to see "who is running at what" during a fan-out. Headless leaves only token spend — a
  subagent's own transcript at `<session-dir>/subagents/agent-<id>.jsonl` (+ `.meta.json` naming
  its `agentType`) — and that is a **weak** oracle: it separates tiers only across several runs
  on a task substantial enough to spend on (above). The transcript's own per-message effort field
  (announced v2.1.212) was **not** observed in headless session JSONL.
- **Two traps when you raise effort on Opus 5** [FP,
  `platform.claude.com/docs/en/about-claude/models/whats-new-opus-5`]:
  - *Thinking is on by default*, and disabling it is accepted **only at effort `high` or below** —
    `thinking: {"type":"disabled"}` with `xhigh`/`max` returns 400, enforced per request. Also:
    with thinking disabled the model can write a tool call into its text output instead of
    emitting a `tool_use` block, so the tool never runs and nothing errors.
  - *The open client-side bug this collides with — **`WebSearch` dies at `xhigh` and `max`***
    (anthropics/claude-code **#76689**, **#79798**, family
    of **#68797**; all open as of 2026-07-26). The server-tool sub-request carries the session's
    **current effort** while **omitting** the thinking config, so the API answers `400
    output_config.effort 'xhigh' is not supported when thinking is disabled on this model`.
    **The trigger is the tier, not how the tier was set** — re-measured 2026-07-26 on CC 2.1.220,
    Linux CLI, one prompt, oracle read straight off `--output-format stream-json`, plus a control
    that `WebSearch` was called at all:

    | effective tier | how it was raised | `WebSearch` |
    | --- | --- | --- |
    | `high` | `--effort high`, `claude-opus-5[1m]` | **ok 0/2** — returned 7 results |
    | `xhigh` | `effortLevel` in settings, `claude-opus-5` | fails 3/3 |
    | `xhigh` | `effortLevel` in settings, `claude-opus-5[1m]` | fails 4/4 |
    | `xhigh` | `--effort xhigh` (settings also said `xhigh` — confounded, see below) | fails 3/3 |
    | `max` | `--effort max` | fails 2/2 |
    | `xhigh` | `CLAUDE_CODE_EFFORT_LEVEL` (env) — settings also said `xhigh`, confounded | fails 2/2 |

    Every rejection in the 14 re-measured runs quotes the tier actually in force — `'xhigh'` ×24
    and `'max'` ×4, two per run — so none of those rows rests on an assumed level. Each row is a
    **session-level** measurement: the env row too, re-run with the same prompt and oracle rather
    than borrowed from a delegate. That env row shows only that the effective tier was `xhigh`,
    not that the environment variable is what set it — the same confound as the flag row. What
    the *env mechanism* does own is carried by the delegate matrix below, where `effort: high` in
    frontmatter fails under an env pin and succeeds without one: only the env layer explains
    that. **Mechanism
    independence rests on the two unconfounded flag rows, not on the `--effort xhigh` row**, which
    agreed with the settings value and therefore proves nothing on its own: `--effort high`
    overrode settings' `xhigh` *downward* (`CLAUDE_EFFORT` read `high`, search restored) and
    `--effort max` overrode it *upward* (the 400 quotes `'max'`). Both directions are the flag
    winning. `ultracode` resolves to `xhigh` — first-party strings in the 2.1.220 binary say so
    verbatim ("Ultracode runs at xhigh effort") — so it inherits the failure without a separate
    run. Client-side thinking blocks are present in the
    failing runs too, so nothing looks wrong locally. Reported on Opus 4.8; transcript-scan
    in #76689 puts the regression at v2.1.207. Three properties make it a harness problem, not a nuisance: **(a)** neither
    `alwaysThinkingEnabled` nor `MAX_THINKING_TOKENS` works around it; **(b)** it lands mostly in
    **subagents** (8 of 10 reported failures) — a research delegate keeps running and returns a
    report with a whole source tier missing; **(c)** it is **silent to the caller, though not
    unflagged**. The `tool_result` itself is marked: `is_error: true`, body prefixed
    `API Error: 400 …` — verified on 30 of 30 failing runs, session-level and delegate-level
    alike, so a scan of `tool_result` records finds it. What is missing is an assistant-level
    API-error record, so a filter on `isApiErrorMessage` ("true when this assistant message wraps
    an API error") does not see it — and, decisively, **a parent sees only a delegate's final
    text, never its `tool_result`s**. That is where the silence actually lives: the delegate
    knows it failed and the parent cannot tell. **The ceiling is Opus 5's, and the escape is per-delegate** — two further matrices,
    same day, same oracle.

    *Which model is affected.* As the **session** model at `xhigh` and `max`,
    `claude-sonnet-5` and `claude-fable-5` searched cleanly — 0/8 failures, real results in
    every run — where `claude-opus-5` and `claude-opus-5[1m]` failed. The tier rule belongs to
    Opus 5, not to Claude Code: Sonnet 5 and Fable 5 keep search **at `xhigh` and `max`** — the
    two tiers that break Opus 5. Their lower tiers were not run (they are safe on Opus too).

    *What a delegate needs in order to search.* Session on `claude-opus-5` at `xhigh`, delegate
    asked for one `WebSearch` call and nothing else. Every row below was measured through
    **YAML frontmatter in `.claude/agents/*.md`** — the path this table prescribes:

    | agent frontmatter | ran on | `WebSearch` |
    | --- | --- | --- |
    | `effort: high` | opus-5 | ✅ 2/2 |
    | `model: claude-sonnet-5` | sonnet-5 | ✅ 2/2 |
    | *nothing declared* | opus-5 | ❌ 2/2 |
    | `effort: xhigh` | opus-5 | ❌ 2/2 |
    | `tools:` narrowed, `WebSearch` omitted | sonnet-5 | ❌ 2/2 — tool absent, never called |
    | `effort: high`, session pinned by **`CLAUDE_CODE_EFFORT_LEVEL`** | opus-5 | ❌ 2/2 |
    | `model: claude-sonnet-5`, session pinned by **env** | sonnet-5 | ✅ 2/2 |

    The same seven rows were also run through `--agents` (programmatic definitions), with
    identical outcomes — so the rule is a property of the agent definition, not of one load path.
    A **plugin-shipped** agent honours `effort:` too (`effort: high` in a plugin agent's
    frontmatter searched 2/2 from an `xhigh` session).

    So the per-delegate `effort:` dial **does** save you — correcting an earlier reading in this
    file — because the sub-request carries the *delegate's* effective level, not the session's.
    Its one blind spot is the env layer: `CLAUDE_CODE_EFFORT_LEVEL` outranks agent frontmatter,
    so `effort: high` never takes hold there and only the model pin survives. A delegate that
    declares nothing **inherits the session's level** — the discriminating control is a varied
    session: the same undeclared delegate fails 2/2 from an `xhigh` session and searches 2/2 from
    a `high` one, which a fixed model default could not produce. For a **built-in** delegate the
    Agent tool's per-call `model` override is the same escape, measured: `general-purpose`
    spawned plainly from an `xhigh` session failed 2/2, and with `model: sonnet` on the call it
    searched 2/2. `WebFetch` is unaffected **as the upstream thread reports** — not re-measured
    here. The prescriptive form of this — what to put in an
    agent you spawn for research — is in `harness-discipline.md` (Subagents §). Detection: grep transcripts
    for the signature, and glob **one level deeper** than the session file —
    `<session-dir>/subagents/agent-*.jsonl` (`isSidechain` is not a usable subagent marker).
    **Method warning, and this entry is the cautionary tale — twice over.** An `env`-block level
    in `settings.json` overrides the `--effort` flag, so a probe that *sets* `xhigh` on the
    command line while the file pins something else measures the file — a whole matrix of green
    runs can mean "never actually left `high`". This entry has since been wrong in both
    directions: a first matrix varied only mechanisms that all break and reached the right
    conclusion by accident; a second one produced green rows for settings, flag and `ultracode`
    that re-measurement could not reproduce at all — the settings and flag rows came back 12/12
    red where 10 passes had been claimed — greens with no independent check that the level had
    ever taken hold. A third round then shipped the right conclusions on insufficient evidence:
    the "delegate inherits the session's level" claim held the session at `xhigh` in all 20 rows,
    so it could not distinguish inheritance from a fixed default, and a table headed "agent
    frontmatter" carried five rows measured through a different load path. **What caught that was
    a fresh-context refuter, not a third self-check** — the author had already reviewed the same
    diff and passed it. Four rules follow. Confirm the level took hold **by an oracle the claim
    does not depend on** — here the API error names the tier it rejected, so a failing run states
    its own effort. **Vary the variable the conclusion names**; a row that holds it constant
    cannot support a causal claim, however many times it is repeated. Read the oracle off
    `--output-format stream-json` rather than hunting a transcript path (slugs fold
    `_` to `-`; a wrong path returns a confident, empty "no failures"). And confirm the
    *negative* — no error signature proves nothing until the same scan shows `WebSearch` was
    called at all.
  - *`max_tokens` is a hard cap on thinking **plus** response text.* First-party guidance: at
    `xhigh`/`max` set it large "so the model has room to think and act across subagents and tool
    calls" (in Claude Code: `CLAUDE_CODE_MAX_OUTPUT_TOKENS`). A budget sized for `high` can end
    the turn before the tool call happens — which reads as a lost capability, not a truncation.
- **Fable 5 specifics** (v2.1.170+): not the default model on any plan (`/model fable`,
  alias `best`); ~2× Opus price; thinking cannot be disabled; `/fast` does not run on it;
  safety classifiers can auto-fall back to Opus mid-session.
- `ultracode` is a **setting, not a tier**: sends `xhigh` *plus* auto dynamic-workflow
  orchestration for substantive tasks; session-only.
- `/fast` — faster output (up to ~2.5×), **not** an effort downgrade; **Opus 5 and Opus 4.8
  only since v2.1.219** (Opus 4.7 was dropped from fast mode); research preview
  (`code.claude.com/docs/en/fast-mode`), billed **via usage credits outside subscription rate
  limits** ($10/$50 MTok) — never "free on the plan".
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
  **the default rung for any substantive change** [FP, `/en/commands`]. Since v2.1.218 it runs
  as a **background subagent** (review work no longer fills the conversation).
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

**Counter-pressure from the model side — don't *instruct* self-verification** [FP,
`whats-new-opus-5`]. The current Opus generation "verifies its own work without being told to",
and first-party guidance is explicit: **remove verification instructions carried over from
earlier models** ("include a final verification step", "use a subagent to verify") — they cause
**over-verification**. This does not retire the ladder: the ladder's rungs are *external*
(`/code-review` on the diff, a fresh-context refuter, `/external-audit` at a gate), and an
independent evaluator is not the same thing as telling the author to check itself
(`harness-discipline.md`, §8 of the practice baseline). What it does retire is prompt-level
nagging — the "remember to verify" line in CLAUDE.md and the "then verify with a subagent" tail
on a task prompt. Same model generation also delegates to subagents more readily on its own.

**Review is invoke-only — the rung has to be pulled.** Since v2.1.215 Claude no longer runs
`/verify` or `/code-review` on its own (`/deep-research` joined them in v2.1.218). A
verification ladder that assumed "the model will reach for review on a substantive change" is
now a ladder with a missing rung: the call has to come from the operator, a CLAUDE.md duty
line, a slash command, or a hook. Prefer the deterministic carriers when it must happen every
time (`harness-discipline.md`, verification ladder).

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
  Invocation control is two independent flags (verified 2026-07-16, `/en/skills`):
  `disable-model-invocation: true` = only the user triggers it (side-effect workflows);
  `user-invocable: false` = only Claude triggers it — hidden from the `/` menu, made for
  background knowledge (first-party example: a `legacy-system-context` skill). **Exact
  spelling `user-invocable`** — the `user-invokable` variant seen in the wild is silently
  ignored. `context: fork` (+ `agent: <type>`) runs the skill body as the prompt of a forked
  subagent — the body never enters main context, only the result returns; combine with
  read-only `allowed-tools` for knowledge lookups over a docs corpus. **Since v2.1.218 a
  `context: fork` skill runs in the *background* by default** — the turn continues without its
  result. So a fork-skill whose answer the current turn depends on **must** carry
  `background: false` in frontmatter; without it the harness step silently proceeds unanswered.
  (This generalizes the long-standing incompatibility with `AskUserQuestion`: a fork could never
  prompt the operator because it always ran detached — that is now the default path, not an edge
  case.) Frontmatter booleans also accept `yes`/`no`/`on`/`off`/`1`/`0` (v2.1.218).
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
- **A bad `permissions.defaultMode` silently voids the whole settings file.** Most keys are
  declared `.optional().catch(...)`, so a bad value is dropped and the rest of the file still
  loads — `effortLevel` behaves exactly this way. `defaultMode` has **no `.catch()`**: an
  out-of-enum string fails the parse and the *entire* file is discarded — hooks (including the
  guard hook meant to be the hard floor), `permissions.allow`/`deny`, `effortLevel`, `language`,
  `enabledPlugins`, statuslines. Nothing is printed; the session simply runs unconfigured.
  Measured 2026-07-26 on v2.1.220 with a differential oracle: a `--settings` layer carrying
  `{"language":"french", …}` answered in French with a valid `defaultMode` and fell back to the
  user-level language with an invalid one (n=2 each). Accepted values:
  `default` · `manual` (alias of `default`) · `acceptEdits` · `bypassPermissions` · `plan` ·
  `dontAsk` · `auto`. Worth a one-line check anywhere settings are generated or edited by
  tooling — and note that a validator omitting `manual` rejects a valid config:
  ```bash
  jq -e '.permissions.defaultMode // "default" |
    IN("default","manual","acceptEdits","bypassPermissions","plan","dontAsk","auto")' \
    ~/.claude/settings.json
  ```
  The general lesson beyond this key: **an invalid config value is not guaranteed to degrade
  gracefully.** Whether a typo costs one setting or all of them depends on a `.catch()` you
  cannot see from the file, so verify a setting *applied* — by an observable behaviour it
  controls — rather than that it is present.
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
  pinned per session (v2.1.210). A **PreToolUse hook `ask` now floors the auto-mode decision
  at a prompt** for unsandboxed Bash (v2.1.211) — the classifier can no longer silently
  downgrade a hook `ask`, so a guard hook stays authoritative over auto mode (consistent with
  "hooks are deterministic enforcement", above). **Since v2.1.207 `autoMode` is no longer read
  from the repo-resident `.claude/settings.local.json`** — put these keys in `~/.claude/settings.json`. `!`-commands now auto-provoke a model response by default — revert with
  `respondToBashCommands: false`.
- **The classifier absorbed more of the prompt surface (v2.1.218).** The dangerous-`rm`,
  background-`&` and suspicious-Windows-path checks **no longer open a permission dialog** —
  the auto-mode classifier adjudicates them; and plan mode under auto no longer prompts for
  Bash the static analyzer can't prove read-only. Consequence for a harness: fewer of these
  reach the operator as a prompt, so a project rule that *counts on the dialog appearing*
  should become a `deny`/`ask` rule or a hook (which still floors the decision, above).
- **Bash permission parsing was tightened in v2.1.214–216** — commands over 10,000 characters
  always prompt; fail-closed on file-descriptor redirect forms the analyzer parses differently
  than bash; `docker`/Podman daemon-redirect flags (`--url`, `--connection`, `--identity`,
  remote mode) now prompt; and **non-ASCII word-boundary parsing was aligned with real shell
  parsing**. That last one is the one to carry into any project guard that inspects the command
  string itself — a hand-rolled matcher still splits on its own idea of a word boundary.
- **Sandbox keys**: `sandbox.filesystem.disabled` (v2.1.216 — skip filesystem isolation while
  keeping network/seccomp isolation; macOS + Linux/WSL only, ignored on native Windows, and
  managed settings can lock it) and `sandbox.network.strictAllowlist` (v2.1.219 — deny
  non-allowlisted hosts for sandboxed commands **without prompting**).

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
