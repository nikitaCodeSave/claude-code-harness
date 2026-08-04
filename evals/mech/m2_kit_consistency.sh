#!/usr/bin/env bash
# M2-M5 — статическая согласованность кита. Запускать из любого места.
K=/home/nikita/PROJECTS/claude-code-harness
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

echo "M3 — authority: rules и проза не противоречат"
r=$(grep -c "never decide it yourself" plugins/harness/references/bootstrap-checklist.md)
a=$(grep -c "never the authority" plugins/harness/references/bootstrap-checklist.md)
bad_phrase=$(grep -c "readings that$" plugins/harness/references/bootstrap-checklist.md 2>/dev/null || echo 0)
say "rules несёт 'never decide it yourself' (n=$r)" $([ "$r" -ge 1 ]; echo $?)
say "проза несёт 'never the authority' (n=$a)" $([ "$a" -ge 1 ]; echo $?)
say "нет старой формулировки 'you settle yourself and say why'" $(! grep -q "you settle yourself and say why" plugins/harness/references/bootstrap-checklist.md; echo $?)

echo "M4 — bounded spike сохраняет ограничение"
# фраза переносится по строкам — ищем по нормализованному тексту, не построчным grep
say "'rather than shipping the behavior' на месте" $(tr '\n' ' ' < plugins/harness/references/bootstrap-checklist.md | tr -s ' ' | grep -q "rather than shipping the behavior"; echo $?)
say "'Bounded is a condition, not a label' на месте" $(tr '\n' ' ' < plugins/harness/references/bootstrap-checklist.md | tr -s ' ' | grep -q "Bounded is a condition, not a label"; echo $?)

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
