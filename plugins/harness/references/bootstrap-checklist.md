# Bootstrap checklist (`.claude/` from scratch)

Procedure for introducing Claude Code to a project with no `.claude/`. Two shapes:

- **Default — production-grade bootstrap:** root `CLAUDE.md` + `settings.json` + the shipped
  workflow distillation in `.claude/docs/` (Phase 2c) + `docs/ARCHITECTURE.md` as a decision
  record, plus `.claude/rules/` for whatever prohibitions Phase 0 actually found. Projects are
  written for production releases from day 0 **regardless of size** — a full professional flow
  is cheaper to lay down at bootstrap than to retrofit (operator directive, 2026-06; the
  retrofit that motivated it cost a full session).
- **Minimal (MVH) — only on explicit operator request:** root `CLAUDE.md` + `settings.json`,
  nothing else. Use when the operator explicitly asks for a minimal setup (throwaway
  experiment, one-off script) — not as a silent default.

Custom subagents / hooks / pipelines stay out of both shapes until a trigger earns them
(see `harness-discipline.md`) — "production-grade" means conventions + documents, not machinery.

Stack-agnostic. Re-verify the environment with `claude --version`.

## Phase 0 — Read the room (no writes)

```bash
claude --version            # confirm the line; primitives drift by minor version
# Built-in subagent TYPES you must NOT recreate (Explore / Plan / general-purpose /
# statusline-setup / claude-code-guide) are catalogued in references/native-capabilities.md.
# Live: /context ("Custom Agents") or ls .claude/agents/ — the /agents wizard is gone.
# NOT `claude agents` (that CLI lists running sessions, not types).
ls -la                      # repo shape
ls -la .claude/ 2>/dev/null # confirm empty / absent
git log --oneline 2>/dev/null | wc -l             # project age (0 + stderr-fatal on a fresh repo is fine)
git log --oneline --since="3 months ago" 2>/dev/null | wc -l  # active vs dormant
ls "${CLAUDE_CONFIG_DIR:-$(echo ~)/.claude}"      # user-level config already present — always the
# ACTIVE config dir ($CLAUDE_CONFIG_DIR when set and non-empty, else <home>/.claude; non-bash shells apply the
# same rule their own way). Absent dir = empty layer, a valid answer, not an error.
ls AGENTS.md .cursor/rules .cursorrules .github/copilot-instructions.md 2>/dev/null  # another agent got here first
grep -rniE '\b(never|must not|do not|forbidden|invariant)\b' README* docs/ CONTRIBUTING* 2>/dev/null | head -30
# ^ prohibitions someone already wrote down — Phase 4's input, see below
```

**Collect the prohibitions while you read — nothing later goes looking for them.** Phase 4 writes
`.claude/rules/` from what this phase found, so a "must never" whose only copy sits in a README
paragraph or a code comment is lost if you don't record it here. The grep above is a starting
point, not the answer: also note what the code enforces defensively without saying why, and ask the
operator directly ("what must never happen in this system, even when it's inconvenient?") — that
one question routinely returns rules no file states. Record them; don't invent any.

**If the repo already carries `AGENTS.md`, that is the source of truth and CLAUDE.md becomes a
bridge, not a rewrite.** `AGENTS.md` is the cross-vendor standard (Codex, Cursor, Copilot);
**Claude Code does not read it** — measured with an `InstructionsLoaded` hook, a repo holding only
`AGENTS.md` starts a Claude session with *no* project instructions
(`native-capabilities.md`, Memory §). Two bridges, both keeping one file authoritative: make
`CLAUDE.md` start with `@AGENTS.md` and put Claude-specific lines below it, or symlink
`CLAUDE.md -> AGENTS.md` when there is nothing Claude-specific to add. Do **not** author a second
instruction file that paraphrases the first: two files drift, and the agent reading the stale one
has no way to know.

