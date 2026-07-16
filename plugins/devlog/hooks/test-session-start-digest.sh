#!/usr/bin/env bash
# Behavior test for hooks/session-start-digest.sh.
#
# The invariant under test is BOUNDEDNESS: this hook's stdout is injected verbatim
# into the model's context at session start, in every project, with no downstream
# trim. It must emit a few lines of orientation and never a file's worth of content,
# whatever the project holds. Everything else it does is secondary to that.
#
# Run: bash test-session-start-digest.sh   ·   SH=dash bash test-session-start-digest.sh
set -uo pipefail

HOOK="${HOOK:-$(dirname "$0")/session-start-digest.sh}"
SH="${SH:-bash}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

run() { CLAUDE_PROJECT_DIR="$1" $SH "$HOOK" 2>&1; }
check() { if printf '%s' "$3" | grep -qF -- "$2"; then echo "PASS: $1"; pass=$((pass+1))
  else echo "FAIL: $1 — expected [$2], got [$3]"; fail=$((fail+1)); fi; }
check_absent() { if printf '%s' "$3" | grep -qF -- "$2"; then echo "FAIL: $1 — should NOT contain [$2]"; fail=$((fail+1))
  else echo "PASS: $1"; pass=$((pass+1)); fi; }
check_empty() { if [ -z "$2" ]; then echo "PASS: $1"; pass=$((pass+1))
  else echo "FAIL: $1 — expected empty, got [$2]"; fail=$((fail+1)); fi; }
check_bounded() { local n; n=$(printf '%s' "$3" | wc -c)
  if [ "$n" -le "$2" ]; then echo "PASS: $1 ($n bytes)"; pass=$((pass+1))
  else echo "FAIL: $1 — $n bytes exceeds cap of $2"; fail=$((fail+1)); fi; }

mkentry() { mkdir -p "$1/.claude/devlog/entries"
  printf -- '---\nid: %s\ndate: %s\ntitle: "%s"\n---\n\n# Body\ntext\n' "$2" "$3" "$4" \
    > "$1/.claude/devlog/entries/$2-slug.md"; }
BIG=$(head -c 300000 /dev/zero | tr '\0' 'X')

# --- Silence where there is nothing to say ---------------------------------
p="$TMP/empty"; mkdir -p "$p"
check_empty "empty project -> silent" "$(run "$p")"
out=$(run "$TMP/nope"); rc=$?
check_empty "missing project dir -> silent" "$out"
[ "$rc" -eq 0 ] && { echo "PASS: missing project dir -> rc=0"; pass=$((pass+1)); } \
                || { echo "FAIL: missing project dir -> rc=$rc"; fail=$((fail+1)); }

# --- Basic digest ----------------------------------------------------------
p="$TMP/basic"; mkdir -p "$p"
mkentry "$p" 1 2026-01-01 "First entry"
mkentry "$p" 2 2026-01-02 "Second entry"
out=$(run "$p")
check "devlog header"  "Recent devlog" "$out"
check "devlog title"   "Second entry"  "$out"
check "devlog date"    "2026-01-02"    "$out"

# An entry whose frontmatter has no date still surfaces — the date is orientation,
# not a precondition.
p="$TMP/nodate"; mkdir -p "$p/.claude/devlog/entries"
printf -- '---\nid: 1\ntitle: "Dateless entry"\n---\n\nbody\n' \
  > "$p/.claude/devlog/entries/1-slug.md"
check "missing date -> entry still shown" "Dateless entry" "$(run "$p")"

p="$TMP/sort"; mkdir -p "$p"
for i in 3 9 10; do mkentry "$p" "$i" 2026-01-01 "Entry $i"; done
out=$(run "$p")
check "numeric sort: #10 outranks #3" "Entry 10" "$out"

# --- BOUNDEDNESS (the core invariant) --------------------------------------
p="$TMP/huge-title"; mkdir -p "$p"
mkentry "$p" 1 2026-01-01 "$BIG"
check_bounded "huge entry title -> bounded" 4096 "$(run "$p")"

