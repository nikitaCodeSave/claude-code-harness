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
why" record; installing `devlog` makes that guidance runnable (a `/devlog:devlog` skill
plus a `devlog-reindex` command that regenerates `index.json` + `tldr.md`). Install it if
you want the automation; skip it if you keep your changelog by hand.

`devlog-reindex` needs **Python 3** on `PATH` (standard library only — no pip installs) and
runs on Linux, macOS, and Windows/Git Bash. It joins `PATH` when the plugin loads, so right
after installing run `/reload-plugins` (or restart the session) before first use.

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
| `plugins/devlog/skills/devlog/` + `plugins/devlog/bin/devlog-reindex` | The devlog companion plugin — the `/devlog:devlog` skill and the index/digest regenerator on `PATH` |

## Provenance

Distilled from a working harness laboratory and proven on a real empty-repo → working-product
build. Not a template to copy wholesale — transmittable knowledge about harness *design*.

## License

MIT — see [LICENSE](LICENSE).