**Decide up front what `/init` does and what you do.** With `CLAUDE_CODE_NEW_INIT=1` the built-in
runs an interactive multi-phase flow — asks which artifacts to set up, explores the codebase with a
subagent, asks follow-ups, and shows a reviewable proposal before writing. It also folds in
`AGENTS.md` and other agents' rule files. That covers the *discovery and drafting* this checklist
used to do by hand. Let it: run `/init` for the draft, then spend your effort on the parts it does
not do — the permission model (Phase 3), the shipped distillation (Phase 2c), and the ruthless cut
described in Phase 2. Reimplementing its discovery by hand is the built-in duplication this kit
exists to prevent.

Detect the stack from manifests (`package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` …),
the test/lint commands, the task runner, CI presence. **Also read the project's intent** (README /
the operator's stated goal) — it shapes what goes in CLAUDE.md, not which phases run. A capable
model reads all this itself — you are confirming, not teaching it. **Write nothing in Phase 0.**

**Greenfield — 0 files, 0 commits — is a detected state, not a blocker.** "No manifests, no code,
no history" is a valid answer to every probe above: record it as the detected state and continue.
Nothing downstream requires a stack to exist *yet*; it requires the harness to be honest about not
knowing one. An explicit operator request for the full harness on an empty repo is **informed
consent — deploy it, don't argue the project is too small to need one**: laying the flow down at
file zero is the cheapest it will ever be, and the retrofit is what costs a session. When intent is
genuinely undeterminable (no README, no stated goal, nothing to read), record that and deploy the
default shape — Phase 1's table is the whole answer, so there is nothing to guess.

## Phase 1 — Propose the default shape

Present this and get approval before writing. **Headless / fire-and-forget flow** (operator said
"set up and go", `--print` run, no one to ask): don't stall — proceed with the minimum table below
and *record the plan you would have presented* in your output; the approval gate is for interactive
sessions where the operator is present.

| File | Create now? |
|---|---|
| `CLAUDE.md` (root) | **yes** — project entry-point indexer. If `AGENTS.md` exists: `@AGENTS.md` import or symlink, never a paraphrase |
| `.claude/settings.json` | **yes** — permissions + minimal env |
| `.claude/docs/` (Phase 2c) | **yes** — shipped distillation: `workflow.md` + `testing.md` + `docs-discipline.md`, copied verbatim from the kit |
| `docs/ARCHITECTURE.md` | **yes** — a decision record (ratified decisions with dates, measured reasons with numbers, deliberate retentions, non-claims), not a module map; greenfield (nothing decided yet) → a labelled stub, never invented facts (MVH-on-request: skip) |
| `.claude/rules/` (Phase 4) | **yes, where Phase 0 found any** — one file per domain prohibition a type or test cannot express; none found → no directory, never an invented rule |
| `docs/CODE-MAP.md` | **no** — the module itself says it. The one exception (a layout genuinely unreadable from the tree) is `docs-discipline.md`'s to grant, and it grants an *index*, not a maintained map |
| `.claude/agents/` | **no** — built-ins cover it; defer until evidence |
| `.claude/hooks/` | **no** — defer until a recurring pain |
| `.claude/skills/` | **no** — defer until a workflow repeats ≥3× |
| `.claude/commands/` | **no** — and when the need arrives, write a skill instead: first-party guidance points new workflows at `skills/`, which adds a directory for supporting files. Same mechanism otherwise, `disable-model-invocation` included; existing `commands/*.md` keep working, nothing to migrate |
| `.mcp.json` | only if there is a clear external-tool need |

Defaulting to "no" on the machinery rows is the discipline, not timidity.

## Phase 2 — Write `CLAUDE.md` (root), ≤ 200 lines

**Order matters, and the evidence is external**: across 2,500+ repositories the files that changed
agent behavior put **executable commands in an early section**, wrote boundaries as three tiers,
named the stack with versions, and showed style with real code instead of prose. The template
below is in that order — commands before philosophy — because a session that stops reading early
should already have what it needs to run the project.

