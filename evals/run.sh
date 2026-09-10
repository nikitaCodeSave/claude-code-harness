#!/usr/bin/env bash
# Регресс-набор для claude-code-harness. Критерии — в criteria.md (объявлены до прогонов).
#
#   ./run.sh mech      только механические тесты (секунды, бесплатно)
#   ./run.sh sessions  один сессионный прогон (read-only, ~4 мин)
#   ./run.sh all       и то, и другое
#
# Сессионный прогон read-only (--permission-mode plan) и подключает кит через --add-dir,
# иначе скилл не загружается из чужой рабочей директории.
#
# 2026-09-10: набор сокращён с шести тестов до двух. M1 и три сессионных прогона (s1, s3, s4)
# целились в Phase 5 / features.json — механизм, ретайренный в v1.23.0; M3 и M4 удалили по той
# же причине ещё 2026-08-29, но чистку не довели. M1 вдобавок не читал plugins/ вовсе: и
# фикстуры, и оракул лежали внутри evals/, так что упасть от правки кита он не мог. Три из
# четырёх прогонов последнего запуска сами открыли это в своём выводе.
set -uo pipefail
R="$(cd "$(dirname "$0")" && pwd)"
KIT="$(dirname "$R")"
MODE="${1:-all}"

run_mech() {
  echo "== механические =="
  "$R/mech/m2_kit_consistency.sh"; m2=$?
  [ $m2 -eq 0 ] && echo "механические: PASS" || { echo "механические: FAIL"; return 1; }
}

launch() { # id fixture prompt
  local id="$1" fx="$2" prompt="$3"
  ( cd "$R/fixtures/$fx" && timeout 1200 claude --print --permission-mode plan --add-dir "$KIT" <<<"$prompt" \
       > "$R/results/$id.txt" 2>&1 ) &
}

AUDIT_PROMPT='audit my Claude Code harness. Report findings as usual. At the very end, list the checklist sections you judged not applicable here, one clause each on why.'

run_sessions() {
  echo "== сессионный прогон (~4 мин) =="
  launch s2 s2-httpping "$AUDIT_PROMPT"
  wait
  echo "-- автоматические индикаторы (вердикт всё равно читается глазами по criteria.md) --"
  # Индикаторы — грубые: 2026-09-10 греп на owner-вопрос выдал FAIL на прогоне, который
  # поднял вопрос в другом формате. Красный индикатор — повод открыть транскрипт, не вердикт.
  printf "S2 подсаженные дефекты найдены: 3.5-Sonnet=%s Glob=%s\n" \
    "$(grep -ci '3\.5 sonnet' "$R/results/s2.txt")" "$(grep -c 'Glob(\./\*\*)' "$R/results/s2.txt")"
}

case "$MODE" in
  mech) run_mech ;;
  sessions) run_sessions ;;
  all) run_mech && run_sessions ;;
  *) echo "usage: $0 [mech|sessions|all]"; exit 2 ;;
esac
