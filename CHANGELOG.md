# Changelog

All notable changes to the **claude-code-harness** plugin are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Versions up to and including 1.12.2 were released from the maintainer's `dot-claude`
practice layer, before the kit was extracted into this standalone repository.

## [1.21.1] — 2026-08-04

**1.21.0 shipped a contract and doubled the length of the checklist item that carries it.** Four
live runs — a bootstrap on Node, an audit of a mature Python project, and two purpose-built probes
(a Python project with a deliberately airtight spec, a 40-line Go CLI with no ledger and two planted
defects) — showed the contract works and let the prose be cut against evidence instead of taste.
The ledger item is back from 94 lines to 72; `bootstrap-checklist.md` net −21 lines, and the kit's
own retire-bias applied to text written a day earlier.

### Fixed

- **The intake audit stopped at the ledger entry and scored clean on projects that are in fact
  waiting on their owner.** Measured on a real project: the blocking question sat three hops out,
  in the plan that the entry's `preconditions` pointed to. The check now follows the pointers, and
  says so — an audit that greps only `verify`/`description` is the false-negative it was meant to
  prevent.
- **`priority` had one failure mode and the check saw only the other.** It caught "the ritual
  promises an order the ledger can't express" and walked past its mirror — the field present but
  read by nothing, or set on some entries and not others. Half-migrated is the worst state, because
  "missing sorts last" buries exactly the entries that predate the migration; the canonical shape
  now says set it on all entries in one pass or none, and the audit reads both directions.
- `Q7-A`-style options, the tracker branch and the write-through note lost the sentences that
  restated them. What survives is what the runs exercised: cost picks the form (diverging readings
  get coded options, converging ones you settle yourself and say why), silence is not consent in a
  headless run, a decision is not automatically work, and an open question blocks the implementation
  feature but never a *bounded* spike.
- **The queue's "next condition" rule is gone entirely** — `blocked_reason` already carries "what
  unblocks it, and who" one paragraph above. It was a second name for an existing field, which is
  the duplication this kit treats as a defect.

### Changed

- Reading a tracker is now a testable step (`gh issue view`; MCP for Jira/Linear), not advice: an
  ID nobody can open reads as resolved when it is merely unreachable.
- The Bootstrap output template names the ledger's intake rule and `priority`, so an operator sees
  them in the plan rather than discovering them in the file.

## [1.21.0] — 2026-08-04

**The kit governed work already chosen and said nothing about how a proposal becomes work.** Every
Phase 5 rule — one feature at a time, verify contracts, `passes` — starts after the commitment
exists; the moment before it, where a question only the owner can answer either stalls the build or
gets decided silently by whoever is implementing, had no contract at all. A production project that
runs the kit had grown that layer itself and paid for it: a tracking audit found competing registers,
a plan whose blocker was misattributed, and uncommitted operator work sitting in the tree that no
plan owned. This release folds the transferable part in — as edits to the existing references, not a
new governance document, and not the project's whole planning machine.

### Added

- **An intake contract on the ledger** (Phase 5 item 2): an open, acceptance-affecting question
  means the feature is not ready to work — recorded as *question → dated answer → what the answer
  rests on*, with coded options only where two readings differ in cost. The agent never ratifies on
  the owner's behalf, a ratified decision is not automatically work (`wontfix` and "this only
  ratifies current behavior" create no entry), and an open question blocks the implementation
  feature but not a *bounded* spike that would answer it — otherwise the discovery is forbidden by
  the question it exists to close. Where a tracker is the canon, the question lives there and the
  ledger carries the ID. It carries its own retire trigger, and it is written through to
  `features.json`'s `rules` — the working session reads the ledger, never this checklist.
- **`priority` in the canonical ledger shape.** The session ritual has said "highest-priority
  incomplete feature" in three places while the schema had no such field, so the order was array
  position wearing another name. Lower runs first, ties break by array order, a missing value sorts
  last — and greenfield's `F0` now seeds at `priority: 0`, because the entry the ritual is
  guaranteed to land on first cannot be the one that sorts last.
- **Audit §11 — Ledger & intake**, two falsifiable checks, skipped entirely where no ledger exists.
  This is the reachability half: Bootstrap's edits never reach a project that was set up last year.
- **A Phase 7 write-through check for ledger projects** — the ordering field and the intake rule
  have to be *in* `features.json`, on the same logic as the CLAUDE.md greps beside it.

### Changed

- **Shipped-docs absence is audited as coverage per file, not as a missing file.** A mature project
  may carry `workflow.md`'s duty areas in its own `AGENTS.md` and process docs; shipping the copy
  there adds a competing instruction for no coverage gain. A shipped line that *contradicts* the
  project's canon is always a finding — and the operator adjudicates it: the local text is not
  automatically right (a project rule waiving a kit invariant is a finding against the project).
  Grounded in a real case: `workflow.md`'s "session start = git log + progress" inside a project
  whose CLAUDE.md forbids reconstructing status from Git.
- **A gate that could not run must never read as pass** (`harness-discipline.md`). When the tool a
  guard shells out to fails, returning "nothing found" turns it green on exactly the runs where it
  saw nothing — a real tracking checker returns an empty change list whenever its `git status` exits
  non-zero, so its unregistered-work check passes by construction. Error state, non-zero exit,
  distinct from a policy violation; and a green gate proves only what it parses.
- **The native session task list is not the repository's register of commitments**
  (`native-capabilities.md`) — it coordinates the run and is machine-local; obligations that outlive
  the run belong in the ledger. Using the ledger for in-run steps is ceremony; using the task list
  as the backlog puts the backlog outside the repo the work ships from.
- **The operator playbook names what only the operator can decide** — ratification, its two
  no-work answers, and the fact that silence is not agreement — and scopes the "no upfront
  questionnaire" line to exclude questions that change what "correct" means.
- **`evidence-base.md`** catalogues GitHub Spec Kit (T4) as independent corroboration that the
  pre-implementation ambiguity gate is a real gap — explicitly *not* a source for the kit's wording.

### Not touched (deliberate)

No new reference file (`harness-evolution.md` requires a fold into an existing one), no plan
lifecycle beside `passes`/`blocked` (a second state machine over the same objects), no per-owner
WIP limit (needs an `owner` field first), no "closed entries leave the ledger" rule (single-source,
and it contradicts flipping `passes: true`), and **no stream object** — the double trigger drafted
for it was circular, and the only evidence available is one project that built a workstream file
and then deleted it.

## [1.20.1] — 2026-08-03

**The devlog `preview` is prose, and now the generator treats it as prose.** It carried raw inline
markdown out of `entries/` into `tldr.md` and `index.json` one level up — where an entry-relative
href stops resolving, and where the href spends a character budget that belongs to meaning. Found
by an operator integrating the kit into another project, reported upstream rather than patched
locally; the report named the broken links, and auditing the generator turned up a second, worse
defect of the same family that was silently rewriting text.

### Fixed

- **Inline links in `preview` are unwrapped to their text.** `[#24](0024-….md)` resolves inside
  `entries/` and nowhere else, so the digest a cold-entering agent reads carried links that go
  nowhere — 3 of them in this repo's own `tldr.md`, present since 2026-07-26. Flattening also
  returns the 280-character budget to the summary: the affected entry went from three paths and
  one clause to three full sentences of meaning, same cap.
- **Code spans are no longer parsed as markdown — this one was corrupting text, not just links.**
  The bold rule paired the `**` of one code span with the `**` of the next and ate everything
  between: entry #12, written *about* `Glob(./**)` and `Grep(./**)` being no-op permission rules,
  displayed them as `Glob(./)` and `Grep(./)` — the misreading it exists to prevent. The paragraph
  is now split on code spans, whose contents are passed through verbatim.
- **`≤280 chars` is now true.** The ellipsis was appended *after* the cut, so a truncated preview
  was 281 — a small lie in a field whose whole contract is a length.
- **Link unwrapping handles the markdown that entries actually write**: parentheses inside a
  destination (wiki-style URLs), a quoted title, one level of nested brackets in a label, an image
  used as a link's label, and `\[` left literal. A destination must be whitespace-free or
  angle-bracketed, so the prose `[0](не ссылка)` is not mistaken for a link. Reference-style links
  and autolinks are deliberately untouched — a definition never travels with the preview, and
  `[1][2]` in prose is the commoner reading. Every pattern stayed linear under measurement where
  the naive one was quadratic — 192 KB of adversarial input costs under 10 ms.

Entries themselves are untouched (they stay immutable and their links stay correct in place), as
are the digest hook, the index/tldr layout, and every consumer-facing surface of the harness kit.

## [1.20.0] — 2026-08-01

**A cross-vendor refuter joins the verification ladder — as a skill the kit hands over on
consent, behind a mechanical gate, and never as a reason to buy a second subscription.** A
same-family refuter is fresh but not foreign: trained as the author was, it inherits a share of
the author's blind spots. A reviewer from another vendor does not. The rung that ships stays the
native `code-refuter`; this is an upgrade for operators who already run a second-vendor CLI.

### Added

