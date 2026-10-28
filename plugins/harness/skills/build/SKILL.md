---
name: build
description: "Build a ticket or spec in a fresh session against acceptance tests committed earlier, which stay untouched."
argument-hint: "<ticket or spec>"
disable-model-invocation: true
---

Build what $ARGUMENTS describes. Its acceptance tests, committed in an earlier session, are the
agreed check and are read-only for you: do not edit them. If a test looks wrong, say so — do not
work around it. Done means they and the existing suite pass; report the command and its output.

At the end, show the tests were left untouched: run `git diff --stat <the commit that added them>
-- <their directory>` and show that it prints nothing. Commit the build. If $ARGUMENTS is a ticket,
remind me to close it — an open ticket keeps the tickets it blocks waiting.