p="$TMP/huge-body"; mkdir -p "$p/.claude/devlog/entries"
{ printf -- '---\nid: 1\ndate: 2026-01-01\n---\n\n'; printf '%s\n' "$BIG"
  printf 'title: SMUGGLED FROM BODY\n'; } > "$p/.claude/devlog/entries/1-slug.md"
out=$(run "$p")
check_bounded "huge body, no title -> bounded" 4096 "$out"
check_absent  "body line not smuggled in as title" "SMUGGLED FROM BODY" "$out"

p="$TMP/huge-prog"; mkdir -p "$p/.claude/progress"
printf '# %s\n' "$BIG" > "$p/.claude/progress/big.md"
check_bounded "huge progress heading -> bounded" 4096 "$(run "$p")"

# A body '---' (horizontal rule / setext underline) must not reopen the frontmatter
# range and let a body line forge id/title. Both are idiomatic markdown.
p="$TMP/forge"; mkdir -p "$p/.claude/devlog/entries"
{ printf -- '---\nid: 1\ndate: 2026-01-01\ntitle: "Real title"\n---\n\nProse.\n\n'
  printf -- '---\nid: EVIL\ntitle: FORGED FROM BODY\n---\n'; } \
  > "$p/.claude/devlog/entries/1-slug.md"
out=$(run "$p")
check        "body --- does not reopen frontmatter" "Real title"       "$out"
check_absent "body --- forgery blocked"             "FORGED FROM BODY" "$out"

p="$TMP/setext"; mkdir -p "$p/.claude/devlog/entries"
{ printf -- '---\nid: 1\ndate: 2026-01-01\n---\n\nHeading\n---\n'
  printf 'title: SETEXT FORGERY\n'; } > "$p/.claude/devlog/entries/1-slug.md"
check_absent "setext --- forgery blocked" "SETEXT FORGERY" "$(run "$p")"

p="$TMP/nofence"; mkdir -p "$p/.claude/devlog/entries"
{ printf 'Just a body.\n\n'; printf 'title: NO FENCE LEAK\n'; } \
  > "$p/.claude/devlog/entries/1-slug.md"
check_absent "unfenced entry leaks nothing" "NO FENCE LEAK" "$(run "$p")"

p="$TMP/crlf"; mkdir -p "$p/.claude/devlog/entries"
printf -- '---\r\nid: 1\r\ndate: 2026-01-01\r\ntitle: "CRLF entry"\r\n---\r\n\r\nbody\r\n' \
  > "$p/.claude/devlog/entries/1-slug.md"
out=$(run "$p")
check        "CRLF title parsed"          "CRLF entry"  "$out"
check_absent "CRLF leaves no stray quote" 'CRLF entry"' "$out"

p="$TMP/huge-all"; mkdir -p "$p/.claude/progress"
for i in 1 2 3 4 5; do mkentry "$p" "$i" 2026-01-01 "$BIG"
  printf '# %s\n' "$BIG" > "$p/.claude/progress/t$i.md"; done
check_bounded "everything huge -> still bounded" 4096 "$(run "$p")"

# --- CLOSED is a status marker, not a substring ----------------------------
p="$TMP/closed-fp"; mkdir -p "$p/.claude/progress"
printf '# Migrate CLOSED-account archive to S3\n\nin progress\n' > "$p/.claude/progress/migrate.md"
check "CLOSED substring in heading -> still shown" "migrate.md" "$(run "$p")"

p="$TMP/closed-fp2"; mkdir -p "$p/.claude/progress"
printf '# Task\n\n## Quick state — refactoring CLOSED-account handler, in progress\n' \
  > "$p/.claude/progress/refactor.md"
check "CLOSED substring in quick state -> still shown" "refactor.md" "$(run "$p")"

p="$TMP/closed-real"; mkdir -p "$p/.claude/progress"
printf '# Task beta\n\n## Quick state — CLOSED, shipped\n' > "$p/.claude/progress/beta.md"
check_empty "real CLOSED marker -> filtered" "$(run "$p")"

