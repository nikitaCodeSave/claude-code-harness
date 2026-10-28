# <project>

<2–4 lines: what this is, who uses it, what "done" usually means here. No marketing.>

## Commands

```bash
<install>
<test>                 # and the single-test form, e.g. pytest tests/test_x.py::test_y
<lint / format / typecheck>
<run, if there is one>
```

Done = these exit 0. <Multi-component: this is the whole-repo check; each component's own
commands are in its CLAUDE.md, loaded when you work there.> <CI-only or service-dependent suites:
name them here with what they need.>

## Boundaries

- **Always:** <update the test or schema a change touches>
- **Ask first:** <migrations · new dependencies · anything under infra/>
- **Never:** <commit secrets · edit vendor/ · force-push>  — those a permission rule can express
  are mirrored in .claude/settings.json

## How we work

- A non-trivial change starts with an interview: ask until you could write the spec, then write
  it where this project keeps specs (see the Agent skills block; otherwise `specs/<slug>.md`) —
  what and why, acceptance criteria as checks, non-goals, scope limits, and any interface I fixed,
  copied verbatim. Then build it in this same session.
- Work that won't fit one session: say so and propose a split — I run `/to-tickets`. Each ticket
  is built in a fresh session from tests written beforehand, in a separate session, from that
  ticket's criteria; the implementer does not edit those tests — if one looks wrong, it says so.
  Large and still unclear: propose `/wayfinder` first.
- One implementer at a time — no parallel fan-out on a bounded change.
- Report "done" with the command and its output, not "tests pass".
- Test order is free, but a test must be able to fail. A bug gets a failing check before the fix.
- Review: `/code-review` on a substantive diff. High-stakes (security, migrations, parsers,
  invariants): a fresh session reviews the change against the spec — correctness only,
  file:line, at most three rounds, then rethink the approach.
- Stuck twice on the same thing: stop and say what you need — a decision, a credential, a service.

## Project knowledge

- Domain terms live in `GLOSSARY.md` <multi-context: `GLOSSARY-MAP.md` points to each context>:
  add a term the first time it is used or settled.
- Decisions that are hard to reverse, or that later work must follow — including ones I mention
  "for later" — go to `docs/adr/NNNN-<slug>.md` <or the decision log this project already keeps>
  in the session where they were made.
- Before changing an area, read the glossary entries and the ADRs that touch it.
