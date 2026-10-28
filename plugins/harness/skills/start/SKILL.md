---
name: start
description: "Where this session stands and the one command to type next. Run it at the start of every session, or whenever unsure."
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git branch:*), Bash(ls:*)
---

Find out where work stands in this repository and tell me what to type next. Change nothing.

Look, in this order:
1. The root `CLAUDE.md`. If there is none, the harness is not set up: tell me to say "set up Claude
   Code harness in this project", and stop.
2. `git status` and the current branch. Uncommitted work means a task is in flight.
3. Open work: specs (where the *Agent skills* block in `CLAUDE.md` says, else `specs/`) and open
   tickets in the tracker it names. A spec or ticket is open while its acceptance criteria are not
   all covered by code and passing tests. Read tracker state only; change nothing.
4. The last few commits.

Answer in a few lines, in the language I write in:
- **Where you are** — the task in flight, if any, and its stage.
- **Next** — the single command to type now, with its argument filled in.
- **Then** — the one or two commands after it.

Route by what you found:
- Nothing in flight → `/harness:task <what you want>`; `/harness:bugfix <the bug>` for a bug;
  `/wayfinder` for a large effort whose route is unclear.
- A raw idea, not yet a task, or one I want challenged → `/grill-with-docs <the idea>` (it also
  writes terms and decisions down), or `/grill-me` when it isn't about this code; then
  `/harness:task` in the same session to spec and build what was settled.
- A change finished in this repo but not reviewed → `/code-review`, or `/harness:check` when it
  touches security, migrations, parsers, invariants, or anything expensive if wrong.
- Finished and reviewed, not committed → `/harness:wrap`.
- A spec left half-built by an earlier session → `/harness:tests <spec>` now, then
  `/harness:build <spec>` in a fresh session.
- Open tickets → the first unblocked one: without acceptance tests → `/harness:tests <ticket>`;
  with tests committed → `/harness:build <ticket>` in a fresh session.
- A conversation that just settled work too big for one session → `/to-spec`, then `/to-tickets`,
  then `/harness:wrap` to get every decision into an ADR before leaving.
- A task this session finally solved after a long search, or one that keeps coming back →
  `/harness:skill <what it does>`; after a run that used a project skill → `/harness:trajectory`.
- Stuck on a decision only someone else can make → `/to-questionnaire`; an explanation that didn't
  land → `/wait-what`; a session that was harder than it should have been → `/retro`; handing the
  work to someone else → `/handoff`; bug reports from other people → `/triage`.

The commands, for reference:
- `/harness:task <what you want>` — a new change: interview, spec, build in this session.
- `/harness:bugfix <the bug>` — reproduce with a failing test, then fix.
- `/harness:tests <ticket or spec>` — acceptance tests first, in their own session.
- `/harness:build <ticket or spec>` — build against those tests, in a fresh session.
- `/harness:check` — an independent review against the spec, then the fixes.
- `/harness:wrap` — end of session: decisions, terms, evidence, commit.
- `/harness:skill <what it does>` — turn a solved task into a project skill.
- `/harness:trajectory` — tighten a project skill from the tool calls of its last run.
- From mattpocock-skills: `/grill-with-docs`, `/grill-me`, `/to-spec`, `/to-tickets`, `/wayfinder`,
  `/to-questionnaire`, `/wait-what`, `/triage`, `/retro`, `/handoff`, `/ask-matt`.
