---
id: 15
date: 2026-07-16
title: "Детект-гейты читают активный config dir, не хардкод ~/.claude"
tags: [harness, portability, silent-wrong]
status: complete
---

# Детект-гейты читают активный config dir, не хардкод `~/.claude`

## Контекст
Kit хардкодил `~/.claude/` в **исполняемых** проверках. Claude Code переносит весь конфиг через
`CLAUDE_CONFIG_DIR` (демо-стенды, контейнеры, CI) — и под переопределением гейты читали
**операторский** профиль вместо активного, делая вывод о чужом окружении. Класс silent-wrong:
ошибки нет, вывод правдоподобен и неверен. Два наблюдённых проявления на чистом стенде
(CC 2.1.211, 2026-07-16): devlog detect-gate увидел операторские симлинки → «носитель уже есть»
→ не предложил компаньон; Phase 2b baseline detect увидел операторский `~/.claude/CLAUDE.md` →
«baseline уже есть» → не предложил. Ирония: `external-audit.md` сам предписывал «do not
hardcode `~/.claude`» — и хардкодил его строкой выше как fallback.

## Изменения
Форма фикса — **правило, а не команда**: «Resolve the active config dir first —
`CLAUDE_CONFIG_DIR` if set and non-empty, else `<home>/.claude`; resolve it with whatever your
shell supports», дальше резолвнутый **литерал** идёт в Read/Glob. Однострочник в чек-листе
непереносим по двум независимым причинам, каждой достаточно: `Read`/`Glob` не разворачивают
`$VAR`, а на Windows без Git Bash шелл — PowerShell, где `${VAR:-default}` не синтаксис.
Bash-форма (`echo "${CLAUDE_CONFIG_DIR:-$(echo ~)/.claude}"` — тильда резолвится через passwd
даже при unset `HOME`) осталась ориентиром в скобках и прямой подстановкой в Phase 0
bash-блоке. Отсутствующий каталог — валидное «слоя нет», не ошибка.

Правленые гейты (5 файлов): bootstrap Phase 0 (`ls` профиля), devlog-companion detect
(hooks + skills), Phase 2b baseline detect и путь бэкапа guarded merge, audit §2
(дубли/симлинк) и §4 (стамп глобальной копии), ROLE_DIR-fallback `/external-audit`.
Описательная проза (layer maps, provenance, maintainer-ритуалы) сохранила литеральный дефолт:
граница — «строка, по которой агент исполняет проверку → правило; строка, объясняющая
устройство → литерал». Реклассифицировано против таблицы спеки: `practice-baseline.md:6`
(provenance) и `SKILL.md:188` (maintenance-ритуал мейнтейнера) — оставлены.

## Верификация
Bash-механика прогнана: unset `HOME` → `/home/<user>/.claude` (passwd-фолбэк), set-but-empty
переменная → дефолт (`:-`), пробелы/trailing slash закрыты кавычками/POSIX. Статическая
приёмка Windows-ветки: в правленых строках нет обязывающего bash — только правило + ориентир.
Fresh-context refuter (`code-refuter`, `.claude/audits/config-dir-portability/`): **stands**,
0 critical/major; needle-контролем по бинарнику подтвердил, что CC сам обрабатывает переменную
как `process.env.CLAUDE_CONFIG_DIR || homedir()` с `trim()` — формулировка «set and non-empty»
совпадает с хостом; devlog-плагин project-relative, исполняемых `~/.claude`-проверок нет.

Headless A/B — **обе ветки подтверждены на живом стеке**. Контроль (без переменной): гейт
резолвнул `/home/nikita/.claude`, вердикт «carrier present» (skills/devlog среди 6 скиллов) —
регресса основного пути нет. Сценарий 4 (переменная → пустая фикстура, операторский `~/.claude`
с симлинками): агент резолвнул именно фикстуру, инспектировал пути внутри неё и отдал «absent»
как валидное «no carrier» — противоположно контролю. Расхождение сред реально наблюдаемо:
старая формулировка на той же машине дала бы ложный «present» (чужой профиль) — суть бага.
Примечательная грабля: фикстуре нужны живые креды (`CLAUDE_CONFIG_DIR` без них = «Not logged
in», фолбэка нет; `--settings env`-инжект подхватывается самим CC — не обход), а
auto-классификатор автономный вынос кредов запретил (и `cp`, и symlink) — плечо 4 запускал
оператор руками; копия кредов удалена по завершении серии. Windows-ветка исполнением не
проверялась (Linux-машина) — её приёмка статическая, как и заложено в спеке.