```markdown
# <project> — instructions for Claude Code

## Project context (3–5 lines)
<What it is, who uses it, what "done" usually looks like. No marketing prose.>

## Commands
​```bash
<install>        # exact invocation, with the flags you actually use
<test>           # and the single-test form: pytest tests/test_x.py::test_y
<lint / format>
<typecheck>
<dev server, if any>
​```
Done = these exit 0.

## Stack
- Language + version · framework + version · package manager · test runner · lint/format.
  Name versions: "React 18 + TypeScript 5.4, Vite" beats "React and TypeScript".

## Conventions
<Only project-specific divergences from stack defaults, shown as code where possible.
"We use PEP 8" is useless; "we mock HTTP with respx, not unittest.mock" is useful.>

## Boundaries
- **Always**: <run the test command before saying done · update the oracle its diff touches>
- **Ask first**: <schema migrations · anything under infra/ · new dependencies>
- **Never**: <commit secrets · edit files under vendor/ · push to main>
  ^ mirror the Never/Ask tiers into settings.json permissions (Phase 3) — prose steers,
    settings enforce, and the two should not disagree.

## Working style
- Think first: state assumptions; if multiple readings exist, ask; if unclear, stop and name it.
- Nontrivial task (multi-file, architectural, or ambiguous spec) → switch to plan mode yourself
  for read-only recon before any write — don't wait for the operator to ask (skip in headless
  runs). If already mid-task, say "this deserves a plan first" and stop coding.
- Size the change before you build (default DOWN): trivial→just do · small→acceptance criteria ·
  medium→design-lite paragraph · large (shared invariant / migration / irreversible / unfamiliar
  brownfield) → NON-GOALS line + brownfield recon + upstream design grill — `.claude/docs/workflow.md`.
- Simplicity first: minimum code that solves it; no speculative abstraction or config.
- Surgical changes: touch only what's needed; don't refactor what isn't broken; every changed
  line traces to the request.
- Verify: turn "fix the bug" into "write a failing test, then make it pass"; state a brief plan
  with per-step checks for multi-step work.
- Verification ladder — at the end of a substantive change, run `/code-review` yourself; the higher
  rungs you *propose* instead of just stopping: fresh-context second opinion (separate
  session/subagent prompted to refute — high-stakes or "looks done") → external audit
  (irreversible / security-critical). Recommend one; the operator decides. Rung semantics
  and the full flow — `.claude/docs/workflow.md`.
- When blocked, escalate instead of improvising: after two failed attempts at the same thing,
  stop and report what you tried and what you need — <a decision from the owner / a credential /
  a service that is down>.
- Doc-with-code: a change updates its matching **oracle** — test, type, schema — in the same
  commit, and a document only where the claim has no oracle; mapping table in
  `.claude/docs/docs-discipline.md`.
- Continuity: a feature / fix / config or API change / architectural decision closes with an
  episodic entry (`/devlog:devlog` if installed, else a `.claude/devlog/entries/` note — or this
  project's disciplined commit messages); a task spanning sessions keeps
  `.claude/progress/<slug>.md` current. Layers and triggers — `.claude/docs/workflow.md`.
- Big/long tasks: give the full task spec up front in one well-specified turn, decompose into
  independently-verifiable slices, and run at `high`/`xhigh` effort for long-horizon / async work.
- When compacting, preserve the list of modified files, the commands already run and their
  results, and any decision the operator ratified.

## Reference materials
- docs/ARCHITECTURE.md / docs/ADR/ / .claude/rules/ (only those that exist)
- .claude/docs/workflow.md — flow: session ritual, plan, verification ladder, continuity
- .claude/docs/testing.md · .claude/docs/docs-discipline.md — invariants (shipped by the kit)
- .claude/devlog/entries/ — episodic record, one entry per change (the first entry creates the
  directory; index.json / tldr.md there are generated — never hand-edit them)
  ^ only when the devlog IS this project's carrier; where the carrier is disciplined commit
  messages, drop this line — pointing at a directory the project will never grow is the same
  dangling-pointer noise the MVH note calls out.
```

