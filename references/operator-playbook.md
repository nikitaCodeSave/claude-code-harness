# Operator playbook — жизненный цикл проекта с Claude Code

Документ для **человека-оператора**: что говорить агенту, что готовить между сессиями,
когда заказывать аудит и когда стричь обвязку. Агент его не preload'ит — это вход
в регламент, а не инструкция модели. Детали каждого шага — по ссылкам, не здесь.

Принцип поверх всего: **under a capable model, less harness yields more productivity**.
Каждый шаг ниже добавляет ровно то, что доказало пользу, — и не раньше триггера.

## Карта слоёв

| Слой | Где | Что это |
|---|---|---|
| Поведенческий baseline | `~/.claude/CLAUDE.md` (или project-embed `.claude/rules/practice-baseline.md`) | §1–§8 для всех проектов (git clone / Bootstrap Phase 2b) |
| Kit (этот скилл) | `~/.claude/skills/claude-code-harness/` | Bootstrap / Audit / Extend / Explain |
| Внешний аудит | внутри kit'а: `skills/claude-code-harness/commands/external-audit.md` + `agents/{evidence-executor,process-auditor,code-refuter}.md` — едет и clone'ом, и plugin'ом | ритуал независимой проверки |
| Workflow-выжимка | `<repo>/.claude/docs/{workflow,testing,docs-discipline}.md` | отгружается bootstrap'ом verbatim из kit'а (`references/project-docs/`); обновляется re-sync'ом на audit'е по `shipped-by`-версии |
| Проектный слой | `<repo>/CLAUDE.md` + `<repo>/.claude/` + `<repo>/docs/` | создаётся шагом 1, растёт по триггерам |

Доставка слоя на машину/профиль — три пути: (а) git-clone dot-claude репо в `~/.claude`
(везёт все слои, включая baseline); (б) установка плагина `claude-code-harness` из
marketplace; (в) копия каталога скилла в `~/.claude/skills/` — на CC ≥2.1.157 авто-загрузится
как плагин вместе с `/external-audit` и agent-ролями, на более старых версиях даст только
SKILL.md (путь (б) надёжнее). Поведенческий baseline при путях (б)/(в) готовым файлом не
приезжает, но **Bootstrap его доставляет** (Phase 2b, `references/practice-baseline.md`):
сессия детектит твой `~/.claude/CLAUDE.md` и предлагает глобальную установку (с твоего
approve) или project-embed в `.claude/rules/`.

## 1. Новый проект — bootstrap (первая сессия)

1. Открыть `claude` в корне пустого/нового репо.
2. Сказать: **«set up Claude Code harness in this project»** — сработает скилл в режиме
   Bootstrap (`references/bootstrap-checklist.md`).
