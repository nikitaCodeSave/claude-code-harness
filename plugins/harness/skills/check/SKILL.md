---
name: check
description: "An independent review of the current change against its spec by a fresh read-only reviewer, then reproduce and fix what is real — at most three rounds."
argument-hint: "[spec] [base commit]"
disable-model-invocation: true
---

Get an independent review of the current change, then handle what it finds.

1. Find the spec this change implements ($ARGUMENTS if it names one, else the spec in flight) and
   the base: the commit before this work started — the parent of the commit that added the spec,
   unless $ARGUMENTS names one.
2. Spawn a subagent of type `Plan` (read-only, fresh context) with exactly this task, the spec path
   and base filled in, and nothing else — not your reasoning, not what you suspect:
   "Review the changes since commit <base> (committed and uncommitted) against <spec>. Report only
   gaps that affect correctness, each with file:line; skip style. If there is nothing to fix, say
   so."
3. A fresh reviewer who has not seen your reasoning reported. Reproduce each finding before
   changing anything; fix the real ones and reject the rest in one sentence each. Report the
   command and its output.
4. If you changed anything, run step 2 again on the new diff. At most three rounds in all; a
   fourth would mean the approach is wrong — stop and say so instead.