**Whatever wrote the draft — `/init`, this template, or you — the next step is cutting it.** Two
2026 studies measured LLM-authored instruction files making agents *worse*: −2% success at +23%
cost in one, reduced success in 5 of 8 settings and +2.45–3.92 steps per task in the other. Both
traced it to the same thing: the generated file restated what the model derives from the repository
anyway. So pass over every line once with one question — **would a new teammate have to be told
this, or can it be read off the code?** Directory layouts, dependency lists, framework tutorials
and architecture overviews go; gotchas, non-obvious behavior, version pins and conventions that
differ from tool defaults stay. `/doctor` runs the same cut mechanically on a checked-in CLAUDE.md
and is worth a pass here.

MVH-on-request: drop the ladder-semantics, doc-with-code and continuity duty lines together with
the `.claude/docs/` + `.claude/devlog/` Reference-materials lines — rules pointing at files that
don't exist are noise (detect-then-prescribe). The change-sizing line stays — Phase 7 greps it —
but strip its trailing `.claude/docs/workflow.md` pointer: the duty stands without it, and a
dangling one is the same noise on a line that survives.

**Resolve the continuity carrier as you write the line.** The branches above are the choice, not
the text to copy: CLAUDE.md names the one carrier this project actually uses (detect it — is the
companion installed?), and that same carrier is the one Phase 8 records the bootstrap in. A duty
line that ships the menu instead of the decision hands the next session the choice all over again.

The `## Working style` block stays even though the system prompt overlaps it — target model
versions vary and its ~25-line cost buys resilience. Do **not** inflate it to a 60-line treatise.
The plan-mode and verification-ladder lines are **proposal duties, not silent rituals**: their
value is that the *session* surfaces the workflow to the operator (transcript evidence: without
them, sessions never proposed a single ladder rung and coded nontrivial integrations plan-free).

**Front-load full paths.** Whenever CLAUDE.md names a file, give its full repo-relative path —
`apps/web/src/app/page.tsx`, not "the homepage component". Concrete paths save a discovery
tool-call; this applies to `Commands` and `Reference materials` too.

