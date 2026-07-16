---
description: "3-role external audit of a deliverable (evidence-executor ∥ process-auditor ∥ code-refuter → adjudication → AUDIT-VERDICT.json)"
argument-hint: "<scope: feature/milestone + where the spec lives; optionally a commit range>"
---

You are the adjudicator of an external audit, launched by the operator in a FRESH session (not
the authoring one) at the root of the audited project. Run a 3-role audit of the scope:
**$ARGUMENTS**

Protocol rule: an external audit beats a self-orchestrated one (an Evaluator the author
commissions inherits the author's framing). If the context shows this session itself wrote the
audited code, stop and tell the operator to open a fresh session.

## Step 0 — scope and preconditions

1. Fix the audited surface: read `.claude/features.json` / `.claude/progress/` / the spec from
   $ARGUMENTS; determine the scope's commit range (`git log --oneline`). **If the project has no
   Phase 5 kit** (no features.json/progress — typical for legacy): take scope and preconditions
   from $ARGUMENTS + git log + README/CLAUDE.md; a missing ledger is not a blocker, but record it
   in the verdict's context. Do NOT review the code yourself — you are the adjudicator, not a
   fourth role; deep reading would compromise your independence.
2. Create `.claude/audits/<slug>/` (slug — a short name for the scope + date).
3. Check the live stack's preconditions (from `features.json.preconditions` / CLAUDE.md): are the
   containers/services up? If not, bring the dev services up if it is safe and reversible (docker
   start of a dev container — yes; anything production-like — stop, go to the operator).

## Step 1 — three roles in parallel

**Resolving the roles (important — otherwise the audit won't launch).** The roles ship inside the
`claude-code-harness` plugin and appear as the agent types `claude-code-harness:evidence-executor` /
`claude-code-harness:process-auditor` / `claude-code-harness:code-refuter` (verified on a clean
profile). If those types are in your list — spawn them directly via `subagent_type`; no need to
read the role file. (Indirect out-of-session pre-flight check: `claude plugin list` →
`claude-code-harness` in loaded/enabled status.)

**Fallback** (the types are not in your list — the roles live as files outside the plugin): spawn
`general-purpose` and make it load the role from disk as the first line of the prompt. Determine
`ROLE_DIR` — the first path that **contains all 3 role files** (check the files, not the directory's
existence — an `agents/` directory with unrelated files does not count):
1. `${CLAUDE_PLUGIN_ROOT}/agents/` — if the command was delivered by the plugin (default);
2. `<config-dir>/skills/claude-code-harness/agents/` — @skills-dir development / maintainer
   symlink. `<config-dir>` is the **active** config dir: `CLAUDE_CONFIG_DIR` if set and
   non-empty, else `<home>/.claude` (the skills dir follows the override) — resolve it with whatever your
   shell supports and hand file tools the resolved literal;
3. `.claude/agents/` at the audited project's root — if the roles were copied in locally.

Launch with THREE parallel Agent calls (one block). In fallback mode, the first line of each
prompt:
> "Read `<ROLE_DIR>/<role>.md` (evidence-executor | process-auditor | code-refuter) and act
> STRICTLY as that role — it is your full definition, follow it literally, including the output
> JSON format and its jq contract."

Then in the same prompt pass:
- target project directory (absolute path) and git_head;
- audited scope in one line + where the spec lives + commit range;
- known preconditions (dev DB/LLM addresses, etc.);
- output file path: `.claude/audits/<slug>/AUDIT-EVIDENCE.json` / `AUDIT-PROCESS.json` /
  `AUDIT-REFUTER.json` respectively (absolute paths);
- scope-specific probe hints, if the operator gave any in $ARGUMENTS.

If none of the ROLE_DIR paths exists — stop and tell the operator: role files not found, check the
plugin install / the git-clone layer.

## Step 2 — validate the verdicts

For each of the three JSONs, run the jq check from the corresponding agent definition
(`<ROLE_DIR>/<role>.md`; under native resolution ROLE_DIR is the `agents/` directory next to this
command: `${CLAUDE_PLUGIN_ROOT}/agents/`; do not hardcode `~/.claude`). An invalid file →
re-spawn that role (1 retry), then an honest report to the operator about the invalid output. Do
not fix the JSON by hand — that substitutes the verdict. If `jq` is absent from the environment —
do not fail: validate the same required keys and enum values by reading the JSON, and note in the
final answer that the jq contract was not executed.

## Step 3 — adjudication

Combine the verdicts by the rules (apply top to bottom):

1. **Executed evidence beats read evidence.** If a reader role's finding (process-auditor /
   refuter's reasoned finding) directly contradicts the observed output of an actual
   evidence-executor run — the finding is dismissed with a reference to the refuting run. Case
   precedent: a reader verdict "golden numbers unproven" against an executor re-derivation that
   matched to the last digit.
2. **Verified-critical = REFUTED.** Any finding with `severity: critical` and
   `demonstrability: verified` (from any role) → verdict `refuted`, regardless of the rest.
3. **A blocked executor blocks the verdict.** `AUDIT-EVIDENCE.verdict.status == "blocked"` →
   verdict `blocked` (an audit without execution cannot return confirmed — reader-only is not
   enough).
4. Otherwise: all three clean (`confirmed`+`clean`+`stands`, no surviving major) → `confirmed`;
   surviving major findings or process violations with a working product →
   `confirmed_with_debt` (each debt an actionable item).

Write `.claude/audits/<slug>/AUDIT-VERDICT.json`:

```json
{
  "audit_version": "1.0",
  "role": "adjudicator",
  "scope": "<one-line>",
  "context": { "git_head": "<sha>", "dirty": true },
  "role_verdicts": { "evidence_executor": "confirmed|refuted|blocked", "process_auditor": "clean|violations", "code_refuter": "stands|refuted" },
  "surviving_findings": [ { "summary": "", "severity": "critical|major|minor", "source_role": "", "file": "" } ],
  "dismissed_findings": [ { "summary": "", "source_role": "", "dismissed_by": "<run/fact that refuted the finding>" } ],
  "verdict": { "status": "confirmed|confirmed_with_debt|refuted|blocked", "summary": "<3-5 sentences>" }
}
```

## Step 4 — report to the operator

1. Append the surviving findings as actionable items to the next steps of the project's progress
   file (`.claude/progress/<...>.md`) in "reproduce → close" form (a claim, not a fact). Do NOT
   edit the code — fixes are done by the authoring session in a separate red→green cycle.
2. Final answer: verdict + role table + surviving/dismissed findings + what exactly was executed
   (evidence-executor's runs) + the path to `.claude/audits/<slug>/`.
