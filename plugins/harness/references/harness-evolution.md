# Harness evolution — D-cycles and strip revision

The procedure for evolving the **canon** — this plugin's repository
(`nikitaCodeSave/claude-code-harness`) — by empirical signals, not by taste.
(The practice baseline §1–8 lives in the operator-global `~/.claude/CLAUDE.md` and evolves
separately; on a release its snapshot is re-distilled into `references/practice-baseline.md`.)
Two operations: the **D-cycle** (folding proven findings inward) and the **strip revision**
(carrying obsolete pieces outward). Both are subordinate to the headline principle: a component
lives only as long as it encodes something the model does not do natively.

## Refresh ledger — the baseline for the delta

The canon ages along three **external** axes: **CC version** (new primitives), **model generation**
(what the model does natively, effort defaults), and **approaches** (first-party essays, arXiv,
community). So the strip revision compares a *delta* rather than "everything from scratch", the
canon carries one provenance stamp — its last grounding point:

<!-- harness-refresh-ledger
last-grounded: CC v2.1.211 · Claude 5 family (Fable 5, Sonnet 5) + Opus 4.8 · 2026-07-16
sources-checked: code.claude.com changelog delta 2.1.210→2.1.211 (micro external-intake — changelog only) · prior full sweep (docs sub-agents/plugins-reference/commands/hooks/memory/model-config · anthropic.com engineering+news · binary strings) grounded at CC v2.1.210 / 2026-07-15, pending next strip revision
-->

The stamp is updated at the end of each strip revision (the external-intake pass below). The
current CC version to compare against is `claude --version`; the built-ins snapshot lives in
`native-capabilities.md`, and its version line after a refresh **must match** this stamp. A delta
of `claude --version` against the ledger is a standalone revision trigger (visible at the start of
a session, with no extra machinery).

## Signal sources

- The project's `.claude/harness-journal.md` — 1–3 "kit-fell-short / kit-got-in-the-way"
  observations per session (opt-in, see operator-playbook §2).
- The verdicts of external audits (`/external-audit`, fresh-context Evaluators).
- The operator's corrections along the way (the recurring ones especially).
- **External drift** (CC version / model / approaches) — compared during the strip revision, the
  external-intake pass; the baseline is the refresh-ledger above.

## D-cycle (≈1 session)

Trigger: a milestone closed, or ≥5 substantive observations accumulated. For projects **without a
journal** (it is opt-in) there is no journal trigger — there, milestone-close and external-audit
verdicts are what work; don't wait for "5 observations" that have nowhere to come from.

1. **Collect** the journal observations + audit verdicts + operator corrections for the period.
2. **Classify** each: `kit-gap` (the canon didn't cover a recurring need) ·
   `project-specific` (stays in the project CLAUDE.md/rules) · `single-incident`
   (keep watching) · `noise`.
3. **Gate**: only a `kit-gap` with multi-source evidence or repeated empirics passes into the
   canon. **A single-incident does not become an invariant** — it stays in the journal marked
   "watch".
4. **Fold** — a surgical edit of a specific reference (checklist / discipline /
   native-capabilities), not a new file and not a new layer. The wording is model-agnostic;
   evidence provenance (dates, n) is acceptable and desirable. Empirics: harness gains localize in
   tools/middleware/memory, NOT in prose (AHE ablation, arXiv 2604.25850) — prefer a fold into a
   mechanical carrier (a checklist step, a permission rule, a schema) over a new paragraph of prose.
5. **Record it**: a commit to the plugin repo + a devlog entry there listing
   "finding → where it went → evidence". A significant change to the kit's composition →
   a release via `scripts/release.sh <version>` (bump `version` in `plugin.json` — the single
   source of truth — + tag + push). (Maintainer's step: commit/devlog — in the plugin repo;
   the empirics of experiments — in the lab repo. On a consumer machine this step does not
   exist — there the canon is updated with `/plugin update`.)

D-cycle anti-pattern: "since the session is open anyway, I'll tidy up the neighboring sections
too". Edits only from the cycle's findings; everything else is a separate decision.

## Strip revision (every 3–6 months, on a major model release, or on a CC-version delta)

The cadence trigger is the calendar (3–6 months), a major model release, **or** a delta of
`claude --version` against the refresh ledger. The revision runs in two passes: first
**external-intake** (what changed outside — updates the canon to the new reality), then
**re-test** (what in the canon has become obsolete relative to the changed model/environment).

### Pass 1 — external-intake (what shifted outside)

Compare the delta *from the refresh ledger*, not "everything from scratch". Sources are CLI-native
(WebFetch / WebSearch, no Anthropic API):

1. **CC changelog** since the ledger version → new hooks / tools / flags / commands. Fold each
   relevant one into `native-capabilities.md` (it must not fall behind live `claude --version`).
2. **First-party docs / blog** (code.claude.com/docs, anthropic.com / claude.com) → shifts in
   defaults (effort, model-config), new canonical patterns.
3. **external-sources catalog** → new essays / arXiv per the T1–T7 rubric.
4. Run each finding through the D-cycle gate (`kit-gap` with multi-source · `single-incident` ·
   `noise`). An external signal **is not privileged**: "an article came out / a flag appeared"
   does not become an invariant as a single-incident; the fold is a point-edit of a specific
   reference, not a new layer.

### Pass 2 — re-test (what in the canon is obsolete)

1. List the canon's components with their assumption "the model can't do X"
   (including every "under Opus <version>" in the texts).
2. Re-test each: does the model do X natively now. The quick tool is
   `claude --safe-mode` (start with no CLAUDE.md/skills/hooks/MCP): if it's no worse without the
   component — it's obsolete.
3. Obsolete pieces are **deleted, not archived into the canon** (history stays in git + devlog).
4. Whatever the last D-cycle added and that didn't work is the first candidate for removal.

At the end of the revision — **update the refresh ledger** (new CC version / model / date /
checked sources), sync the version line of `native-capabilities.md`, and record a devlog entry. A
significant shift in the canon's composition → bump `version` (see D-cycle step 5).

## The procedure's evidence base

Grown on the dogfood track (the maintainer's lab Harnesses-Claude, devlog #78–#82 — artifacts not
shipped with the kit): 2 D-cycles, 12 findings folded into the kit, each with journal or audit
empirics; the first-party grounding is Anthropic's "review your configuration every 3-6 months"
and "find the simplest solution possible" (see `references/evidence-base.md`).

<!-- last-updated: 2026-07-16 -->