**Root `docs/` is part of the default shape — but only the half that has no oracle**: write
`docs/ARCHITECTURE.md` as a **decision record** (what was ratified and when, the measured reason
with its number, code deliberately kept without a caller, explicit non-claims), from what Phase 0
actually established. Do **not** put the module map, the data-flow overview or the import graph in
it, and do not write a module map at bootstrap at all — the narrow exception for an unreadable
layout is `docs-discipline.md`'s to grant, not the bootstrap's. The code carries that material, and
prose restating it costs a write on every structural change forever. (Distinct from the two studies
above: those measured the *runtime* cost of a derivable claim sitting in an always-on instruction
file, which is why the same material must not reach CLAUDE.md either. Two costs, one conclusion —
don't merge them into one citation.) Where Phase 0 established nothing for a section, a labelled
stub naming its fill trigger; the ban on invention is unchanged.

Do not wait for docs to "emerge" either — that inverts causality (no docs → no doc rules → docs
never appear; observed in a real bootstrapped product: zero documentation after 8 features). The
ongoing docs rules (rule 0 "oracle before prose", the doc-with-code mapping, ADR threshold,
glossary first-use, owner/last-updated frontmatter) ship as `.claude/docs/docs-discipline.md` in
Phase 2c — CLAUDE.md carries only the one-line duty pointer, not the rules themselves.
`GLOSSARY.md` / `ADR/` / `RUNBOOKS/` are created on first real entry, not empty.
MVH-on-request: skip `docs/` entirely.

**Placeholder ≠ boilerplate — the ban is on invention, not on empty cells.** "Never boilerplate"
forbids writing a plausible-looking fact you did not read: a decision nobody ratified, a rationale
you imagined, a stack you assumed from the repo name. It does not forbid an
**honestly-labelled empty cell that names its own fill trigger**. So on a greenfield repo
`ARCHITECTURE.md` is still written — as a stub carrying the heading skeleton the real content will
occupy and a marker saying what it is: `> Stub — nothing decided yet. Fill from the first ratified
decision (bootstrap <date>).` A labelled stub is legible state; the next session sees exactly what
is missing and what fills it. An invented one is a lie the next session trusts. **Name the fill
trigger inside the marker, and name one that exists** — the marker itself is the trigger, so let
it say what lands ("fill from the first ratified decision"), and name a *decision*, never "the
first modules that land": a module-shaped trigger refills the file with the module map this shape
just removed. A stub pointing at a file that does
not exist is the noise the MVH note above forbids, wearing an accountability costume.

## Phase 2c — Ship the workflow distillation (`.claude/docs/`)

Copy the kit's three project-docs **verbatim** (including the `shipped-by` provenance header)
from `references/project-docs/` into the project:

- `.claude/docs/workflow.md` — the full flow: session ritual, plan-before-code, red→green work
  cycle, verification-ladder semantics, continuity layers, production posture.
- `.claude/docs/testing.md` — the five stack-agnostic testing invariants + cross-cutting rules.
- `.claude/docs/docs-discipline.md` — rule 0 (oracle before prose: what earns a document at all,
  and where prohibitions live), the doc-with-code mapping table, ADR threshold, glossary,
  frontmatter rules.

Why files in the project and not knowledge in the plugin: skills are a pull channel — a working
session never reads the kit's references; project files are the push channel every session can
open without any skill trigger (transcript-grounded: sessions with the knowledge only in the
plugin proposed zero ladder rungs). Division of labor: CLAUDE.md carries the ~per-turn duty
lines; `.claude/docs/` carries the on-demand depth; the plugin remains the canon.

Rules: copy verbatim — do **not** hand-adapt the content to the project (project facts belong
in CLAUDE.md; verbatim copies keep re-sync a trivial diff). The provenance header
is the update channel: Audit compares the `shipped-by` version against the installed plugin and
offers a re-sync when the plugin is newer. MVH-on-request: skip this phase.

## Phase 3 — Write `.claude/settings.json`

The deny list matters more than the allow list. Goal: freedom inside a sandbox — most ops
auto-allowed, dangerous ones denied or gated, no blanket `--dangerously-skip-permissions`.

```jsonc
{
  "permissions": {
    "allow": [
      "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)", "Bash(ls:*)",
      "Bash(<test-runner>:*)", "Bash(<lint-runner>:*)",
      "Read(./**)", "Edit(./**)"
    ],
    "ask":  [ "Bash(git push:*)", "Bash(git commit --amend:*)", "Bash(git rebase:*)" ],
    "deny": [ "Read(./secrets/**)", "Edit(./secrets/**)", "Edit(./.git/**)",
              "Bash(rm -rf /:*)", "Bash(git push --force:*)" ]
  }
}
```

Tune to what actually exists. If the project uses MCP, gate it via `enabledMcpjsonServers`.

**Two rules cover every file tool: `Read(path)` and `Edit(path)` are the only forms the file-permission
checks match.** `Read(./**)` already governs Grep and Glob; `Edit(./**)` already governs Write and
NotebookEdit. Giving one of *those* tools a path of its own is the no-op — `Glob(path)`, `Write(path)`,
`NotebookEdit(path)` are parsed, never matched, and warn at startup; measured live, a
`deny: Write(./s/**)` let the file be created anyway. `Grep(path)` never warns at all — the warning
list is hardcoded and omits it — so nothing tells you it isn't doing what you meant; write `Read(path)`
and the question doesn't arise. (`MultiEdit` is gone as a tool and emits **both** warnings — "matches
no known tool" *and* the "use `Edit(path)` instead" line, since it is still in the hardcoded
edit-tool list.) A **bare**
tool name is a different rule and stays live: `deny: Write` without parens matches the tool everywhere
and is not a typo. Dead rules are worse than absent ones — they read as protection while enforcing
nothing, and a template is the one place a no-op propagates into every project that copies it.

On the **deny** side the two are not interchangeable: a `Read` deny also blocks Edit on that path
but never reaches Write or NotebookEdit, so a path nothing may read *or* change needs both
— hence the `Read(./secrets/**)` + `Edit(./secrets/**)` pair above. Neither reaches a subprocess that
opens the file itself (a Python/Node script); for OS-level enforcement, enable the sandbox.

