<!-- shipped-by: claude-code-harness v1.17.4 — do not hand-evolve in the project;
     improvements flow through the plugin (re-synced on audit). Stack-specific
     commands live in CLAUDE.md, not here. -->

# Testing — invariants (any stack)

Five rules, extended by project CLAUDE.md, never replaced by it.

1. **Test in the same session as the code change.** "I'll add tests later" is debt that
   compounds; write and run them before the session ends.
2. **A test verifies behavior and is able to fail.** If it passes immediately and would not
   fail on broken behavior, it verifies nothing: see it fail (or prove it catches a planted
   regression) before trusting it. The red must come from the assertion you targeted — not an
   incidental ImportError, typo, or broken fixture; otherwise the red proves nothing. Red→green
   ordering is a useful default, not dogma — the lever is a runnable oracle asserting
   **observable behavior through the public interface**, not prints, not private internals.
3. **Tests live next to the code**: `test_<module>` beside `<module>`, or a mirrored `tests/`
   tree. No tests in odd corners — it kills discoverability.
4. **One test — one behavior.** When something breaks you should not have to guess which of
   eight asserts died.
5. **Regression test before the bugfix.** Reproduce the bug as a failing test (red), then fix
   (green) — proving the fix works and the bug can't return silently.

Cross-cutting:

- **Green baseline from session 0**: the suite runs green before feature work starts; an
  oracle that is red on day 0 emits false-alarm signal until fixed.
- **Never weaken or edit a test just to make it pass.** Removing/relaxing tests to get green
  is falsified verification.
- **Mock only the genuinely external boundary** (third-party API, network, clock) — never
  your own unbuilt internals.
- **"Tests pass" is evidence to open, not a done-claim**: verify the feature end-to-end the
  way a user would hit it before calling it done.
- Negative and degradation cases are first-class: a verify contract without them only proves
  the happy path.
