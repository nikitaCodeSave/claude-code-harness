#!/usr/bin/env bash
# Regression suite for the harness kit (v2). Criteria — criteria.md (declared before the runs).
#
#   ./run.sh mech      static checks (seconds, free)
#   ./run.sh sessions  three headless runs A/B/C (~10 min, uses the subscription)
#   ./run.sh all
set -uo pipefail
R="$(cd "$(dirname "$0")" && pwd)"
KIT="$(dirname "$R")"
MODE="${1:-all}"
MODEL="${KIT_EVAL_MODEL:-opus}"
ONLY="${KIT_SESSIONS:-a1 b1 c1}"   # subset, e.g. KIT_SESSIONS="a1 b1"

run_mech() {
  echo "== mechanical =="
  "$R/mech/kit_consistency.sh" && echo "mechanical: PASS" || { echo "mechanical: FAIL"; return 1; }
}

session() { # id fixture permission-mode prompt
  local id="$1" fx="$2" mode="$3" prompt="$4" w; w="$(mktemp -d)/ws"
  mkdir -p "$w"; [ -d "$R/fixtures/$fx" ] && cp -r "$R/fixtures/$fx/." "$w/"
  ( cd "$w" && git init -q && git add -A && git -c user.name=eval -c user.email=eval@x commit -qm base --allow-empty \
    && timeout 1800 claude -p --model "$MODEL" --permission-mode "$mode" --setting-sources project,local \
         --settings '{"permissions":{"allow":["Bash","Skill","Edit(./.claude/**)"]}}' --plugin-dir "$KIT/plugins/harness" <<<"$prompt" \
         > "$R/results/$id.txt" 2>&1 )
  echo "$w" > "$R/results/$id.ws"
}

total=0; fails=0
check() { # id label cond
  total=$((total + 1))
  if eval "$3"; then echo "  PASS $1 $2"; else echo "  FAIL $1 $2"; fails=$((fails + 1)); fi
}

run_sessions() {
  mkdir -p "$R/results"
  echo "== sessions (~10 min): ${ONLY} =="
  # a scenario left out of KIT_SESSIONS is neither run nor checked: its .ws is missing or stale
  ran() { [[ " $ONLY " == *" $1 "* ]]; }
  ran a1 || ran b1 || ran c1 || { echo "sessions: KIT_SESSIONS names none of a1 b1 c1"; return 2; }
  ran a1 && session a1 greenfield bypassPermissions "set up Claude Code harness in this project. It will be a large project built over several months: an HTTP API, a background worker and a web frontend, Python and TypeScript. Nothing exists yet. I will not be around to answer questions: record them as open and proceed." &
  ran b1 && session b1 monorepo bypassPermissions "set up Claude Code harness in this project. I will not be around to answer questions: record them as open and proceed." &
  ran c1 && session c1 s2-httpping plan "audit my Claude Code harness" &
  wait
  local a b; a=$(cat "$R/results/a1.ws" 2>/dev/null); b=$(cat "$R/results/b1.ws" 2>/dev/null)
  heads() { for h in Commands Boundaries "How we work" "Project knowledge"; do grep -q "^## $h" "$1/CLAUDE.md" || return 1; done; }
  nomachinery() { ! ls -d "$1"/.claude/{agents,hooks,skills,commands,docs} >/dev/null 2>&1; }
  settings_ok() { python3 -c "import json,sys;d=json.load(open('$1/.claude/settings.json'))['permissions'];sys.exit(0 if d.get('deny') else 1)" 2>/dev/null; }
  if ran a1; then
    echo "-- A: new large project"
    check A1 "root CLAUDE.md with four sections, ≤120 lines" "[ -f $a/CLAUDE.md ] && heads $a && [ \$(wc -l < $a/CLAUDE.md) -le 120 ]"
    check A2 "unknown commands labelled TBD" "grep -qi 'TBD' $a/CLAUDE.md"
    check A3 "settings parse with a deny list" "settings_ok $a"
    check A4 "no component files, no machinery" "[ -z \"\$(find $a -mindepth 2 -name CLAUDE.md -not -path '*/.claude/*')\" ] && nomachinery $a"
    check A5 "hand-over names setup and wayfinder" "grep -q 'setup-matt-pocock-skills' $R/results/a1.txt && grep -q 'wayfinder' $R/results/a1.txt"
  fi
  if ran b1; then
    echo "-- B: existing multi-component"
    check B1 "root CLAUDE.md with four sections, ≤120 lines" "[ -f $b/CLAUDE.md ] && heads $b && [ \$(wc -l < $b/CLAUDE.md) -le 120 ]"
    check B2 "no directory tree in any CLAUDE.md" "! grep -rlE '├──|└──' --include=CLAUDE.md $b >/dev/null"
    check B3 "a component CLAUDE.md carries its test command" "grep -rlE 'pytest|node --test' $b/services $b/web --include=CLAUDE.md >/dev/null 2>&1"
    check B4 "ledger prohibition captured" "grep -rqE 'ledger\.post' --include=CLAUDE.md $b || grep -rqsi 'ledger' $b/.claude/rules"
    check B5 "existing decision log adopted, not copied" "grep -q 'docs/decisions.md' $b/CLAUDE.md && ! grep -rliE 'cents|retr' $b/docs/adr 2>/dev/null | grep -q ."
    check B6 "contract named in a CLAUDE.md" "grep -rlq 'order.schema.json' --include=CLAUDE.md $b"
    check B7 "settings parse with a deny list; no machinery" "settings_ok $b && nomachinery $b"
    check B8 "nested AGENTS.md bridged" "grep -q '@AGENTS.md' $b/web/CLAUDE.md 2>/dev/null"
  fi
  if ran c1; then
    echo "-- C: existing harness with planted defects (read the transcript for the verdict)"
    check C1 "stale model pin reported" "grep -qiE '3\.5[ -]?sonnet' $R/results/c1.txt"
    check C2 "dead Glob(./**) rule reported" "grep -q 'Glob(./\*\*)' $R/results/c1.txt"
    check C3 "nothing edited" "[ -z \"\$(cd \$(cat $R/results/c1.ws) && git status --porcelain)\" ]"
  fi
  # the exit code reports the checks, so "exit 0" can't stand in for a run with a FAIL
  echo "sessions: $([ "$fails" -eq 0 ] && echo PASS || echo FAIL) ($((total - fails))/$total)"
  [ "$fails" -eq 0 ]
}

case "$MODE" in
  mech) run_mech ;;
  sessions) run_sessions ;;
  all) run_mech && run_sessions ;;
  *) echo "usage: $0 [mech|sessions|all]"; exit 2 ;;
esac
