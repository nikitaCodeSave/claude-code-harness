---
name: wrap
description: "End of a session: decisions and terms not yet written down, evidence that the work is done, finished or dropped work closed, what is left, and a commit with what and why."
disable-model-invocation: true
---

Wrap up this session's work.

1. **Decisions — catch the ones not yet written.** A decision is written when it is made
   (*Project knowledge* in `CLAUDE.md`); this step only catches the ones that weren't. List each
   decision made in this session that later work must follow, including ones I stated "for later".
   Write every one not yet in an ADR — in `docs/adr/`, or the decision log `CLAUDE.md` names — and
   name the ones caught only here. A decision that changes an earlier one is a new ADR, and the earlier
   ADR's status becomes `superseded by NNNN`. An ADR that rests on a spec or research note cites it
   by path — git keeps the file after it goes.
2. **Terms.** Add to `GLOSSARY.md` any domain term used or settled in this session that is missing;
   a term replaced by a better name keeps the old one under `_Avoid_`.
3. **Evidence.** Show the project's check command and its output for this work; if it has not run
   since the last change, run it.
4. **Closures — propose them, don't act yet.**
   - A ticket whose acceptance tests pass, once its review (if it needs one) is done: propose
     closing it as resolved, so the tickets it blocks can start.
   - A spec whose criteria all pass, once its review (if it needs one) is done: go through it, and
     any ticket files under `specs/<slug>/`, line by line. Every line must live somewhere else —
     a test, an ADR, the glossary or the commit message; write what is missing. Then propose removing the spec
     file and those ticket files. A spec or ticket in a tracker (`.scratch/` included) is closed
     there, not deleted.
   - Work I explicitly told you to drop — "later" is not "drop": write to an ADR only what later
     work must follow. Then propose removing its spec and ticket files (a spec in a tracker, `.scratch/` included, is
     closed there), its acceptance tests, any code built only for it and glossary terms only it
     used; closing its tracker tickets `wontfix`
     with the reason in one line; and setting ADRs made only for it to `deprecated`. If I rejected a
     request that later work must not re-propose, propose `.out-of-scope/<concept>.md` saying why;
     if I reverse such a rejection, propose removing that file.
   - A research note whose decision is now in an ADR or a spec: propose removing it.
5. **What is left.** If a spec or ticket is unfinished, say in one line what remains, so the next
   session starts there.
6. **Commit.** Propose a message — what changed and why — with every file the closures remove and
   every ticket they close. After I confirm: commit the work, then carry out the closures and commit
   the removals on their own, so git keeps what was removed.
