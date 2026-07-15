# Operator playbook — the lifecycle of a project with Claude Code

A document for the **human operator**: what to tell the agent, what to prepare between sessions,
when to commission an audit, and when to trim the harness. The agent does not preload it — this is
the entry point into the discipline, not an instruction to the model. Details of each step are
behind the links, not here.

The principle above everything: **under a capable model, less harness yields more productivity**.
Each step below adds exactly what has proven its worth — and not before its trigger.

## Layer map

| Layer | Where | What it is |
|---|---|---|
| Behavioral baseline | `~/.claude/CLAUDE.md` (or project-embed `.claude/rules/practice-baseline.md`) | §1–§8 for every project (Bootstrap Phase 2b) |
| Kit (this plugin) | source of truth — repo `nikitaCodeSave/claude-code-harness`; on the machine — the installed plugin in `~/.claude/plugins/` | Bootstrap / Audit / Extend / Explain |
| External audit | inside the plugin: `commands/external-audit.md` + `agents/{evidence-executor,process-auditor,code-refuter}.md` — travel with the plugin | the independent-verification ritual |
| Workflow distillation | `<repo>/.claude/docs/{workflow,testing,docs-discipline}.md` | shipped by bootstrap verbatim from the kit (`references/project-docs/`); refreshed by a re-sync at audit time keyed on the `shipped-by` version |
| Project layer | `<repo>/CLAUDE.md` + `<repo>/.claude/` + `<repo>/docs/` | created by step 1, grows by triggers |

The plugin and the behavioral baseline reach the machine/profile **separately**:
- **The plugin (kit)** — `/plugin marketplace add nikitaCodeSave/claude-code-harness`, then
  `/plugin install claude-code-harness`; carries SKILL.md, `/external-audit`, and the agent roles.
  (For a maintainer developing the plugin itself — symlink its checkout into `~/.claude/skills/`:
  a directory with `.claude-plugin/plugin.json` is auto-loaded as `claude-code-harness@skills-dir`,
  with no install step.)
- **The behavioral baseline (§1–8)** does NOT arrive with the plugin (the plugin does not ship an
  operator-global `CLAUDE.md`), but **Bootstrap delivers it** (Phase 2b,
  `references/practice-baseline.md`): the session detects your `~/.claude/CLAUDE.md` and offers a
  global install (with your approval) or a project-embed under `.claude/rules/`.

## 1. New project — bootstrap (first session)

1. Open `claude` at the root of the empty/new repo.
2. Say: **"set up Claude Code harness in this project"** — this triggers the skill in Bootstrap
   mode (`references/bootstrap-checklist.md`).
3. The default is **production-grade regardless of project size**: a root `CLAUDE.md`
   (≤200 lines, an indexer, including a Working style with a verification ladder) +
   `.claude/settings.json` (the deny list matters more than allow) + the workflow distillation in
   `.claude/docs/` (3 files, verbatim from the kit) + `docs/ARCHITECTURE.md` and `docs/CODE-MAP.md`
   with real content + an offer to install the practice baseline (globally in `~/.claude/CLAUDE.md`
   — preferred — or in `.claude/rules/`). The minimal MVH (CLAUDE.md + settings only) — via a
   separate phrase: **"set up a minimal harness"**. There are no custom agents/hooks/skills in
   either variant — this is discipline, not an omission.
4. The contract (stack / acceptance of the first feature / verify mechanism / sensitive paths)
   surfaces from the conversation as you go — no upfront questionnaire is needed; just make sure
   the dangerous paths land in `permissions.deny` as soon as they're named.

Step check: `claude --print "what is the project's stack?"` answers from CLAUDE.md.

## 2. A multi-session product — commission the Phase 5 kit

If the project is a product built feature-by-feature (not a library/script/one-off):

1. Say: **"set up the long-running build kit (Phase 5)"**.
2. You get conventions + files (not machinery): a runnable oracle `init.sh` with a green
   baseline · `.claude/features.json` (verify steps + `preconditions`, `passes: false`)
   · `.claude/progress/<slug>.md` + devlog · a session-start ritual in CLAUDE.md
   · a line about the fresh-context Evaluator. (`docs/ARCHITECTURE.md` + `CODE-MAP.md` and the
   workflow distillation are already in place from bootstrap — that's the default shape, not
   Phase 5.)
3. **The session seeds the ledger, the operator reviews it**: the agent writes the product's
   decomposition into features and verify contracts from your description; your step is to read
   the seeded `features.json` and correct the boundaries/verify BEFORE the first feature (this is
   your insurance against silent micro-decisions).
