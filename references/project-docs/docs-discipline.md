<!-- shipped-by: claude-code-harness v1.10.1 — do not hand-evolve in the project;
     improvements flow through the plugin (re-synced on audit). -->

# Documentation discipline — invariants (any stack)

The canonical layout: `docs/ARCHITECTURE.md` · `docs/CODE-MAP.md` · `docs/GLOSSARY.md` ·
`docs/CONVENTIONS.md` · `docs/ADR/` · `docs/RUNBOOKS/`. ARCHITECTURE + CODE-MAP exist from
bootstrap; the rest are created on first real entry, never as empty boilerplate.

1. **Doc-with-code.** A change that alters architecture / adds a top-level dir / introduces a
   domain term / sets a convention updates the matching doc **in the same commit/PR**.
   Classify each changed file (one file can hit several rows):

   | Change category | Diff signal | Document |
   |---|---|---|
   | Structural | new/removed/renamed module, top-level dir, entry point | `ARCHITECTURE.md`, `CODE-MAP.md`, root `CLAUDE.md` index |
   | Data flow / dependencies | import graph changed, new pipeline step, new external service | `ARCHITECTURE.md` |
   | New domain term | an entity name / acronym appears for the first time | `GLOSSARY.md` |
   | New convention | naming pattern, layout, protocol, style | `CONVENTIONS.md` |
   | Config / setup | new env var, config param, install step, dependency | `README.md` (+ setup doc if any) |
   | Operational procedure | new deploy / migration / recovery scenario | `RUNBOOKS/` |
   | Architectural decision | lib A vs B, protocol, deliberate non-refactor | `ADR/` (threshold — rule 3) |

   Edit **only the affected sections**, not the whole document.

2. **CLAUDE.md is an indexer, not a store.** It links to `docs/*`; it does not duplicate
   them. Target ≤200 lines — longer means something belongs in `docs/` or rules.
3. **ADR for non-trivial decisions.** Anything a future contributor would ask "why is it like
   this?" — lib choice, protocol, layout, a refactor deliberately not done → a 1-page ADR
   (Context / Decision / Consequences / Alternatives considered). Threshold: if explaining
   the decision takes >5 minutes, it needs an ADR.
4. **Glossary first-use.** First use of an acronym/domain term in any doc, commit, or comment
   → an entry in `docs/GLOSSARY.md`.
5. **Owner + last-updated.** Every doc in `docs/` carries `owner` + `last-updated: YYYY-MM-DD`
   frontmatter; editing a doc updates the date. Stale >6 months = review candidate.
6. **Escalate, don't silently "fix".** If reality has diverged from `ARCHITECTURE.md` by 3+
   modules, that is a re-bootstrap of the doc (re-read the code, rewrite the canonical docs),
   not a point-sync; contradictions between docs and CLAUDE.md get surfaced to the operator.
7. **Current-state, not changelog.** A reference doc (`ARCHITECTURE`/`PRD`/`CODE-MAP`/`GLOSSARY`/
   `README`) is a snapshot of how things *are now*. Transition narration — `was X → now Y`,
   "previously/now", "supersedes the earlier decision", "⚠ CHANGED" — belongs in the git diff
   and devlog, not the doc body. Keep the *rationale* for the current choice; route *what it
   used to be* (and that it's a reversal) to an `ADR`-supersedes line / devlog. When editing,
   also clear stale edit-residue left in adjacent sections. Exception: `ADR` history, where
   dated supersession provenance is intentional. The trigger is narrow: reversing a
   previously-documented decision and multi-session accretion leak natively; a clean
   fact-replacement does not — so this is a layer-pointer, not a ban on editing.
