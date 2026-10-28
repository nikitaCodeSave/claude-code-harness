# Report — kit v2 (2026-10-28)

**Final run, after the refute-review fixes: 16/16** — A 5/5, B 8/8, C 3/3. B now adopts the existing
`docs/decisions.md` as the decision home instead of copying it, and bridges the nested `web/AGENTS.md`
with a one-line `web/CLAUDE.md` (`@AGENTS.md`). The section below is the earlier run.


Model: Opus (alias `opus`), headless, kit via `--plugin-dir`, operator settings excluded.

- mech: PASS (14 checks); each check verified to fail on a planted defect (dead `Write(...)` rule,
  a version pin, a missing template section).
- A (new large project): 5/5 — 77-line `CLAUDE.md` with honest `TBD`s, settings with deny and
  `ask` on migrations, no component files before code exists, hand-over names
  `/setup-matt-pocock-skills` and `/wayfinder`.
- B (existing monorepo): 7/7 — 52-line root `CLAUDE.md` and three component files (14–18 lines),
  no tree or module map, the README-only ledger prohibition in *Never* and in the worker file,
  three ADRs seeded from `docs/decisions.md` with their source, the contract named and put behind
  `ask`; it also surfaced a real gap (the worker does not validate against the shared schema).
- C (existing harness with planted defects, read-only): 3/3 — both defects reported, nothing edited.

Rig fixes before these results (not kit changes): the runner allowed only `Bash`, so the first run
could not invoke the skill at all ("Execute skill" permission, declined headless) and the session
improvised a harness without it — directory trees, an invented layout, `docs/architecture.md`;
writing `.claude/settings.json` needs approval even under allow rules, so A/B run under
`bypassPermissions` in throwaway directories; a pipefail bug in the B4 check; the A prompt now says
nobody will answer questions (the skill correctly stopped to ask them).

Transcripts: `a1.txt`, `b1.txt`, `c1.txt`.
