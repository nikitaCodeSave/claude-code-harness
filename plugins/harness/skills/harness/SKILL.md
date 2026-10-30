---
name: harness
description: "Use when setting up, bringing in, auditing or tidying the Claude Code harness of a project — root CLAUDE.md, .claude/settings.json, per-component CLAUDE.md files and the project knowledge layer — for a new project or an existing one, including large multi-component and long-lived codebases. Skip for questions about building agents in other frameworks."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(ls:*), Bash(find:*), Bash(wc:*), Bash(cat:*), Bash(git log:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git shortlog:*), Bash(claude --version), Bash(claude --print:*), Bash(claude plugin list:*)
---

# Claude Code harness

One opinion: **under a capable model, the least harness that works wins.** This skill lays down
a short list of things and nothing else:

1. a short root `CLAUDE.md` — commands, boundaries, how we work, where knowledge lives;
2. `.claude/settings.json` — a deny list for what a permission rule can express;
3. a `CLAUDE.md` inside each component that has its own commands, invariants or contracts;
4. the knowledge layer (`GLOSSARY.md`, ADRs) and the work-state tracker, through the
   `mattpocock-skills` plugin.

No custom agents, hooks, commands or skills; no rulebooks copied into the project. The *How we
work* lines each have a named basis — a measurement, a first-party source, published research or
established practice (README, *How we work — and why*); the multi-component layout follows
Claude Code's own loading rules and is not benchmarked.

Templates: `templates/CLAUDE.md`, `templates/component-CLAUDE.md`, `templates/settings.json`.

## 1. Read the room — no writes

```bash
claude --version
git log --oneline 2>/dev/null | wc -l; git log --since="3 months ago" --oneline 2>/dev/null | wc -l
git shortlog -sn 2>/dev/null | head
ls -la; ls -la .claude 2>/dev/null
find . \( -name AGENTS.md -o -name CLAUDE.md \) -not -path "*/node_modules/*" | head -20
ls .cursor/rules .github/copilot-instructions.md 2>/dev/null
ls pnpm-workspace.yaml nx.json turbo.json lerna.json go.work Cargo.toml WORKSPACE MODULE.bazel \
   settings.gradle* pom.xml *.sln package.json pyproject.toml docker-compose*.yml 2>/dev/null
find . -maxdepth 3 \( -name package.json -o -name pyproject.toml -o -name Cargo.toml -o -name go.mod \
   -o -name "build.gradle*" -o -name pom.xml -o -name "*.csproj" \) -not -path "*/node_modules/*" | head -40
ls .github/workflows .gitlab-ci.yml .circleci Jenkinsfile 2>/dev/null
ls docs README* CONTRIBUTING* GLOSSARY* 2>/dev/null
find . -maxdepth 3 -type d \( -iname "*adr*" -o -iname "*decision*" \) -not -path "*/node_modules/*" 2>/dev/null
claude plugin list 2>/dev/null | grep -i mattpocock
```

Classify, and state the classification before writing anything:

- **State.** *New* — no code, no history (greenfield is a state, not a blocker). *Existing,
  no harness* — code but no `CLAUDE.md` / `.claude/`. *Existing harness* — either exists.
- **Shape.** *Multi-component* when two or more units build or test on their own: a workspace
  manifest (pnpm / npm / yarn workspaces, Nx, Turbo, Lerna, Cargo `[workspace]`, `go.work`, a uv
  workspace, Bazel, Gradle or Maven multi-module, a `.sln` with several projects), several
  manifests under `apps/` · `packages/` · `services/`, or a compose file building several services.
- **Horizon.** *Long-lived* when it will be worked on over months — history beyond a few months
  or a few hundred commits, or the operator says so. Treat every multi-component project as
  long-lived.

Then ask the operator **only what the repository cannot answer**, in one round:
what must never happen in this system even when inconvenient · which paths are sensitive
(secrets, prod config, migrations, vendored code) · the one command that proves the project
works, if none is visible · for a new project: its purpose, stack and planned components.
A headless run with no one to ask records the questions as open in its output and proceeds.

## 2. What lands — every path

