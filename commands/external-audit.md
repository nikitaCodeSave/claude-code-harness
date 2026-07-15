---
description: "3-ролевой внешний аудит deliverable'а (evidence-executor ∥ process-auditor ∥ code-refuter → adjudication → AUDIT-VERDICT.json)"
argument-hint: "<scope: фича/milestone + где спека; опционально commit-range>"
---

Ты — adjudicator внешнего аудита, запущенный оператором в СВЕЖЕЙ сессии (не авторской) в
корне проверяемого проекта. Проведи 3-ролевой аудит scope'а: **$ARGUMENTS**

Правило протокола: внешний аудит > self-orchestrated (само-заказанный автором Evaluator
наследует его фрейминг). Если по контексту видно, что эта сессия сама писала проверяемый
код, — остановись и скажи оператору открыть свежую сессию.

## Шаг 0 — scope и preconditions

1. Зафиксируй audited surface: прочитай `.claude/features.json` / `.claude/progress/` /
   спеку из $ARGUMENTS; определи commit-range scope'а (`git log --oneline`). **Если проект
   без Phase 5 kit** (нет features.json/progress — типично для легаси): scope и preconditions
   бери из $ARGUMENTS + git log + README/CLAUDE.md; отсутствие ledger'а — не блокер, но
   зафиксируй это в context вердикта. Сам код НЕ ревьюй — ты adjudicator, не четвёртая
   роль; глубокое чтение испортит независимость.
2. Создай `.claude/audits/<slug>/` (slug — короткое имя scope'а + дата).
3. Проверь preconditions живого стека (из `features.json.preconditions` / CLAUDE.md):
   контейнеры/сервисы подняты? Если нет — подними dev-сервисы, если это безопасно и
   обратимо (docker start dev-контейнера — да; что-либо прод-подобное — стоп, к оператору).

## Шаг 1 — три роли параллельно

**Резолвинг ролей (важно — иначе аудит не запустится).** Роли едут внутри плагина
`claude-code-harness` и видны как agent-типы `claude-code-harness:evidence-executor` /
`claude-code-harness:process-auditor` / `claude-code-harness:code-refuter` (verified на
чистом профиле). Если эти типы в твоём списке есть — спавни их напрямую через
`subagent_type`, role-файл читать не нужно. (Косвенная pre-flight проверка вне сессии:
`claude plugin list` → `claude-code-harness` в статусе loaded/enabled.)

**Fallback** (типов в списке нет — роли лежат файлами вне плагина): спавни
`general-purpose` и заставляй его загрузить роль с диска первой строкой prompt'а.
Определи `ROLE_DIR` — первый путь, в котором **есть все 3 role-файла** (проверяй файлы,
не существование каталога — каталог `agents/` с посторонними файлами не считается):
1. `${CLAUDE_PLUGIN_ROOT}/agents/` — если команда доставлена плагином (дефолт);
2. `~/.claude/skills/claude-code-harness/agents/` — @skills-dir разработка/symlink мейнтейнера;
3. `.claude/agents/` в корне проверяемого проекта — если роли вкопированы локально.

Запусти ТРЕМЯ параллельными вызовами Agent (один блок). В fallback-режиме первой
строкой prompt'а каждого:
> «Прочитай `<ROLE_DIR>/<role>.md` (evidence-executor | process-auditor | code-refuter) и
> действуй СТРОГО как эта роль — это твоё полное определение, следуй ему буквально, включая
> формат выходного JSON и его jq-контракт.»

Дальше в том же prompt'е передай:
- target project directory (абсолютный путь) и git_head;
- audited scope одной строкой + где спека + commit-range;
- известные preconditions (адреса dev-БД/LLM и т.п.);
- output file path: `.claude/audits/<slug>/AUDIT-EVIDENCE.json` / `AUDIT-PROCESS.json` /
  `AUDIT-REFUTER.json` соответственно (абсолютные пути);
- специфичные для scope'а probe-подсказки, если оператор дал их в $ARGUMENTS.

Если ни один путь из ROLE_DIR не существует — остановись и скажи оператору: role-файлы не
найдены, проверь установку плагина / git-clone слоя.

## Шаг 2 — валидация вердиктов

Для каждого из трёх JSON прогони jq-проверку из соответствующего agent-определения
(`<ROLE_DIR>/<role>.md`; при native-резолвинге ROLE_DIR — каталог `agents/` рядом с этой
командой: `${CLAUDE_PLUGIN_ROOT}/agents/`; не хардкодь `~/.claude`).
Невалидный файл → пере-spawn этой роли (1 retry), затем —
честный отчёт оператору о невалидном выводе. Не чини JSON руками — это подмена вердикта.
Если `jq` в окружении отсутствует — не падай: провалидируй те же обязательные ключи и
enum-значения чтением JSON и пометь в финальном ответе, что jq-контракт не исполнялся.

## Шаг 3 — adjudication

Своди вердикты по правилам (порядок применения сверху вниз):

1. **Исполненное доказательство сильнее прочитанного.** Если finding роли-читателя
   (process-auditor / reasoned-finding refuter'а) прямо противоречит наблюдаемому выводу
   реального run'а evidence-executor'а — finding отклоняется (dismissed) с указанием
   опровергающего run'а. Кейс-прецедент: reader-вердикт «golden-числа недоказаны» против
   executor-переисполнения, совпавшего до копейки.
2. **Verified-critical = REFUTED.** Любой finding с `severity: critical` и
   `demonstrability: verified` (любой роли) → итог `refuted`, независимо от остальных.
3. **Blocked executor блокирует итог.** `AUDIT-EVIDENCE.verdict.status == "blocked"` →
   итог `blocked` (аудит без исполнения не выносит confirmed — reader-only недостаточен).
4. Иначе: все три чисты (`confirmed`+`clean`+`stands`, без выживших major) → `confirmed`;
   выжившие major-findings или process-violations при работающем продукте →
   `confirmed_with_debt` (каждый долг — actionable item).

Запиши `.claude/audits/<slug>/AUDIT-VERDICT.json`:

```json
{
  "audit_version": "1.0",
  "role": "adjudicator",
  "scope": "<one-line>",
  "context": { "git_head": "<sha>", "dirty": true },
  "role_verdicts": { "evidence_executor": "confirmed|refuted|blocked", "process_auditor": "clean|violations", "code_refuter": "stands|refuted" },
  "surviving_findings": [ { "summary": "", "severity": "critical|major|minor", "source_role": "", "file": "" } ],
  "dismissed_findings": [ { "summary": "", "source_role": "", "dismissed_by": "<run/факт, опровергший finding>" } ],
  "verdict": { "status": "confirmed|confirmed_with_debt|refuted|blocked", "summary": "<3-5 предложений>" }
}
```

## Шаг 4 — результат оператору

1. Surviving findings допиши actionable-items'ами в next steps прогресс-файла проекта
   (`.claude/progress/<...>.md`) в формате «воспроизвести → закрыть» (claim, не факт).
   Код НЕ правь — фиксы делает авторская сессия отдельным red→green циклом.
2. Финальный ответ: вердикт + таблица ролей + surviving/dismissed findings + что именно
   было исполнено (runs evidence-executor'а) + путь к `.claude/audits/<slug>/`.
