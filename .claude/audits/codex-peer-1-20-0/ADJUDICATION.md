# v1.20.0 — cross-vendor refuter: two refute passes, adjudicated

Two fresh-context `code-refuter` passes ran on the working diff before release, both prompted to
refute. Both returned `refuted`. This file is the maintainer's adjudication of their findings —
what was accepted, what was rejected, and how each accepted one was reproduced. The refuters'
own JSON was not preserved (deleted during cleanup); the record below is authored, not quoted.

## Pass 1 — on the initial diff

| # | Finding | Verdict | Action |
|---|---|---|---|
| 1 (CRITICAL) | The cross-vendor clause sat in `project-docs/workflow.md`, which bootstrap Phase 2c copies **verbatim and unconditionally** into every consumer repo — defeating the gate the same diff introduced | **accepted** | clause removed entirely; file reverted to HEAD including its `shipped-by` stamp |
| 2 | A suppression instruction (`Omit this sentence entirely otherwise`) sat *inside* the blockquote the model prints to the operator | **accepted** | footer addition removed |
| 3 | The gate was defined in three places and the definitions already disagreed (Audit dropped one condition) | **accepted** | reduced to one condition, stated in full in `bootstrap-checklist.md` Phase 2b; others reference it |
| 4 | "It is the default executor of the Tier-1 refute" is a standing rule off n=1 and contradicted the same paragraph's disclaimer | **accepted** | split into two questions: acquiring a vendor (no) vs frequency for one already wired (maintainer's practice, labelled as such) |
| 5 | The block ships another vendor's perishable call shape behind an inline expiry badge, which `SKILL.md` itself rejects as inert | **partially accepted** | carve-out stated with its reason (this file reaches only operators who own the tool and can falsify a stale line in one command), badge replaced with an event trigger, real re-verification trigger added to `SKILL.md` Maintenance |
| 6 | Provenance dating overstated duration ("sustained use since"); missing "lab artifacts don't ship" caveat | **accepted** | dated 2026-08-01, reworded to "days old, not a track record", caveat added |
| 7 (minor) | Circularity: bootstrap said to run detection *in* the file `SKILL.md` forbids reading before a positive | **accepted** | gate condition written out in bootstrap; the reference loads only on a positive |
| 8 (minor) | `SKILL.md` description + README route the in-scope claim through the always-loaded channel | **rejected** | it is a scope disclaimer, not a recommendation; removing it re-opens the contradiction this release exists to fix |

## Pass 2 — verify-after-fix on the corrected diff

| # | Finding | Verdict | Action |
|---|---|---|---|
| 1 (CRITICAL) | The content-version stamp sat as an HTML comment **above** the YAML frontmatter, copied from the `practice-baseline.md` convention whose target file has no frontmatter. Frontmatter is only recognised at byte 0, so the comment becomes the skill's description — the skill loads, counts, and never triggers | **accepted, reproduced** | see below; stamp moved below the frontmatter, reason recorded in the block and in delivery step 3 |
| 2 | The "make it the executor of the Tier-1 refute" phrasing survived in `codex-peer-skill.md`'s Provenance — the fix had landed in 2 of 3 sites, and the surviving one is the file the positive gate actually opens | **accepted** | rewritten to match: evidence grounds the discipline; frequency is stated as preference |
| 3 (minor) | The gate's config-path fallback pointed at a directory that holds no `mcpServers` | **accepted** | dropped; `claude mcp list` is the single authoritative probe |
| 4 (minor) | The audit bullet contradicted itself for "copy on disk + server unregistered" | **accepted** | an existing copy is itself the opt-in; re-sync applies regardless of current registration |
| 5 (minor) | "finish the run without ever learning the option exists" is undeliverable — the always-printed footer points at the playbook, which a human may read | **accepted** | reworded: the gate governs what a session *says*, not what a human finds by reading |

## Reproduction of pass 2's critical finding

Own oracle, live session, 2026-08-01:

1. A project skill whose `SKILL.md` began with an HTML comment above the frontmatter appeared in
   the available-skills listing with its **description replaced by that comment line**.
2. Injecting the same comment above the frontmatter of `plugins/harness/SKILL.md` broke this
   kit's own description the same way; removing it restored the description immediately.

Conclusion: the failure is the leading comment, not the comment itself. The corrected block has
`---` at byte 0, structurally identical to the skills that load correctly in this session.

## Scope note

`plugins/harness/references/project-docs/*` and `references/practice-baseline.md` are untouched by
this release; their stamps do not move.
