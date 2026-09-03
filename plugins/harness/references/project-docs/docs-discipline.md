<!-- shipped-by: claude-code-harness v1.27.0 — do not hand-evolve in the project;
     improvements flow through the plugin (re-synced on audit). -->

# Documentation discipline — invariants (any stack)

The canonical layout: `docs/ARCHITECTURE.md` · `docs/GLOSSARY.md` · `docs/CONVENTIONS.md` ·
`docs/ADR/` · `docs/RUNBOOKS/`, plus `.claude/rules/` for prohibitions. ARCHITECTURE exists from
bootstrap; the rest are created on first real entry, never as empty boilerplate.

`ARCHITECTURE.md` is a **decision record, not a description of the system.** It carries ratified
decisions with their dates, measured reasons with their numbers, deliberate retentions of code that
has no caller, explicit non-claims. A module map, a data-flow overview, an import graph and a
service inventory belong to the code: a capable model reads them off the repository when it needs
them, and where a boundary test exists that test — not a paragraph — is what *pins* them. An
ARCHITECTURE.md that opens with a directory listing is the file rule 0 deletes.

**Division of labour with `ADR/` (rule 3), so the two don't become the same file twice**: an ADR is
*one* decision argued in full — context, alternatives, consequences — created above rule 3's
threshold. `ARCHITECTURE.md` is the system-level record of what currently holds: the decision in
one line with its date and its measured number, the retentions, the non-claims, and a pointer to
the ADR wherever one exists. Argument there, standing state here.

**There is no `CODE-MAP.md`.** One line per module (path → responsibility) restates the module
itself, and a hand-maintained copy costs a write on every structural change to buy nothing. Where a
repository's layout is genuinely unreadable from its tree, a short index is allowed — as an index,
never maintained against the diff, and deleted once a boundary test exists.

Two costs, measured separately, pointing the same way. **Maintenance**: keeping derivable prose
true costs a write on every change, forever — the field measurement in rule 0. **Runtime**: two
2026 studies measured LLM-authored *instruction* files that restate what the model derives from the
repository making agents worse — −2% success at +23% cost in one; reduced success in 5 of 8
settings and +2.45–3.92 steps per task in the other. The studies are about the always-on layer, not
about a document read on demand: they are why a derivable claim must never reach `CLAUDE.md` or
`.claude/rules/`, while the maintenance cost is why it should not be written down at all.

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
   field's meaning requires a new schema version". A test pins the call sites that exist; the
   prohibition binds the ones not yet written, which is the part no test reaches — so where a
   single instance *is* assertable, write that test **as well**, and keep the rule for the code to
   come. What makes these lines fragile is that they read like description, so a reduction deletes
   them along with the description. Deleting the file loses them silently. Walk the document line by line asking "where else is
   this said", and put a deletion of this class through an independent fresh-context review —
   measured on the reduction that produced this rule, a cross-vendor reviewer recovered four such
   claims from four already-read documents.

   **Those lines live in `.claude/rules/`, not in a document.** A prohibition has to be in the
   context *before* the agent acts, which a document nobody opened cannot do; rules load with the
   session. Keep each rule file short (≤30 lines) and prescriptive — the always-on layer is
   precisely where descriptive prose becomes a per-turn tax, so nothing that a test could assert
   goes there either. This does not duplicate CLAUDE.md's `Never` tier: that tier carries
   repository operations, mirrored into `settings.json` permissions, while `.claude/rules/` carries
   the *domain* prohibitions no permission rule can express ("an observation code is never derived
   from prose", "filling a counter must not trigger a producer call").

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
   | Structural | new/removed/renamed module, top-level dir, entry point | the boundary test — it *is* the map. No such test yet and the boundary matters? Writing it is the update; prose only for what a test cannot express |
   | Data flow / dependencies | import graph changed, new pipeline step, new external service | same test; `ARCHITECTURE.md` only when the decision needs a "why" |
   | New domain term | an entity name / acronym appears for the first time | `GLOSSARY.md` |
   | New convention | naming pattern, layout, protocol, style | `CONVENTIONS.md` |
   | Config / setup | new env var, config param, install step, dependency | `README.md` (+ setup doc if any) |
   | Operational procedure | new deploy / migration / recovery scenario | `RUNBOOKS/` |
   | Architectural decision | lib A vs B, protocol, deliberate non-refactor | `ADR/` (threshold — rule 3) |
   | Prohibited action | a "must never" no type or test can express | `.claude/rules/` (≤30 lines, always-on) |

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
6. **Escalate, don't silently "fix".** When the system has moved far enough that
   `ARCHITECTURE.md`'s ratified decisions no longer hold — one was reversed in practice, a
   non-claim became false, a measured reason no longer matches the measurement — that is a re-read
   and a rewrite of the record, not a point-sync; contradictions between docs and CLAUDE.md get
   surfaced to the operator.
7. **Current-state, not changelog.** A reference doc (`ARCHITECTURE`/`PRD`/`GLOSSARY`/
   `README`) is a snapshot of how things *are now*. Transition narration — `was X → now Y`,
   "previously/now", "supersedes the earlier decision", "⚠ CHANGED" — belongs in the git diff
   and devlog, not the doc body. Keep the *rationale* for the current choice; route *what it
   used to be* (and that it's a reversal) to an `ADR`-supersedes line / devlog. When editing,
   also clear stale edit-residue left in adjacent sections. Exception: `ADR` history, where
   dated supersession provenance is intentional. The trigger is narrow: reversing a
   previously-documented decision and multi-session accretion leak natively; a clean
   fact-replacement does not — so this is a layer-pointer, not a ban on editing.
