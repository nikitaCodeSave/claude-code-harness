# claude-code-harness

A Claude Code plugin that sets up — and keeps lean — the harness of your project: the root
`CLAUDE.md`, `.claude/settings.json`, a `CLAUDE.md` per component where one is needed, and the
project's knowledge layer. Built for new projects and existing ones, including large
multi-component codebases worked on for months.

One opinion drives it: **under a capable model, the least harness that works wins.** Every line of
the *How we work* block rests on a measurement or a first-party source; the layout for large
repositories follows Claude Code's own loading rules. Everything else was cut.

## Install

```
/plugin marketplace add nikitaCodeSave/claude-code-harness
/plugin install harness@claude-code-harness
/plugin install mattpocock-skills --marketplace mattpocock/skills
```

The second plugin, [mattpocock-skills](https://github.com/mattpocock/skills), brings the process
tools the harness points at: the tracker, tickets, `/wayfinder`, `/retro`, domain modeling. Two
settings worth making once, in your **user** settings:

- `"deny": ["Skill(mattpocock-skills:tdd)"]` — the harness works without a test-first ritual
  (why below); `/implement` then builds without it.
- Updates: third-party marketplaces don't auto-update by default — enable it in `/plugin` →
  Marketplaces (or `"autoUpdate": true` on the marketplace's `extraKnownMarketplaces` entry), or
  run `claude plugin update <plugin>@<marketplace>` when you choose. With `DISABLE_AUTOUPDATER`,
  `DISABLE_UPDATES` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` set, plugin auto-update also
  needs `FORCE_AUTOUPDATE_PLUGINS=1`.

## Use

Open the project and say:

> **"set up Claude Code harness in this project"**

The same phrase works for every state — the skill reads the repository and picks the path:

| The project | What happens |
|---|---|
| New, nothing on disk | Asks what it can't read (purpose, stack, planned components, what must never happen, sensitive paths) and writes the harness with honest `TBD`s instead of invented commands |
| Existing, no harness | Maps the components, runs each test command once, writes the harness, and seeds the glossary and ADRs only from what the code can't tell — decisions with their reasons, terms used inconsistently |
| Existing harness | Reports what to cut and what is missing, worst first; edits only after you approve |

Then, once per repository: `/setup-matt-pocock-skills`. On a large effort whose path isn't clear
yet, the first session is `/wayfinder`. In a monorepo, start Claude Code at the repository root —
the shared settings and their deny list load from the directory a session starts in.

Every few months, or after a model upgrade: **"audit my Claude Code harness"** — the cut matters
more than the additions.

**Day to day**, the [manual](docs/manual.md) gives what to type: a change that fits one session,
work that spans sessions, a bug, a high-stakes review, knowledge between sessions, a large
repository — and the signs that the flow is being followed.

## What lands

- **`CLAUDE.md`** (≤ 120 lines): commands, three-tier boundaries, *How we work*, *Project knowledge*.
- **`.claude/settings.json`**: a deny list for the boundaries a permission rule can express, with
  only path forms Claude Code actually matches.
- **`<component>/CLAUDE.md`** in a multi-component repository, only where a component has its own
  commands, invariants or contracts — Claude Code loads it when work touches that directory.
- **Knowledge**: `GLOSSARY.md` (or a `GLOSSARY-MAP.md` per bounded context) and `docs/adr/`,
  created on the first real entry.

No custom agents, hooks, commands or skills, and nothing copied into `.claude/docs/`.

## How we work — and why

The *How we work* block every project gets, with what each line rests on. Measured in the
maintainer's lab with a hidden test oracle, N=3 per cell, a frontier model implementing and a
second model playing the product owner; a script write-protected stages from each other and the
repositories carried no `CLAUDE.md`. Two rigs:

- **single session** — 63 runs on three small single-language tasks with hidden requirements;
- **multi-session** — 9 runs of one project built as three features in new sessions, with an owner
  who keeps no memory between features and states some decisions only once, "for later".



- **Interview before code**, then write the spec (single session). Where the owner did not correct
  the agent's final report: without the interview, full acceptance in 3 of 9 runs; with it, 7 to 9
  of 9, depending on where the build ran.
- **The interface you fixed goes into the spec verbatim.** In a smoke run, one dropped interface
  line zeroed an acceptance suite.
- **Build in the session that wrote the spec.** Same session: 8 of 9 runs, the cheapest flow that
  held that rate. A fresh session building from the file alone: 7 of 9. With acceptance tests
  first written from the spec in a separate session, read-only for the implementer: 9 of 9.
- **Work that won't fit one session**: tickets, each built in a fresh session from tests written
  beforehand from its criteria — an extension of the result above, not measured on its own. Only
  then: in the multi-session rig, a ticket flow without the tests-first step, run on features that
  fit one session, cost 11×, took five times the owner's turns and lost a decision.
- **One implementer at a time.** A pipeline with grilling, tickets, `/tdd` and 12–22 subagents
  reached the same acceptance at 3.1–4.4× the cost of a sequential flow (factors not separated); a
  controlled external study that isolated parallelism saw parallel subagents lose resolve rate on
  bounded tasks.
- **No test-first ritual.** A flow without it (with acceptance tests from a separate session)
  stayed within 0.05 mutation score of a `/tdd` pipeline; an external study found no gain at
  3–8.5× the tokens. A test must be able to fail, and "done" comes with the command and its output.
- **Knowledge in files**: terms in the glossary, decisions — including ones stated "for later" — in
  ADRs, read before touching an area (multi-session). A frontier model kept earlier decisions in
  3 of 3 runs without the rule — it wrote them into a file on its own — and in 3 of 3 with it, at
  about +17% cost. In one smoke run outside the planned design, a weaker model kept 8 of 19 checks
  without the rule and 18 of 19 with it. The rule is insurance against one model's habit, not a
  measured gain on the frontier model.
- **Review by risk**, against the spec, correctness only, at most three rounds (first-party
  guidance: "a reviewer that's asked to find problems will always find something"). In the lab a
  spec review found issues in 3 of 18 runs, none that changed hidden acceptance.

Changes between releases, with what to do when upgrading, are in [CHANGELOG.md](CHANGELOG.md).

## License

MIT
