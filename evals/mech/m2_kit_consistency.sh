#!/usr/bin/env bash
# M2-M6 — статическая согласованность кита. Запускать из любого места.
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
# Путь якорится на top-level каталог плагина. Без якоря примеры про чужой проект
# (`index.json`, `path/to/file.py`) читаются как ссылки внутрь кита и глушат проверку.
ANCHORED=re.compile(r'`((?:references|skills|hooks|bin|scripts)/[\w/\-.]+\.(?:md|py|sh|json))`')
RELLINK=re.compile(r'\]\((\.\./)?([\w/\-.]+\.md)\)')
for plugin in ('plugins/harness','plugins/devlog'):
    root=pathlib.Path(plugin)
    for p in sorted(root.rglob('*.md')):
        t=p.read_text()
        for x in ANCHORED.finditer(t):
            if not (root/x.group(1)).exists(): print(f"{p}: {x.group(1)}")
        for x in RELLINK.finditer(t):
            if not (p.parent/(x.group(1) or '')/x.group(2)).resolve().exists():
                print(f"{p}: {x.group(2)}")
PY
)
if [ -n "$miss" ]; then echo "$miss" | sed 's/^/    /'; fi
say "битых внутренних ссылок нет" $([ -z "$miss" ]; echo $?)
v1=$(jq -r .version plugins/harness/.claude-plugin/plugin.json); v2=$(jq -r .version plugins/devlog/.claude-plugin/plugin.json)
say "версии в локстепе ($v1 = $v2)" $([ "$v1" = "$v2" ]; echo $?)

# M6 — обратное направление к M5. M5 держит «карта не врёт»: названный файл существует.
# M6 держит «карта полна»: reference, которого нет в карте SKILL.md, модель никогда не
# загрузит — он едет мёртвым весом в каждую установку. Каталог в карте покрывает свои файлы.
echo "M6 — карта SKILL.md покрывает references/"
orphan=$(python3 - <<'PY'
import pathlib
root=pathlib.Path('plugins/harness'); skill=(root/'SKILL.md').read_text()
for f in sorted(root.glob('references/**/*.md')):
    rel=f.relative_to(root).as_posix()
    # Предок засчитывается только глубже самого references/: подстрока `references/`
    # есть в каждом упоминании карты, и как кандидат она сделала бы проверку вырожденной.
    cands=[rel]; d=pathlib.PurePosixPath(rel).parent
    while d.as_posix() not in ('.','references'):
        cands.append(d.as_posix()+'/'); d=d.parent
    if not any(c in skill for c in cands): print(rel)
PY
)
if [ -n "$orphan" ]; then echo "$orphan" | sed 's/^/    /'; fi
say "каждый reference назван в карте" $([ -z "$orphan" ]; echo $?)
exit $fail
