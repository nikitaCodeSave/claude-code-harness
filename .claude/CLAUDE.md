# Dev harness for the claude-code-harness plugin

Это **отдельный проект-репозиторий плагина** `claude-code-harness` — source of truth.
Здесь ведётся разработка kit'а; правь тут, не в копиях.

## Топология (не сломать)

- Этот checkout — **source of truth**. Публичный marketplace-репо.
- `~/.claude/skills/claude-code-harness` — **symlink на `plugins/harness/`**; так kit
  догфудится живьём в операторском окружении. Правки здесь видны Claude Code сразу.
  (Симлинк указывает на подпапку плагина, а не на корень репо — топология marketplace.)
- Лаборатория `~/PROJECTS/Harnesses-Claude` — R&D/провенанс; выводы экспериментов
  вносятся сюда как изменения плагина.

## Два разных `.claude`-неймспейса — не путать

- `.claude-plugin/marketplace.json` (корень) — **каталог marketplace**; манифест
  каждого плагина — `plugins/<name>/.claude-plugin/plugin.json`. Это то, что публикуется.
- Плагинов **два**: `plugins/harness/` (kit) и `plugins/devlog/` (continuity-компаньон;
  автоматизация devlog'а, на которую kit ссылается). Раскладка — как в официальном
  multi-plugin walkthrough; `source` в marketplace.json — явные `./plugins/<name>`.
- `.claude/` — dev-harness **этого репо** (этот файл + `devlog/`). НЕ входит в плагины.

## Release

Ритуал целиком — в скилле `release` (развилка «нужен ли тег», bump обоих `plugin.json`
в локстепе, `scripts/release.sh`, devlog, commit/tag/push, верификация синка с origin).

## Инвариант

Плагин описывает harness-дизайн для Claude Code 2.x / Opus-class. Model-agnostic
формулировки; не пере-привязывать к конкретной версии модели при апгрейде.