# The marker's tail: a status suffix means closed; a lowercase suffix means the word is
# part of an identifier (a domain term), so the journal is active.
closed_case() { # desc filename state expected(hidden|shown)
  local d="$TMP/cc-$2"; mkdir -p "$d/.claude/progress"
  printf '# Task\n\n## Quick state — %s\n' "$3" > "$d/.claude/progress/$2.md"
  local o; o=$(run "$d")
  if [ "$4" = hidden ]; then check_absent "CLOSED tail: $1 -> filtered" "$2.md" "$o"
  else check "CLOSED tail: $1 -> shown" "$2.md" "$o"; fi
}
closed_case "CLOSED-<date>"      dated     "CLOSED-2026-07-16"               hidden
closed_case "CLOSED_<UPPER>"     upper     "CLOSED_TASK"                     hidden
closed_case "(CLOSED)"           paren     "(CLOSED) done"                   hidden
closed_case "CLOSED-<lowercase>" ident     "refactor CLOSED-account handler" shown
closed_case "UNCLOSED"           unclosed  "UNCLOSED transaction bug"        shown
closed_case "lowercase closed"   lower     "closed the modal, still testing" shown

# --- The MAX_BYTES backstop is reachable and announces itself ----------------
p="$TMP/capped"; mkdir -p "$p"
mkentry "$p" 1 2026-01-01 "A perfectly ordinary entry title here"
mkentry "$p" 2 2026-01-02 "Another perfectly ordinary entry title"
# The fixture emits 116 B uncapped (this hook's lines carry no date), so the ceiling
# has to sit below that to exercise the backstop at all.
out=$(DEVLOG_DIGEST_MAX_BYTES=80 run "$p")
check "cap: truncation is announced" "truncated" "$out"
check_bounded "cap: honours a lowered ceiling" 220 "$out"
check_absent "cap: no marker when under the ceiling" "truncated" "$(run "$p")"

# --- Progress behavior ------------------------------------------------------
p="$TMP/prog"; mkdir -p "$p/.claude/progress"
printf '# Task alpha\n\n## Quick state\nhalf done\n' > "$p/.claude/progress/alpha.md"
out=$(run "$p")
check "progress header"    "Active progress" "$out"
check "progress file name" "alpha.md"        "$out"

p="$TMP/nostate"; mkdir -p "$p/.claude/progress"
printf '# Refactor the parser\n\nprose\n' > "$p/.claude/progress/gamma.md"
check "progress heading fallback" "Refactor the parser" "$(run "$p")"

p="$TMP/many"; mkdir -p "$p/.claude/progress"
for i in 1 2 3 4 5; do printf '# Task %s\n\n## Quick state\nrunning\n' "$i" > "$p/.claude/progress/t$i.md"; sleep 0.01; done
n=$(run "$p" | grep -c '\.md')
[ "$n" -eq 3 ] && { echo "PASS: progress caps at 3"; pass=$((pass+1)); } \
               || { echo "FAIL: progress caps at 3 — got $n"; fail=$((fail+1)); }

p="$TMP/emptyprog"; mkdir -p "$p/.claude/progress"
check_empty "empty progress dir -> silent" "$(run "$p")"

# --- Odd filenames ----------------------------------------------------------
p="$TMP/odd"; mkdir -p "$p/.claude/progress"
mkentry "$p" 1 2026-01-01 "Normal entry"
printf '# spaced\n\n## Quick state\nok\n' > "$p/.claude/progress/with space.md"
printf '# star\n\n## Quick state\nok\n' > "$p/.claude/progress/star*.md"
out=$(run "$p"); rc=$?
[ "$rc" -eq 0 ] && { echo "PASS: odd filenames -> rc=0"; pass=$((pass+1)); } \
                || { echo "FAIL: odd filenames -> rc=$rc"; fail=$((fail+1)); }
check "odd filenames: entry still surfaces" "Normal entry" "$out"

echo "----"
echo "SHELL=$SH PASS=$pass FAIL=$fail"
[ "$fail" -eq 0 ]