**`.env` — distinguish secret-bearing from dev-only before denying it.** A blanket
`deny: Edit(./.env*)` looks safe but, in a dev-only project, it blocks the agent from creating
the very `.env` its integration tests need — the agent ends up smuggling creds through env-var
prefixes on every command (worse ergonomics, no real safety gain). Decide per project: if `.env`
would hold *production* secrets → deny it; if it holds *dev-only* creds (local DB container, a
local LLM) → **allow it, gitignore it, and add a one-line "no prod creds in `.env`" rule** instead.
The mechanical guard that matters most is `.gitignore` + the secret never reaching a shared remote,
not blocking the file the agent legitimately needs to run.

**Rewrite-with-donors:** when the project rewrites an existing system, pin donor/reference
repos read-only *mechanically* — `allow: Read(//abs/path/**)` plus `deny: Edit(//abs/path/**)`
(`//` = absolute path; that one `Edit` deny is what covers Write and NotebookEdit — a `Read` deny
would not). A deny rule survives context loss; in live use the same mechanism also blocked a
credential-file write that prompt-discipline had missed.

## Phase 4 — `.claude/rules/` for hard prohibitions

Part of the default shape wherever Phase 0 found something to put there — and absent otherwise; an
invented rule is the same noise as an invented doc. What belongs here is a **non-negotiable
prohibition on an action**: "PII fields must never be logged", "an observation code is never
derived from prose", "filling a counter must not trigger a producer call". A single instance of any
of those is assertable — mock the producer and assert it was not called — and where it is, **write
that test too**; the rule earns its place because it binds the call sites nobody has written yet,
which is the part no test reaches. That is the class `docs-discipline.md` rule 0 marks as
unprovable from code, and the class that disappears silently when a document is deleted, which is
why it gets a carrier instead of a paragraph.

Each rule file ≤30 lines, prescriptive, referenced from CLAUDE.md. Needs more than 30 lines → it is
guidance, put it in `docs/CONVENTIONS.md`. Two mechanism facts set that budget (detail in
`native-capabilities.md`): rules **without** `paths:` load in full at every session start, so this
layer is priced per turn and descriptive prose in it is exactly the tax rule 0 forbids; and
`paths:` scoping is heuristic, so a must-not-miss rule stays always-on rather than scoped.

Do not restate CLAUDE.md's `Never` tier here. That tier carries repository operations, mirrored
into `settings.json` (Phase 3); this directory carries domain prohibitions, which no permission
rule can reach.

## Phase 6 — Stop

No hooks, agents, skills, or commands yet. The default shape (indexer + settings + shipped
`.claude/docs/` + `docs/ARCHITECTURE.md` + whatever prohibitions Phase 4 earned) is the harness
most projects need forever — still no custom subagents/hooks until a trigger earns them.

## Phase 7 — Verify

**Have the operator run `/doctor` first** (alias `/checkup`) — it is a slash command in *their*
session, not something a delegate or a headless run can reach, and `claude doctor` on the CLI is a
different, installation-health-only tool. The native setup checkup catches unparseable
settings, colliding agent definitions, slow hooks, version currency and context-heavy extensions
without any of the checks below. The rest of this phase is the write-through evidence `/doctor`
has no view of: whether *this project's* files got the duties, and whether its permission rules
are live rather than merely present.