4. **harness-journal — opt-in, off by default**: ask for `.claude/harness-journal.md`
   (1–3 "kit-fell-short" observations per session) only if you plan to run D-cycles (step 6).
   Without D-cycles the journal is dead weight.

## 3. The build ritual — what the operator does between sessions

- **Preconditions before starting a session**: bring up the services from
  `features.json.preconditions` (DB docker container, local LLM, …). The session will check them
  and stop if they're missing.
- **Session start**: it's enough to say "continue from features.json" — the session-start ritual
  is wired into the project CLAUDE.md (git log → progress → one feature → `./init.sh`).
- **Session end**: check by eye — is there a commit per feature, is `progress` updated, is
  `passes: true` set only for features with completed verify steps.
- **A handoff note is a claim, not a fact**: if the previous session wrote "verified" — the next
  one must re-execute before relying on it.
- **Contract/docs vs disk**: on a mismatch (a path doesn't exist, a file isn't where expected) the
  truth is the disk: detect-then-prescribe, fix by the facts and record an observation in
  journal/progress, don't follow the contract blindly. Resolve commands per-tool (`.venv` first,
  PATH fallback) — and **watch what actually resolved**: an inherited PATH may substitute another
  project's venv (the oracle is "green" but the interpreter isn't from this project); have
  init.sh print resolved paths.

## 4. An existing project — bring it to the canon

1. At the project root, say: **"audit my Claude Code harness"** — this triggers Audit mode
   (`references/audit-checklist.md`; the gap-report template is in the kit's `SKILL.md`).
2. You get a gap report (finding → why it matters → remediation). **Edits happen only after your
   approval**, anything irreversible is flagged separately; before a strip — a branch/backup.
3. The audit also compares the `shipped-by` version of the workflow distillation (`.claude/docs/*`)
   with the version of the installed plugin and offers a re-sync if the plugin is newer — so the
   factory distillation in projects doesn't fall behind the canon.

## 5. External audit — `/external-audit`

When to commission: a milestone closed · a security/correctness-critical feature · an expensive
irreversible delivery that "looks done". It's periodically useful even on *accepted* features — a
fresh-context audit has caught HIGH defects in code that was already green.

How (the independence rule — external beats self-orchestrated):
1. Open a **new session** (not the authoring one) at the root of the audited project.
2. Say: **`/external-audit <scope>`** (feature/milestone + where the spec lives); if the command
   was delivered by the plugin, the name in the list is `claude-code-harness:external-audit`.
3. The session launches three roles in parallel — evidence-executor (must EXECUTE the live stack),
   process-auditor (git/scope/red→green), code-refuter (refutes the code) — and combines the
   verdicts by the rule "executed evidence beats read evidence".
4. Result: `.claude/audits/<slug>/AUDIT-VERDICT.json` + actionable items in progress.

## 6. D-cycle — evolving the canon (role: canon maintainer)

When: a milestone closed, or the journal has accumulated ≥5 substantive observations.
How: a separate session following `references/harness-evolution.md` (classify observations →
gate "single-incident ≠ invariant" → a surgical fold into the canon → commit + devlog).

"Canon" = this plugin's repository (`nikitaCodeSave/claude-code-harness`) at its maintainer's.
A plugin consumer does not edit the canon — they update the plugin version (`/plugin update`) and
pass findings/journal observations to the maintainer.

## 7. Strip revision — when to trim the harness

Once every 3–6 months or on a major model release: re-test each component "does the model already
do this natively?" (a quick test — `claude --safe-mode`: if it's no worse without the harness, the
component is obsolete). The procedure is the second half of `references/harness-evolution.md`.

## Cross-cutting operator rules

- (maintainer) Every kit edit = a commit to the plugin repo (`nikitaCodeSave/claude-code-harness`)
  + a devlog entry there; the empirical provenance (experiments) goes in the maintainer's lab repo.
- The harness grows **only by triggers** (the "Optional next steps" table in
  `references/bootstrap-checklist.md`), never speculatively.
- The project code is not touched through harness rituals: the scope of audits and Audit mode is
  `.claude/`, `CLAUDE.md`, `docs/`.

<!-- last-updated: 2026-07-15 (v1.13.0) · sources (maintainer's lab, not shipped): WORKFLOW.md, devlog #78–#82; bootstrap-checklist.md (in the kit) -->
