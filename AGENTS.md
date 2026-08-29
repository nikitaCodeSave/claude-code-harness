# claude-code-harness — operational notes for coding agents

This repository is the **source of truth** for two Claude Code plugins. Read this before changing
anything; it carries what the file tree cannot tell you. Claude Code additionally loads
`.claude/CLAUDE.md` (maintainer-facing, Russian); agents from other vendors get this file.

## Layout — the part that is easy to break

- `.claude-plugin/marketplace.json` (repo root) is the **marketplace catalog**. Each plugin's own
  manifest is `plugins/<name>/.claude-plugin/plugin.json`.
- There are **two plugins**: `plugins/harness/` (the kit — a skill plus on-demand references) and
  `plugins/devlog/` (the continuity companion the kit points at).
- `.claude/` at the repo root is this repository's **own** dev harness. It is not part of either
  plugin and never ships.
- `~/.claude/skills/claude-code-harness` on the maintainer's machine is a **symlink to
  `plugins/harness/`**, so edits here are live immediately. Edit here, never in a copy.

## Commands

```bash
# release: writes the version into BOTH plugin.json files in lockstep, checks shipped-by stamps,
# stages the shippable surface, prints the commit/tag/push finish. It never commits for you.
./plugins/harness/scripts/release.sh <version>

# manifest validation
claude plugin validate .

# devlog index (required after adding an entry under .claude/devlog/entries/)
./plugins/devlog/bin/devlog-reindex
```

Done = `release.sh` completes without a stamp mismatch, `plugin validate` prints
`✔ Validation passed`, and the reindexer reports no ERRORS.

## Boundaries

- **Always**: bump the version in `plugin.json` for any change consumers should receive — it is the
  update cache key, so pushing content without bumping it ships nothing. Use `release.sh`; two
  manual releases in a row shipped desynced manifests, which is why the ritual is a script.
- **Ask first**: changing what the plugin ships (adding an agent, a command, a hook). The kit's own
  position is that it ships a skill and references only; adding machinery needs a reason that
  survives the question "does a built-in already do this?"
- **Never**: edit `.claude/devlog/entries/` (existing entries) or `.claude/audits/` — frozen
  provenance. Never hand-edit `index.json` / `tldr.md`; they are generated. Never put a `version`
  field in the marketplace entry — `plugin.json` is authoritative and the release script fails the
  build if one appears.

## Conventions that are not obvious from the files

- **One file carries the version pin.** Only `plugins/harness/references/native-capabilities.md`
  states a Claude Code version. Every other document describes behavior without binding it to a
  release and points there. Duplicating a currency pin makes it go stale silently in one copy.
- **`references/project-docs/*` ship verbatim into other people's repositories.** They carry a
  `shipped-by:` stamp that is the re-sync key, and a content gate: durable principles and stable
  affordances only. A claim tied to a ticket number or a specific Claude Code version belongs in
  `native-capabilities.md` or nowhere. Modify one of these files and the release script requires
  its stamp to match the new version.
- **Language split is deliberate**: everything that ships to users is English; the maintainer's
  devlog under `.claude/devlog/` is Russian.
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
