# Dev harness for the claude-code-harness plugin

@../AGENTS.md

Это **отдельный проект-репозиторий плагина** `harness` (маркетплейс `claude-code-harness`) — source of truth.
Здесь ведётся разработка kit'а; правь тут, не в копиях. Операционный слой (команды,
границы, неочевидные конвенции) живёт в корневом `AGENTS.md` — один источник для агентов
любого вендора, здесь подключён импортом. Ниже — только то, что специфично для мейнтейнера.

## Топология (не сломать)

- Этот checkout — **source of truth**. Публичный marketplace-репо.
- `~/.claude/skills/harness` — **symlink на `plugins/harness/`**; так kit
  догфудится живьём в операторском окружении. Правки здесь видны Claude Code сразу.
  (Симлинк указывает на подпапку плагина, а не на корень репо — топология marketplace.)
- Лаборатория `~/PROJECTS/Harnesses-Claude` — R&D/провенанс; выводы экспериментов
  вносятся сюда как изменения плагина.

## Два разных `.claude`-неймспейса — не путать

- `.claude-plugin/marketplace.json` (корень) — **каталог marketplace**; манифест
  каждого плагина — `plugins/<name>/.claude-plugin/plugin.json`. Это то, что публикуется.
- Плагин **один**: `plugins/harness/` (kit). Раскладка — как в официальном
  multi-plugin walkthrough; `source` в marketplace.json — явный `./plugins/harness`.
- `.claude/` — dev-harness **этого репо** (этот файл, скилл `release`, замороженные `devlog/` и
  `audits/`). НЕ входит в плагин.

## Release

Ритуал целиком — в скилле `release` (развилка «нужен ли тег», bump `plugin.json`,
CHANGELOG, `scripts/release.sh`, commit/tag/push, верификация синка с origin).

## Инвариант

Плагин ставит в проект измеренный минимум harness'а: один скилл и три шаблона; исследование и
версионные факты о Claude Code живут в лаборатории (`native-capabilities.md`). Model-agnostic
формулировки; не пере-привязывать к конкретной версии модели при апгрейде.
