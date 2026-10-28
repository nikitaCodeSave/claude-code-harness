---
name: tests
description: "Acceptance tests first, in their own session: turn a ticket's or spec's criteria into tests that fail for now, and commit them for the build."
argument-hint: "<ticket or spec>"
disable-model-invocation: true
---

Read $ARGUMENTS. Turn every acceptance criterion into tests under tests/acceptance/<slug>/,
exercising only the public interface it names. Take expected values from it, not from the code. Do
not implement the feature: these tests should fail for now. Report the command you ran and its
output.

Then look at how they fail. Each test must fail on its own assertion, not on an import error or a
broken fixture; rewrite any that doesn't. A test that already passes means its criterion is already
true at this commit — say so instead of keeping a test that cannot fail. If `CLAUDE.md` names
another place for acceptance tests, use it.

Commit the tests on their own and give me the commit id. The build runs in a fresh session:
`/harness:build $ARGUMENTS`.