| File | Content | Size |
|---|---|---|
| `CLAUDE.md` (root) | `templates/CLAUDE.md`: purpose, commands, boundaries, how we work, project knowledge | ≤ 120 lines, aim for 60–90 |
| `.claude/settings.json` | `templates/settings.json`, tuned to what exists (§6) | ~20 lines |
| `<component>/CLAUDE.md` | multi-component only, and only where the component has its own commands, invariants or contracts | ≤ 60 lines each |
| `.claude/rules/<topic>.md` | only for a domain prohibition no type or test can express, that §1 actually found | ≤ 30 lines each |
| tracker + domain-docs config | `/setup-matt-pocock-skills` (§5) | — |
| `GLOSSARY.md`, ADRs | created on the first real term or decision, never empty | — |
| `.out-of-scope/<slug>.md`, `docs/research/<slug>.md` | created when first needed; their lifecycle, and that of specs and ADRs, is in *Project knowledge* | — |

**`AGENTS.md`.** Claude Code reads `AGENTS.md` only while no `CLAUDE.md` exists in the working
directory or above it — so the root `CLAUDE.md` this skill writes switches off every `AGENTS.md`
below it. Keep `AGENTS.md` as the source of truth: start the root `CLAUDE.md` with `@AGENTS.md`,
give every nested `AGENTS.md` a sibling `CLAUDE.md` containing `@AGENTS.md`, and put only
Claude-specific lines in the `CLAUDE.md` files. Never paraphrase it into a second copy — two
copies drift.

**Auto memory is off.** It is on by default, and Claude writes it itself, outside review and
outside the repository — a second, unreviewed store of project facts that keeps what the project
has since revised. The settings template sets `"autoMemoryEnabled": false` for the project; what
later work must know lives in `CLAUDE.md`, ADRs, the glossary and specs. Paths B and C: before it
goes off, open `/memory` with the operator, move the project facts later work needs into ADRs or
`CLAUDE.md`, and personal notes about this project into a gitignored `CLAUDE.local.md`. A teammate can turn it
back on for themselves in `.claude/settings.local.json`; the `/memory` toggle writes user
settings, which the project file outranks.

**Every line must be something a new teammate would have to be told.** Directory trees, module
maps, dependency lists and architecture overviews are derivable from the repo; instruction files
that restate them measured more cost and no better results. Commands, non-default conventions,
gotchas and prohibitions stay. `/init` can draft; your job is the cut.

## 3. Paths

### A — New project
1. Ask the §1 questions; write `CLAUDE.md` from the answers. Unknown commands are an honest
   `TBD — fill when the stack lands`, never invented.
2. `settings.json` from the template.
3. Multi-component plan → the layout in §4, with component `CLAUDE.md` files only for components
   that already exist on disk. Do not create directories for planned components.
4. Install and set up `mattpocock-skills` (§5).
5. If the destination is still foggy (more than a session can hold), the operator's first
   session is `/wayfinder`; otherwise the first feature follows *How we work*.

### B — Existing project, no harness
1. Recon with the built-in `Explore` subagent: components, how each is built and tested (CI
   configuration included), invariants the code enforces defensively, contracts between
   components. Keep the map in context — do not write it to a file.
2. Run each fast, local, side-effect-free test command once and record the exact invocation that
   works. Suites that need services, credentials or network, or that change shared state, are not
   run: name them in *Commands* with what they need (or "CI-only").
3. Write `CLAUDE.md`, `settings.json`, component files (§4) — auto memory goes off only after its
   project facts are moved (§2).
4. Knowledge, **only from what is not derivable**:
   - The project already keeps decisions (`docs/adr/`, `docs/decisions*`, MADR, an RFC folder) →
     that is the decision home; point *Project knowledge* at it. Do not copy it into a second place.
   - Decisions with reasons live only in issues, commit messages or a README → an ADR citing its
     source.
   - A term the code uses inconsistently → `GLOSSARY.md`.
   - Finished specs, research notes or an archive folder already in the repository → list them in
     the report; removing any of them is the operator's call.
   Do not migrate a wiki; do not summarize the code.
5. Set up `mattpocock-skills` (§5).

### C — Existing harness
1. Ask the operator to run the native audits in their session: `/doctor` (instruction files,
   settings, agents, hooks, context weight), `/doctor prompt-audit` (instructions written for older
   models, stale paths and commands, contradicting files) and `/skill-doctor` (skills that go
   unused, with their context cost). Don't re-derive what they report. Then read everything under
   `.claude/` and every `CLAUDE.md` / `AGENTS.md`; count plugin mods with the hooks.
