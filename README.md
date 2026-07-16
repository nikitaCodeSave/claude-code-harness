# claude-code-harness

A Claude Code plugin that **designs, bootstraps, audits, and extends the harness** around
Claude Code — the `.claude/` directory and root `CLAUDE.md` that turn a fresh repository into a
high-leverage agentic workspace.

Opinionated, and the opinion is one line:

> **Under a capable model, less harness yields more productivity.** Find the simplest setup that
> works; add a component only when a simpler approach demonstrably underperforms. If a component
> encodes "the model can't do X" and the model already does X natively, it should not exist.

Claude Code 2.x / Opus-class-specific. It does **not** cover provider-neutral patterns for
OpenAI/Codex/other frameworks.

## Install

```
/plugin marketplace add nikitaCodeSave/claude-code-harness
/plugin install claude-code-harness@claude-code-harness
/plugin install devlog@claude-code-harness          # optional companion — see below
```

The marketplace ships **two plugins**: the `claude-code-harness` design kit and a
`devlog` continuity companion. The kit recommends keeping an episodic "what changed and
why" record; installing `devlog` makes that guidance runnable (a `/devlog:devlog` skill,
a `devlog-reindex` command that regenerates `index.json` + `tldr.md`, and a SessionStart
digest that surfaces recent devlog entries + active progress at session start — silent in
projects that keep neither). Install it if you want the automation; skip it if you keep
your changelog by hand.

`devlog-reindex` needs **Python 3** on `PATH` (standard library only — no pip installs) and
runs on Linux, macOS, and Windows/Git Bash. It joins `PATH` when the plugin loads, so right
after installing run `/reload-plugins` (or restart the session) before first use.

## First session (start here)

Everything is driven by plain phrases in a Claude Code session — there is no setup wizard
and nothing to configure by hand:

| You want | Say |
|---|---|
| A project gets its harness (new or existing repo) | **"set up Claude Code harness in this project"** |
| The minimal variant (CLAUDE.md + settings only) | **"set up a minimal harness"** |
| A gap report on an existing `.claude/` | **"audit my Claude Code harness"** |
| The multi-session product-build spine (oracle, feature ledger, progress) | **"set up the long-running build kit (Phase 5)"** |
| Independent verification of a finished deliverable | **`/claude-code-harness:external-audit <scope>`** in a fresh session |

What the first bootstrap touches — and what it doesn't:

- **Inside the repo**: root `CLAUDE.md`, `.claude/settings.json`, the shipped workflow docs
  in `.claude/docs/`, real `docs/ARCHITECTURE.md` + `docs/CODE-MAP.md` (`.mcp.json` only if a
  clear external-tool need surfaces). Custom subagents, hooks, skills, and commands are
  deliberately **not** created.
- **Outside the repo**: nothing, unless you opt in. The one offer is the practice baseline
  (the behavioral layer §1–8): by default it lands in the project
  (`.claude/rules/practice-baseline.md` — in git, reviewable, removable); merging it into
  your global `~/.claude/CLAUDE.md` happens only if you explicitly approve, after seeing the
  diff, with a timestamped backup written first.
- Installing the plugins changes nothing in your `~/.claude/` profile. The devlog
  companion's only always-on piece is the read-only SessionStart digest above, silent
  wherever there is nothing to surface.

The human-facing lifecycle map — what to say at each stage, what to prepare between
sessions, and how to keep everything current (`/plugin update` → "audit my Claude Code
harness" → approve the offered re-syncs) — is
[`plugins/harness/references/operator-playbook.md`](plugins/harness/references/operator-playbook.md).

## Four modes

- **Bootstrap** — a project has no `.claude/` and wants its harness now (production-grade
  default; minimal on explicit request).
- **Audit** — an existing `.claude/` has accumulated cruft (custom orchestrator subagent,
  multi-stage pipeline, 500-line CLAUDE.md, mid-thought blocking hooks, stale model pins).
- **Extend** — before adding a hook/skill/subagent/command, confirm a built-in doesn't already
  cover it.
- **Explain** — how Claude Code differs from generic agentic frameworks; when to reach for a
  dynamic workflow.

## What ships

| Path | Role |
|---|---|
| `plugins/harness/SKILL.md` | The skill entry point — the four modes + routing |
| `plugins/harness/references/` | On-demand knowledge (bootstrap/audit checklists, native-capabilities, evidence base, operator playbook, harness discipline/evolution, shippable project-docs) |
| `plugins/harness/agents/` + `plugins/harness/commands/external-audit.md` | The 3-role external-audit pass (evidence-executor ∥ process-auditor ∥ code-refuter → adjudication) |
| `plugins/devlog/` (skill + `bin/devlog-reindex` + `hooks/`) | The devlog companion plugin — the `/devlog:devlog` skill, the index/digest regenerator on `PATH`, and the SessionStart continuity digest |

## Provenance

Distilled from a working harness laboratory and proven on a real empty-repo → working-product
build. Not a template to copy wholesale — transmittable knowledge about harness *design*.

## License

MIT — see [LICENSE](LICENSE).
