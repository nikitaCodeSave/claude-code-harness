# The manual — working by the harness

**English** · [Русский](manual.ru.md)

What to type, when, and what to check, from the first install to month six of a project. The
harness itself is small: a `CLAUDE.md` with a *How we work* block, a deny list, and the process
tools from [mattpocock-skills](https://github.com/mattpocock/skills). This page is the flow those
pieces add up to.

Think in **flows, not skills**. There is one main flow for a change that fits one session, and a
few branches off it: work that spans sessions, a foggy effort, a bug, work that arrives from other
people. Each section gives the lines to type.

The interview, review and fix lines are the prompts that were measured; the tests and build lines
adapt the measured whole-spec test and build prompts to a ticket. In the measurement a script
write-protected the tests during the build; here a deny rule plus a `git diff` check stands in.
The *How we work* block asks every session to follow the same flow unprompted, which has not been
measured on its own — where a session skips a step, type its line from here.

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

The deny blocks `/tdd` under its short name too, so `/implement` builds without it. `autoUpdate`
turns on updates for both third-party marketplaces, where they are off by default. If your
settings set `DISABLE_AUTOUPDATER`, `DISABLE_UPDATES` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`,
plugin auto-update is off until you also set `"FORCE_AUTOUPDATE_PLUGINS": "1"` under `env`. That
keeps Claude Code itself pinned while plugins update. The update runs in the background of an
interactive session and loads in the next one. Merge these keys into the file you have; don't
replace it.

**Once per project.** Open Claude Code **at the repository root** and say:

> set up Claude Code harness in this project

It reads the repository, picks the path (new / existing / already has a harness), asks only what
the code cannot tell it, and hands over. Then run `/setup-matt-pocock-skills` once. It records the
tracker (GitHub, GitLab or local files), the triage labels and where domain docs live.

**Every session starts at the repository root.** The deny list in `.claude/settings.json` loads from
the directory a session starts in. A session started inside a package runs without it.

## The main flow — a change that fits one session

```
describe + interview line  →  answer questions  →  spec file  →  build, same session
        →  "done" with command and output  →  /code-review  →  commit
```

**1. Describe the change and ask for the interview.**

```
<what you want, in your words; any interface you have already fixed — module, signature, error type>

Interview me until you could write the spec, then write it to specs/<slug>.md. The spec says what
and why (acceptance criteria as checkable statements, non-goals), not how. Copy any interface my
request fixes (module paths, signatures, error classes) into it verbatim. Then build it. Done means
the test suite passes and the spec's criteria are covered; report the command and its output.
```

If `/setup-matt-pocock-skills` set a spec location in the *Agent skills* block, use that one.

**2. Answer the questions.** This is where your time goes, and it is the step that pays. Where the
owner did not correct the agent's final report: without an interview, 3 of 9 runs reached full
acceptance; with one, 7 to 9 of 9. An owner who corrected the report got 5 of 9 without an
interview, by doing that correcting themselves. Say decisions meant "for later" now, once. The
session puts them in an ADR, and later sessions read them.

**3. Skim the spec when it lands.** Check three things:
- the interface you fixed is there word for word;
- the non-goals are yours;
- each criterion is something a test could fail.

Correct it now; it is the cheapest moment. One dropped interface line once zeroed an acceptance
suite.

**4. Let it build in the same session.** Do not `/clear` between spec and build. The same session
held full acceptance in 8 of 9 runs, the cheapest flow that held that rate. A fresh session
building from the file alone got 7 of 9. Use one implementer — no subagent fan-out on a change this
size.

**5. Read the "done".** It must contain the command and its output. "Tests pass" with nothing
under it is not done:

```
Show the command you ran and its output.
```

**6. Review by risk.**

- **Ordinary change:** `/code-review` on the diff. At medium effort it also reports cleanups and
  `CLAUDE.md` conventions; fix what affects correctness, the rest is optional.
- **High-stakes change** — security, migrations, parsers, invariants, anything that "looks done"
  and would be expensive if wrong: a **separate, read-only** session reviews it against the spec.

  ```
  claude --permission-mode plan
  ```

  Plan mode is read-only only when bypass permissions is not available in that session (no
  `--dangerously-skip-permissions`, no `bypassPermissions` default); otherwise Claude Code says
  so once and edits go through.
  ```
  Review the changes since commit <base> (committed and uncommitted) against specs/<slug>.md.
  Report only gaps that affect correctness, each with file:line; skip style. If there is nothing
  to fix, say so.
  ```

  Paste the findings back into the build session. Keep it open in another terminal, or run
  `claude --resume` and pick it; `--continue` would reopen the review session.

  ```
  A fresh reviewer who has not seen your reasoning reported:
  <findings>
  Reproduce each finding before changing anything; fix the real ones and reject the rest in one
  sentence each. Report the command and its output.
  ```

  At most three rounds. A fourth means the approach is wrong — stop and rethink it.

**7. Commit.** The message says what changed and why. Decisions live in ADRs, work in flight in
the spec or the tracker, history in git.

## Work that won't fit one session

Use this flow only when the work really does not fit one session. Signs:
- the session says so (the *How we work* block asks it to);
- the spec has several independent deliverables;
- the context is filling up before the build starts.

On features that fit one session, a ticket flow (without the tests-first session below) cost 11×
the main flow, took five times the owner's turns and lost a decision — so it is for work that
really doesn't fit.

**1. Interview as above, then stop before the build.**
- With a tracker: finish the same conversation with `/to-spec`. It writes the spec from the
  conversation into the tracker, so you don't also need `specs/<slug>.md`.
- Without a tracker: let the session write `specs/<slug>.md`.

Then, in the same context:

```
/to-tickets
```

Each ticket is a vertical slice, sized for one fresh session, with its blockers declared.

Before you leave this context, make sure every decision is in an ADR:

```
Which decisions from this conversation are not yet in an ADR? Write them.
```

A decision kept anywhere but an ADR — even as an out-of-scope note in the spec — can be re-asked
in a later session and dropped by an owner who has forgotten it; an ADR is read before the
work starts.

**2. For each ticket — two sessions.**

*a. Tests first, in their own session* (`/clear` or a new terminal):

```
Read ticket <ref>. Turn every acceptance criterion into tests under tests/acceptance/<ticket>/,
exercising only the public interface the ticket names. Take expected values from the ticket, not
from the code. Do not implement the feature: these tests should fail for now. Report the command
you ran and its output.
```

Look at *how* they fail. Each test should fail on its own assertion, not on an import error.
Only that shows the criterion can fail at all — `/to-tickets` occasionally writes one that is
already true at the base commit. Then commit the tests.

*b. Build in a fresh session where those tests are read-only:*

```
claude --settings '{"permissions":{"deny":["Edit(./tests/acceptance/**)","Bash(chmod:*)"]}}'
```
```
/implement <ref>
tests/acceptance/<ticket>/ is the agreed check and is read-only for you. Done means it and the
existing suite pass; report the command and its output. If a test looks wrong, say so — do not
work around it.
```

`/implement` commits to the current branch and does not close the ticket. Close it yourself, or
blocked tickets never become ready. The deny stops the edit tools and recognisable shell writes
(redirects, `tee`, `sed -i`), not a script that opens the file itself, so check that the tests
stayed untouched:

```bash
git diff --stat <tests-commit> -- tests/acceptance/    # prints nothing
```

*c. Review by risk*, as in the main flow.

Why two sessions: acceptance tests written from the spec by a separate session, read-only for the
implementer, gave the best result measured (9 of 9). Per ticket this extends that result; it is
not measured on its own.

**One ticket at a time.** `/implement-spec` builds ready tickets in parallel. In the lab, a
pipeline that ran 12–22 subagents together with grilling, tickets and `/tdd` cost 3.1–4.4× a
sequential flow for the same acceptance (those factors were not separated); a controlled external
study that isolated parallelism saw parallel subagents lose resolve rate on bounded tasks.

## Other situations

| You have | Type | Notes |
|---|---|---|
| A large effort whose route you can't see yet | `/wayfinder` | Charts decision tickets and resolves them one at a time. It plans; it does not build. Then use the flow above. |
| A bug | `Reproduce this with a failing test first and show it failing; then fix it and show the same test passing.` | That is diagnosis, not a test-first ritual. On a hard bug the agent may pull in `diagnosing-bugs` itself. |
| Bug reports and requests from other people | `/triage` | Tickets you generated yourself don't belong there. |
| A session that was harder than it should have been | `/retro` | Proposes checks and pointers for the environment; you pick. Prefer a check that can fail over a new line of prose. |
| A design question that talking won't settle | ask for a throwaway prototype | `prototype` is model-invoked. |
| The domain language itself is the problem | `/grill-with-docs` | Builds `GLOSSARY.md` and ADRs inline. Not needed for routine knowledge — the rules in `CLAUDE.md` cover that. |
| A codebase that feels like mud | `/improve-codebase-architecture` | A survey with candidates; each one re-enters the main flow. Not measured here. |
| Not sure which of these fits | `/ask-matt` | Routes over the Pocock skills. |

## Knowledge between sessions

A project worked on for months needs every new session to start with its language and its
decisions, not with the first conversation. The harness keeps them in versioned files:

- **Terms** → `GLOSSARY.md`, or `GLOSSARY-MAP.md` pointing at one glossary per bounded context.
  A term is added the first time it is used or settled.
- **Decisions** that later work must follow, including ones you mention "for later" →
  `docs/adr/`, or the decision log the project already keeps. They are written in the session
  where they were made.
- **Before changing an area**, the session reads the glossary entries and ADRs that touch it.
- **Work in flight** lives in the open spec or the tracker. Nothing else.

At the end of a session where you decided something, ask:

```
Which ADRs and glossary entries did you write this session?
```

What was measured: three features in new sessions, with an owner who never repeated earlier
decisions.
- A frontier model kept them in 3 of 3 runs even without these rules — it wrote them down on its
  own.
- With the rules it also kept 3 of 3, at about +17% cost.
- In a single smoke run, a weaker model kept 8 of 19 checks without the rules and 18 of 19 with
  them.

So the rules are insurance. Months of accumulation — dozens of features, a spec file that keeps
growing — were not modelled.

## Context at phase boundaries

| Boundary | Do |
|---|---|
| Interview → spec → build | Continue in the same session (measured above). |
| `/to-spec` → `/to-tickets` | Continue — one context. |
| Tests session → build session | New session: the implementer must not have written its own oracle. |
| Ticket → next ticket | New session; each ticket is self-contained. |
| Build → high-stakes review | Separate read-only session. |
| A session left waiting | A large session idle for about an hour (a build session parked during a long review) is compacted on its own; when you return to it, type `Re-read specs/<slug>.md before continuing.`, or turn it off in `/config` → Idle compaction. |
| Context getting long | Mid-phase, keep going or hand a scoped piece to a subagent. At a boundary, prefer continuing or `/clear`; `/compact` is the last option (Pocock's `ask-matt`). After any compaction, type `Re-read specs/<slug>.md before continuing.` Scope limits live in the spec file because compaction is reported to drop them more often than requirements — one external study, not verified here. |
| Work moves to a colleague, another directory or another harness | `/handoff`. |

## Large, multi-component repositories

- **Start at the root.** A component's `CLAUDE.md` loads when work touches its directory, so its
  commands and invariants cost nothing elsewhere.
- **Contracts between components are the riskiest seam.** Changing one means an ADR plus the
  updated check both sides run, before the change. Contract paths sit under `ask` in settings.
- **Tickets stay vertical slices** even when a deliverable crosses components. Don't cut them one
  component at a time.
- **Teams:** keep a short `REVIEW.md` by code owners. It says what failure looks like here, which
  paths always need a person, and caps the nits. Keep it a regular file: the review service skips
  a symlinked one and cuts one past its size limit.
- **Who reviews is set by risk, not by author** (Anthropic's account of how its Claude Code team
  reviews):

  | Risk | Reviewers |
  |---|---|
  | Low | Green automated checks |
  | Medium | One person |
  | High | Two people |

  Sensitive paths and CI workflows always need a person. The person who directed the agent counts
  as one reviewer; an agent's approval does not count as a person's.

## Don't

| Don't | Why |
|---|---|
| Use `/tdd`, or prescribe red-green-refactor to the implementer | A flow without it reached a mutation score within 0.05 of a pipeline that drove `/tdd`. Its suite included acceptance tests from a separate session, so the comparison is "independent tests, no ritual" against "ritual". An external study found no gain from test-first at 3–8.5× the tokens. Tests written beforehand by *another* session (above) and a failing check before a bug fix are not this ritual. |
| Use the ticket flow for work that fits one session | 11× the cost, five times the owner's turns, and one lost decision (above). |
| Fan out parallel implementers on a bounded change | See "One ticket at a time". |
| Build in a fresh session from the spec file alone | 7 of 9 against 8 of 9 in the session that wrote it. If it must be fresh, write the acceptance tests first (9 of 9). |
| Accept "tests pass" without output | That is a claim, not evidence. |
| Review until the reviewer is happy | A reviewer asked to find problems always finds something. Correctness only, three rounds. |
| Add custom agents, hooks or rulebooks | The harness is deliberately small; every addition is paid on every turn. Run `/retro` and prefer a check. |
| Start a session journal the project doesn't keep | It duplicates the spec, the ADRs and git. |

## It's working if

- Sessions ask questions before writing code, about your domain rather than the obvious.
- A spec exists for every non-trivial change, with your interface in it word for word.
- Every "done" carries a command and its output.
- When you state a decision once, an ADR appears in that session, and a later session cites it
  without being told.
- There is no subagent fan-out on bounded changes, and reviews end within three rounds.
- `CLAUDE.md` gets shorter over time, not longer.

When one of these slips repeatedly, type that step's line from this page. If it keeps slipping
with the line typed, that is a finding about the harness — report it rather than adding rules.

## Upkeep

- **Every 3–6 months, or after a model upgrade**: say `audit my Claude Code harness`. It reports
  what to cut first; the cut matters more than the additions.
- **Plugins**: auto-update as set up above, or update deliberately with
  `claude plugin update <plugin>@<marketplace>`.
- Never pin a model or Claude Code version in a project file.

## Where the numbers come from

The conditions behind every number on this page are in the README's *How we work — and why*.
