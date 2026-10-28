# claude-code-harness — operational notes for coding agents

This repository is the **source of truth** for the `harness` Claude Code plugin (marketplace
`claude-code-harness`). Read this before changing
anything; it carries what the file tree cannot tell you. Claude Code additionally loads
`.claude/CLAUDE.md` (maintainer-facing, Russian); agents from other vendors get this file.

## Layout — the part that is easy to break

- `.claude-plugin/marketplace.json` (repo root) is the **marketplace catalog**. Each plugin's own
  manifest is `plugins/<name>/.claude-plugin/plugin.json`.
- There is **one plugin**: `plugins/harness/` (the kit — one skill, `SKILL.md`, plus `templates/`).
- `.claude/` at the repo root is this repository's **own** dev harness. It is not part of the
  plugin and never ships.
- `~/.claude/skills/harness` on the maintainer's machine is a **symlink to
  `plugins/harness/`**, so edits here are live immediately. Edit here, never in a copy.
- `evals/` is the kit's own regression suite — mechanical checks plus three headless sessions on
  fixtures, with criteria written before the runs. Dev harness, never shipped. **A test whose
  mechanism the kit has retired is deleted, not kept green.**

## Commands

```bash
# release: writes the version into plugin.json, stages the shippable surface,
# prints the commit/tag/push finish. It never commits for you.
./scripts/release.sh <version>

# manifest validation
claude plugin validate .

# regression suite — mech: seconds, free, before every release; sessions: ~10 min, after changing SKILL.md or templates
./evals/run.sh mech
./evals/run.sh sessions
```

Done = `./evals/run.sh mech` exits 0, `release.sh` completes without a marketplace-drift error,
and `plugin validate` prints `✔ Validation passed`.

**Green does not mean correct, and the gap is the reason review exists here.** The suite checks
structure: that a path a shipped document names resolves, that every reference is reachable from
the map in `SKILL.md`, that the marketplace lists exactly the plugins on disk, that a JSON example parses. It
cannot see that a claim went stale, that two documents assert opposite things, or that a check
has outlived the mechanism it guarded — so treat a green suite as permission to review, never as a
verdict.

## Boundaries

- **Always**: bump the version in `plugin.json` for any change consumers should receive — it is the
  update cache key, so pushing content without bumping it ships nothing. Use `release.sh`: it keeps
  the manifests in sync.
  Record what changed and why in the commit message, and anything consumers receive in
  `CHANGELOG.md`; there is no journal beyond these.
- **Ask first**: changing what the plugin ships (adding an agent, a command, a hook). The kit's own
  position is that it ships a skill and templates only; adding machinery needs a reason that
  survives the question "does a built-in already do this?"
- **Never**: edit `.claude/devlog/` (a closed journal) or `.claude/audits/` — frozen provenance. Never put a `version`
  field in the marketplace entry — `plugin.json` is authoritative and the release script fails the
  build if one appears.
  - The one repair a frozen file admits is **a link whose target moved**: the text stays exactly as
    it was written, the path is corrected. A record that points nowhere has stopped being
    provenance, and repairing the pointer is not rewriting the claim. Nothing else about a frozen
    file is editable — not a rename it predates, not a conclusion later work overturned.

## Conventions that are not obvious from the files

- **Nothing shipped pins a version.** `SKILL.md` and `templates/` describe behavior without binding
  it to a Claude Code release or a model; the mechanical suite fails on a pin. Version-specific
  knowledge about Claude Code lives in the maintainer's lab (`native-capabilities.md`), not here.
- **Templates ship into other people's repositories.** Every line there is paid for on every turn
  of every session in those projects; a line stays only if it rests on a measurement or a
  first-party source, and the reason is recorded in the README's *How we work — and why* or the
  CHANGELOG.
- **Language split is deliberate**: everything that ships to users is English; the maintainer's
  dev harness under `.claude/` is Russian.
- **Single-incident does not become an invariant.** A new rule needs multi-source evidence or
  repeated empirics; the kit rejects rules grounded in one observation, including its own.
- **The kit is as willing to delete as to add.** A component lives only while it encodes something
  Claude Code does not do natively — see `CHANGELOG.md` for what has been retired and why.

## Reviewing work here

Prefer refuting to confirming. The content is prose, so style notes are noise; what matters is
whether a claim is true of the current Claude Code, whether it contradicts another document in the
repo, and whether a document that ships verbatim smuggled in a perishable fact. Where a claim rests
on a measurement, check that the oracle is independent of the claim and that the run varied the
variable the conclusion names.

**Grep the whole tree for the mechanism's name, not for the sentence you remember writing.** Facts
here live in several files at once — a reference, a checklist item, the skill's own table — and an
edit that fixes one copy leaves the others asserting the opposite, silently. Three such
contradictions were found in a single external audit (`CLAUDE_CODE_SUBAGENT_MODEL`, `REVIEW.md`,
where a side-effecting ritual belongs), and in every case the correct copy already existed in the
repository; it simply was not the copy a reader reaches. So: before changing a claim, `grep -rn`
the identifier across `plugins/` and fix every hit or note why a hit is legitimately different.
After changing it, grep again — the third contradiction in that audit survived a targeted edit
because the search had been for meaning rather than for the name.
