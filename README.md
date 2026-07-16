# claude-code-harness

Two Claude Code plugins that set up, audit, and evolve your project's harness — the root
`CLAUDE.md` and `.claude/` directory that turn a fresh repository into a workspace Claude
works well in — and keep a memory of it across sessions.

You drive both by talking. There is no wizard and nothing to configure by hand.

## Install

```
/plugin marketplace add nikitaCodeSave/claude-code-harness
/plugin install claude-code-harness@claude-code-harness
/plugin install devlog@claude-code-harness
```

The `devlog` companion is a separate plugin, but install both: the kit designs the harness,
devlog gives it a memory. [Why that matters](#the-devlog-companion-your-projects-memory) —
short version: a session that starts cold repeats mistakes a session that starts informed
doesn't.

Run `/reload-plugins` (or restart the session) right after installing, before first use.

Then open any project and say:

> **"set up Claude Code harness in this project"**

That's the whole setup. Installing writes nothing to your `~/.claude` profile, and everything
the kit creates lands in your repo as plain files — read the diff, `git checkout` to undo.

<details>
<summary>Prefer to try it without touching your own setup at all?</summary>

Run the kit against a disposable config **and** a disposable project:

```bash
export CLAUDE_CONFIG_DIR=~/claude-fresh                # a whole separate ~/.claude
mkdir -p "$CLAUDE_CONFIG_DIR"
cp ~/.claude/.credentials.json "$CLAUDE_CONFIG_DIR/"   # Linux/Windows: skips a re-login.
                                                       # macOS keeps credentials in the Keychain — omit this
mkdir -p ~/demo-project && cd ~/demo-project && git init -q

claude plugin marketplace add nikitaCodeSave/claude-code-harness --scope project
claude plugin install claude-code-harness --scope project

claude    # then say: "set up Claude Code harness in this project"
```

You need both halves: `CLAUDE_CONFIG_DIR` relocates the *entire* `~/.claude` (global
`CLAUDE.md`, settings, skills, memory), so the session sees the kit and none of your own setup —
no project-level file can switch off a global `~/.claude/CLAUDE.md`. `--scope project` keeps the
install in the demo project's `.claude/settings.json` rather than your user settings.

Undo is `rm -rf ~/claude-fresh ~/demo-project`; your real `~/.claude` is never written to. Two
things that bite: the plugin is named `claude-code-harness`, not `harness`, and a fresh config
does not trust the demo project until you accept the dialog once.

</details>

## What you can say

| You want | Say |
|---|---|
| A project gets its harness (new or existing repo) | **"set up Claude Code harness in this project"** |
| The minimal variant (CLAUDE.md + settings only) | **"set up a minimal harness"** |
| A gap report on an existing `.claude/` | **"audit my Claude Code harness"** |
| To record what you just changed and why, for the next session | **"запиши в devlog"** / **`/devlog:devlog`** |
| To know whether Claude Code already does X natively, before you build it | **"can Claude Code already do X?"** |
| The multi-session product-build spine (oracle, feature ledger, progress) | **"set up the long-running build kit (Phase 5)"** |
| Independent verification of a finished deliverable | **`/claude-code-harness:external-audit <scope>`** in a fresh session |
| To call it explicitly — in your own words, in your own language | **`/claude-code-harness:claude-code-harness настрой мне харнесс, друг`** |

The phrases are examples, not incantations. The skill reads intent, so anything that means the
same thing works — and if you'd rather not rely on that, the last row calls it by name.

## What the first setup touches

- **In your repo**: root `CLAUDE.md`, `.claude/settings.json`, workflow docs under `.claude/docs/`,
  and real `docs/ARCHITECTURE.md` + `docs/CODE-MAP.md`. Custom subagents, hooks, skills, and
  commands are deliberately **not** created — see the opinion below.
- **Outside your repo**: nothing, unless you say yes. The one thing you're ever offered is the
  practice baseline (a behavioral layer for how Claude works). By default it lands in the project
  at `.claude/rules/practice-baseline.md` — in git, reviewable, deletable. Merging it into your
  global `~/.claude/CLAUDE.md` happens only if you explicitly approve, after seeing the diff, with
  a timestamped backup written first.

## The devlog companion: your project's memory

A Claude Code session forgets. Context gets compacted, the session ends, tomorrow's session opens
cold — and re-litigates a decision you already made, or walks into a trap you already mapped. The
harness the kit builds is *atemporal*: it says what's true about your project, not what happened
in it. Those are different jobs, and the second one is where sessions actually bleed time.

devlog is that second job, made runnable:

- **`/devlog:devlog`** — after a feature, fix, refactor, or a decision worth keeping, this writes
  one entry to `.claude/devlog/entries/NNNN-slug.md`: what changed, why, what was verified. It's
  git-tracked and reviewable, so it's a record your teammates read too, not a private cache. Ask
  for it by name or just say "запиши в devlog" — and Claude offers it on its own once a
  significant change lands.
- **A digest at session start** — every new session opens with the recent entries and any
  in-flight work already in view, so it starts informed instead of asking you to re-explain.
  It's read-only, costs a few lines, and stays silent in projects that keep no devlog.
- **`devlog-reindex`** — regenerates `index.json` + `tldr.md` from the entries, so the digest and
  search stay correct without hand-maintained bookkeeping.

The payoff isn't the file — it's that the *next* session starts where the last one left off. That
compounds: entry #18 in this repo's own devlog exists because entry #12 and #13 taught the same
lesson twice, and the third time it got caught before shipping.

Requirements: **Python 3** on `PATH` (standard library only — no pip installs). Runs on Linux,
macOS, and Windows/Git Bash. If you'd rather keep your changelog by hand, skip the plugin — the
kit works without it, it just won't remember for you.

## The opinion

> **Under a capable model, less harness yields more productivity.** Find the simplest setup that
> works; add a component only when a simpler approach demonstrably underperforms. If a component
> encodes "the model can't do X" and the model already does X natively, it should not exist.

So the kit is as happy removing things as adding them. Point it at an existing `.claude/` and it
reports what's dead weight: a custom orchestrator subagent, a multi-stage pipeline, a 500-line
`CLAUDE.md`, mid-thought blocking hooks, stale model pins.

Claude Code 2.x / Opus-class-specific. It does **not** cover provider-neutral patterns for
OpenAI/Codex/other frameworks.

## Learn more

- [Operator playbook](plugins/harness/references/operator-playbook.md) — the human-facing
  lifecycle: what to say at each stage, what to prepare between sessions, and how to stay current
  (`/plugin update` → "audit my Claude Code harness" → approve the offered re-syncs).
- [What ships](plugins/harness/) — the skill entry point (`SKILL.md`), on-demand references
  (bootstrap/audit checklists, native capabilities, evidence base, harness discipline), and the
  3-role external-audit pass (`agents/` + `commands/external-audit.md`).
- [The devlog plugin](plugins/devlog/) — the `/devlog:devlog` skill, the `devlog-reindex`
  regenerator, and the session-start digest hook.

## Provenance

Distilled from a working harness laboratory and proven on a real empty-repo → working-product
build. Not a template to copy wholesale — transmittable knowledge about harness *design*.

## License

MIT — see [LICENSE](LICENSE).
