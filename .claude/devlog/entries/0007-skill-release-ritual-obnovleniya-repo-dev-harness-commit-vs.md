---
id: 7
date: 2026-07-16
title: "Skill release: ритуал обновления репо — dev-harness commit vs shipped-release"
tags: [feature, skill, dev-harness, release]
status: complete
---

# Skill release: ритуал обновления репо — dev-harness commit vs shipped-release

## Контекст
За сессию release-ритуал выполнялся вручную дважды (v1.14.3, v1.14.4) одной и той же
последовательностью, с повторяющимися gotcha-граблями (release.sh не стейджит `.claude/devlog/`;
slug только через настоящий slugify; shipped-правка без бампа доставляет консюмерам ничего;
project-doc требует бампа `shipped-by`). Знание было размазано между прозой `.claude/CLAUDE.md` и
рабочей памятью сессии. Оператор попросил один раз качественно спроектировать подход и оформить
его как skill, которым дальше пользоваться всегда. Кейс «adopt-on-proof»: 2 идентичных прогона +
известный класс отказов (release.sh header документирует 3 прошлых сломанных релиза) оправдывают
кодификацию.

## Изменения
- **Новый project-local skill `.claude/skills/release/SKILL.md`** — рунбук поверх существующего
  `plugins/harness/scripts/release.sh` (не переизобретение механики). Во главе — **развилка**:
  shipped-поверхность (`plugins/**`, README, CHANGELOG, marketplace) → релиз с bump+тегом; только
  dev-harness (`.claude/**`, `.gitignore`) → обычный commit+push без тега. Далее два пути с явными
  шагами и зашитыми gotcha. Секция «класс отказов, который снимает ритуал» объясняет why каждого шага.
- **`.gitignore`** — добавлен whitelist `!/.claude/skills/` (репо в whitelist-режиме: `/.claude/*`
  игнорит всё, кроме явно разрешённого; без этой строки новый skill был бы untracked).

Решения дизайна: skill (не command) — pushy-description триггерит на release-интент, а release
многошаговый; project-local (не shipped) — ритуал специфичен для этого репо (два плагина, этот
devlog), не transmittable-знание для консюмеров; язык RU — под конвенцию devlog-скилла.

## Затронутые файлы
- `.claude/skills/release/SKILL.md` — новый рунбук (164 строки)
- `.gitignore` — whitelist `!/.claude/skills/`

## Проверка
- git трекает новый skill (`git check-ignore` → не игнорируется после whitelist-правки).
- Frontmatter валиден (name/description/argument-hint/allowed-tools); тело <500 строк.
- Slug-однострочник из тела скилла копипастится и исполняется (проверен на реальном title).
- Диагностика VS Code «allowed-tools not supported by VS Code agents» — **false positive**: линтер
  валидирует по схеме VS Code-agents, а это Claude Code skill; обе shipped-скилла репо (devlog,
  harness) используют `allowed-tools` и работают. Не правил.
- Landing самого скилла — первый живой прогон Пути A (dev-harness commit: без бампа, без тега).

## Related
- #6, #5 — релизы, ручная последовательность которых стала эмпирической основой рунбука