- **`references/codex-peer-skill.md`** — the canonical `codex-peer` skill text plus its delivery
  procedure. Not a live plugin skill on purpose: a plugin skill's description loads into every
  consumer's session, so shipping it live would tax the majority who have no Codex and read as
  "install another CLI". It reaches disk only through the same consent channel as
  `practice-baseline.md` — global profile (recommended, matching the server's user scope) or
  project embed, both on explicit approval, with a content-version stamp Audit re-syncs.
- **One mechanical gate, stated in full in `bootstrap-checklist.md` Phase 2b**: a Codex MCP server
  is already registered (`claude mcp list`). `codex` merely on PATH does not open it — an unwired
  CLI means the operator has not chosen this, and offering to wire it is the recommendation the
  gate exists to prevent. On a negative the option is not raised at all, and the reference is not
  even loaded.
- **`evidence-base.md`** — the provenance, bounded honestly: one controlled episode (n=1, one
  component, one vendor: 5 real holes in a defensive Bash guard that 109 tests, three fix commits
  and every same-family pass had missed; 16 raw findings triaged to those 5) plus the maintainer's
  current daily practice, which is preference, not measurement, and days old rather than a track
  record. It grounds the *discipline*, never "always call a second vendor".

### Changed

- **The scope disclaimer no longer contradicts the kit** (`SKILL.md` description + "Do NOT use
  when", `README.md`): "does not cover provider-neutral patterns for OpenAI/Codex" became "does
  not teach harness design *inside other frameworks*" — an external CLI wired into *this* harness
  via MCP is in scope, and always was.
- **`SKILL.md` Maintenance** gains a real re-verification trigger for the one shipped block whose
  facts the kit cannot check from its own repo: re-read the live `tools/list` when a call is
  rejected on an argument or the vendor's CLI is upgraded. A badge without a runner rots silently —
  the kit's own finding, now honoured rather than repeated.

### Not touched (deliberately)

- **`references/project-docs/*`** — the files bootstrap copies verbatim and unconditionally into
  every repository. A vendor-neutral clause was drafted for `workflow.md` and **removed after a
  fresh-context refuter showed what it actually does**: a consumer with no second vendor would
  have found, permanently in their own git history and re-synced at every audit, the statement
  that the rung they have is not the strongest form. Their `shipped-by` stamps stay put.
- **`references/practice-baseline.md`** — §8 stays vendor-neutral; ~80 lines that load every turn
  in every project are the wrong home for an optional upgrade. Its content-version stamp does not
  move.
- No new agent, command, or mode. The `code-refuter` role is unchanged — what changes is who may
  execute it.

## [1.19.9] — 2026-07-26

**Verify-after-fix on v1.19.8: the three fixes hold, three minor issues came in with them.**
The refuter re-verified each fix against its own findings rather than accepting the claim — it
confirmed the newly load-bearing half of the `is_error` rewrite from the Agent `tool_result`
records, tested the prescribed `printenv` check against all three pin shapes (settings `env`
block, `--settings` layer, shell export) and found it reveals the pin in every one, and measured
the drift detector dropping 20 → 16. Verdict `stands`, no regression of the class the diff
existed to remove.

### Fixed

- **The pre-audit env check now lives in `/external-audit` itself**, as Step 0, not two documents
  away in `harness-discipline.md`. Advice placed where the reader will not be standing is advice
  that does not run — the failure it prevents was still fully reachable.
- **"A guarantee against every layer except that one" corrected.** It contradicted the file's own
  precedence ladder, which puts an org ceiling above the env var. Now: holds against every
  *user-side* layer except env, with the org ceiling named and marked unmeasured.
- **`24 of 30` → `30 of 30`.** The `is_error` count was carried over from the auditor's sample
  rather than re-derived from the full corpus. All 30 failing runs carry the flag, so the
  direction was conservative — but a number in this file should come from the corpus it cites.

## [1.19.8] — 2026-07-26

**A full three-role audit at the end of the day, with a refuter that had never seen this work,
found three major defects that three earlier passes had walked past.** The runtime conclusions
still hold; what failed was a load-bearing property claim, the stated purpose of a fix shipped
hours earlier, and the file's own claim to be the single version-pinned document.

### Fixed

- **"It is silent — no `is_error` flag" was false.** All 24 failing runs in this file's own
  evidence carry `is_error: true` and a body prefixed `API Error: 400 …` on the `WebSearch`
  `tool_result`. The property is rewritten to where the silence actually lives: the `tool_result`
  *is* flagged and a scan of those records finds it; what is absent is an assistant-level
  API-error record, and — decisively — a parent sees only a delegate's final text, never its
  `tool_result`s. This bullet is load-bearing for both the "why it is a harness problem" argument
  and the detection method, so it was wrong in the place it could do most damage.
- **`effort: xhigh` on the three audit roles does not survive an env pin.** New measurement: a
  frontmatter delegate declared `effort: xhigh`, spawned under `CLAUDE_CODE_EFFORT_LEVEL=low`,
  reports `low`, 2/2. So `CLAUDE_CODE_EFFORT_LEVEL` overrides agent frontmatter **in both
  directions**, not only upward as previously measured — and v1.19.4's rationale ("depth becomes
  a property of the audit rather than of the caller") holds for every layer except that one. The
  rule is corrected and a pre-audit check added: confirm `printenv CLAUDE_CODE_EFFORT_LEVEL` is
  empty before a pass whose whole value is depth.
- **Three live docs carried their own currency pins**, contradicting `native-capabilities.md`'s
  claim to be the only version-pinned document — `harness-discipline.md` was stamped v2.1.210 /
  Opus 4.8 while carrying the Opus-5 spawn rule measured on 2.1.220. `harness-discipline.md`,
  `audit-checklist.md` and `evidence-base.md` are de-versioned to the form the checklist itself
  prescribes, pointing at the single pin. The kit's own drift detector had been signalling this
  the whole time; its count had risen from 18 to 20.

Not touched: every runtime conclusion from v1.19.2–v1.19.7 — the audit re-derived all 16 session
runs and all 7 frontmatter delegate rows from the raw logs and they reproduce exactly.

Known and not fixed here, recorded for the next pass: `release.sh` accepts any string as a
version and its `shipped-by` stamp guard is bypassed by a multi-commit release; `rebuild-index.py`
writes a fresh `generated_at` on every run, so reindexing always dirties the tree.

## [1.19.7] — 2026-07-26

**The verification loop terminated clean, and this closes the one note it left.** A third,
deliberately narrow refuter pass over v1.19.6 confirmed all three regressions closed, re-derived
the updated counts from the raw logs, and found nothing new of substance — `clean, loop can
terminate`. It did leave one consistency note, fixed here.

### Fixed

- **The env row of the session matrix is now marked confounded, like the flag row.** Settings
  pinned `xhigh` while the probe set `CLAUDE_CODE_EFFORT_LEVEL=xhigh`, so the row shows only that
  the effective tier was `xhigh`, not that the environment set it. Row 4 already carried that
  marker for the identical situation; row 6 did not. Added, together with a pointer to where the
  env *mechanism* is genuinely demonstrated — the delegate rows, where frontmatter `effort: high`
  fails under an env pin and succeeds without one, which only the env layer explains.
- **The `git check-ignore` caveat gains its missing half.** v1.19.6 recorded that the command
  exits 0 on a negation match; it also consults the index unless given `--no-index`, so a *1* can
  mean "already tracked" rather than "not ignored". Both halves matter when it is used as an
  oracle — the refuter caught this one in its own earlier reasoning and recorded it against
  itself.

Not touched: every conclusion in the file — the third pass confirmed the counts and found no new
substantive issue.

## [1.19.6] — 2026-07-26

**The refuter was asked whether its findings were closed, and found three problems the fixes
themselves introduced.** 13 closed, 1 partially closed, 0 still open — plus three regressions,
one of them the same scope-mismatch class v1.19.5 existed to remove.

### Fixed

- **The session matrix's env row is a session-level measurement again.** While being corrected it
  lost its honest "earlier run" tag and gained a `2/2` taken from *delegate* runs — a cell about
  the session backed by a sub-agent. Re-run at session level with the same prompt and oracle:
  fails 2/2, `CLAUDE_EFFORT` reads `xhigh`, the 400 quotes `'xhigh'`, `WebSearch` was called.
  Counts updated accordingly (14 re-measured runs, `'xhigh'` ×24).
- **Run count in the 1.19.5 intro corrected** from 16 to 18.
- **`.gitignore` audit rule narrowed to verdicts.** v1.19.5's `!/.claude/audits/` re-admitted the
  whole directory, weakening the whitelist guarantee the rest of the block relies on; now only
  `AUDIT-*.json` under an audit directory is trackable. Verified by both arms — a verdict file
  shows in `git status`, a stray file in the same directory does not. Note that
  `git check-ignore -v` returns 0 on a *negation* match, so its exit code cannot answer "is this
  ignored"; `git status` was the oracle.

Not touched: the 13 closed findings; every conclusion from v1.19.2–v1.19.5; the three
pre-existing audit directories, which remain untracked pending an explicit decision to publish.

## [1.19.5] — 2026-07-26

**First run of the new refuter step, and it caught the file shipping right conclusions on
insufficient evidence.** A fresh-context adversarial pass over v1.19.2–v1.19.4 re-derived every
published number from the raw run logs (all reproduced) and an independent executor re-ran the
stack from scratch on its own harness (all four headline claims confirmed). What did not survive
was the bookkeeping: two claims refuted as stated, ten needing correction, zero wrong runtime
conclusions. The gaps were then measured rather than hedged — 18 further runs.

### Fixed

- **The delegate matrix is now measured on the path it prescribes.** All seven rows re-run
  through YAML frontmatter in `.claude/agents/*.md`; previously five were measured through
  `--agents` (programmatic definitions) while the column was headed "agent frontmatter". Both
  paths give identical outcomes, and a plugin-shipped agent honours `effort:` too (2/2) — the
  load path v1.19.4 actually changed.
- **"A delegate inherits the session's level" now has the discriminating control.** As published
  it held the session at `xhigh` in every row, so it could not tell inheritance from a fixed
  default. Varying the session settles it: the same undeclared delegate fails 2/2 from `xhigh`
  and searches 2/2 from `high`.
- **`CLAUDE_EFFORT` inside a delegate reports the *delegate's* level, not the parent's.** An
  agent pinned `effort: high` inside an `xhigh` session read back `high` and searched, 2/2. The
  previous claim rested on token spend.
- **The built-in-delegate escape is measured, not inferred.** `general-purpose` spawned plainly
  from an `xhigh` session failed 2/2; with `model: sonnet` on the Agent call it searched 2/2.
- **Sonnet 5 / Fable 5 narrowed to what was run** — `xhigh` and `max`, not "every effort level".
- **The `--effort xhigh` session row is marked confounded** (settings said `xhigh` too).
  Mechanism independence is carried by the two unconfounded flag rows, `--effort high` overriding
  settings downward and `--effort max` overriding it upward — now said explicitly.
- **`ultracode` = `xhigh` now cites its oracle** (first-party strings in the 2.1.220 binary),
  and **`WebFetch` regains its attribution** to the upstream thread rather than borrowing the
  credibility of a matrix it was never part of.
- **`.gitignore`: `.claude/audits/` un-ignored.** The refuter step added in the release ritual
  told the operator to file evidence into a directory git silently discarded — the artifact would
  have vanished at the next clone.

### Changed

- **Method warning gains a fourth rule and a third cautionary round:** vary the variable the
  conclusion names. Recorded plainly that what caught this round was a fresh-context refuter and
  not a further self-review — the author had already re-read the same diff and passed it.

Not touched: every runtime conclusion from v1.19.2–v1.19.4 — the audit confirmed all of them;
`defaultMode`; grounding stamps; `references/project-docs/*.md`.

## [1.19.4] — 2026-07-26

**An audit whose depth depends on whoever launched it is not a reliable verifier.** The three
external-audit roles declared no `effort:`, and v1.19.3 established that a delegate declaring
none inherits the session's level — so `/external-audit` launched from a shallow session
produced a shallow audit, silently, while reporting the same verdict shape.

### Changed

- **`evidence-executor`, `process-auditor` and `code-refuter` now declare `effort: xhigh`.**
  These are verification roles where the expensive failure is a false negative, and declaring the
  level makes depth a property of the audit rather than of the caller's settings. Safe at this
  tier because none of the three carries `WebSearch` in its `tools:` — the Opus 5 search ceiling
  does not reach them.

### Fixed

- **The v1.19.3 spawn rule is now verified on the path it prescribes.** That rule was measured
  through `--agents` (programmatic definitions) but written up as YAML frontmatter — a different
  load path. Re-run against `.claude/agents/*.md` from a session at `xhigh`: `effort: high`
  searched 2/2 with no `400`, an agent declaring nothing failed 2/2. The prescription stands as
  written; the gap was in the evidence, not in the rule.

## [1.19.3] — 2026-07-26

**The `WebSearch` ceiling turns out to be Opus 5's, and a delegate can step out of it — which
converts "a capability you lose above `high`" into a spawn rule the orchestrator can act on.**
v1.19.2 established that the tier is the trigger; two further matrices establish whom it binds
and how a subagent escapes it.

### Added

- **Spawn rule for research delegates** (`harness-discipline.md`, Subagents §) — what an agent
  must declare in order to reach the web: `WebSearch` in `tools:` (a narrowed allowlist drops it
  outright, and the delegate reports having no such tool rather than erroring), plus either
  `effort: high` or `model: claude-sonnet-5` / `claude-fable-5`. Includes the minimal frontmatter
  and the built-in-delegate case, where the Agent tool's per-call `model` override is the escape.

### Fixed

- **The ceiling is Opus 5's, not Claude Code's.** As session models at `xhigh` and `max`,
  `claude-sonnet-5` and `claude-fable-5` searched cleanly — 0/8 failures with real results —
  where `claude-opus-5` and `claude-opus-5[1m]` failed. v1.19.2's "the session that searches runs
  at `high` or below" holds only on Opus 5.
- **The per-delegate `effort:` dial does save you** — corrects v1.19.2 and earlier. 16-run
  delegate matrix from an Opus 5 session at `xhigh`: `effort: high` searched 3/3 and
  `model: claude-sonnet-5` 3/3, while a delegate declaring nothing failed 2/2. The server-tool
  sub-request carries the *delegate's* effective level, not the session's. Sole exception: an
  env-pinned level outranks agent frontmatter, so under `CLAUDE_CODE_EFFORT_LEVEL` only the model
  pin survives — measured both ways, 2/2 each.
- **A delegate that declares no `effort:` inherits the session's level.** Replaces "an ad-hoc
  delegate stays at the model default", which rested on token spend that never separated
  (937/1550 vs 1043/746) — the oracle this same file marks as weak.

Not touched: the tier finding from v1.19.2 (these matrices refine it, not overturn it), the
`defaultMode` findings, the grounding stamps and drift detector, and
`references/project-docs/*.md`.

## [1.19.2] — 2026-07-26

**The same matrix re-run with an oracle that does not depend on the claim — and the green rows
came back red.** v1.19.1 corrected v1.19.0 by moving the blame for the `WebSearch` failure onto
the env layer and clearing `effortLevel`, `--effort` and `ultracode`. A live call from a session
pinned by `effortLevel: xhigh`, with `CLAUDE_CODE_EFFORT_LEVEL` set nowhere, failed with the same
400. Re-measurement puts the trigger back on the tier, where v1.19.0 had it.

### Fixed

- **`WebSearch` × effort — attribution corrected back to the tier.** 14 headless runs on CC
  2.1.220: `high` searched (0/2 failures, 7 results); `xhigh` and `max` failed 12/12 across
  `effortLevel` in settings, the `--effort` flag, and both `claude-opus-5` and
  `claude-opus-5[1m]`. Neither the mechanism nor the model variant moves the outcome. The
  mitigation no longer reads "move the level out of the environment" — nothing above `high`
  searches; a `model: sonnet` delegate and `WebFetch` remain the only ways out.
- **`CLAUDE_EFFORT` is no longer written off as a false oracle.** Re-measured in `claude --print`
  it read back `high` / `xhigh` / `max` exactly as set, matching the tier quoted in the 400; the
  earlier "always `high`, however the level was set" reading did not reproduce. It still does not
  report a *delegate's* level, and the env path was not re-tested.

### Changed

- **Method warning rewritten.** "Confirm the level took hold" did not save v1.19.1, because that
  release left nothing to confirm it with — the token oracle was weakened and `CLAUDE_EFFORT`
  declared false in the same pass. It now reads: confirm with an oracle the claim does not depend
  on (the 400 names the tier it rejected), and read that oracle off `--output-format stream-json`
  rather than a guessed transcript path.

Not touched: the `defaultMode` findings and the weakened token oracle from v1.19.1 — the
re-measurement does not bear on either; the v1.19.0 grounding stamps and drift detector; and
`references/project-docs/*.md`.

## [1.19.1] — 2026-07-26

**A matrix that never varies the variable proves nothing, confidently.** v1.19.0 shipped a
finding — "`WebSearch` dies at `xhigh`/`max` on Opus 5" — measured across five call sites, both
model tiers, main thread and subagents. Every row of it raised effort the same way: through
`CLAUDE_CODE_EFFORT_LEVEL`. That turned out to be the *only* mechanism that breaks. Set the same
`xhigh` through `effortLevel`, `--effort` or `ultracode` and search works — on `claude-opus-5`,
same CLI, same day. The conclusion inverted: the tier is not the trigger, the env layer is, and
the practical consequence flips from "you cannot run deep sessions with web access" to "move the
level out of the environment". This release corrects that, and records the class of error that
produced it — a control variable held constant across every row reads exactly like a confirmed
finding.

### Fixed
- **`references/native-capabilities.md` — the `WebSearch` / effort entry, re-measured.** Retitled
  from "dies at `xhigh`/`max`" to "dies when the level arrives through `CLAUDE_CODE_EFFORT_LEVEL`",
  with the differential matrix (env `xhigh` fails 5/5, 3–4 rejections per run; `effortLevel` 0/5,
  `--effort xhigh`/`max` 0/5, `ultracode` 0/2 — all `claude-opus-5`, CC 2.1.220). The remedy line
  "the only general fix is keeping the session at `high` or below" is **removed**: it forbade
  exactly the depth the level is raised for. `model: sonnet` and `WebFetch` stay documented, now
  scoped to where the env layer cannot be removed. The refuted frontmatter workaround and the
  silent-failure properties are unchanged — those measurements stood.
- **`effortLevel` / `ultracode` in settings, corrected.** `ultracode` *is* a settings key
  (boolean) and a `--settings` layer carrying it starts an `xhigh` session; the previous text
  called it rejected there. `max` remains session-only. Out-of-enum `effortLevel` is swallowed by
  a `.catch()` — it costs the level silently, it does not invalidate the file.
- **Token spend demoted from oracle to weak signal.** The claim that a level is verified by
  token spend rested on n=1 per group. On repeat it did not hold: `--effort low` vs `xhigh`
  overlapped completely on a short prompt (n=3 each), and on a heavy reasoning task the medians
  parted ~25% with ranges still crossing. Interactive `/effort` reports the level directly and is
  now named as the answer.

### Added
- **`references/native-capabilities.md` — invalid config does not always degrade gracefully.** A
  bad `permissions.defaultMode` discards the **entire** settings file, not the key: it is one of
  the few schema entries without `.catch()`. Hooks (including a guard hook meant as the hard
  floor), `permissions.allow`/`deny`, `effortLevel`, `language`, `enabledPlugins` and statuslines
  all stop applying, with nothing printed. Found live in an operator config, where `"xhigh"` had
  been pasted into the permissions block; confirmed by a differential language oracle (n=2 each).
  Ships the accepted-value list (including `manual`, whose omission makes a validator reject a
  valid config) and a one-line `jq` check. The general rule sits with it: verify a setting
  *applied*, by a behaviour it controls — presence in the file is not evidence.

### Not touched (deliberately)
- The **v1.19.0 grounding stamps and the drift detector** — this release re-measures one finding,
  it does not re-ground the inventory.
- **devlog #23**, which carries the superseded conclusion. The devlog is episodic: what was
  believed on the day is part of the record. #24 supersedes it and says so explicitly.

## [1.19.0] — 2026-07-26

**A pin duplicated in two live docs goes stale in one of them silently.** Nothing fails, no test
goes red — the two files just disagree, and the reader believes whichever they opened. The kit
drifted this way three model upgrades in a row (4.7 → 4.8 → 5), each time caught by hand, each
time re-introduced, because "proofread the docs for stale versions" is not a procedure — it is a
hope. So this release does two separable things: it re-issues the inventory against the current
generation, and it adds the *mechanical* detector that makes the next drift visible instead of
discovered. The target form is one file carrying the currency pin (`native-capabilities.md`),
every other live doc version-free and pointing at it.

### Added
- **`references/audit-checklist.md` §1 — target form + drift detector.** Names the single
  version-carrying document as the goal state, and ships the `grep` that enumerates every version
  reference outside the inventory and the frozen layers (`archive/`, `devlog/`, `reports/`,
  `audits/`, `CHANGELOG.md`). Each survivor gets classified by the section's existing rule
  (behavioral binding → de-version; honest when/against-what sourcing → keep); **a rising hit
  count between audits is the drift signal**, so the count gets recorded. Run on audit and after
  every model / CC upgrade. Deliberately **not** a hook: block-at-write is corrosive (§6), and the
  output needs a human classification pass — which is what an audit is. Minor, not patch: this
  adds a rule and a procedure to the checklist, not a wording fix.

### Changed
- **`references/native-capabilities.md` re-issued against CC v2.1.220 / Opus 5** and now states
  in-band that it is the kit's single version-pinned document. Substantive deltas, all
  changelog- and binary-verified:
  - **`context: fork` skills run in the background by default since v2.1.218** — a fork-skill whose
    answer the current turn depends on **must** carry `background: false`, or the turn proceeds
    unanswered. This generalizes the long-standing `AskUserQuestion` incompatibility from an edge
    case into the default path. The highest-consequence correction in this release.
  - **Subagent nesting was wrong**: not "5 levels deep" — depth **3** by default (v2.1.219; nesting
    was off entirely in v2.1.217), `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` disables it. Added the
    native fan-out caps: 20 concurrent subagents, 200 spawns/session (reset by `/clear`), 200
    WebSearch calls/session — a runaway backstop no harness needs to re-encode.
  - **`/fork` is no longer the in-session fork** (v2.1.212): it copies the conversation into a
    *background* session with its own `claude agents` row; the in-session forked subagent is
    **`/subtask`**.
  - **Review is invoke-only** — `/verify` + `/code-review` since v2.1.215, `/deep-research` since
    v2.1.218: the model no longer reaches for them on its own, so that rung of the verification
    ladder has to be pulled by an operator, a duty line, a command, or a hook. `/code-review` also
    runs as a background subagent now (v2.1.218).
  - **Effort configuration mechanics**, previously absent — session-wide (`effortLevel` in
    settings, enum low|medium|high|xhigh with `max`/`ultracode` rejected there;
    `CLAUDE_CODE_EFFORT_LEVEL`, which adds `auto` and overrides the settings key; `claude
    --effort`, `claude agents --effort`) **and per delegate**, which is the part a harness
    actually steers with: `effort:` in `.claude/agents/*.md` frontmatter (named level, integer,
    or `inherit`), since the Agent tool overrides only `model` per call — a dynamic workflow is
    the one surface taking effort per call. Measured: same prompt, same parent, `effort: low` →
    862 / 656 output tokens vs `effort: xhigh` → 3358 / 3452.
  - **Effort precedence, measured** (org ceiling ▸ env ▸ launch pin ▸ settings ▸ model default),
    with the trap it creates spelled out: an `env: {"CLAUDE_CODE_EFFORT_LEVEL": …}` block inside
    `settings.json` is still the env var, so it silently outranks that same file's `effortLevel`
    key, the `--effort` flag and `/effort` — a harness pinned that way can never raise effort
    again. With the env set, `--effort low` vs `xhigh` moved nothing (911/953 vs 798/533 tokens);
    with it unset the same pair separated cleanly (722 vs 1053 median).
  - **The `WebSearch`-dies-at-`xhigh` class, with its issue trail** (anthropics/claude-code
    #76689 / #79798 / #68797, open): the server-tool sub-request carries the session's current
    effort but omits the thinking config → `400 output_config.effort 'xhigh' is not supported
    when thinking is disabled`. Reported on Opus 4.8, **reproduced here on Opus 5 / CC 2.1.220**
    once the session level genuinely reached `xhigh`; regression traced to v2.1.207. It earns a
    place in the kit because of *how* it fails: mostly inside **subagents**, and **silently** —
    the error sits in the `WebSearch` `tool_result` body with no `is_error` flag, so a research
    delegate returns a confident report with a source tier missing. Recorded with the verified
    workarounds — and the one that does *not* work: a delegate pinned to `effort: high` still
    fails, because the sub-request carries the session's level, so only a different model
    (`model: sonnet`), `WebFetch`, or a session at `high` or below actually avoids it — plus the
    detection glob one level deeper than the session file. Also documented: the
    first-party rule it collides with (thinking may be disabled only at effort ≤ `high`) and the
    silent tool-call-as-text mode when thinking is off.
  - **First-party counter-pressure on prompt-level self-verification** [FP, `whats-new-opus-5`]:
    the current Opus generation verifies its own work unprompted, and the docs say to *remove*
    carried-over instructions like "include a final verification step" / "use a subagent to
    verify" — they cause over-verification. Recorded beside the review surfaces with the boundary
    stated: this retires prompt-level nagging, **not** the ladder's external rungs (a
    fresh-context evaluator is not the author checking itself).
  - **`CLAUDE_EFFORT` is documented as *not* a reliable oracle** — measured false on v2.1.220:
    it reported `high` in `claude --print` under `--effort low|xhigh|max`, and reported the
    parent's level inside a subagent pinned to `low`/`xhigh`, while behavior differed 4–5× in
    token spend. The oracle that did discriminate is the subagent's own transcript under
    `<session-dir>/subagents/`.
  - Dynamic-workflow size guideline defaults to **medium** ("fewer than 15 agents") since v2.1.219
    and is settable from any settings file via `workflowSizeGuideline`; `/fast` now covers Opus 5
    and 4.8 (dropped from 4.7); hooks list gains **`DirectoryAdded`** (30 → 31 events, counted);
    the auto-mode classifier absorbed the dangerous-`rm` / background-`&` / Windows-path prompts
    (v2.1.218); Bash permission parsing hardened in v2.1.214–216 — including non-ASCII word
    boundaries, which matters to any project guard that inspects the command string itself; new
    `sandbox.filesystem.disabled` and `sandbox.network.strictAllowlist` keys.
- **`references/evidence-base.md`** — the capable-model baseline note de-versioned
  (`Fable 5 / Opus 4.8` → `current frontier generation`). The claim itself is untouched: it is a
  first-party citation, not our measurement, and re-writing it under a new model would be
  laundering someone else's finding.

### Not touched (deliberately)
- **Grounding stamps stay where they were** in `audit-checklist.md`, `harness-discipline.md`,
  `harness-evolution.md`, `evidence-base.md`. A stamp is an honest claim about a past
  verification; those files were not re-verified end-to-end in this release, and raising the stamp
  without the re-check would be a lie about re-grounding. `native-capabilities.md` moves because
  it actually was re-issued.
- **`references/project-docs/*.md`** — already version-free, checked, zero pins; their `shipped-by`
  headers therefore do not move.

## [1.18.0] — 2026-07-22

**A spec written out of a conversation designs for the implementer by default.** Every conversation
a spec grows out of carries implementation asides — a table name, a file path, a library someone
happened to mention. Absent a rule, they don't stay asides: in a 2026-07-22 lab A/B (Claude Code
2.1.217, Opus 4.8, 21 headless runs, N=3 per arm, deterministic oracles) all 6 planted
implementation details landed in the *binding* sections of the synthesized spec in 3/3 runs — and in
one run an implementation key replaced the acceptance criterion outright ("re-running the same file
— *the same `file_hash`* — creates no entries", where the actual pain was double-charging a
*payment*). With the detector: 0/6, in 3/3 runs, with every one of the 8 required business facts
still present in both arms — the guard for the known regression class (a rule that strips facts
along with the narrative, devlog #113) stayed clean. Full separation, no overlap, and the spec came
out *shorter*, not longer. The delta's neighbour in the same brief did not survive the same filter:
a spec-faithfulness axis in the review mandate tied 3/3 against baseline on both a smelly and a
silent spec defect — a control arm with `docs/SPEC.md` deleted from the repo produced 0 references
to requirements while still finding every code smell, which locates the lever in **the spec being a
file in the repo**, not in the wording of the mandate. Adopt-on-proof cuts both ways; that is the
point of running it.

### Changed
- **`references/project-docs/workflow.md` — two bullets in `Size the change before you build`,
  beside NON-GOALS**: (1) *Spec what and why; leave how to the implementer* — the detector is
  business-risk-or-architecture → write it down, pure implementation (class and function names, file
  paths, table schema, library choice) → don't, because the implementer's call beats a guess frozen
  into the spec; (2) *Constraints are invariants, not steps* — "the operation is idempotent", not
  "add a dedup table", each marked `[hard]` (non-negotiable) or `[soft]` (may be traded away for
  simplicity — an explicit licence to simplify, not decoration). Minor, not patch: the second bullet
  adds an element to the spec skeleton, and both change what a session writes.
- The file's `shipped-by` stamp advances `v1.16.1 → v1.18.0`, so installed copies are offered the
  re-sync on their next audit. `testing.md` (v1.17.4) and `docs-discipline.md` (v1.10.1) keep their
  own stamps — per-file provenance, untouched files don't move.

Untouched, deliberately: the CLAUDE.md template's duty lines (`bootstrap-checklist.md` Phase 2) —
this rule is needed at the moment a spec is written, and on-demand `workflow.md` is exactly the
carrier for that, so it does not earn per-turn context; `practice-baseline.md` §1 — the baseline is
the operator-global layer and this delta is spec-phase-scoped; `harness-discipline.md` — its Plan
bullet already lists "critical files" as legitimate recon output, and a *don't fix file paths*
sentence beside it would read as a contradiction rather than a sharpening. Everything else under
`plugins/**` is unchanged.

## [1.17.4] — 2026-07-20

**"See it fail" is not enough — the red has to fail for the right reason.** Rule #2 in the shipped
testing invariants told sessions to watch a test go red before trusting it, but a red from an
incidental `ImportError`, a typo in the test, or a broken fixture is red for the wrong reason: it
proves the harness is broken, not that the test catches the behaviour it targets. A session that
accepts any red as the green light ships a test that never actually guarded the thing it names. The
sharpening survived a strict adopt-on-proof filter over a multi-agent harvest of an external
agent-harness project (39 dedup practices → exactly one immediate keep); the other 38 were already
ours (HAVE) or solve other harnesses' problems — multi-IDE rule-drift, weak-model step-skipping,
marketplace distribution — and were rejected as out-of-scope.

### Changed
- **Testing rule #2 now names what makes the red trustworthy** (`references/project-docs/testing.md`):
  after "see it fail … before trusting it," one sentence — the red must come from the assertion you
  targeted, not an incidental `ImportError`, typo, or broken fixture; otherwise the red proves
  nothing. The file's `shipped-by` stamp advances `v1.9.2 → v1.17.4` (the block's text changed, so the
  per-file provenance moves with it), so installed copies are offered the re-sync on their next audit.
  Single-source confirmed: `workflow.md` step 3 *links* to "`testing.md` rule 2 for what actually
  matters" — a pointer, not a copy — so the sharpening lands in one place and propagates by reference.

Untouched: every other rule, the cross-cutting block, and all other `plugins/**` behaviour — this is
the one-sentence invariant sharpening and its stamp, nothing else. Distilled from the maintainer's lab,
which carries the same wording one layer up.

## [1.17.3] — 2026-07-17

**The README was written for someone who already knew what the kit was.** Two things it got wrong for
a first-time reader: the happy path was buried — install, then thirty lines of `CLAUDE_CONFIG_DIR`
sandbox mechanics before the one phrase that actually starts the thing — and `devlog` was filed under
"Optional" at the bottom, three paragraphs of component inventory, as if a project's memory across
sessions were a nice-to-have. Both are onboarding defects, not prose defects: the reader who bounces
off a README never reaches the kit that would have served them.

### Changed
- **The happy path is three lines**: two `/plugin` commands and one sentence to say. The throwaway-config
  recipe (v1.16.2) keeps every hard-won detail — both mechanisms and why you need both, the
  Linux/Windows-vs-Keychain split, `rm -rf` undo, the `claude-code-harness`-not-`harness` trap — but
  inside a collapsed `<details>`, where it serves the reader who wants it without taxing the one who
  doesn't.
- **`devlog` is installed by default, not offered as a footnote**: the install block ships both
  plugins, the header says "two plugins … and keep a memory of it across sessions", and a real section
  (`The devlog companion: your project's memory`) leads with the problem — a session that opens cold
  re-litigates a settled decision — before the components. Framed as the atemporal harness (what's true
  about the project) vs. the episodic record (what happened in it): different jobs, and the second is
  where sessions bleed time. Requirements (Python 3, platforms) demoted to a closing line; the
  skip-it-if-you-changelog-by-hand escape hatch kept.
- **`What you can say` gained two rows**: `/devlog:devlog` (the skill was never shown being called) and
  an explicit, fully-qualified `/claude-code-harness:claude-code-harness` invocation — with a note that
  the phrases are examples, not incantations. The namespaced form is the one a subscriber actually has;
  the bare `/claude-code-harness` only resolves in the maintainer's symlink-dogfood environment
  (the #14/DEMO.md trap, caught before it shipped this time).
- **`Four modes` is gone** — it restated the phrase table in abstract nouns. Bootstrap/Audit live in the
  table and in `The opinion` (which moved below the how-to: the reader learns what it does before why
  it's built that way); Extend/Explain collapsed into one table row. `What ships` became a `Learn more`
  link — repo-path inventory is a contributor's view, not a user's.

Untouched: every `plugins/**` behaviour. This release is the README only — no skill, reference, agent,
hook, or template changed, so `/plugin update` delivers identical kit behaviour with a readable front door.

## [1.17.2] — 2026-07-17

**The MVH note's own rule, applied to the line it walked past.** The `## Working style` template ends
its change-sizing bullet with a pointer to `.claude/docs/workflow.md`, and that bullet is one of the
two Phase 7 greps that still apply to an MVH project — so it has to survive where the note drops its
neighbours. It survived with the pointer attached, into the one shape that never creates
`.claude/docs/`. The defect pre-dates v1.17.0; v1.17.1 fixed its sibling in Phase 2b's delta list and
left this one standing.

### Fixed
- **The MVH note strips the change-sizing pointer** instead of only dropping whole lines: the duty
  stays (Phase 7 greps `size the change` there), its trailing `.claude/docs/workflow.md` goes.
  Dropping the line — the other obvious fix — would have put the note in conflict with its own gate.
  Every other `.claude/` mention in the two template blocks was already handled, by the note
  (ladder-semantics · doc-with-code · continuity · the `.claude/docs/` + `.claude/devlog/`
  Reference-materials lines) or by "(only those that exist)" — so an MVH CLAUDE.md now points at
  nothing that shape doesn't create.

Untouched: the Phase 7 gate, `practice-baseline.md`, `project-docs/*` (per-file stamps).

## [1.17.1] — 2026-07-17

**v1.17.0's regression test did not work.** External refutation of the shipped diff (arriving after
the push) found that `grep -ci continuity CLAUDE.md` — the gate written specifically to catch a
CLAUDE.md with no continuity duty — **passes that exact file**. Measured, not argued: a fixture built
from the pre-diff template (Working style with no duty + the verbatim `Reference materials` block)
scores `continuity` = 1, because the block this same template prescribes already ends a line with the
word: `- .claude/docs/workflow.md — flow: session ritual, plan, verification ladder, continuity`.
v1.17.0's two live bootstraps could not reveal it — both wrote the duty, so the gate returned ≥1 for
the *right* reason. A gate that passes when the artifact is correct and passes when it is broken is
not a gate. This release is that gate, actually working.

### Fixed
- **Phase 7's continuity token is anchored**: `grep -ciE '^#{0,4} *-? *\*{0,2}Continuity'` — the word
  as a *label at line start* (duty bullet, or a `## Continuity` heading), which no pointer line
  satisfies. Verified against four real artifacts: buggy fixture → 0 (catches it); library bootstrap,
  sustained bootstrap, section-style CLAUDE.md → 1 (all pass). The refuter's proposed token
  (`closes with an episodic`) was rejected on evidence, not taste: sessions paraphrase the duty
  ("closes with a `/devlog:devlog` entry"), so it scored **0 on all three correct bootstraps** — it
  would have replaced a false pass with a false fail on every project.
- **The same anchor in `audit-checklist.md`.** The bare grep made the new gap-check miss most of the
  population it targets — pre-1.17.0 projects carry that Reference-materials line, so `→ 0` never
  fires. The "expect this on **every** project bootstrapped before v1.17.0" claim was wrong and is
  corrected to "common".
- **Phase 2b told sessions to delete the line Phase 7 demands.** Its dedupe rule trimmed Working style
  to "project-specific deltas (plan-mode duty + verification-ladder lines)" — and the practice
  baseline's §6 *is* continuity, with the project embed as Phase 2b's default. A session obeying both
  phases deleted the duty and then failed the gate. The delta list is now explicit (plan-mode ·
  ladder · change-sizing · continuity · doc-with-code) and says why these survive: they are the
  project-side write-through, and "the baseline says it one layer up" is the union-of-layers argument
  Phase 7 exists to reject. The same unclosed list in audit §4's "evidence-backed keeps" is updated —
  its neighbouring "lines that don't change behavior → cut" bullets read as a licence to cut exactly
  these. (`size the change` had this defect before v1.17.0; fixed here too.)
- **Remaining unconditional Phase-5 references** (v1.17.0 fixed three of five): Phase 7's "with F0 as
  their due date" and SKILL.md's greenfield line + Mode 1 prose all promised an `F0`/ledger that a
  non-sustained greenfield never gets. Now branch-aware.
- **The `.claude/devlog/entries/` Reference-materials line is conditional** on the devlog actually
  being the project's carrier — where the carrier is disciplined commits it pointed at a directory
  the project will never grow, which is the dangling-pointer noise the MVH note forbids.
- **Phase 5 item 1's "Session 0 establishes a green baseline"** got the greenfield clause the
  neighbouring phases received: at 0 files there is no runner to configure and no entry point to
  reuse, so the oracle is a TBD carried by `F0` — and authoring `scripts/init.sh` against a guessed
  stack is the invented-fact ban in script form.
- **"the full shape"** (Phase 0) named a shape the file never defined; it now resolves to
  "default shape + Phase 5". `~16-line cost` → `~25-line` (the block is 25 lines).

## [1.17.0] — 2026-07-17

A clean-environment bootstrap test caught the kit failing its own write-through rule. The Phase 2
CLAUDE.md template carried no continuity duty, so **a session following the checklist to the letter
was obliged to produce a CLAUDE.md with zero mention of devlog or progress** — while Phase 7's
write-through grep, whose stated job is catching instructions that stay in the references instead of
landing in the project, tested three other tokens and passed it green. The depth had shipped twice
over (`practice-baseline.md` §6, `project-docs/workflow.md` §Continuity); only the ~per-turn duty and
the carrier's name never made the trip. The second gap: at 0 files / 0 commits nothing in the
checklist applied, so the session improvised a policy on the spot.

### Added
- **Continuity duty in the Phase 2 CLAUDE.md template** — three lines by the existing
  `Doc-with-code` pattern: the trigger (feature / fix / config or API change / decision → episodic
  entry), the carrier, `.claude/progress/<slug>.md`, and a pointer to `.claude/docs/workflow.md` for
  the depth. Deliberately **not** a section: the kit's own division of labor (Phase 2c) puts the
  ~per-turn duty in CLAUDE.md and the on-demand depth in `.claude/docs/` — restating the shipped
  depth in every project's CLAUDE.md is the over-correction, not the fix.
- **Phase 8 — Record the bootstrap.** The run writes its own devlog entry #1 in the carrier the
  Phase 2 duty names. One action, four effects: the *why* of the harness enters the episodic layer
  instead of evaporating with the session; `.claude/devlog/entries/` exists for real; the
  SessionStart digest has something to show on turn one; and the carrier gets a live smoke test.
  Phase 6 "Stop" keeps its name — it is about *not adding machinery*, not about the end.
- **Greenfield policy (Phase 0)** — "0 files, 0 commits" is a valid detected state, not a blocker.
  An explicit request for the full harness on an empty repo is **informed consent: deploy it, don't
  argue the project is too small**. Undeterminable intent → ask once, default to the full shape.
- **`F0` ledger seed (Phase 5, item 2)** — on a greenfield sustained build the ledger seeds
  `F0` "get the brief → fill Stack / ARCHITECTURE / CODE-MAP / name the oracle", `passes: false`.
  The session ritual lands on it first, so the TBDs close **inside the loop** rather than in the
  operator's memory.
- **`continuity` as Phase 7's fourth write-through grep token** — the regression test for the bug
  above. Carrier-agnostic on purpose: it passes whether the carrier is a devlog or disciplined
  commits.
- **Audit gap-check** — CLAUDE.md that names no continuity duty. Every project bootstrapped on
  ≤1.16.3 has this by construction, so the audit now surfaces it (adopt-on-proof: this run is the
  proof).

### Changed
- **Placeholder vs boilerplate, made explicit (Phase 2 + Phase 1 table).** "Never boilerplate" bans
  *inventing a plausible fact you did not read*; it does not ban an honestly-labelled empty cell that
  names its own fill trigger. Greenfield `docs/ARCHITECTURE.md` / `docs/CODE-MAP.md` therefore ship as
  marked stubs. A labelled stub is legible state; an invented one is a lie the next session trusts.
- **Phase 5 item 3** now points at the Phase 2 duty instead of describing the episodic layer in
  mid-air — a layer described only in the checklist is a layer the working session never hears about.
  The carrier detect-gate is unchanged.
- **Phase 7** marks the stack probe and the oracle run **N/A by construction** on greenfield (the
  stack is a labelled TBD — there is nothing to match and no command to run), not "skipped". The
  deny-rules probe and all four greps still apply.

### Fixed
- **Stubs no longer cite an `F0` that will never exist.** Phase 5 is explicitly skipped for
  libraries / scripts / one-offs, so on a *non-sustained* greenfield there is no `features.json` —
  yet the first draft asserted unconditionally that the stub's fill trigger "is the `F0` ledger
  feature". A stub pointing at a file the project will never have is precisely the dangling-pointer
  noise the checklist's own MVH note forbids, wearing an accountability costume. The claim is now
  branch-aware, and the same Phase-5 assumption is removed from Phase 8's carrier fallback and from
  the duty template's carrier placeholder. (Caught pre-release by refutation of the diff, then
  confirmed by an A/B of two live bootstraps.)

### Not touched
`practice-baseline.md` (its content-version stamp stays **v1.16.0** — it advances only when the
block's text changes) and `references/project-docs/*` (their per-file `shipped-by` stamps stay at
v1.9.2 / v1.10.1 / v1.16.1). The continuity depth was already correct in both; only the project-side
duty was missing.

## [1.16.3] — 2026-07-16

The kit hardcoded `~/.claude` in its *executable* detect-gates. Claude Code relocates the whole
config directory via `CLAUDE_CONFIG_DIR` (throwaway stands, containers, CI) — and under the
override the gates read the **operator's** profile instead of the active one, verdicting about
someone else's environment. Silent-wrong class: no error, a plausible and false conclusion.
Observed twice on a clean-config stand (2.1.211): the devlog detect-gate saw the maintainer's
symlinks and withheld the companion offer; the Phase 2b baseline detect saw the maintainer's
global CLAUDE.md and withheld the baseline offer.

### Fixed
- **Executable detect-gates resolve the active config dir** — `CLAUDE_CONFIG_DIR` if set and
  non-empty, else `<home>/.claude` — shipped as a *rule the agent resolves with whatever its
  shell supports*, not a mandated one-liner: `Read`/`Glob` don't expand `$VAR` (the path must
  reach them as a literal), and on Windows without Git Bash the shell is PowerShell, where bash
  substitution isn't syntax. The bash form (`"${CLAUDE_CONFIG_DIR:-$(echo ~)/.claude}"` — its
  tilde survives even unset `HOME` via passwd) remains as a parenthesized hint and as the direct
  substitution inside the inherently-bash Phase 0 block. An absent dir is a valid "layer
  absent", not an error. Gates touched: bootstrap Phase 0 profile listing, the devlog-companion
  detect (hooks + skills), Phase 2b baseline detect and the guarded-merge backup path, audit §2
  duplicate/symlink checks and §4 global-stamp check, and `/external-audit`'s ROLE_DIR fallback
  — which now practices the "do not hardcode `~/.claude`" its neighboring step preaches.
  Descriptive prose (layer maps, provenance, maintainer rituals) keeps the literal default:
  parameterizing an explanation is noise, not portability. Externally refuted before release
  (`code-refuter`: stands, 0 critical/major); the fix matches the host's own semantics —
  the binary reads the variable as `process.env.CLAUDE_CONFIG_DIR || homedir()` with `trim()` —
  and a two-arm headless A/B confirmed both branches at runtime: default profile → carrier
  found; override → the gate inspects the fixture and returns a valid "absent", where the old
  wording would have reported someone else's profile.

