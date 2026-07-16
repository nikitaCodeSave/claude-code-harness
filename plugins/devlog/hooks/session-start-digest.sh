#!/usr/bin/env bash
# SessionStart continuity digest (devlog companion plugin).
# Surfaces what the built-ins don't: the project's recent devlog entries (episodic
# "what changed and why") and its active progress journals (in-flight task state).
# Git branch/status/commits are injected natively by Claude Code — not duplicated here.
# Degrades SILENTLY: no .claude/devlog/ and no .claude/progress/ -> no output, exit 0.
# Read-only, no network; POSIX tools + bash 3.2 only (macOS default bash works).
#
# BOUNDED OUTPUT IS THE CORE INVARIANT. stdout lands verbatim in the model's context
# ahead of the operator's first turn, this hook runs in EVERY project including a
# freshly cloned untrusted one, and nothing downstream trims it. The job is a few
# lines of orientation — never a file's worth of anything. Every field is capped on
# the way in and the whole digest is capped on the way out (MAX_BYTES), independently.
set -u

# Whole-digest ceiling, applied to the digest BODY (the announcement line is added on
# top, so real worst-case output is MAX_BYTES + ~90). The per-field caps hold every
# known path far below this, so it is a backstop for the path nobody foresaw.
# Overridable so the tests can exercise it — a guard no test fires is a guard nobody
# should trust.
MAX_BYTES=${DEVLOG_DIGEST_MAX_BYTES:-4096}

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

context=""
append() { context="${context:+$context
}$1"; }

# --- Recent devlog entries (last 3, latest last) ------------------------------
entries_dir=".claude/devlog/entries"
if [ -d "$entries_dir" ]; then
    recent=$(ls "$entries_dir" 2>/dev/null | grep -E '^[0-9]+-.*\.md$' | sort -t- -k1,1n | tail -3)
    if [ -n "$recent" ]; then
        append "Recent devlog (latest last):"
        while IFS= read -r name; do
            f="$entries_dir/$name"
            # Byte caps bound the digest even against a malformed multi-MB line;
            # a cap may tear a trailing multibyte char — cosmetic, kept for portability.
            # Cut the frontmatter out ONCE, then read fields from that text — never from
            # the file. A sed /^---/,/^---/ RANGE cannot do this job: it re-opens on the
            # next '---', so a horizontal rule or setext underline in the body (both
            # idiomatic markdown) starts a second "frontmatter" whose lines forge id and
            # title. Only the fence pair opening on line 1 is frontmatter. The 41q also
            # makes the read bounded: otherwise sed streams the whole file when a field
            # is absent.
            #   line 1: not a fence -> quit; a fence -> drop it, go on
            #   next fence -> end of frontmatter, quit   ·   line 41 -> ceiling, quit
            fm_block=$(sed -n '1{/^---[[:space:]]*$/!q;d;}; /^---[[:space:]]*$/q; 41q; p;' \
                       "$f" 2>/dev/null)
            # Strip CR before the quotes, or a CRLF file leaves s/"$// unable to fire.
            fm() { printf '%s\n' "$fm_block" \
                   | sed -n "/^$1:/{s/^$1:[[:space:]]*//;s/\r\$//;s/^\"//;s/\"\$//;p;q;}" 2>/dev/null; }
            id=$(fm id | head -c 20)
            date=$(fm date | head -c 20)
            title=$(fm title | head -c 160)
            # The date answers "was this yesterday or in March?" — orientation the id
            # alone can't give. It is optional: an entry missing it still surfaces.
            if [ -n "$title" ]; then
                append "  #${id:-?}${date:+ · $date} · $title"
            else
                append "  $name"
            fi
        done <<EOF
$recent
EOF
    fi
fi

# --- Active progress journals (newest first; CLOSED excluded; max 3) ----------
progress_dir=".claude/progress"
if [ -d "$progress_dir" ]; then
    files=$(ls -t "$progress_dir"/*.md 2>/dev/null)
    if [ -n "$files" ]; then
        lines=""
        shown=0
        while IFS= read -r f; do
            [ -f "$f" ] || continue
            [ "$shown" -ge 3 ] && break
            # Prefer the conventional "Quick state" line (line-anchored, so prose that
            # merely mentions it doesn't shadow the marker); fall back to the first heading.
            state=$(grep -m1 -iE '^[#*[:space:]-]*quick state' "$f" 2>/dev/null \
                    | sed -E 's/^[#*[:space:]-]+//' | head -c 200)
            [ -z "$state" ] && state=$(grep -m1 -E '^#' "$f" 2>/dev/null \
                    | sed -E 's/^#+[[:space:]]*//' | head -c 200)
            # A CLOSED task-scoped journal no longer reads as active work — skip it.
            # CLOSED must be the STATUS MARKER, not any occurrence of the letters: a
            # plain *CLOSED* match hid "Migrate CLOSED-account archive to S3" — an
            # ACTIVE task — which is the very loss this digest exists to prevent.
            # Leading edge: not preceded by a word char or '-' (UNCLOSED, NOT-CLOSED stay).
            # Trailing edge: end, or a non-word char (CLOSED. / (CLOSED)), or '-'/'_' plus
            # a NON-lowercase char (CLOSED-2026-07-16, CLOSED_TASK are statuses) — while
            # '-'/'_' plus a lowercase word reads as an identifier (CLOSED-account) and
            # stays visible. Signed residual: a lowercase-suffixed status (CLOSED-shipped)
            # shows as active — the cheap direction, since a closed journal shown is noise
            # while an active one hidden is the continuity loss itself. Convention is bare
            # upper-case CLOSED (docs/workflow.md).
            if printf '%s' "$state" \
               | grep -qE '(^|[^A-Za-z0-9_-])CLOSED($|[^-_A-Za-z0-9]|[-_][^a-z])'; then
                continue
            fi
            lines="${lines:+$lines
}  $(basename "$f")${state:+ — $state}"
            shown=$((shown + 1))
        done <<EOF
$files
EOF
        if [ -n "$lines" ]; then
            append "Active progress:"
            append "$lines"
        fi
    fi
fi

# --- Emit (stdout is added to session context; silent if nothing to say) ------
[ -z "$context" ] && exit 0

# Backstop cap. The per-field caps above bound every known path; this catches what
# they miss, because the failure mode is severe and one-directional — no downstream
# trim exists, and an oversized digest burns the context window before the operator
# types anything. Truncation is announced, never silent: a digest that quietly lost
# its tail would misreport project state, which is worse than one that says it was cut.
if [ "$(printf '%s' "$context" | wc -c)" -gt "$MAX_BYTES" ]; then
    context="$(printf '%s' "$context" | head -c "$MAX_BYTES")
  … [digest truncated at ${MAX_BYTES}B — read .claude/devlog/ and .claude/progress/ directly]"
fi

printf '%s\n' "$context"
exit 0
