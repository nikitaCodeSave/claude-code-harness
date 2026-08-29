#!/usr/bin/env bash
# M2-M5 — статическая согласованность кита. Запускать из любого места.
K="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$K"; fail=0
say() { if [ "$2" = 0 ]; then echo "  PASS $1"; else echo "  FAIL $1"; fail=1; fi }

echo "M2 — JSON-примеры в plugins/**"
bad=$(python3 - <<'PY'
import json,re,pathlib
b=0
for p in pathlib.Path('plugins').rglob('*.md'):
    for m in re.finditer(r'```json\n(.*?)```', p.read_text(), re.S):
        try: json.loads(m.group(1))
        except Exception: b+=1
print(b)
PY
)
say "все json-блоки парсятся (bad=$bad)" $([ "$bad" = 0 ]; echo $?)

# M3 (authority ledger) и M4 (bounded spike) удалены 2026-08-29: инварианты, которые они
# сторожили, ушли вместе с Phase 5 в v1.23.0 — тесты остались орфанами и держали набор
# красным четыре релиза. Восстанавливать ретайренную прозу ради зелёного теста нельзя.

echo "M5 — ссылки и версии"
miss=$(python3 - <<'PY'
import re,pathlib
root=pathlib.Path('plugins/harness'); m=0
for p in root.rglob('*.md'):
    t=p.read_text()
    for x in re.finditer(r'`(references/[\w/\-.]+\.md)`', t):
        if not (root/x.group(1)).exists(): m+=1
    for x in re.finditer(r'\]\((\.\./)?([\w/\-.]+\.md)\)', t):
        if not (p.parent/(x.group(1) or '')/x.group(2)).resolve().exists(): m+=1
print(m)
PY
)
say "битых внутренних ссылок нет (n=$miss)" $([ "$miss" = 0 ]; echo $?)
v1=$(jq -r .version plugins/harness/.claude-plugin/plugin.json); v2=$(jq -r .version plugins/devlog/.claude-plugin/plugin.json)
say "версии в локстепе ($v1 = $v2)" $([ "$v1" = "$v2" ]; echo $?)
exit $fail