## [1.16.2] — 2026-07-16

A safe way to try the kit before it touches anything. Installing already writes nothing to your
`~/.claude/` — but "already" is a claim a prospective user has no reason to take on faith, so the
README now carries a throwaway-config recipe they can run and undo with one `rm -rf`.

### Added
- **README "Try it in a throwaway config first"** — `CLAUDE_CONFIG_DIR` (relocates the *whole*
  `~/.claude`, so the session sees the kit and none of your own setup) plus `--scope project`
  (keeps the install in the demo project's `.claude/settings.json`). The two are orthogonal and
  both are needed: no project-level file can switch off a global `~/.claude/CLAUDE.md`. Run
  end-to-end against a clean config on 2.1.211 before shipping the text — the marketplace/install
  pair resolves the GitHub source and delivers the current version. The credentials line is
  platform-split straight from first-party docs: Linux/Windows keep `.credentials.json` *inside*
  the config dir, so it moves with `CLAUDE_CONFIG_DIR` and copying it skips a re-login, while macOS
  keeps credentials in the Keychain, where the copy would be pointless.
- **`.claude/DEMO.md`** — the maintainer's consumer-journey rig, now tracked. Same clean-config
  stand, but pointed at a *local* checkout so unreleased edits can be walked as a subscriber would
  see them, plus the traps that cost a session to find: the plugin is `claude-code-harness`, not
  `harness` (that is only its folder); `plugin details` outside the stand reports the symlink
  dogfood rather than the package, which reads as a packaging bug that doesn't exist; `plugin
  update` is gated on the version, not the content. It opens with an addressee marker pointing
  users to the README recipe — the two readers differ, so the two texts do. Dev-harness: it ships
  in neither plugin.

## [1.16.1] — 2026-07-16

Two corrections to shipped guidance, both the same shape: an instruction that read as protection or
as necessity while being neither. The Phase 3 `settings.json` template carried permission rules the
engine parses and never matches — and a template is the one place a no-op propagates into every
project that copies it. Phase 5, separately, buried its no-file alternative in a mid-paragraph
parenthesis, so the de-facto default read as *author a script*: on a project whose entire
verification is `pytest -q`, the old wording duly produced a root `init.sh` wrapping that one
command.

The permission half was found in live use rather than by review: an operator's own config carried
`Glob(./**)` / `Grep(./**)` because the checklist put them there. Verified against Claude Code
2.1.211 three ways — the permissions doc, the rule validator inside the shipped binary
(`filePatternTools: ["Read","Write","Edit","Glob","NotebookRead","NotebookEdit","Cd"]` — no `Grep`),
and a red→green fixture run.

### Fixed
- **Dead file rules removed from the template** — `Glob(./**)` and `Grep(./**)` out of `allow`,
  `Write(//abs/path/**)` out of the rewrite-with-donors deny pair. The file-permission checks match
  only `Read(path)` and `Edit(path)`: `Read` already governs Grep and Glob, `Edit` already governs
  Write and NotebookEdit. `Glob(path)` / `Write(path)` / `NotebookEdit(path)` are parsed, never
  matched, and warn on v2.1.210+ — a `deny: Write(./s/**)` demonstrably let the file be created
  anyway. **`Grep(path)` never warns at all**, which is why the template's copy survived this long.
  (`MultiEdit` is additionally gone as a tool: "matches no known tool".) A **bare** tool name stays
  live and is a different rule: `deny: Write` without parens matches the tool everywhere.
- **The template's `secrets/` deny now fences reading, not only writing** — `Read(./secrets/**)`
  joins `Edit(./secrets/**)`. `audit-checklist.md` §10 already grades "secret paths not denied for
  `Read`" as a finding while the template shipped exactly that. The two rules are not
  interchangeable: a `Read` deny also blocks Edit (v2.1.208+) but never reaches Write or
  NotebookEdit, so a path nothing may read *or* change needs both.

### Added
- **A mechanical check for the class, in both rituals — with its blind spots named, not papered
  over.** Phase 7 gains a dead-rule grep (pass = no output) and `audit-checklist.md` §10 the matching
  finding. The check greps for the untrusted-workspace line as well as `^Permission `, and that second
  pattern is not decoration: a fresh-context refuter showed the obvious one-pattern form reports
  **clean** in an untrusted workspace — a fresh clone, CI, the bootstrap case itself — because `allow`
  entries are dropped *before* validation, and the single line that says so doesn't begin with
  `Permission`. It would have handed operators a clean bill of health on precisely the dead-`allow`-rule
  defect this release exists to eliminate. Two blind spots are stated outright: `Grep(path)` never
  warns, and only deny/ask are typo-checked, so a typo'd *allow* rule vanishes without a word
  (`Bogustool(./z/**)` in `allow` → zero output). Remediation is a **fold, not a delete**, and a bare
  `Write`/`Glob` must survive it. A dead **deny** rule is graded the harness's most expensive defect
  class — the operator believes a path is fenced and it is not.

### Changed
- **The Phase 5 oracle is a command, not a file — no script authored by default.** Item 1 stops
  hiding the alternative in a parenthesis and branches explicitly: (a) an entry point already exists
  (`make check`, `npm test`, `just check`, `tox`) → *that* is the oracle; name it in CLAUDE.md and
  stop — a second entry point re-running the same gates is a drift source; (b) verification is one
  well-known command → document the one-liner, create no file; (c) no entry point *and* multi-gate or
  env-prep needed → author **one** script at `scripts/init.sh`, not the repo root (a bespoke harness
  script among the build manifests reads as clutter; only (c) earns a file at all). Measured rather
  than assumed: a three-fixture behavioural A/B against the old text — control shipped through the
  same dogfood symlink, machine criterion, one run per cell — found that on a `pytest -q`-only
  project the old wording created a root `init.sh` whose whole payload was `exec "$PYTEST" -q`, while
  the new one names the command and writes no file. The asymmetry is recorded, not smoothed over:
  branch (a) produced **no delta** — the model already reused an existing `make check` unprompted —
  so (a) is insurance and (b)/(c) are what fix the measured defect. Ripples through everything that
  named `init.sh` as a given: `SKILL.md`'s Phase 5 line, `operator-playbook.md` §2 and §3,
  `evidence-executor.md`'s oracle step, `audit-checklist.md`'s post-refresh run, the root-files list,
  the session-start ritual, and the Phase 7 run-it-once check. `project-docs/workflow.md` step 3 now
  reads "run the oracle — the verification command CLAUDE.md names"; its `shipped-by` stamp advances
  to v1.16.1, so installed copies are offered the re-sync on their next audit.
- **`audit-checklist.md` grounding stamp synced to CC v2.1.211** — its §10 findings were live-verified
  against 2.1.211 in this release, so the functional "grounded for X" stamp tracks that.
  `harness-discipline.md` keeps v2.1.210: its content wasn't re-grounded here, and these stamps are
  per-file provenance, not a global version marker.

Untouched on purpose: `native-capabilities.md` §Settings (its "Read deny rules hide files from
Glob/Grep" line was already correct — the fix was the template contradicting it, not the fact), and
`Bash(rm -rf /:*)` in the template deny (not a no-op: it hardens the built-in circuit-breaker prompt
into a hard deny).

## [1.16.0] — 2026-07-16

Consumer-journey fold. A fresh-context external audit of how the kit lands on a machine that
is *not* the maintainer's (no personal hooks, no lab rules) found the delivery layer
inconsistent enough that adoption could read net-negative next to bare Claude Code: the
practice baseline claimed a discipline whose machinery didn't ship, the global-merge
procedure carried weaker guards than the kit demands for in-repo operations, and README gave
a fresh installer no entry phrase. This release makes the two consumer flows — first contact
and staying current — coherent end-to-end. Docs + one plugin hook; the kit's component set
(skills/agents/commands) is unchanged — existing texts, including `SKILL.md`'s description
and Mode 1, are edited in place.

### Added
- **`devlog` companion now ships a SessionStart continuity digest** (`hooks/hooks.json` +
  `hooks/session-start-digest.sh`): surfaces the last 3 devlog entries + up to 3 active
  (non-CLOSED) progress journals at session start; silent (exit 0, no output) in projects
  that keep neither; read-only, POSIX + bash-3.2 portable, no dependencies. This closes the
  dogfooding asymmetry the audit led with: the zero-prompting continuity empirics in
  `practice-baseline.md` Provenance were observed under the lab's personal session-start
  hook, which consumers never got — the equivalent machinery is now installable
  (`/plugin install devlog@claude-code-harness`), and Provenance + delivery step 4 say so
  directly instead of burying the confound in a subordinate clause.
- **Practice-baseline content-version stamp** — the canonical block now opens with an HTML
  comment stamp (stripped before context injection — zero runtime cost) with the same
  semantics as the project-docs `shipped-by` headers: it advances only when the block's
  text changes. `audit-checklist.md` §4 gains the matching re-sync check (embed vs canon,
  diff-first, unstamped copy = hand-edit, a global copy is never auto-edited);
  `practice-baseline.md` gains "Keeping installed copies current"; `operator-playbook.md`
  gains §5 "Keeping the kit and the baseline current" (the `/plugin update` → audit →
  offered-re-syncs ritual; former §§5–7 renumbered to 6–8).
- **README "First session (start here)"** — the trigger-phrase table (bootstrap / minimal /
  audit / Phase 5 / external-audit), an explicit what-bootstrap-touches contract (inside
  repo / outside repo / profile), and a direct link to `operator-playbook.md` — previously
  the only human-facing map was a table-cell mention with no path.

### Changed
- **Baseline delivery inverted: project embed is the default, global merge is a guarded
  opt-in** (`practice-baseline.md` delivery procedure; synced in `bootstrap-checklist.md`
  Phase 1/2b/4, `SKILL.md` Mode 1 + plan template, `operator-playbook.md` layer map + §1).
  First contact lands the baseline in-repo (git-tracked, reviewable, removable); the global
  merge is offered with its radius stated in the offer ("every project on this machine,
  ~80 lines per session") and executes only after a shown diff, a timestamped backup
  (`~/.claude/CLAUDE.md.bak-<date>` — the file is usually not under git, so the backup IS
  the rollback), and a budget check against the same ≤200-line discipline as project
  CLAUDE.md. Detection now spans **all** memory layers (managed policy → user → project →
  auto-memory), and a fourth outcome is specified: a rule the baseline contradicts is named
  to the operator and never silently merged — co-loaded contradictions tell the model X and
  not-X every turn.
- **Baseline §7 names the native floor** — destructive-command block + the permission flow
  are the platform's out-of-the-box floor; the baseline's reactive `permissions.deny` layer
  builds above it. Previously §7 implicitly assumed a machine-level guard hook that only
  the maintainer's machine had.
- Continuity texts (`bootstrap-checklist.md` Phase 5 items 3–4) no longer describe
  state-surfacing automation as "which this kit does not ship" — the companion ships it;
  the CLAUDE.md session-start ritual remains the carrier without it. The block's line-count
  quotes corrected to the measured ~80 (were "~60").
- **Audit checklist gained two hook items** the shipped digest's own defects earned:
  context-injecting hooks (`SessionStart` / `UserPromptSubmit` / `Stop`) with unbounded
  stdout (§6), and a derived file (`index.json` / `tldr.md`) read as a fast path — stale
  and unvalidated for a few saved milliseconds (§6). §2 gained the hook-merge case below.
- **Detect before installing the companion** (`bootstrap-checklist.md` Phase 5 item 3):
  hooks and skills from every layer *merge, never override* (verified against the 2.1.211
  bundle: hook sources are concatenated, not replaced — modulo `allowManagedHooksOnly` /
  `disableAllHooks`), so an operator who already runs a personal SessionStart digest gets
  the same state twice, in two formats, before turn one. The kit gated ~80 lines of prose
  behind a four-outcome detect while waving through a hook that fires every session.

- **The digest line now carries the entry's date** (`#id · date · title`): the id alone
  doesn't answer "was this yesterday or in March?", and the date costs ~12 bytes per line.
  Optional — an entry without one still surfaces. Order stays `latest last` (recency).
- **Two duplication items the maintainer's own machine earned.** `audit-checklist.md` §2:
  a hand-kept copy of something a plugin already ships. Plugin skills are namespaced
  (`plugin:skill`), so a personal copy never *collides* — no error, no shadow warning, just
  two skills with one description and a model picking either; the tell is a fix you must
  apply twice. `operator-playbook.md`: symlinking the checkout is the **only** dogfooding
  path that stays live (a marketplace install *copies* into `~/.claude/plugins/cache/`;
  `--plugin-dir` is per-invocation) — and it must point at the **plugin directory**, not its
  `skills/` subfolder, or you get the skill without the plugin's `hooks/` and `bin/`.

### Fixed
- **The SessionStart digest could flood the context window** (`session-start-digest.sh`).
  Its stdout is injected verbatim ahead of the operator's first turn, in every project
  including a freshly cloned untrusted one, with no downstream trim — so boundedness is the
  component's core invariant. Two fresh-context refuter rounds found it broken in four ways,
  all now closed and covered by a 36-case suite (`test-session-start-digest.sh`, new — the
  hook shipped with none) green under bash, dash, `bash --posix` and busybox sh:
  - **Frontmatter is now cut by its fence pair, not by a sed range.** A `/^---/,/^---/`
    range re-opens on the next `---`, so a horizontal rule or setext underline in an entry
    body — both idiomatic markdown — started a second "frontmatter" whose lines forged
    `id`/`title`. An explicit `41q` also makes the read genuinely bounded: a whole-file scan
    on an absent field previously read 402 MB (straced); a 382 MB entry now reads 65 KB.
  - **`CLOSED` is matched as a status marker, not a substring.** `*CLOSED*` hid
    `# Migrate CLOSED-account archive to S3` — an *active* journal — which is the exact
    continuity loss the digest exists to prevent. Word boundaries alone then leaked
    `CLOSED-2026-07-16` back in as active, so the tail rule distinguishes a status suffix
    from an identifier; the residual (`CLOSED-shipped` reads as active) is signed in-file
    as the cheap direction — noise beats a hidden active task.
  - **CRLF entries** no longer emit a stray quote and CR into the context.
  - **A whole-digest `MAX_BYTES` backstop** (4096, overridable via `DEVLOG_DIGEST_MAX_BYTES`)
    now sits under the per-field caps, announcing truncation rather than silently dropping a
    tail. It is deliberately unreachable in normal operation — and, being overridable, is
    actually exercised by the suite: a guard no test fires is a guard nobody should trust.

## [1.15.0] — 2026-07-16

Drift-remediation fold. A cross-project fresh-context audit of consumer projects (4 adversarial
harvest agents over 37 `.claude/` projects; provenance in the maintainer's lab) showed the canon's
prescriptive FORMAT diverging from what operators actually needed in two layers — continuity and
verification — with almost every operator deviation better than the canon. Every fold below is
multi-source-evidenced, passed a two-refuter adopt gate (two independent fresh-context refuters,
verdicts converged 6/6), and was behaviorally A/B-verified on temp fixtures (kit-before vs
kit-after, headless fresh-context runs, 3/3 fixtures with a visible delta) before landing.
Text/schema only — no new machinery, zero always-on cost. Two further candidates (an optional
4th `state/` continuity layer; a guard-heavy CLAUDE.md ≤200 carve-out) were **rejected** at the
refuter gate as N=1-evidenced and already covered by existing canon — recorded as lab watch-items.

### Changed
- **Continuity: the progress layer now has two legitimate shapes** (`workflow.md` Continuity,
  `practice-baseline.md` §6) — **task-scoped** (closes with the task; terminal = `CLOSED` marker
  *or* delete, both valid — what matters is the file no longer reads as active work) and the
  **workstream snapshot** (a long-lived rolling picture of one workstream's current state + open
  threads; episodic history → devlog; prune, don't append). The hard "convert→devlog, then
  delete" mandate is gone: across three audited projects the delete never once happened, and the
  strongest operator practice was exactly the rolling snapshot the canon didn't recognize.
- **Verification ladder: externally-initiated refute for the silent-wrong class**
  (`workflow.md`) — for parsers/guards/validators prefer a refuter **initiated outside the
  authoring session** (fresh session / external audit) over a subagent the author spawns: a
  self-commissioned evaluator partly inherits the author's framing (a real one passed a denylist
  that an external pass then broke with Unicode-obfuscated input). And "verify passed" ≠ "the
  invariant holds": a consumer ledger stood at 6/6 green while an external audit refuted the
  invariant with an input class the suite never encoded — the refuter's mandate is the
  invariant, not the diff.
- **features.json canon: `blocked` / `blocked_reason` / `notes`** (`bootstrap-checklist.md`
  Phase 5 + `workflow.md`) — externally-gated verify is now expressible in the ledger. A bare
  `passes: false` can't distinguish "not done yet" from "cannot proceed here", so sessions
  re-attempted walls and invented ad-hoc carriers (a consumer project and a fixture run
  independently invented `notes`-like fields and root handoff files). Now: verify every
  reachable layer below the wall first, record `blocked` + `blocked_reason` (what unblocks it,
  and who), route the narrative to `notes`/progress, skip blocked features at session start,
  never flip `passes` on partial verify. Plus the campaign fork: a multi-initiative campaign
  keeps **one** roadmap carrier — not a ledger per initiative with a mirror roadmap.
- **Shipped-docs re-sync keys on content-versions** (`audit-checklist.md` §4,
  `operator-playbook.md` §4) — the project copy's `shipped-by` header is compared against the
  canon file's own header, never the plugin package version (which advances on unrelated
  releases and turned "re-sync available" into a permanent false positive).

### Added
- **Skills invocation-control facts** (`native-capabilities.md` Skills §, verified against
  first-party docs 2026-07-16): `user-invocable: false` (background knowledge, hidden from the
  `/` menu; exact spelling — the `user-invokable` variant seen in the wild is silently ignored)
  vs `disable-model-invocation: true`; `context: fork` + `agent:` for forked knowledge lookups.
  `harness-discipline.md` names the proven reference-skill species: the **project-knowledge
  skill** (background domain knowledge out of CLAUDE.md), pointing at those mechanics.
- **Audit checklist §3: hand-rolled `sync-docs` skill/agent** — duplicates the *kit-shipped*
  docs-discipline rule 1 ("doc-with-code") rather than a native surface; observed built only in
  projects that lacked the rule and retired once the rule arrived. Retire toward the rule.

### Fixed
- `operator-playbook.md` install command now matches README:
  `/plugin install claude-code-harness@claude-code-harness`.

## [1.14.4] — 2026-07-16

Docs hygiene — strip decorative edit-log meta from the reference surface, keeping the
functional staleness machinery intact. The kit's own `docs-discipline` rule 7 ("current-state,
not changelog") and practice-baseline §6 ("atemporal facts, not history") apply to the kit's
own references: a date that drives a future action (re-verify / re-sync / delta-compare) is
load-bearing and stays; a date that only records "this file was edited" is a log and goes.

### Removed
- **Decorative edit-log meta** — the dated "re-distilled on DATE (added §1/§2/§6/§8…)" changelog
  narration from `practice-baseline.md`'s Provenance, and two `<!-- last-updated -->` HTML
  comments (`harness-evolution.md`, `operator-playbook.md`) that only stamped a file-edit date
  and pointed at unshipped lab artifacts.

### Changed
- **`practice-baseline.md` Provenance rewritten to current-state** — keeps the load-bearing
  empirical anchor (§5/§6 zero-prompt red→green, §8 fresh-context-critic result) and now
  cross-references `evidence-base.md` for the wider citation set, instead of narrating what was
  added when.
- **`evidence-base.md` grounding stamp synced to CC v2.1.211** — was left at 2.1.210 after the
  1.14.3 bump; this is a functional "verified against docs on X" stamp, so it tracks live.

Untouched (functional provenance, deliberately kept): the `harness-evolution.md` refresh ledger,
`native-capabilities.md`'s version line + `verified DATE` / `re-ground on bump` markers, and the
`shipped-by:` headers that key the project-docs re-sync.

## [1.14.3] — 2026-07-16

Micro external-intake pass — the refresh ledger drifted one CC patch behind live
(`claude --version` = 2.1.211 vs the ledger's 2.1.210), which is a standalone strip-revision
trigger. Swept the changelog delta 2.1.210→2.1.211, folded the one canon-relevant finding, and
re-stamped the ledger. Not a full strip revision: only the changelog was re-checked; the
docs/blog/binary sweep stays grounded at 2.1.210 until the next calendar revision.

### Changed
- **`native-capabilities.md` current to CC v2.1.211** — the inventory version line advanced from
  2.1.210, and the auto-mode-classifier note now records that a **PreToolUse hook `ask` floors the
  auto-mode decision at a prompt** for unsandboxed Bash (v2.1.211): the classifier can no longer
  silently downgrade a hook `ask`, so a guard hook stays authoritative over auto mode. This is the
  only 2.1.211 delta that touches harness design — the rest of the release is bug/UX fixes and
  niche SDK flags (`--forward-subagent-text`), which the D-cycle gate correctly rejects as
  non-canon.
- **Refresh ledger re-stamped** (`harness-evolution.md`) to CC v2.1.211 / 2026-07-16, honestly
  scoped to "changelog delta only" so the next strip revision still knows the full multi-source
  sweep is grounded at 2.1.210.

## [1.14.2] — 2026-07-16

Canon evolution — two D-cycle folds distilled from a real consumer project's usage, each verified
against that project's on-disk evidence before folding. Prose only; no code changes. Project name
kept out of the shipped surface (anonymized as in `evidence-base` / `practice-baseline`).

### Changed
- **Independent verification repositioned into two tiers** — the operator surfaces
  (`operator-playbook §5` + Layer map, the `SKILL.md` handoff footer) and the discipline ladder
  (`harness-discipline.md`) now lead with the lightweight per-change fresh-context refute (the
  `code-refuter` role solo) as the workhorse, and frame the full 3-role `/external-audit` as the
  rare milestone/irreversible escalation. This matches observed usage: the heavy audit ran once at
  a milestone while the refuter role alone carried per-change verification. No new command or
  agent — the workhorse reuses the already-shipped `code-refuter` role.

### Added
- **"The spec's own premise is a claim, not a fact"** — a new rule in `operator-playbook §3`
  (the "claim, not fact" cluster): measure whether a requirement's assumption holds before building
  to it; an oracle sweep can refute the requirement itself, and when it does, trust the measurement
  over the spec.

## [1.14.1] — 2026-07-15

Locale standardization and unified versioning. The kit's shipped **prompts** are now
uniformly English (matching the agents, README, and project-docs); the **devlog** companion
stays in the operator's language because its artifacts — devlog entries — are written in the
user's language, and its machinery is now language-agnostic rather than Russian-only.

### Changed
- **Harness-plugin prompt surfaces translated to English** — the `/external-audit` command,
  `operator-playbook`, `harness-evolution`, and the operator-handoff footer in `SKILL.md` were
  the last Russian-language files on the shipped harness surface; they now match the rest of
  the plugin. No behavioral change — prose only.
- **`devlog` preview extraction is now language-agnostic** — `rebuild-index.py` anchors on the
  first `## ` section instead of a hardcoded `## Контекст`, so `## Context`, `## Контекст`, and
  any-language headings all resolve. Devlog entries can now be written in the user's language
  (RU/EN and beyond) from one machinery; slugs were already bilingual via transliteration.
- **Both plugins share one version, bumped in lockstep** — `harness` and `devlog` are now both
  `1.14.1`; `scripts/release.sh` versions and stages both plugin trees under one number
  (previously it touched only the harness plugin, leaving devlog to a manual bump).

### Fixed
- `operator-playbook` referenced `.claude/audit/<slug>/` (singular) while `/external-audit`
  writes `.claude/audits/<slug>/` (plural). Aligned the doc to the command, which is the
  source of truth.

### Added
- Two regression tests for language-agnostic preview extraction (RU/EN/DE headings + first-
  section anchoring that fails under the old hardcoded heading).

## [1.14.0] — 2026-07-15

Multi-plugin marketplace: the harness kit gains a `devlog` companion so the continuity
guidance it already ships becomes runnable for the public, without a second copy of the
maintainer's global skill.

### Added
- **`devlog` companion plugin** (`plugins/devlog/`) — a `/devlog:devlog` skill plus a
  `devlog-reindex` command (shipped in `bin/`, on the Bash tool's `PATH` when enabled) that
  regenerates `.claude/devlog/{index.json,tldr.md}` from markdown entries. Install with
  `/plugin install devlog@claude-code-harness`. Verified against Claude Code 2.1.210
  (`claude plugin validate` + `--plugin-dir` load + the script's own pytest suite).

### Changed
- **Repository restructured into the idiomatic multi-plugin layout** — the harness plugin
  moved from the repo root to `plugins/harness/`; the marketplace manifest stays at the root
  and now lists both plugins with explicit `./plugins/<name>` sources (the `metadata.pluginRoot`
  shorthand is rejected by `claude plugin validate`, so paths are spelled out). The install
  command is unchanged — `claude-code-harness@claude-code-harness` resolves by name, not path.
- `scripts/release.sh` and the dogfood symlink re-pointed to the new `plugins/harness/` paths;
  `.gitignore` whitelist updated for the `plugins/` tree.

## [1.13.0] — 2026-07-15

First release from the standalone repository.

### Changed
- Re-centered all internal narrative on the new source of truth — this public repo,
  installed via `/plugin marketplace add nikitaCodeSave/claude-code-harness` — instead of
  the previous `dot-claude`-embedded delivery (`operator-playbook`, `harness-evolution`,
  `external-audit`).
- `version` is now the single source of truth in `plugin.json`; removed from the marketplace
  entry (per Anthropic guidance — `plugin.json` silently wins, so duplication only risks the
  desync a prior external audit caught).
- Release ritual moved into the repo as `scripts/release.sh` (was `~/.claude/scripts/`,
  bound to `dot-claude`); it now guards against version drift instead of syncing two manifests.

### Added
- `plugin.json`: correct `$schema` (json.schemastore.org), `keywords`, `homepage`.
- `README.md`, `LICENSE` (MIT), and this `CHANGELOG.md`.

### Fixed
- Dropped the redundant `skills: ["./"]` manifest field that contradicted single-skill-plugin
  auto-loading (Claude Code v2.1.142+).

## [1.12.2] — binary-verifier enrichments (Claude Code 2.1.199–2.1.210 deltas)
## [1.12.1] — retire the last stale `/agents`-wizard instruction in Bootstrap Phase 0
## [1.12.0] — external-audit fold: currency to 2.1.210, scripted release mechanics
## [1.10.1] — docs-discipline rule 7 (current-state, not changelog) + version sync
## [1.10.0] — campaign scoped-delivery + `paths:` reliability
## [1.9.2] — staleness-guard (content-gate + orphan-sweep)
## [1.9.1] — retire the stale Plan-Mode → Auto-Mode caveat
## [1.9.0] — D-cycle fold of dialog-analyzer practices into the shipped workflow
## [1.8.0] — production-grade default + shipped workflow distillation in `.claude/docs/`
## [1.7.0] — write-through of practices (practice baseline / workflow ladder / docs bootstrap)
## [1.6.1] — external-audit debt fold (review availability, index-regen dependency)
## [1.6.0] — operator handoff footer
## [1.5.1] — clean fair-copy edition
## [1.5.0] — full first-party re-ground (Fable 5, nested subagents, ultrareview)
## [1.4.1] — Monitor/Cron documented as first-party; fix profile-blind claims
## [1.4.0] — review ladder, execution spine, maintainer/consumer split
