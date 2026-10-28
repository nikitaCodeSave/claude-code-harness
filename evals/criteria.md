# Session criteria (v2) — declared before the first run

Each run is a headless `claude -p` with the kit loaded by `--plugin-dir`, the operator's own
settings excluded (`--setting-sources project,local`), in a temporary copy of the fixture.
A red indicator opens the transcript; the verdict is read there.

## A — new large project (`fixtures/greenfield` = empty repo)
Prompt: set up the harness; the operator states a multi-component, months-long project.
- A1 root `CLAUDE.md` exists, ≤ 120 lines, with `## Commands`, `## Boundaries`, `## How we work`,
  `## Project knowledge`.
- A2 unknown commands are labelled (`TBD`), not invented.
- A3 `.claude/settings.json` parses and has a non-empty `deny`.
- A4 no component `CLAUDE.md` (nothing exists on disk yet); no `.claude/agents|hooks|skills|commands|docs`.
- A5 the hand-over names `/setup-matt-pocock-skills` and `/wayfinder`.

## B — existing multi-component repo without a harness (`fixtures/monorepo`)
Prompt: set up the harness in this project.
- B1 as A1.
- B2 no module map or directory tree in any `CLAUDE.md` (no `├──` / `└──`, no section listing every directory).
- B3 at least one component `CLAUDE.md` carrying that component's own test command.
- B4 the README prohibition (ledger writes only through `worker.ledger.post()`) lands in a
  `CLAUDE.md` boundary, a component `CLAUDE.md` rule or `.claude/rules/`.
- B5 the existing decision log is the decision home: *Project knowledge* names `docs/decisions.md`, and its
  entries (cents, retries) are not copied into a second place. *(Revised 2026-10-28 before the run, after the
  refute-review: the kit now adopts an existing decision log instead of copying it.)*
- B6 the shared contract (`contracts/order.schema.json`) is named as a contract in a `CLAUDE.md`.
- B7 as A3 and A4 (component files allowed here).
- B8 `web/AGENTS.md` (added 2026-10-28 before the run) is kept switched on: `web/CLAUDE.md` exists and
  imports it with `@AGENTS.md`.

## C — existing harness with planted defects (`fixtures/s2-httpping`), read-only
Prompt: audit my Claude Code harness.
- C1 the stale model pin ("3.5 Sonnet") is reported.
- C2 the dead permission rule `Glob(./**)` is reported.
- C3 nothing is edited (plan mode).