2. Report gaps before editing, worst first, and **edit only after approval**:
   custom agents or commands duplicating built-ins · hooks that block mid-write · skills restating
   `CLAUDE.md` · `CLAUDE.md` over budget or carrying derivable content · stale model or version
   pins · a paraphrased or switched-off `AGENTS.md` (§2) · missing or dead permission rules (§6) ·
   rulebooks copied into `.claude/docs/` (`workflow.md`, `testing.md`, `docs-discipline.md`) — the
   *How we work* block replaces them · missing knowledge rules · no tracker · sediment: finished
   specs left in place, ADRs a newer one contradicts without saying so, glossary terms of dropped
   work, research notes whose decision is recorded, archive folders · auto memory on.
3. Apply the approved items, then fill the gaps as in path B. Deleting accumulated data or an
   actively used skill is confirm-before-acting. A finished spec, research note or glossary term
   goes only after the line-by-line pass of `/harness:wrap` step 4: each line first gets its home.

## 4. Multi-component layout

- **Root `CLAUDE.md`** carries the whole-repo check, boundaries, how we work and project
  knowledge. Components are not listed — the workspace manifest lists them.
- **`<component>/CLAUDE.md`** (`templates/component-CLAUDE.md`) — Claude Code loads it when work
  touches that directory, so per-component commands, invariants and contracts cost nothing
  elsewhere. Write one only where there is something to say.
- **Knowledge per bounded context.** One shared domain language → root `GLOSSARY.md` and one ADR
  directory. Components with their own language → root `GLOSSARY-MAP.md` pointing at each
  context's glossary and ADR directory; decisions that cross components stay in the root one.
  `/setup-matt-pocock-skills` proposes the multi-context layout only on JavaScript-style workspace
  signals — for Cargo, Go, uv, JVM, .NET or polyglot repositories, choose it explicitly when it
  asks.
- **Contracts are the riskiest seam.** Each interface between components has a check both sides
  run (schema validation, consumer test). Changing one is an ADR plus the updated check first;
  put the contract path under `ask` in settings.
- **Component prohibitions** go to `.claude/rules/<topic>.md` with `paths:` scoping; a rule that
  must never be missed stays unscoped (path scoping is heuristic).
- **Teams:** a short `REVIEW.md` written by code owners — what failure looks like in this repo,
  paths that always need a person, a cap on nits. Keep it apart from `CLAUDE.md`.

## 5. mattpocock-skills

The process tools (tracker, tickets, wayfinding, retros, domain modeling) come from
`mattpocock-skills`:

```
/plugin install mattpocock-skills --marketplace mattpocock/skills
```

- **Updates.** Auto-update is off by default for third-party marketplaces. Turn it on in
  `/plugin` → Marketplaces → `mattpocock` → *Enable auto-update*, or declare it in user settings
  with `"autoUpdate": true` on the marketplace's `extraKnownMarketplaces` entry (the settings
  entry wins over the toggle). Any of `DISABLE_AUTOUPDATER`, `DISABLE_UPDATES` or
  `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` switches the whole plugin auto-update pass off and
  hides the toggle unless `FORCE_AUTOUPDATE_PLUGINS=1` is also set — that keeps Claude Code itself
  pinned while plugins update. Update deliberately with
  `claude plugin update mattpocock-skills@mattpocock`. The plugin pins its version in
  `plugin.json`, so an update arrives when its author bumps it, not on every commit.
- **Once per repository** the operator runs `/setup-matt-pocock-skills`: the tracker (GitHub,
  GitLab or local `.scratch/`), triage labels and the domain-docs layout, recorded in an
  "Agent skills" block in `CLAUDE.md` and `docs/agents/`.
- **`/tdd` is not used** (no test-first ritual): the operator adds `"deny": ["Skill(mattpocock-skills:tdd)"]` to
  **user** settings — it blocks the skill under its short name too, so `/implement` builds
  without it. `skillOverrides` does not reach plugin skills. A project file must not impose this
  on teammates; their `/implement` will still use it.
- **`/implement-spec`** (parallel implementers) is not the default; one `/implement` per ticket is.
- **ADRs.** Its domain-modeling skill writes an ADR only for decisions that are hard to reverse,
  surprising and a real trade-off. *Project knowledge* deliberately widens that to decisions later
  work must follow, including ones stated "for later" — keep that line.
- `/to-tickets`, `/implement`, `/wayfinder` run only when the operator types them; *How we work*
  phrases them as proposals the session makes.

