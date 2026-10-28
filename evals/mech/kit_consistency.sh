#!/usr/bin/env bash
# Static consistency of the kit (v2). Run from anywhere; exit 0 = all PASS.
K="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$K"; fail=0
say() { if [ "$2" = 0 ]; then echo "  PASS $1"; else echo "  FAIL $1"; fail=1; fi }

echo "M1 — every json block and template parses"
bad=$(python3 - <<'PY'
import json,re,pathlib
b=0
for p in pathlib.Path('plugins').rglob('*.md'):
    for m in re.finditer(r'```json\n(.*?)```', p.read_text(), re.S):
        try: json.loads(m.group(1))
        except Exception: b+=1
for p in pathlib.Path('plugins/harness/templates').glob('*.json'):
    try: json.loads(p.read_text())
    except Exception: b+=1
print(b)
PY
)
say "json parses (bad=$bad)" $([ "$bad" = 0 ]; echo $?)

echo "M2 — links resolve, marketplace lists exactly the plugins on disk and carries no version"
miss=$(python3 - <<'PY'
import re,pathlib
ANCHORED=re.compile(r'`((?:templates|skills|hooks|bin|scripts)/[\w/\-.]+\.(?:md|py|sh|json))`')
RELLINK=re.compile(r'\]\((\.\./)?([\w/\-.]+\.md)\)')
for root in sorted(pathlib.Path('plugins').iterdir()):
    if not root.is_dir(): continue
    for p in sorted(root.rglob('*.md')):
        if 'templates' in p.parts: continue   # templates hold placeholders for the target repo
        t=p.read_text()
        for x in ANCHORED.finditer(t):
            if not (root/x.group(1)).exists(): print(f"{p}: {x.group(1)}")
        for x in RELLINK.finditer(t):
            if not (p.parent/(x.group(1) or '')/x.group(2)).resolve().exists(): print(f"{p}: {x.group(2)}")
PY
)
[ -n "$miss" ] && echo "$miss" | sed 's/^/    /'
say "no broken internal links" $([ -z "$miss" ]; echo $?)
listed=$(jq -r '.plugins[].source' .claude-plugin/marketplace.json | sed 's|^\./||' | sort)
ondisk=$(for d in plugins/*/; do [ -f "$d.claude-plugin/plugin.json" ] && echo "${d%/}"; done | sort)
[ "$listed" != "$ondisk" ] && diff <(echo "$listed") <(echo "$ondisk") | sed 's/^/    /'
say "marketplace sources = plugin dirs with a manifest" $([ "$listed" = "$ondisk" ]; echo $?)
say "marketplace entries carry no version" $([ "$(jq '[.plugins[]|select(has("version"))]|length' .claude-plugin/marketplace.json)" = 0 ]; echo $?)

echo "M3 — SKILL.md names every template, and every named template exists"
orphan=$(python3 - <<'PY'
import pathlib
root=pathlib.Path('plugins/harness'); skill=(root/'SKILL.md').read_text()
for f in sorted(root.glob('templates/*')):
    if f.relative_to(root).as_posix() not in skill: print(f.relative_to(root))
PY
)
[ -n "$orphan" ] && echo "$orphan" | sed 's/^/    /'
say "no orphan templates" $([ -z "$orphan" ]; echo $?)

echo "M4 — budgets and required sections"
t=plugins/harness/templates/CLAUDE.md
say "root template ≤ 120 lines ($(wc -l < $t))" $([ "$(wc -l < $t)" -le 120 ]; echo $?)
for h in "Commands" "Boundaries" "How we work" "Project knowledge"; do
  say "root template has '## $h'" $(grep -q "^## $h" $t; echo $?)
done
c=plugins/harness/templates/component-CLAUDE.md
say "component template ≤ 60 lines ($(wc -l < $c))" $([ "$(wc -l < $c)" -le 60 ]; echo $?)
say "SKILL.md ≤ 500 lines ($(wc -l < plugins/harness/SKILL.md))" $([ "$(wc -l < plugins/harness/SKILL.md)" -le 500 ]; echo $?)

echo "M5 — nothing shipped pins a Claude Code or model version"
pins=$(grep -rnE "v?2\.1\.[0-9]{3}|Opus [0-9]|Sonnet [0-9]|Haiku [0-9]|claude-(opus|sonnet|haiku)-[0-9]" plugins/harness/SKILL.md plugins/harness/templates/ || true)
[ -n "$pins" ] && echo "$pins" | sed 's/^/    /'
say "no version pins in SKILL.md / templates" $([ -z "$pins" ]; echo $?)

echo "M6 — the settings template carries no dead path rule"
dead=$(python3 - <<'PY'
import json,re
s=json.load(open('plugins/harness/templates/settings.json'))['permissions']
for k in ('allow','ask','deny'):
    for r in s.get(k,[]):
        if re.match(r'(Write|Glob|Grep|NotebookEdit|MultiEdit)\(', r): print(k, r)
PY
)
[ -n "$dead" ] && echo "$dead" | sed 's/^/    /'
say "only Read(path)/Edit(path) path forms" $([ -z "$dead" ]; echo $?)
echo "M7 — shipped instructions describe the present: no dates, versions, journal or history phrasing"
hist=$(grep -nE '20[0-9]{2}-[0-9]{2}-[0-9]{2}|\bv?[0-9]+\.[0-9]+\.[0-9]+\b|devlog|\bno longer\b|\bused to\b|\bpreviously\b|\bearlier version|\bformerly\b|\brenamed\b|\bUpgrading\b|больше не |раньше |по-прежнему' \
  plugins/harness/SKILL.md plugins/harness/templates/* docs/manual.md docs/manual.ru.md README.md README.ru.md || true)
[ -n "$hist" ] && echo "$hist" | sed 's/^/    /'
say "no history or version markers (history lives in CHANGELOG.md)" $([ -z "$hist" ]; echo $?)
exit $fail
