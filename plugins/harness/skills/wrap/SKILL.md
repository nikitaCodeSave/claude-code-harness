---
name: wrap
description: "End of a session: decisions into ADRs, terms into the glossary, evidence that the work is done, what is left, and a commit with what and why."
disable-model-invocation: true
---

Wrap up this session's work.

1. **Decisions.** List each decision made in this session that later work must follow, including
   ones I stated "for later". Write every one not yet in an ADR — in `docs/adr/`, or the decision
   log `CLAUDE.md` names.
2. **Terms.** Add to `GLOSSARY.md` any domain term used or settled in this session that is missing.
3. **Evidence.** Show the project's check command and its output for this work; if it has not run
   since the last change, run it.
4. **What is left.** If a spec or ticket is unfinished, say in one line what remains, so the next
   session starts there.
5. **Commit.** Propose a message — what changed and why — and commit when I confirm.
