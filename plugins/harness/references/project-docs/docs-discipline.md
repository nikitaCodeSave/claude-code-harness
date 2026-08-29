<!-- shipped-by: claude-code-harness v1.26.0 — do not hand-evolve in the project;
     improvements flow through the plugin (re-synced on audit). -->

# Documentation discipline — invariants (any stack)

The canonical layout: `docs/ARCHITECTURE.md` · `docs/CODE-MAP.md` · `docs/GLOSSARY.md` ·
`docs/CONVENTIONS.md` · `docs/ADR/` · `docs/RUNBOOKS/`. ARCHITECTURE + CODE-MAP exist from
bootstrap; the rest are created on first real entry, never as empty boilerplate.

`CODE-MAP.md` is a **navigation aid for a repository whose structure is not obvious**, not a
contract. The moment a boundary test exists, that test is the canonical import graph and the map
stops being maintained against the diff: keep it as a short index, or delete it. A CODE-MAP kept
in sync by hand costs a write on every structural change and buys what `ls` and the test already
give.

0. **Oracle before prose — document only what the code cannot state.** Before writing or
   updating a document, ask whether the claim can be pinned by an **executable oracle**: a test,
   a type, a schema, a linter. If it can, that oracle *is* the documentation and no prose is
   written. A document carries what has no place in code: a ratified decision with its date and
   owner, a **measured** reason for a choice (with the number), a deliberate retention of code
   that has no caller, an explicit non-claim. Prose that restates a schema, a module table, a
   guard list or an import graph is **deleted, not refreshed** — it has no oracle, so it diverges
   silently, and a partially-true document is more dangerous than a missing one.

   Order of pinning an invariant: test → type/schema → checked rule → prose. Prose is the last
   resort, never the first.

   **The test applies to a single claim, not to a file.** A duplicate document almost always
   holds a few lines that exist nowhere else — typically a prohibition on an *action*: "a code is
   never derived from text", "filling a counter must not cause a producer call", "changing a
   field's meaning requires a new schema version". Types and tests express permitted *values*;
   they cannot express a forbidden action, so those lines are unprovable from code by nature.
   Deleting the file loses them silently. Walk the document line by line asking "where else is
   this said", and put a deletion of this class through an independent fresh-context review —
   measured on the reduction that produced this rule, a cross-vendor reviewer recovered four such
   claims from four already-read documents.

   Repository-visible symptom of violating this: the share of commits touching only `.md` stays
   above the share touching code. That is not discipline, it is a tax — the documentation grows
   faster than the system it describes. (Field evidence, 2026-08-29: a production Text-to-SQL
   repo at 55% `.md`-only commits, 63k lines of prose against 100k of code and 35k of tests —
   with *no* live document actually stale. The cost was paid in continuous repair, not in drift.)

1. **Doc-with-code** (inside rule 0). A change that alters architecture / adds a top-level dir /
   introduces a domain term / sets a convention updates the matching **oracle** in the same
   commit/PR, and a document only where the claim has no oracle. Classify each changed file
   (one file can hit several rows):

   | Change category | Diff signal | Where (oracle before prose) |
   |---|---|---|
   | Structural | new/removed/renamed module, top-level dir, entry point | the boundary test — it *is* the map; prose only for what the test cannot express |
   | Data flow / dependencies | import graph changed, new pipeline step, new external service | same boundary test; `ARCHITECTURE.md` only when the decision needs a "why" |
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
