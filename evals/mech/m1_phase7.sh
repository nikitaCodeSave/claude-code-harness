#!/usr/bin/env bash
# M1 — проверка Phase 7 ledger-check из bootstrap-checklist Phase 7.
# Ожидание: all.json → "all"+True | partial.json → PARTIAL+False | none.json → PARTIAL+False
# (none.json содержит слово "question" в verify — старый grep дал бы ложный PASS)
cd "$(dirname "$0")/ledgers"
fail=0
check() { # file expect_priority expect_rule
  out=$(python3 -c 'import json,sys;d=json.load(open(sys.argv[1]));p=[f.get("priority") for f in d["features"]];print("all" if p and all(v is not None for v in p) else "PARTIAL/NONE");print(any("owner can answer" in r for r in d.get("rules",[])))' "$1")
  gotp=$(echo "$out" | sed -n 1p); gotr=$(echo "$out" | sed -n 2p)
  if [ "$gotp" = "$2" ] && [ "$gotr" = "$3" ]; then echo "  PASS $1 → $gotp / $gotr";
  else echo "  FAIL $1 → $gotp / $gotr (expected $2 / $3)"; fail=1; fi
  # контроль: что дал бы старый grep
  og=$(grep -c '"priority"' "$1"); oq=$(grep -ci 'question' "$1")
  echo "       (old greps would report priority=$og question=$oq → $([ "$og" -ge 1 ] && [ "$oq" -ge 1 ] && echo "GREEN" || echo "red"))"
}
echo "M1 — Phase 7 ledger check"
check all.json     "all"          "True"
check partial.json "PARTIAL/NONE" "False"
check none.json    "PARTIAL/NONE" "False"
exit $fail
