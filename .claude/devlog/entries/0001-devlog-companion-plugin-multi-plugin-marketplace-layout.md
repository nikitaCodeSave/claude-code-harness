---
id: 1
date: 2026-07-15
title: "Devlog companion plugin + multi-plugin marketplace layout"
tags: [feature, plugin]
status: complete
---

# Devlog companion plugin + multi-plugin marketplace layout

## Контекст
Kit ссылался на devlog как на рекомендованный continuity-компонент (10 упоминаний
в references/README), но сама runnable-машинерия (`/devlog` skill + `rebuild-index.py`)
жила только в операторском глобальном `~/.claude/skills/devlog/`. Для публичного
установщика плагина это dangling reference: kit советует «веди devlog», а инструмента
в поставке нет. Цель — закрыть зазор, сохранив глобальный devlog-skill единственным
источником истины (без второй копии, которая дрейфует).

## Изменения
Выбран вариант B: devlog опубликован как **отдельный плагин в том же marketplace**,
а не вложен в kit и не оставлен только глобальным.

- **Репозиторий переведён в идиоматичную multi-plugin раскладку**: harness-плагин
  переехал из корня в `plugins/harness/`; marketplace.json остался в корне и теперь
  перечисляет два плагина с явными `./plugins/<name>` source (shorthand
  `metadata.pluginRoot` **отклоняется** `claude plugin validate` — проверено живьём,
  поэтому пути прописаны полностью). Install-команда не изменилась — резолвится по `name`.
- **Новый `devlog`-плагин** (`plugins/devlog/`): `/devlog:devlog` skill (адаптирован из
  глобального канона) + `bin/devlog-reindex` — обёртка на PATH, зовущая
  `skills/devlog/rebuild-index.py` относительно себя. Механизм найден эмпирически:
  `$CLAUDE_PLUGIN_ROOT` в Bash-окружении тула **пуст** (доки скоупят его к hook/MCP),
  а `bin/` реально попадает в PATH — поэтому self-resolving wrapper, а не переменная.
- **Побочки переезда починены**: `scripts/release.sh` (пути к plugin.json/references/
  git-add), `.gitignore` whitelist (был про старую корневую раскладку → игнорировал
  `plugins/`), догфуд-симлинк `~/.claude/skills/claude-code-harness` re-point на
  `plugins/harness/`, comment-заголовок `rebuild-index.py`.
- Companion-pointer добавлен в `bootstrap-checklist.md` + README, чтобы рекомендация
  devlog вела на `/plugin install devlog@claude-code-harness`.

## Затронутые файлы
- `plugins/devlog/**` — новый плагин (manifest, SKILL.md, bin/devlog-reindex, скрипт+тесты)
- `plugins/harness/**` — переезд всего kit'а (git mv, история сохранена)
- `.claude-plugin/marketplace.json` — два плагина, explicit sources
- `plugins/harness/scripts/release.sh` — пути под новую раскладку
- `.gitignore` — whitelist под `plugins/`
- `README.md` · `CHANGELOG.md` · `.claude/CLAUDE.md` — топология + install обоих плагинов

## Проверка
- `claude plugin validate` (2.1.210): marketplace + оба плагина — passed.
- `--plugin-dir plugins/devlog` → skill загружается как `/devlog:devlog`.
- `bin/devlog-reindex` e2e: обёртка находит скрипт и регенерирует index/tldr (корректно
  отвергает невалидный slug — оракул способен упасть).
- `pytest test_rebuild_index.py` — 5/5.
- Re-point симлинка: догфуд harness резолвится как `claude-code-harness@skills-dir 1.14.0`.
- Публичный путь: `marketplace add` локального репо — успешно; после теста снят, env восстановлен.

## Related
- Версии: harness-плагин 1.13.0 → 1.14.0; devlog-плагин 1.0.0 (новый).
