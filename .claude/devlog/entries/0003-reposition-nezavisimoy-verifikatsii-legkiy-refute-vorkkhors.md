---
id: 3
date: 2026-07-16
title: "Reposition независимой верификации: лёгкий refute = воркхорс, 3-ролевой аудит = редкая эскалация"
tags: [canon, d-cycle, verification]
status: complete
---

# Reposition независимой верификации: лёгкий refute = воркхорс, 3-ролевой аудит = редкая эскалация

## Контекст
D-cycle-фолд из доказанной находки. Дисциплинарный текст (`harness-discipline.md`,
лестница верификации) уже ставил лёгкий fresh-context вариант первым, но **операторские
поверхности** переусиливали тяжёлый инструмент: `operator-playbook.md §5` был целиком про
3-ролевой `/external-audit`, а handoff-футер `SKILL.md` выносил наружу только его — как
единственный «independent-verification ritual». Эмпирика противоречит: в живом
многосессионном продуктовом билде полный 3-ролевой аудит прогнан **однажды** (на вехе,
полный `AUDIT-VERDICT.json`), а рабочей лошадкой стал **одно-субагентный `code-refuter`**,
запускаемый per-change на silent-wrong класс (одна директория аудита содержит только
`AUDIT-REFUTER.json`). Тот же билд сам сошёлся к минимуму обвязки: кастомных команд — одна,
проектных хуков нет, план жил в progress. Атрофия тяжёлого тира подтверждает headline-принцип,
а не опровергает его — значит инструмент остаётся как редкая эскалация, но переставляется по
весу. Воркхорс — это буквально роль `code-refuter`, которую плагин уже отгружает, запущенная
соло; чинить в коде нечего, разрыв только в позиционировании.

Тонкую команду `/refute` рассматривали и отвергли: escalation-ladder её формально оправдывает,
но эмпирика того же билда (кастомные команды атрофировались до одной) — прямой сигнал, что
тонкие команды не приживаются. Reposition документации даёт пользу без новой обвязки.

## Изменения
Хирургический point-edit конкретных reference'ов (не новый файл, не новый слой):
- **`operator-playbook.md §5`** — из «External audit — /external-audit» в
  «Independent verification — two tiers»: Tier 1 (per-change refute, воркхорс — одиночный
  `code-refuter` → `.claude/audits/<slug>/AUDIT-REFUTER.json`) + Tier 2 (полный 3-ролевой
  `/external-audit`, редкая эскалация). Анонимная эмпирика: «full audit ran once, per-change
  used code-refuter alone».
- **`operator-playbook.md` Layer map** — строка «External audit / the independent-verification
  ritual» → «Independent verification / code-refuter solo = per-change workhorse, full 3-role =
  rare escalation».
- **`SKILL.md` handoff-футер** — bullet `/external-audit` заменён на двухтировый: по умолчанию
  одиночный `code-refuter` на silent-wrong изменение, эскалация до полного `/external-audit`
  только на вехе/необратимом.
- **`harness-discipline.md`** — верхняя ступень лестницы названа по весам: «single refuter by
  default, full 3-role /external-audit (or a workflow) only as a rare escalation».

Что осталось нетронутым (согласованность подтверждена, не правил): `practice-baseline.md §8`
уже в синхроне с усиленным глобальным baseline (per-change silent-wrong), `external-audit.md`
команда и агент-роли работают как есть.

## Затронутые файлы
- `plugins/harness/references/operator-playbook.md` — §5 переписана в два тира + Layer map
- `plugins/harness/SKILL.md` — handoff-футер, bullet независимой верификации
- `plugins/harness/references/harness-discipline.md` — верхняя ступень лестницы верификации

## Проверка
- Ground truth сверен с реальным проектом-потребителем: `iter3-observability/` — все 4 файла
  (EVIDENCE+PROCESS+REFUTER+VERDICT, полный аудит однажды); `sprint3-code-guard/` — только
  `AUDIT-REFUTER.json` (refuter соло); команды = один `release.md`; проектных хуков/агентов
  нет; 108 devlog + 3 живых progress. Утверждение анализа подтверждено дословно.
- `grep` по каноническому пути: fold использует `.claude/audits/` (мн.ч., источник истины
  команды после v1.14.1), не историческое `audit/` из старого проекта.
- Имя проекта-потребителя в shipped-поверхность и публичный devlog не просочилось
  (анонимизация как в `evidence-base`/`practice-baseline`).

## Related
- #2 — стандартизация пути `.claude/audits/`, на который опирается fold
