# Демо-стенд: плагин глазами нового пользователя

Как запустить сессию с **чистой конфигурацией** и поставить плагин **только для одного
проекта** — чтобы пройти consumer-journey так, как его проходит подписчик, а не автор.

> **Адресат — мейнтейнер, не пользователь.** Рецепт ниже ставит плагин из **локального
> чекаута** (`~/PROJECTS/claude-code-harness`), чтобы проверять ещё не выпущенные правки, а
> грабли — про симлинк-догфуд, итерацию без bump и `plugin details` вне стенда. Пользователю,
> который хочет безопасно попробовать кит, нужен README → «Try it in a throwaway config
> first»: та же пара `CLAUDE_CONFIG_DIR` + `--scope project`, но источник — GitHub, и без
> авторского шума.

Проверено на Claude Code 2.1.211 (Linux). Флаги CLI меняются — при расхождении верить
`claude plugin install --help`, не этому файлу.

## Зачем это нужно

В операторском окружении kit догфудится симлинком `~/.claude/skills/claude-code-harness`
(см. CLAUDE.md → Топология). Это удобно для разработки и **бесполезно для проверки
consumer-journey**: автор видит правки мгновенно, подписчик — только то, что приехало
через marketplace. Стенд отсекает симлинк вместе со всей остальной глобалкой.

## Два независимых механизма — не путать

| Задача | Механизм | Что делает |
|---|---|---|
| Чистый лист, без глобальных настроек | `CLAUDE_CONFIG_DIR` | Переносит **весь** `~/.claude`: глобальный CLAUDE.md, settings, skills, agents, hooks, plugins, авто-память, историю проектов |
| Плагин только для этого проекта | `--scope project` | Пишет `enabledPlugins` + marketplace в `.claude/settings.json` проекта; user settings не трогает |

Они ортогональны. `--scope project` работает и в обычном конфиге, но глобальный
`~/.claude/CLAUDE.md` при этом всё равно подгрузится — **никакой проектный файл его не
отключает**. Для роли нового пользователя нужны оба.

Локальные settings задачу изоляции не решают в принципе: иерархия
`settings.local.json` → `settings.json` → `~/.claude/settings.json` **мержится**, а
`permissions.allow/deny` именно объединяются. `--setting-sources project,local` отсекает
только settings-файлы, но не CLAUDE.md.

## Рецепт

```bash
export CLAUDE_CONFIG_DIR=~/claude-fresh
mkdir -p "$CLAUDE_CONFIG_DIR"
cp ~/.claude/.credentials.json "$CLAUDE_CONFIG_DIR/"   # иначе потребуется перелогин

mkdir -p ~/demo-project && cd ~/demo-project && git init -q

claude plugin marketplace add ~/PROJECTS/claude-code-harness --scope project
claude plugin install claude-code-harness --scope project
claude plugin install devlog --scope project

claude
```

Креды копируются потому, что на Linux они лежат файлом **внутри** `~/.claude/` и уезжают
вместе с конфигом. Это единственный обход перелогина; OAuth-сессия подхватывается как есть.

`--scope project` пишет в `.claude/settings.json` — файл git-tracked, то есть предназначен
для команды. Для личной установки, не попадающей в git, — `--scope local`
(`.claude/settings.local.json`).

## Проверка, что стенд собран верно

```bash
claude plugin list                       # оба плагина, Scope: project, Status: enabled
claude plugin details claude-code-harness # инвентарь компонентов + прогноз токенов
```

В самой сессии — спросить полный список skills. Должны быть
`claude-code-harness:claude-code-harness`, `claude-code-harness:external-audit`,
`devlog:devlog`, и **не** должно быть личных глобальных инструкций.

Проверять изоляцию только негативной пробой нельзя: «глобалки не видно» ничего не значит,
если проба в принципе не умеет её детектировать. Нужен контроль — тот же вопрос без
`CLAUDE_CONFIG_DIR` обязан дать противоположный ответ.

## Грабли

- **Имя плагина — `claude-code-harness`, не `harness`.** `harness` — только имя папки в
  `plugins/`; `claude plugin install harness` падает с «not found in any configured
  marketplace». На это же напорется пользователь, читающий структуру репо.
- **Skills приходят под namespace плагина** — `claude-code-harness:claude-code-harness`,
  `devlog:devlog`. Поиск по голому имени даст ложный отрицательный результат.
- **Правки в репо не видны стенду сразу.** Симлинк-догфуд здесь отключён: плагин приезжает
  версионированной **копией** в `$CLAUDE_CONFIG_DIR/plugins/cache/`. Источник при
  marketplace-по-пути — рабочая директория, коммит не нужен (проверено: незакоммиченная
  правка доезжает).
- **`plugin update` гейтится версией, а не содержимым.** Без bump в
  `plugins/harness/.claude-plugin/plugin.json` он отвечает «already at the latest version» и
  правку не забирает. Для итерации по правкам **без** bump — переустановка:
  ```bash
  claude plugin uninstall claude-code-harness@claude-code-harness --scope project
  claude plugin install claude-code-harness --scope project
  ```
- **`update`/`uninstall` требуют полный id и явный scope.** `claude plugin update
  claude-code-harness` падает с «not found», хотя `plugin list` показывает плагин
  установленным: нужен `claude-code-harness@claude-code-harness` **и** `--scope project`
  (по умолчанию команда смотрит в user scope). У `install` таких требований нет — там
  достаточно голого имени.
- **Изменения применяются после перезапуска сессии** — CLI об этом честно предупреждает
  («Restart to apply changes»).
- **`plugin details` вне стенда врёт про инвентарь.** В операторском окружении симлинк-догфуд
  выигрывает разрешение, и команда отвечает про него: `Source: claude-code-harness@skills-dir`,
  `Skills (1) external-audit` — головного скилла в списке нет, потому что корневой `SKILL.md`
  там уже загружен отдельно, как личный скилл. Читается как «плагин не везёт головной скилл»
  и провоцирует охоту на несуществующий баг упаковки. Внутри стенда та же команда даёт
  `Source: claude-code-harness@claude-code-harness`, `Skills (2) claude-code-harness,
  external-audit`. **Инвентарь смотреть только со стенда.**
- **Стенд — untrusted workspace.** Свежий `CLAUDE_CONFIG_DIR` не знает демо-проект: интерактивный
  `claude` спросит про доверие (принять и идти дальше), а `--print` молча **проигнорирует
  `permissions.allow`** из `.claude/settings.json` («has not been trusted»). Если стенд гоняется
  headless — allow-лист передавать флагом `--allowedTools`, а промпт подавать через stdin
  (`--allowedTools` вариадический и съедает позиционный аргумент).

## Чего не использовать

- `--safe-mode` / `--bare` — отключают кастомизацию **вместе с плагинами**; тестировать
  становится нечего.
- `--plugin-dir <path>` — грузит плагин из папки на одну сессию. Годится для быстрой
  итерации по правкам, но обходит marketplace, то есть не проверяет путь, которым плагин
  получает реальный пользователь.

## Уборка

```bash
rm -rf ~/claude-fresh ~/demo-project
```

Глобальный `~/.claude` не затрагивается: стенд живёт целиком в `CLAUDE_CONFIG_DIR` и в
`.claude/settings.json` демо-проекта.
