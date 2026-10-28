---
name: task
description: "Start a new change: an interview, then a spec, then the build in this same session; done comes with the command and its output."
argument-hint: "<what you want, and any interface you already fixed>"
disable-model-invocation: true
---

$ARGUMENTS

Interview me until you could write the spec, then write it to specs/<slug>.md. The spec says what
and why (acceptance criteria as checkable statements, non-goals), not how. Copy any interface my
request fixes (module paths, signatures, error classes) into it verbatim. Then build it. Done means
the test suite passes and the spec's criteria are covered; report the command and its output.

If `CLAUDE.md` names another place for specs, write it there. If this conversation already settled
parts of it — a grilling, a discussion — don't ask those again; ask only what the spec still needs.
If the request above is empty, start by asking what I want.