3. Дефолт — **production-grade независимо от размера проекта**: корневой `CLAUDE.md`
   (≤200 строк, indexer, включая Working style с verification-лестницей) +
   `.claude/settings.json` (deny-список важнее allow) + workflow-выжимка в `.claude/docs/`
   (3 файла, verbatim из kit'а) + `docs/ARCHITECTURE.md` и `docs/CODE-MAP.md` с реальным
   содержимым + предложение установить practice baseline (глобально в `~/.claude/CLAUDE.md`
   — предпочтительно — или в `.claude/rules/`). Минимальный MVH (только CLAUDE.md +
   settings) — отдельной фразой: **«set up a minimal harness»**. Кастомных
   агентов/хуков/скиллов нет в обоих вариантах — это дисциплина, не упущение.
4. Контракт (стек / acceptance первой фичи / verify-механизм / sensitive paths) всплывает
   из разговора по ходу — upfront-анкета не нужна; следи только, чтобы опасные пути
   попали в `permissions.deny` сразу, как только названы.

Проверка шага: `claude --print "what is the project's stack?"` отвечает по CLAUDE.md.

## 2. Продукт на много сессий — заказать Phase 5 kit

Если проект — продукт, строящийся feature-by-feature (не библиотека/скрипт/one-off):

1. Сказать: **«set up the long-running build kit (Phase 5)»**.
2. Получишь конвенции + файлы (не машинерию): runnable-оракул `init.sh` с зелёным
   baseline'ом · `.claude/features.json` (verify-шаги + `preconditions`, `passes: false`)
   · `.claude/progress/<slug>.md` + devlog · session-start ritual в CLAUDE.md
   · строку про fresh-context Evaluator. (`docs/ARCHITECTURE.md` + `CODE-MAP.md` и
   workflow-выжимка уже стоят с bootstrap'а — это дефолтная форма, не Phase 5.)
3. **Ledger засеивает сессия, ревьюит оператор**: декомпозицию продукта на фичи и
   verify-контракты пишет агент из твоего описания; твой шаг — прочитать засеянный
   `features.json` и поправить границы/verify ДО первой фичи (это твоя страховка от
   тихих микро-решений).
4. **harness-journal — opt-in, дефолт off**: попроси `.claude/harness-journal.md`
   (1–3 наблюдения «kit-не-хватило» за сессию), только если собираешься гонять
   D-циклы (шаг 6). Без D-циклов journal — мёртвый груз.

## 3. Build-ритуал — что делает оператор между сессиями

- **Preconditions до старта сессии**: подними сервисы из `features.json.preconditions`
  (docker-контейнер БД, локальный LLM, …). Сессия проверит их и встанет, если их нет.
- **Старт сессии**: достаточно сказать «продолжай по features.json» — session-start
  ritual зашит в проектный CLAUDE.md (git log → progress → одна фича → `./init.sh`).
- **Конец сессии**: глазами проверь — commit per feature есть, `progress` обновлён,
  `passes: true` стоит только у фич с выполненными verify-шагами.
- **Handoff-заметка = претензия, не факт**: если прошлая сессия написала «проверено» —
  следующая обязана переисполнить, прежде чем опираться.
- **Контракт/доки vs диск**: при расхождении (путь не существует, файл не там) истина — диск:
  detect-then-prescribe, исправить по факту и зафиксировать наблюдением в journal/progress,
  не следовать контракту вслепую. Команды резолвить per-tool (`.venv` first, PATH fallback) —
  и **смотреть, что именно зарезолвилось**: унаследованный PATH может подсунуть чужой venv
  (оракул «зелёный», но интерпретатор не из этого проекта); init.sh пусть печатает resolved-пути.

## 4. Существующий проект — привести к канону

1. В корне проекта сказать: **«audit my Claude Code harness»** — режим Audit
   (`references/audit-checklist.md`; шаблон gap-report'а — в `SKILL.md` kit'а).
2. Получишь gap-report (находка → почему важно → remediation). **Правки — только после
   твоего approve**, необратимое помечается отдельно; до strip'а — ветка/бэкап.
3. Audit заодно сверяет `shipped-by`-версию workflow-выжимки (`.claude/docs/*`) с версией
   установленного плагина и предлагает re-sync, если плагин новее, — так выжимка фабрики
   в проектах не отстаёт от канона.

## 5. Внешний аудит — `/external-audit`

Когда заказывать: закрыт milestone · security/correctness-critical фича · дорогая
необратимая поставка «выглядит готовой». Периодически полезен и по *принятым* фичам —
fresh-context аудит ловил HIGH-дефекты в уже зелёном.

Как (правило независимости — внешний > self-orchestrated):
1. Открыть **новую сессию** (не авторскую) в корне проверяемого проекта.
2. Сказать: **`/external-audit <scope>`** (фича/milestone + где спека); если команда
   доставлена plugin'ом, имя в списке — `claude-code-harness:external-audit`.
3. Сессия параллельно запустит три роли — evidence-executor (обязан ИСПОЛНЯТЬ живой
   стек), process-auditor (git/scope/red→green), code-refuter (опровергает код) — и
   сведёт вердикты по правилу «исполненное доказательство сильнее прочитанного».
4. Результат: `.claude/audit/<slug>/AUDIT-VERDICT.json` + actionable items в progress.

## 6. D-цикл — эволюция канона (роль: мейнтейнер канона)

Когда: закрыт milestone или в journal накопилось ≥5 содержательных наблюдений.
Как: отдельная сессия по `references/harness-evolution.md` (классификация наблюдений →
gate «single-incident ≠ invariant» → точечный fold в канон → commit + devlog).

«Канон» = исходный репозиторий этого kit'а у его мейнтейнера. Потребитель плагина канон
не правит — обновляет версию плагина, а находки/журнальные наблюдения передаёт мейнтейнеру.

## 7. Strip-ревизия — когда стричь обвязку

Раз в 3–6 месяцев или на major-релизе модели: re-test каждого компонента «модель уже
делает это нативно?» (быстрый тест — `claude --safe-mode`: если без harness'а не хуже,
компонент устарел). Процедура — вторая половина `references/harness-evolution.md`.

## Сквозные правила оператора

- (мейнтейнер) Каждая правка канона (`~/.claude`) = commit в dot-claude + devlog-запись
  в репо-лаборатории мейнтейнера.
- Harness растёт **только по триггерам** (таблица «Optional next steps» в
  `references/bootstrap-checklist.md`), не спекулятивно.
- Проектный код через harness-ритуалы не трогается: scope аудитов и audit-режима —
  `.claude/`, `CLAUDE.md`, `docs/`.

<!-- last-updated: 2026-06-11 (v1.8.0) · источники (maintainer's lab, не отгружаются): WORKFLOW.md, devlog #78–#82; bootstrap-checklist.md (в kit'е) -->