Declined or unavailable → specs live in `specs/<slug>.md` and tickets as files under
`specs/<slug>/`.

## 6. Permissions that actually enforce

- **Start Claude Code at the repository root.** The shared `.claude/settings.json` is read from
  the session's starting directory; a session started inside a package does not load the root
  deny list. Say so in the hand-over.
- **Path anchors.** `secrets/**` or `./secrets/**` is relative to the current directory — as a
  deny rule a bare `secrets/**` matches a `secrets` directory at any depth below it. `/path` is
  relative to the settings file's project; `//path` is absolute; `~/path` is home-relative.
- **Only `Read(path)` and `Edit(path)` are matched against files.** `Read` also governs Grep and
  Glob; `Edit` also governs Write and NotebookEdit. `Write(path)`, `Glob(path)`, `Grep(path)` are
  parsed and never matched. A path nothing may read **or** change needs both `Read` and `Edit`
  deny; neither reaches a script that opens the file itself — that is the OS sandbox's job.
- **Bash argument patterns are fragile** — `git push --force` vs `-f` vs `+main`. Deny the forms
  you know, and treat the deny list as hygiene; enforcement against a determined bypass is the
  sandbox or auto mode's classifier. Interactive sessions start in auto mode unless a mode is set,
  but a project file cannot set `auto` or `bypassPermissions` (user settings or the flag can), and
  some headless setups start in `default` mode — there the deny list is the only guard.
- `.env`: production secrets → deny; dev-only credentials the tests need → allow, gitignore, and a
  one-line "no prod creds in `.env`" boundary. A donor or reference repository →
  `Read(//abs/path/**)` allowed, `Edit(//abs/path/**)` denied.
- Mirror the *Never* boundaries a rule can express into `deny`, *Ask first* into `ask`.

## 7. Verify — end of every run

```bash
claude --print "ok" </dev/null 2>&1 >/dev/null | grep -E -A3 '^(Permission |Ignoring .*permissions\.allow|These settings )'
# pass = prints nothing. "not matched by file permission checks" = a dead path form;
# "matches no known tool" = a typo; "These settings entries were skipped" = a malformed rule,
# dropped; "These settings files did not load" = an invalid value voided the whole file;
# "Ignoring N permissions.allow" = untrusted workspace — accept the trust dialog once and re-run.
claude --print "what is the command that proves this project works?"   # answers from CLAUDE.md
claude --print "what must you never do here?"                          # names the deny rules
find . -name CLAUDE.md -not -path "*/node_modules/*" | xargs wc -l      # within §2 budgets
```

Run the named check command once and confirm it executes. When launching the app takes more than
one command, run `/run-skill-generator` once instead of writing a launch procedure by hand.

## 8. Record and hand over

Record the run in the commit that carries it — what was detected, what landed, what was
deliberately left out, which questions are open. Do not introduce a journal the project does not
keep. End with the operator's next steps:

- Start Claude Code at the repository root (§6).
- Auto memory is off in this project (§2): teammates' memory notes for it stop loading, and
  `.claude/settings.local.json` turns it back on for one person.
- Install `mattpocock-skills` if missing, choose its update mode, deny `/tdd` in user settings
  (§5), then run `/setup-matt-pocock-skills`.
- Every session starts with `/harness:start`: it says where work stands and the one command to
  type next. The flow's commands — `/harness:task`, `/harness:bugfix`, `/harness:tests`,
  `/harness:build`, `/harness:check`, `/harness:wrap` — carry its prompts, so nothing long is typed
  by hand.
- New: the first feature with `/harness:task`, or `/wayfinder` if the way is unclear. Existing:
  work as usual, through the same commands.
- The project's own harness grows from solved work: once a task that took a long search finally
  works, or a task keeps coming back, `/harness:skill` turns it into a project skill, and
  `/harness:trajectory` tightens it after a real run.
- Every 3–6 months or after a model upgrade: say "audit my Claude Code harness" — the cut
  matters more than the additions.

## Do not

Create custom subagents, hooks, commands or skills at setup — project skills grow later, from
tasks the project actually solved · write module maps, directory trees
or architecture overviews · copy rulebooks into `.claude/docs/` · copy an existing decision log
into a second place · add a journal the project does not keep · use
`--dangerously-skip-permissions` · pin a model or Claude Code version in a project file · propose
API-key-only features.
