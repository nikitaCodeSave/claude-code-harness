# Harness evolution — D-циклы и strip-ревизия

Процедура эволюции **канона** — репозитория этого плагина
(`nikitaCodeSave/claude-code-harness`) — по эмпирическим сигналам, а не по вкусу.
(Практический baseline §1–8 живёт в operator-global `~/.claude/CLAUDE.md` и эволюционирует
отдельно; при релизе его снимок re-distill'ится в `references/practice-baseline.md`.)
Две операции: **D-цикл** (fold доказанных находок внутрь) и **strip-ревизия**
(вынос устаревшего наружу). Обе подчинены headline-принципу: компонент живёт, только
пока кодирует то, чего модель не делает нативно.

## Refresh ledger — baseline для дельты

Канон стареет по трём **внешним** осям: **CC-версия** (новые primitives), **поколение
модели** (что модель умеет нативно, effort-дефолты), **подходы** (first-party essays,
arXiv, community). Чтобы strip-ревизия сверяла *дельту*, а не «всё с нуля», канон несёт
один provenance-штамп — последнюю точку заземления:

<!-- harness-refresh-ledger
last-grounded: CC v2.1.210 · Claude 5 family (Fable 5, Sonnet 5) + Opus 4.8 · 2026-07-15
sources-checked: code.claude.com changelog + docs (sub-agents, plugins-reference, commands, hooks, memory, model-config) · anthropic.com engineering + news · binary strings 2.1.210
-->

Штамп обновляется в конце каждой strip-ревизии (проход external-intake ниже). Текущая
CC-версия для сравнения — `claude --version`; срез built-ins живёт в
`native-capabilities.md`, и его version-строка после refresh **должна совпадать** с этим
штампом. Дельта `claude --version` против ledger — самостоятельный триггер ревизии (её
видно в начале сессии, без отдельной машинерии).

## Источники сигналов

- `.claude/harness-journal.md` проекта — 1–3 наблюдения «kit-не-хватило / kit-помешал»
  за сессию (opt-in, см. operator-playbook §2).
- Вердикты внешних аудитов (`/external-audit`, fresh-context Evaluator'ы).
- Поправки оператора по ходу работы (повторяющиеся — особенно).
- **Внешний дрейф** (CC-версия / модель / подходы) — сверяется в strip-ревизии,
  проход external-intake; baseline — refresh-ledger выше.

## D-цикл (≈1 сессия)

Триггер: закрыт milestone, или накопилось ≥5 содержательных наблюдений. Для проектов
**без journal'а** (он opt-in) журнального триггера не будет — там работают milestone-close
и вердикты внешних аудитов; не жди «5 наблюдений», которых неоткуда взяться.

1. **Собрать** наблюдения журнала + audit-вердикты + операторские поправки за период.
2. **Классифицировать** каждое: `kit-gap` (канон не покрыл повторяемую нужду) ·
   `project-specific` (остаётся в проектном CLAUDE.md/rules) · `single-incident`
   (наблюдать дальше) · `noise`.
3. **Gate**: в канон проходит только `kit-gap` с multi-source evidence или повторной
   эмпирикой. **Single-incident в invariant не превращается** — он остаётся в журнале
   с пометкой «watch».
4. **Fold** — точечная правка конкретного reference (checklist / discipline /
   native-capabilities), не новый файл и не новый слой. Формулировка model-agnostic;
   evidence-провенанс (даты, n) — допустим и желателен. Empirics: harness-gains
   локализуются в tools/middleware/memory, НЕ в прозе (AHE ablation, arXiv 2604.25850) —
   предпочитай fold в механический носитель (checklist-шаг, permission-правило, schema),
   а не в новый абзац прозы.
5. **Зафиксировать**: commit в репо плагина + devlog-запись там же со списком
   «находка → куда сложена → доказательство». Значимое изменение состава kit'а →
   релиз через `scripts/release.sh <version>` (bump `version` в `plugin.json` — единый
   источник истины — + tag + push). (Шаг мейнтейнера: commit/devlog — в репо плагина;
   эмпирика экспериментов — в репо-лаборатории. На машине-потребителе этого шага нет —
   там канон обновляется `/plugin update`.)

Анти-паттерн D-цикла: «раз сессия всё равно открыта — причешу заодно соседние разделы».
Правки только по находкам цикла; всё остальное — отдельным решением.

## Strip-ревизия (раз в 3–6 мес, на major-релизе модели, или на дельте CC-версии)

Триггер cadence — календарь (3–6 мес), major-релиз модели, **или** дельта
`claude --version` против refresh-ledger. Ревизия идёт двумя проходами: сперва
**external-intake** (что изменилось снаружи — обновляет канон под новую реальность),
затем **re-test** (что из канона устарело относительно изменившейся модели/окружения).

### Проход 1 — external-intake (что сдвинулось снаружи)

Сверять дельту *от refresh-ledger*, не «всё с нуля». Источники — CLI-нативно
(WebFetch / WebSearch, без Anthropic API):

1. **CC-changelog** since ledger-версии → новые hooks / tools / flags / команды.
   Каждую релевантную — fold в `native-capabilities.md` (она не должна отставать от
   live `claude --version`).
2. **First-party docs / blog** (code.claude.com/docs, anthropic.com / claude.com) →
   сдвиги дефолтов (effort, model-config), новые canonical-паттерны.
3. **external-sources catalog** → новые essays / arXiv по T1–T7 rubric.
4. Каждую находку — через D-цикл-gate (`kit-gap` с multi-source · `single-incident` ·
   `noise`). External-сигнал **не привилегирован**: «вышла статья / появился флаг»
   single-incident в invariant не превращается; fold — point-edit конкретного
   reference, не новый слой.

### Проход 2 — re-test (что из канона устарело)

1. Перечислить компоненты канона с их assumption «модель не умеет X»
   (включая every «under Opus <version>» в текстах).
2. Re-test каждого: умеет ли модель X нативно теперь. Быстрый инструмент —
   `claude --safe-mode` (старт без CLAUDE.md/skills/hooks/MCP): если без компонента
   не хуже — он устарел.
3. Устаревшее **удалять, не архивировать в канон** (история остаётся в git + devlog).
4. То, что добавлено последним D-циклом и не сработало, — первый кандидат на вынос.

В конце ревизии — **обновить refresh-ledger** (новая CC-версия / модель / дата /
проверенные источники), синхронизировать version-строку `native-capabilities.md`,
зафиксировать devlog-записью. Значимый сдвиг состава канона → bump `version`
(см. D-цикл шаг 5).

## Доказательная база процедуры

Выращено на dogfood-треке (maintainer's lab Harnesses-Claude, devlog #78–#82 — артефакты
не отгружаются с kit'ом): 2 D-цикла,
12 находок сложено в kit, каждая — с журнальной или аудиторской эмпирикой; первопартийное
основание — Anthropic «review your configuration every 3-6 months» и «find the simplest
solution possible» (см. `references/evidence-base.md`).

<!-- last-updated: 2026-07-15 -->
