# Dev harness for the claude-code-harness plugin

Это **отдельный проект-репозиторий плагина** `claude-code-harness` — source of truth.
Здесь ведётся разработка kit'а; правь тут, не в копиях.

## Топология (не сломать)

- Этот checkout — **source of truth**. Публичный marketplace-репо.
- `~/.claude/skills/claude-code-harness` — **symlink сюда**; так kit догфудится
  живьём в операторском окружении. Правки здесь видны Claude Code сразу.
- Лаборатория `~/PROJECTS/Harnesses-Claude` — R&D/провенанс; выводы экспериментов
  вносятся сюда как изменения плагина.

## Два разных `.claude`-неймспейса — не путать

- `.claude-plugin/` — манифест **плагина** (`plugin.json`, `marketplace.json`). Это то,
  что публикуется и ставится.
- `.claude/` — dev-harness **этого проекта** (этот файл + `devlog/`). НЕ входит в плагин.

## Release

1. Bump версии синхронно в `.claude-plugin/plugin.json` **и** `.claude-plugin/marketplace.json`.
2. Devlog-запись в `.claude/devlog/`.
3. Commit + push → подписчики получают через `/plugin update`.

## Инвариант

Плагин описывает harness-дизайн для Claude Code 2.x / Opus-class. Model-agnostic
формулировки; не пере-привязывать к конкретной версии модели при апгрейде.
