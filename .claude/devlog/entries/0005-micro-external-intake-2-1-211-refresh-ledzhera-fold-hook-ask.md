---
id: 5
date: 2026-07-16
title: "Micro external-intake 2.1.211: рефреш леджера + фолд hook-ask-floors"
tags: [canon, refresh-ledger, native-capabilities]
status: complete
---

# Micro external-intake 2.1.211: рефреш леджера + фолд hook-ask-floors

## Контекст
Refresh-ledger (`harness-evolution.md`) числился last-grounded на CC v2.1.210, а живой
`claude --version` = 2.1.211. По `harness-evolution.md` дельта `claude --version` против
леджера — самостоятельный триггер strip-revision (external-intake pass). Дельта минимальная
(один patch), но формально стамп протух: `native-capabilities.md` не должен отставать от
живой версии. Модельный и календарный триггеры не горели (леджер уже на Claude 5 + Opus 4.8;
дата 2026-07-15), поэтому запущен не полный strip revision, а **micro external-intake** —
только changelog-дельта 2.1.210→2.1.211.

## Изменения
Прошёл changelog 2.1.211 (`code.claude.com/docs/en/changelog`) и прогнал каждую запись через
D-cycle gate «новый примитив/durable-инвариант, релевантный harness-дизайну, → point-edit; иначе
noise». Из ~35 записей релиза почти всё — bugfix/UX/платформенные фиксы. Один durable-инвариант
прошёл гейт:
- **Фолд (1):** `native-capabilities.md` §Settings/permissions — в abzац про auto-mode-классификатор
  добавлена клауза: **PreToolUse hook `ask` теперь floors auto-mode-решение до prompt** для
  unsandboxed Bash (v2.1.211); классификатор больше не может молча даунгрейднуть hook `ask`, значит
  guard-хук остаётся authoritative над auto mode. Прямо усиливает «hooks are deterministic
  enforcement» из того же файла.
- **Version-line** `native-capabilities.md` → CC v2.1.211.
- **Refresh-ledger re-stamp** → CC v2.1.211 / 2026-07-16, но честно scoped: `sources-checked`
  помечен «changelog delta only (micro external-intake)», а полный multi-source sweep
  (docs/anthropic.com/binary strings) явно оставлен grounded на 2.1.210 — чтобы следующая полная
  strip-revision не приняла micro-pass за полный sweep.

Отклонено гейтом как noise/too-niche (записано для watch-трейла): `--forward-subagent-text` флаг
(SDK/stream-json observability, не harness-design); subagent model-override на resume, nested
`.claude/rules` loading при exclude project-settings, "always allow" в repo-root, scientific-notation
в integer env-vars, memory-index over-limit warning refinement, routines-year-1 — все bugfix/UX,
не новые примитивы и не durable design-инварианты.

## Затронутые файлы
- `plugins/harness/references/native-capabilities.md` — version-line → 2.1.211 + клауза hook-ask-floors
- `plugins/harness/references/harness-evolution.md` — refresh-ledger стамп + last-updated
- `CHANGELOG.md`, обе `plugin.json` — bump 1.14.3 (lockstep через `release.sh`)

## Проверка
- Changelog сверен verbatim с официальной страницей `code.claude.com/docs/en/changelog`
  (записи 2.1.211 и 2.1.210 для контекста дельты).
- Стамп честно фиксирует micro-scope: version-триггер погашен (CC-поле = 2.1.211), но docs/blog/
  binary sweep остаётся на 2.1.210 — следующая strip-revision сравнит дельту от правильной точки.
- `release.sh 1.14.3` бампит оба plugin.json в локстепе, guard'ит marketplace-drift, стейджит
  surface; коммит/тег/пуш выполнены вручную (скрипт не автокоммитит — это сознательный шаг оператора).
- Reindex (`rebuild-index.py .claude/devlog`) регенерирует index.json + tldr.md; slug файла = slugify(title).

## Related
- #3, #4 — предыдущие фолды в канон; тот же механизм эволюции (D-cycle / strip-revision)
