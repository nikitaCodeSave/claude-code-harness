#!/usr/bin/env bash
# Регресс-набор для claude-code-harness. Критерии — в criteria.md (объявлены до прогонов).
#
#   ./run.sh mech      только механические тесты (секунды, бесплатно)
#   ./run.sh sessions  четыре сессионных прогона (read-only, ~8 мин, параллельно)
#   ./run.sh all       и то, и другое
#
# Сессионные прогоны read-only (--permission-mode plan) и подключают кит через --add-dir,
# иначе скилл не загружается из чужой рабочей директории.
set -uo pipefail
R="$(cd "$(dirname "$0")" && pwd)"
KIT=/home/nikita/PROJECTS/claude-code-harness
MODE="${1:-all}"

run_mech() {
  echo "== механические =="
  "$R/mech/m1_phase7.sh"; m1=$?
  "$R/mech/m2_kit_consistency.sh"; m2=$?
  [ $m1 -eq 0 ] && [ $m2 -eq 0 ] && echo "механические: PASS" || { echo "механические: FAIL"; return 1; }
}

launch() { # id fixture prompt
  local id="$1" fx="$2" prompt="$3"
  ( cd "$R/fixtures/$fx" && timeout 1200 claude --print --permission-mode plan --add-dir "$KIT" <<<"$prompt" \
       > "$R/results/$id.txt" 2>&1 ) &
}

LEDGER_PROMPT='Set up the long-running build kit (Phase 5) for this project — a sustained multi-session build. Write NOTHING to disk. Output the exact .claude/features.json you would create as one JSON code block, then list which entries are not ready to work and why.'
AUDIT_PROMPT='audit my Claude Code harness. Report findings as usual. At the very end, list the checklist sections you judged not applicable here, one clause each on why.'

run_sessions() {
  echo "== сессионные (параллельно, ~8 мин) =="
  launch s1 s1-csv2json "$LEDGER_PROMPT"
  launch s2 s2-httpping "$AUDIT_PROMPT"
  launch s3 s3-worklog  "$LEDGER_PROMPT"
  launch s4 s4-invoicer "$LEDGER_PROMPT"
  wait
  echo "-- автоматические индикаторы (вердикт всё равно читается глазами по criteria.md) --"
  # S1: вопросы только по неуказанному + priority у всех
  printf "S1 priority у всех: "; python3 - "$R/results/s1.txt" <<'PY'
import json,re,sys
t=open(sys.argv[1]).read(); m=re.search(r'```json\s*\n(.*?)```', t, re.S)
if not m: print("? (JSON обрезан в выводе)"); raise SystemExit
d=json.loads(m.group(1)); p=[f.get("priority") for f in d["features"]]
print("да" if all(v is not None for v in p) else "НЕТ — FAIL")
PY
  printf "S2 §11 признана неприменимой: "; grep -qiE '§11[^.]{0,80}(features\.json|ledger)' "$R/results/s2.txt" && echo да || echo "НЕТ — проверить"
  printf "S2 подсаженные дефекты найдены: 3.5-Sonnet=%s Glob=%s\n" \
    "$(grep -ci '3\.5 sonnet' "$R/results/s2.txt")" "$(grep -c 'Glob(\./\*\*)' "$R/results/s2.txt")"
  printf "S3 owner-вопрос по округлению поднят: "; grep -qiE 'Q[0-9][^"]{0,40}round' "$R/results/s3.txt" && echo да || echo "НЕТ — FAIL (P0-регресс)"
  printf "S4 формат остался owner-вопросом: "; grep -qiE 'Q[0-9][^"]{0,60}(CSV|XLSX|format)' "$R/results/s4.txt" && echo да || echo "НЕТ — проверить"
}

case "$MODE" in
  mech) run_mech ;;
  sessions) run_sessions ;;
  all) run_mech && run_sessions ;;
  *) echo "usage: $0 [mech|sessions|all]"; exit 2 ;;
esac
