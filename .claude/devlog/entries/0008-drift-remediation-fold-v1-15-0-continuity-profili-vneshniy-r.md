---
id: 8
date: 2026-07-16
title: "Drift-remediation fold v1.15.0: continuity-профили, внешний refuter, blocked-схема"
tags: [canon, d-cycle, continuity, verification, backlog, audit]
status: complete
---

# Drift-remediation fold v1.15.0: continuity-профили, внешний refuter, blocked-схема

## Контекст
Kickoff-артефакт лаборатории `harness-drift-remediation.md` (кросс-проектный fresh-context
аудит: 4 адверсариальных harvest-агента над 37 `.claude/`-проектами, продолжение lab-devlog
#115) выявил: дрейф консьюмерских проектов сконцентрирован в прескриптивном ФОРМАТЕ слоёв
continuity и verification, и почти каждое отклонение оператора лучше канона. Проекты сидели
на старых версиях кита, поэтому первый шаг — матрица «что уже закрыто»: WU-4 (.env-deny +
donor-pin) уже отгружен в Phase 3; двухъярусность верификации уже в v1.14.2; WU-9
(harness-journal) уже opt-in в operator-playbook §2.

## Изменения
**TIER 1 (multi-source канон-фиксы):**
- WU-1 — `workflow.md` Continuity + `practice-baseline.md` §6: у progress-слоя два легитимных
  профиля — task-scoped (терминал = CLOSED **или** delete, оба валидны) и **workstream
  snapshot** (живой снимок: текущее состояние + открытые хвосты; эпизодика → devlog; prune,
  don't append). Жёсткий мандат «convert→devlog + delete» снят (delete не сработал НИ РАЗУ в
  3 проектах; rolling-снимок оператора оказался лучше канона).
- WU-2 — `workflow.md` ladder: для silent-wrong класса рефьютер **внешне-инициирован** (не
  субагент авторской сессии — само-заказанный evaluator наследует фрейминг, реальный кейс:
  пропущенный Unicode-обход) + «verify passed ≠ invariant holds» (реальный кейс: 6/6 green,
  внешний аудит REFUTED).
- WU-3 — `bootstrap-checklist.md` Phase 5 + `workflow.md`: канон-схема features.json получила
  `blocked`/`blocked_reason`/`notes`; skip blocked на session start; «verify достижимые слои
  ДО записи blocked»; развилка single-track ledger vs один roadmap-носитель для
  multi-initiative кампании.
**TIER 2/3 (через refuter-гейт, сужены):**
- WU-5 → сужен до 2 предложений при blocked-тексте (именованная 6-строчная «e2e-ladder» убита
  рефьютерами: 4/5 клауз уже в каноне или нативны).
- WU-6 → одно предложение-указатель в `harness-discipline.md` (project-knowledge skill) +
  инвентарные факты в `native-capabilities.md` (`user-invocable: false` — точная орфография,
  `user-invokable` тихо игнорируется; `context: fork` + `agent:`; сверено с first-party docs).
- WU-10 → буллет в `audit-checklist.md` §3: hand-rolled `sync-docs` дублирует kit-shipped
  docs-discipline rule 1 (эмпирика: скилл строили только там, где правила не было; принявший
  правило — ретайрнул скилл+агента).
- WU-11 → re-sync сравнивает shipped-by header-vs-header канона (не vs package-версии) —
  снят вечный ложный «re-sync available» (`audit-checklist.md` §4, `operator-playbook.md` §4).
- WU-12 → install-команда playbook = README.
**REJECT (два независимых fresh-context рефьютера, вердикты сошлись 6/6):** WU-7 (`state/`
4-й слой) и WU-8 (guard-heavy карвель ≤200) — N=1 + уже покрыто каноном («state-on-disk, not
layout»; Phase 4 + rule 2 «docs/ or rules»). Watch-items в лаборатории.

## Затронутые файлы
- `plugins/harness/references/project-docs/workflow.md` — shipped-by → v1.15.0 (WU-1/2/3/5)
- `plugins/harness/references/{practice-baseline,bootstrap-checklist,harness-discipline,audit-checklist,operator-playbook,native-capabilities}.md`
- `CHANGELOG.md`, обе `plugin.json` — bump 1.15.0 (lockstep, `release.sh`)
- Лаборатория: `plans/harness-drift-remediation-execution-log.md` (WU-лог с B0/B1-дельтами),
  devlog #121

## Проверка
- **Evidence-гейт**: 13/13 цитат дозье подтверждены fresh-context агентом + продублированы
  main-thread'ом (2 поправки: F6-a файл отсутствует — тезис держится сильнее; F11-a
  .env-кейс атрибутирован соседнему проекту). Правки опираются только на подтверждённое.
- **Refuter-чекпойнт §6**: два независимых рефьютера (второй — после стойла первого;
  первый дошёл сам) — конвергенция 6/6, TIER 2 сужен по их вердиктам.
- **TEMP-verify §5 (A/B, 3 фикстуры, headless fresh-context, kit-до=tag v1.14.4 vs
  kit-после=worktree)**: 3/3 PASS с видимой дельтой. longrun: workstream-снимок распознан
  и назван легитимным (B0: терпим лишь как «не закрыт»); guard: rung 3 → «инициирует
  оператор, вне сессии» + мандат «инвариант, не diff» (B0 дважды: «инициирую я, субагент»);
  extgate: канонные `blocked`/`blocked_reason`/`notes` вместо изобретённых полей и
  root-handoff (B0: ad-hoc `note` + HANDOFF-файл — тот же реинвент, что у живого
  консьюмер-проекта). Лог: лаборатория, `harness-drift-remediation-execution-log.md`.
- `claude plugin validate` — оба плагина + marketplace ✔ (до и после правок).

## Related
- #3 (reposition независимой верификации — v1.14.2 закрыл часть WU-2 заранее), #5 (микро-интейк
  2.1.211), lab-devlog #115/#121 — провенанс аудита и трека.
