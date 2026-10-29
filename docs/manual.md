# The manual — working by the harness

**English** · [Русский](manual.ru.md)

What to type, when, and what to check, from the first install to month six of a project. You work
on your project; the commands carry the way of working, so you don't have to think about how to
make the agent work well.

## Your sequence

| Situation | Type |
|---|---|
| Any session, first thing — or whenever unsure | `/harness:start` |
| A new change | `/harness:task <what you want>` |
| A bug | `/harness:bugfix <the bug>` |
| A raw idea you want discussed or challenged first | `/grill-with-docs <the idea>`, then `/harness:task` |
| A risky change is built | `/harness:check` (ordinary change: `/code-review`) |
| End of the session | `/harness:wrap` |
| Work too big for one session | `/harness:task` → `/to-spec` → `/to-tickets` → `/harness:wrap`; then per ticket: `/harness:tests <ticket>` and, in a fresh session, `/harness:build <ticket>` |
| A task finally solved after a long search, or one that keeps coming back | `/harness:skill <what it does>`, later `/harness:trajectory` |

`/harness:start` reads the repository and tells you which of these comes next, with its argument
filled in. The `/harness:*` commands carry the prompts that were measured, so nothing long is typed
by hand; they cost no context until you type them.

The interview, review and fix prompts inside the commands are the ones that were measured; the
tests and build commands adapt the measured whole-spec prompts to a ticket. The *How we work* block
in `CLAUDE.md` holds the same flow without a command: given a plain request, sessions interviewed,
wrote the spec and reported the test command with its output in 9 of 9 runs. The commands add no
measured quality on top of it; they are there so you always know what to type next.

## Setup

**Once per machine.**

```
/plugin marketplace add nikitaCodeSave/claude-code-harness
/plugin install harness@claude-code-harness
/plugin install mattpocock-skills --marketplace mattpocock/skills
```

What you install from `/plugin` takes effect when its menu closes.

Pocock's README also lists an official-directory route, `mattpocock-skills@claude-plugins-official`.
Pick one route. Don't also copy the skills into a project with skills.sh, and don't also enable the
plugin on your claude.ai account, which syncs it into terminal sessions as `mattpocock-skills@synced`:
either way every skill comes twice.

Then, in your **user** settings (`~/.claude/settings.json`):

```json
{
  "permissions": { "deny": ["Skill(mattpocock-skills:tdd)"] },
  "extraKnownMarketplaces": {
    "claude-code-harness": {
      "source": { "source": "github", "repo": "nikitaCodeSave/claude-code-harness" },
      "autoUpdate": true
    },
    "mattpocock": {
      "source": { "source": "github", "repo": "mattpocock/skills" },
      "autoUpdate": true
    }
  }
}
```

The deny blocks `/tdd` under its short name too. `autoUpdate` turns on updates for both
third-party marketplaces, where they are off by default. If your settings set
`DISABLE_AUTOUPDATER`, `DISABLE_UPDATES` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`, plugin
auto-update is off until you also set `"FORCE_AUTOUPDATE_PLUGINS": "1"` under `env`. Merge these
keys into the file you have; don't replace it.

**Once per project.** Open Claude Code **at the repository root** and say:

> set up Claude Code harness in this project

It reads the repository, picks the path (new / existing / already has a harness), asks only what
the code cannot tell it, and hands over. Then run `/setup-matt-pocock-skills` once: it records the
tracker (GitHub, GitLab or local files), the triage labels and where domain docs live.

**Every session starts at the repository root.** The deny list in `.claude/settings.json` loads from
the directory a session starts in. A session started inside a package runs without it.

## A new change — one session

```
/harness:task  →  answer the questions  →  skim the spec  →  build, same session
   →  "done" with command and output  →  /code-review or /harness:check  →  /harness:wrap
