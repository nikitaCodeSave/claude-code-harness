---
id: 2
date: 2026-07-15
title: "Локали кита: harness на английский, devlog языко-независим"
tags: [refactor, i18n]
status: complete
---

# Локали кита: harness на английский, devlog языко-независим

## Контекст
Кит был локале-сплит: harness-промпты частично по-русски (`/external-audit`,
operator-playbook, harness-evolution, footer SKILL.md), а devlog-машинерия
хардкодила `## Контекст` в извлечении preview — плюс path-рассинхрон `audits/`
(мн.ч. в команде) vs `audit/` (ед.ч. в playbook). Для не-русскоязычного
потребителя shipped-поверхность была частично русской.

## Изменения
Разделено по принципу «промпты плагина → английский, но devlog и артефакты
в проекте → язык пользователя»:
- **harness-промпты → английский** — 4 последних русских файла на shipped-поверхности
  переведены (проза, поведение не менялось). Теперь однородны с агентами/README/project-docs.
- **devlog языко-независим** — `extract_preview` якорится на **первую `## `-секцию**
  вместо литерала `## Контекст`; `## Context`/`## Контекст`/любой язык резолвятся одинаково.
  Записи можно вести на языке пользователя (RU/EN и далее) из одной машинерии; slug и так был
  двуязычным через транслитерацию. Русская сторона devlog (шаблон, комментарии) сохранена.
- **Единая версия** — оба плагина → `1.14.1`; `release.sh` теперь бампит и стейджит оба
  дерева в локстепе (раньше трогал только harness, devlog требовал ручного бампа).
- **Path-фикс** — playbook выровнен на `.claude/audits/<slug>/` (источник истины — команда).

## Затронутые файлы
- `plugins/harness/commands/external-audit.md`, `references/operator-playbook.md`,
  `references/harness-evolution.md`, `SKILL.md` — RU → EN (+ path-фикс в playbook)
- `plugins/devlog/skills/devlog/rebuild-index.py` — языко-независимый `extract_preview`
- `plugins/devlog/skills/devlog/SKILL.md` — заметка про язык записи
- `plugins/devlog/skills/devlog/test_rebuild_index.py` — +2 регресс-теста
- `plugins/harness/scripts/release.sh` — версионирует/стейджит оба плагина
- `CHANGELOG.md`, обе `plugin.json` — bump 1.14.1

## Проверка
- `pytest test_rebuild_index.py` — 7/7 (5 исходных + 2 двуязычных)
- Живой reindex: RU-запись → русский preview, EN-запись → английский preview
- Существующая запись 0001 (RU) извлекается по-прежнему
- `grep` — singular `.claude/audit/` не осталось; 0 залётной кириллицы в harness-промптах

## Related
- #1 — multi-plugin layout, на котором это стоит