```bash
claude --print "ok" </dev/null 2>&1 >/dev/null | grep -E '^(Permission |Ignoring .*permissions\.allow)'
# pass = prints NOTHING. Read each hit, don't just count them:
#   "not matched by file permission checks" → a no-op path form (Glob/Write/NotebookEdit).
#   "matches no known tool" → a typo. Only deny/ask are typo-checked, so a typo'd *allow* rule is
#     dropped forever without a word — eyeball that list yourself; this is a blind spot, not a pass.
#   "Ignoring N permissions.allow entries … not been trusted" → the allow half was never validated.
#     Accept the trust dialog once and re-run. Without this second pattern in the grep an untrusted
#     workspace (fresh clone, CI) prints nothing while every allow rule is inert — a clean bill of
#     health on the exact defect the check exists to find.
# The name in parentheses is the source file: a hit can come from ~/.claude/settings.json or a
# managed layer rather than this project (and the typo variant carries no label at all).
# Also blind to `Grep(path)`, which never warns — only the Phase 3 template prevents that one.
claude --print "what is the project's stack?"  # pass = answer matches CLAUDE.md, not a guess
claude --print "what files are you not allowed to touch here?"  # pass = names the deny/ask rules from settings.json
# CM resolves the instruction file: Claude Code loads a root CLAUDE.md and .claude/CLAUDE.md alike,
# and a project using the latter scores 0 on every grep below if you hard-code the former.
# CM resolves the file AND its @imports: a bridged CLAUDE.md (`@AGENTS.md`, per Phase 0/1) carries
# the duty in the imported file, and a literal read of CLAUDE.md scores 0 on all six.
CM=$([ -f CLAUDE.md ] && echo CLAUDE.md || echo .claude/CLAUDE.md)
CMTEXT=$(cat "$CM"; sed -n 's/^@\(.*\)$/\1/p' "$CM" | while read -r i; do [ -f "$i" ] && cat "$i"; done)
# separate with `;` not `&&` — grep -c returns 1 on a zero count, so a chain stops at the first
# miss and the "all six" line the comment promises never prints
echo "$CMTEXT" | grep -ci "plan mode"; echo "$CMTEXT" | grep -ci "fresh-context"
echo "$CMTEXT" | grep -ci "size the change"
echo "$CMTEXT" | grep -ciE '^[[:space:]]*#{0,4} *[0-9.]* *[-*+]? *\*{0,3}Continuity'
echo "$CMTEXT" | grep -cE '^#{1,4} *Commands'; echo "$CMTEXT" | grep -cE '^#{1,4} *Boundaries'
ls .claude/docs/workflow.md .claude/docs/testing.md .claude/docs/docs-discipline.md docs/ARCHITECTURE.md
# pass = all six greps ≥1 (plan-mode duty + verification ladder + change-sizing + continuity duty +
# a Commands section + a three-tier Boundaries section landed in CLAUDE.md) and all four
# shipped/authored docs exist. `.claude/rules/` is deliberately NOT in that list: it exists only
# where Phase 0 found a prohibition, so a presence check there would reward inventing one. The last two are anchored as headings because that is the shape the
# 2,500-repository analysis found load-bearing: commands early and executable, boundaries in three
# tiers. A file with the commands buried in prose passes a word-grep and fails the reader. This is the write-through check — it catches
# instructions that stayed in the kit's references instead of landing in the project (e.g. a skipped
# evaluator line, or — the case that earned the fourth token — a CLAUDE.md naming no continuity duty
# at all, while the depth sat shipped and unreferenced in `.claude/docs/workflow.md`).
# **The continuity token is ANCHORED, and that anchor is the whole check.** A bare `grep -ci continuity`
# is a false pass: the Reference-materials block this very template prescribes already ends a line with
# the word ("…verification ladder, continuity"), so the buggy CLAUDE.md — pointer present, duty absent —
# scores 1 and passes. Measured against the real artifact, not reasoned about. The anchor demands the
# word as a *label at line start* (the duty bullet, or a `## Continuity` heading), which no pointer line
# satisfies. Don't "simplify" it back. Equally, don't swap it for a prose fragment like
# `closes with an episodic`: sessions paraphrase the duty (observed: "closes with a `/devlog:devlog`
# entry"), so a phrase-token false-fails correct bootstraps — it was tried and scored 0 on all three.
# The anchor is carrier-agnostic: it passes whether the carrier is a devlog or disciplined commits.
# It is mechanical on purpose: a behavioral probe (`claude --print "what happens next
# after a feature?"`) is contaminated by the operator's own global memory layers — their union
# answers correctly even when the project file is missing the lines.
# Greenfield: the stack probe above and the verify run below are **N/A by construction** — the stack is
# a labelled TBD, so nothing exists for an answer to match and no verify command exists to run. Record
# them as N/A-by-construction, not "skipped" — due when the stack lands; name that in the stub marker.
# The deny-rules probe and all
# four greps apply unchanged (settings.json and CLAUDE.md are real on day zero).
# MVH-on-request projects: only the plan-mode and change-sizing greps apply.
```

Each check has a crisp criterion — "command produced output" is not a pass.

If CLAUDE.md names a verification command (`make check`, `pytest -q`), **run it once and confirm it
actually executes** — a runnable check the agent can close its own loop against is the difference
between long-horizon autonomy and drift, and one that only exists on paper is worse than none.
Running it will prompt for permission on first use — expected; don't skip the run because of it.

**When launching the app is more than one command** — a database, an env file, a graphical
session, a multi-step build — do not hand-write a launch procedure into CLAUDE.md. `/run` and
`/verify` infer a standard launch on their own, and that inference is exactly what gets unreliable
here; `/run-skill-generator`, run **once per project** (again when the build changes), gets the app
up from a clean environment and commits the working recipe as `.claude/skills/run-<name>/`, which
every later run in the repo follows. `/verify` records its own recipe the same way when it had to
work one out. That is the kit's "state on disk" rule satisfied natively — a recorded skill, not a
second entry point wrapping your gates. **Detect before prescribing**: these are bundled skills,
and a bundled skill can be absent from a given profile (`CLAUDE_CODE_DISABLE_BUNDLED_SKILLS`, a
managed policy, an org build). Check mechanically rather than by looking at autocomplete, which a
headless run has no access to: `claude --print "list your available skills"` names what this
profile actually carries. If the skill is not there, name the real launch command in CLAUDE.md as
above and stop.

## Phase 8 — Record the bootstrap

The bootstrap writes its own first episodic entry **in the carrier the Phase 2 duty line names** —
`/devlog:devlog` where the companion is installed, otherwise a hand-written
`.claude/devlog/entries/0001-*.md`, or, where the project's carrier is disciplined commit messages,
the bootstrap commit itself. The content is the bootstrap itself — what was detected (including
"greenfield"), what shape was deployed, what was deliberately deferred, what is still a labelled
stub. The carrier is the one Phase 2's duty line names.

Four things fall out of that one action, which is why it is a phase and not a nicety: the *why* of
this harness lands in the episodic layer instead of evaporating with the session that chose it;
`.claude/devlog/entries/` exists for real, so the next entry appends to a live directory instead of
re-inventing the convention; the SessionStart digest has something to show on turn one instead of
greeting the next session with silence; and the carrier gets a live smoke test — a `/devlog:devlog`
that breaks on entry #1 breaks now, while you are here to fix it, not three sessions later when
someone finally tries to use it. MVH-on-request: skip.

## Optional next steps (only after the trigger fires)

| Trigger | Add |
|---|---|
| A convention Claude gets wrong twice | a line in CLAUDE.md |
| The same multi-step ritual typed 3×+ | a skill (`disable-model-invocation` if side-effecting) |
| Something must happen every time | a hook (block at submit, never mid-write) |
| "Claude claims done when it isn't" | verification ladder: in-prompt check → `/goal` → Stop hook (deterministic gate on mechanical tests/lint/types) → `/code-review` on substantive change → fresh-context second opinion (next row) |
| High-stakes deliverable where silent-wrong is costly (security, migration, untrusted-input parser, invariant refactor) | a **fresh session** told to refute, or `/code-review ultra` when the change itself is the risk. The lever is the fresh, un-anchored context, not an in-context "re-check yourself" pass — per-change for this class, not one-time |
| Codebase-scale sweep / migration / trust-critical audit that exceeds one context | route to a **dynamic workflow** (keyword `ultracode`) — do not build a custom pipeline |
| External service (DB, browser, monitoring) | an MCP server in `.mcp.json` |

## Anti-patterns in bootstrap

❌ a custom orchestrator subagent · ❌ five hooks "for hygiene" · ❌ a 600-line copied CLAUDE.md ·
❌ a prescriptive language/stack preset the model didn't need · ❌ a blocking Stop hook on day one ·
❌ `--dangerously-skip-permissions` · ❌ treating bootstrap as one-shot (the harness evolves; the starting state is the default shape —
documents and conventions, no machinery — and the kit is stripped back as the model improves).