```

**1. `/harness:task <what you want>`.** Say what you want in your own words, in any language, and
any interface you already fixed (module, signature, error type).

**2. Answer the questions.** This is where your time goes, and it is the step that pays. Where the
owner did not correct the agent's final report: without an interview, 3 of 9 runs reached full
acceptance; with one, 7 to 9 of 9. An owner who corrected the report got 5 of 9 without an
interview, by doing that correcting themselves. Say decisions meant "for later" now, once.

**3. Skim the spec when it lands.** Check three things:
- the interface you fixed is there word for word;
- the non-goals are yours;
- each criterion is something a test could fail.

Correct it now; it is the cheapest moment. One dropped interface line once zeroed an acceptance
suite.

**4. Let it build in the same session.** Don't `/clear` between spec and build. The same session
held full acceptance in 8 of 9 runs, the cheapest flow that held that rate; a fresh session
building from the file alone got 7 of 9. One implementer — no subagent fan-out on a change this
size.

**5. Read the "done".** It must contain the command and its output. "Tests pass" with nothing under
it is not done — ask: `Show the command you ran and its output.`

**6. Review by risk.**
- **Ordinary change:** `/code-review` on the diff. At medium effort it also reports cleanups and
  `CLAUDE.md` conventions; fix what affects correctness, the rest is optional.
- **High-stakes change** — security, migrations, parsers, invariants, anything that "looks done" and
  would be expensive if wrong: `/harness:check`. A fresh read-only reviewer that hasn't seen the
  session's reasoning reviews the diff against the spec; the session reproduces each finding
  before changing anything, fixes the real ones and rejects the rest, at most three rounds. The
  measured review ran in a separate session; the command uses a fresh subagent for the same
  reason — a reviewer who hasn't seen the reasoning.

**7. `/harness:wrap`.** Decisions into ADRs, new terms into the glossary, the check's output,
finished or dropped work closed, what is left, and a commit that says what changed and why —
including every file it deletes.

## A raw idea — discuss it first

When the idea itself is unsettled, or you want it challenged before any spec, start with Pocock's
grilling and build in the same session:

- `/grill-with-docs <the idea>` — a relentless interview that also writes terms into `GLOSSARY.md`
  and decisions into ADRs as they settle;
- `/grill-me` — the same interview when the question isn't about this codebase.

Then `/harness:task` in the same session: it asks only what the spec still needs, writes it and
builds. A grilling before the build has not been measured on its own; the interview inside
`/harness:task` is the measured default for a task that is already clear.

## A bug

`/harness:bugfix <what happens, what should happen>` — the agent reproduces it with a failing test
first, shows it failing, then fixes it and shows the same test passing. That is diagnosis, not a
test-first ritual. On a hard bug the agent may pull in `diagnosing-bugs` itself. End with
`/harness:wrap`.

## Work that won't fit one session

Use this only when the work really does not fit one session. Signs:
- the session says so (the *How we work* block asks it to);
- the spec has several independent deliverables;
- the context is filling up before the build starts.

On features that fit one session, a ticket flow (without the tests-first session below) cost 11×
the main flow, took five times the owner's turns and lost a decision — so it is for work that
really doesn't fit.

**1. Settle it, then cut it.** `/harness:task` (or a grilling) settles what is wanted; stop before
the build. With a tracker, `/to-spec` writes the spec into it from the conversation; without one,
let the session write `specs/<slug>.md`. Then `/to-tickets` in the same context: vertical slices,
each sized for one fresh session, with blockers declared. Finish with `/harness:wrap`: every
decision goes into an ADR before you leave. A decision kept anywhere but an ADR — even as an
out-of-scope note in the spec — can be re-asked in a later session and dropped by an owner who has
forgotten it.

**2. For each ticket — two sessions.**
- `/harness:tests <ticket>` in its own session. Tests from the ticket's criteria, failing for now;
  each must fail on its own assertion, not on an import error, which also catches a criterion that
  is already true at the base commit. The command commits them and gives you the commit id.
- `/harness:build <ticket>` in a fresh session. It builds against those tests without editing them,
  shows with `git diff` that they stayed untouched, and commits. Close the ticket afterwards —
  `/harness:wrap` proposes it — because an open ticket keeps the tickets it blocks waiting.

  For a hard guarantee that the tests can't be edited, start that session with:

  ```
  claude --settings '{"permissions":{"deny":["Edit(./tests/acceptance/**)","Bash(chmod:*)"]}}'
  ```

  The deny stops the edit tools and recognisable shell writes (redirects, `tee`, `sed -i`), not a
  script that opens the file itself — which is why the build also shows the `git diff`.

- `/harness:check` when the ticket is risky, then `/harness:wrap`.

Why two sessions: acceptance tests written from the spec by a separate session, read-only for the
implementer, gave the best result measured (9 of 9). Per ticket this extends that result; it is not
measured on its own.

**One ticket at a time.** `/implement-spec` builds ready tickets in parallel. In the lab, a pipeline
that ran 12–22 subagents together with grilling, tickets and `/tdd` cost 3.1–4.4× a sequential flow
for the same acceptance (those factors were not separated); a controlled external study that
isolated parallelism saw parallel subagents lose resolve rate on bounded tasks.

## Grow the project's harness: project skills

The harness in a production project grows with it. Not at setup — from tasks the project actually
solved. A task that took a long search to get right, or one that keeps coming back, becomes a
project skill in `.claude/skills/`, committed with the project, so the next session does it
directly.

1. **Solve the task in a session**, however long it takes, until the result is right.
2. **`/harness:skill <what it should do>`** in that same session. The agent writes the skill from
   everything the session learned: when to use it, the shortest path that worked, the inputs, where
   results go, the check that proves it worked, and the traps it hit — as logic, not as a pile of
   examples.
3. **Run the task again in a fresh session** with the skill in place. It will get the right answer,
   often the long way round.
4. **`/harness:trajectory`** in that session. The agent lists every tool call in order — what it
   took from each and where it put it — marks the wasted ones, writes the shortest chain a person
   would take, and changes the skill's logic to lead there. You confirm the diff.
5. **Repeat 3–4** until a run takes the shortest chain. Repeat again when the skill grows.

Helpers that write and check skills better than a bare prompt — the command uses whichever is
installed:

- [`skill-conductor`](https://github.com/smixs/skill-conductor) — skill architecture first, then
  evals and a gated improvement loop;
- [`developing-ai-agents`](https://github.com/ilkruglov/developing-ai-agents-skill) — design and
  debugging of agents, when the skill runs an agent loop;
- `writing-for-agents` from mattpocock-skills, already installed;
- `skill-creator` from Anthropic's plugin directory.

None of them, and not this procedure, is measured in the lab. For a skill whose result matters,
write a few evals for it before tuning — a check that can fail beats a smoother trajectory.

`/retro` sits next to this: after a session that was harder than it should have been, it proposes
checks and pointers for the environment rather than a skill.

## Other situations

| You have | Type | Notes |
|---|---|---|
| A large effort whose route you can't see yet | `/wayfinder` | Charts decision tickets and resolves them one at a time. It plans; it does not build. |
| A decision only someone else can make | `/to-questionnaire` | Turns it into a questionnaire for that person. |
| An explanation that didn't land | `/wait-what` | Re-pitches it with the context you're missing, in the glossary's words. |
| Bug reports and requests from other people | `/triage` | Tickets you generated yourself don't belong there. |
| A session that was harder than it should have been | `/retro` | Proposes checks and pointers; you pick. Prefer a check that can fail over a new line of prose. |
| A design question that talking won't settle | ask for a throwaway prototype | `prototype` is model-invoked. |
| A codebase that feels like mud | `/improve-codebase-architecture` | A survey with candidates; each re-enters the main flow. Not measured here. |
| Work moving to a colleague, another directory or another harness | `/handoff` | |
| Not sure which Pocock skill fits | `/ask-matt` | Routes over the Pocock skills; `/harness:start` covers this flow. |

## Knowledge between sessions

A project worked on for months needs every new session to start with its language and its
decisions, not with the first conversation. The harness keeps them in versioned files:

- **Terms** → `GLOSSARY.md`, or `GLOSSARY-MAP.md` pointing at one glossary per bounded context.
- **Decisions** that later work must follow, including ones you mention "for later" → `docs/adr/`,
  or the decision log the project already keeps, written in the session where they were made.
- **Procedures** the project has solved → project skills in `.claude/skills/`.
- **Before changing an area**, the session reads the glossary entries and the ADRs that touch it,
  skipping those marked deprecated or superseded.
- **Work in flight** lives in the open spec or the tracker. Nothing else.
- **A changed decision** → a new ADR; the old one's status becomes `superseded by NNNN`. That status
  line is the only edit an accepted ADR takes.
- **Finished or dropped work leaves no files.** A finished, reviewed spec file goes once every line
  lives in a test, an ADR, the glossary or the commit message; a spec in a tracker is closed there. Work you explicitly drop goes
  too — spec, tickets (`wontfix`), acceptance tests and code; a request you rejected for good goes to
  `.out-of-scope/`. A research note in `docs/research/` lasts until its decision is recorded.
  `/harness:wrap` proposes each removal and acts after you confirm, committing the work first. History
  is git — no archive folders.
- **No auto memory.** The settings template turns it off: memory Claude writes itself, outside
  review, keeps facts the project has revised.

`/harness:wrap` writes the terms and decisions and closes finished or dropped work at the end of every
session.

What was measured: three features in new sessions, with an owner who never repeated earlier
decisions.
- A frontier model kept them in 3 of 3 runs even without these rules — it wrote them down on its own.
- With the rules it also kept 3 of 3, at about +17% cost.
- In a single smoke run, a weaker model kept 8 of 19 checks without the rules and 18 of 19 with them.

So the rules are insurance. Months of accumulation — dozens of features, a spec file that keeps
growing — were not modelled.

## Context at phase boundaries

| Boundary | Do |
|---|---|
| Interview → spec → build | Continue in the same session (measured above). |
| Grilling → `/harness:task` | Continue — the settled answers are the input. |
| `/to-spec` → `/to-tickets` | Continue — one context. |
| Tests session → build session | New session: the implementer must not have written its own oracle. |
| Ticket → next ticket | New session; each ticket is self-contained. |
| A session left waiting | A large session idle for about an hour is compacted on its own; when you return, type `Re-read specs/<slug>.md before continuing.`, or turn it off in `/config` → Idle compaction. |
| Context getting long | Mid-phase, keep going or hand a scoped piece to a subagent. At a boundary, prefer continuing or `/clear`; `/compact` is the last option (Pocock's `ask-matt`). After any compaction, type `Re-read specs/<slug>.md before continuing.` Scope limits live in the spec file because compaction is reported to drop them more often than requirements — one external study, not verified here. |

## Large, multi-component repositories

- **Start at the root.** A component's `CLAUDE.md` loads when work touches its directory, so its
  commands and invariants cost nothing elsewhere.
- **Contracts between components are the riskiest seam.** Changing one means an ADR plus the
  updated check both sides run, before the change. Contract paths sit under `ask` in settings.
- **Tickets stay vertical slices** even when a deliverable crosses components.
- **Teams:** keep a short `REVIEW.md` by code owners — what failure looks like here, which paths
  always need a person, a cap on nits. Keep it a regular file: the review service skips a symlinked
  one and cuts one past its size limit.
- **Who reviews is set by risk, not by author** (Anthropic's account of how its Claude Code team
  reviews):

  | Risk | Reviewers |
  |---|---|
  | Low | Green automated checks |
  | Medium | One person |
  | High | Two people |

  Sensitive paths and CI workflows always need a person. The person who directed the agent counts as
  one reviewer; an agent's approval does not count as a person's.

## Don't

| Don't | Why |
|---|---|
| Use `/tdd`, or prescribe red-green-refactor to the implementer | A flow without it reached a mutation score within 0.05 of a pipeline that drove `/tdd`. Its suite included acceptance tests from a separate session, so the comparison is "independent tests, no ritual" against "ritual". An external study found no gain from test-first at 3–8.5× the tokens. Tests written beforehand by *another* session and a failing check before a bug fix are not this ritual. |
| Use the ticket flow for work that fits one session | 11× the cost, five times the owner's turns, and one lost decision (above). |
| Fan out parallel implementers on a bounded change | See "One ticket at a time". |
| Build in a fresh session from the spec file alone | 7 of 9 against 8 of 9 in the session that wrote it. If it must be fresh, write the acceptance tests first (9 of 9). |
| Accept "tests pass" without output | That is a claim, not evidence. |
| Review until the reviewer is happy | A reviewer asked to find problems always finds something. Correctness only, three rounds. |
| Write project skills up front, or add custom agents, hooks or rulebooks | A skill grows from a task the project solved; everything else is paid on every turn. |
| Start a session journal the project doesn't keep | It duplicates the spec, the ADRs and git. |
| Keep finished specs or an archive folder "for reference" | Sessions read them as live requirements; git keeps the history. |

## It's working if

- Each session starts with `/harness:start`, and you never wonder what to type next.
- Sessions ask questions before writing code, about your domain rather than the obvious.
- A spec exists for every non-trivial change, with your interface in it word for word.
- Every "done" carries a command and its output.
- When you state a decision once, an ADR appears in that session, and a later session cites it
  without being told.
- `specs/` holds only open work, and every ADR a newer one replaced says so in its status.
- Tasks that recur are project skills, and their runs get shorter.
- `CLAUDE.md` gets shorter over time, not longer.

When one of these slips repeatedly with the command typed, that is a finding about the harness —
report it rather than adding rules.

## Upkeep

- **Every 3–6 months, or after a model upgrade**: say `audit my Claude Code harness`. It reports what
  to cut first; the cut matters more than the additions.
- **Plugins**: auto-update as set up above, or update deliberately with
  `claude plugin update <plugin>@<marketplace>`.
- Never pin a model or Claude Code version in a project file.

## Where the numbers come from

The conditions behind every number on this page are in the README's *How we work — and why*.
