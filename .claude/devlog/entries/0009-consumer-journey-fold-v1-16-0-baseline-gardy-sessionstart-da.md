---
id: 9
date: 2026-07-16
title: "Consumer-journey fold v1.16.0: baseline-гарды, SessionStart-дайджест, README first-session"
tags: [feature, harness]
status: complete
---

# Consumer-journey fold v1.16.0: baseline-гарды, SessionStart-дайджест, README first-session

## Контекст
Fresh-context аудит того, как кит приземляется на чужую машину (без личных хуков и
lab-правил), показал: слой доставки настолько несогласован, что внедрение читается
хуже «чистого» Claude Code. Шесть находок: (1) догфуд-асимметрия — provenance
baseline'а ссылается на дисциплину, наблюдавшуюся под личным SessionStart-хуком,
который консюмер не получает; (2) к чужому глобальному `~/.claude/CLAUDE.md` — ни
diff-превью, ни бэкапа, ни потолка, хотя к файлам под git кит требует большего;
(3) кейс «правило пользователя противоречит baseline» не предусмотрен — молчаливый
мерж кладёт X и не-X в co-loaded слои; (4) детект однофайловый при четырёх слоях
загрузки; (5) «global — preferred» при первом контакте — слишком широкий радиус;
(6) README не даёт ни одной trigger-фразы, operator-playbook упомянут ячейкой без пути.

## Изменения
- **Доставка baseline инвертирована**: project embed `.claude/rules/practice-baseline.md`
  — дефолт (git, обратимо, радиус = репо); global merge — guarded opt-in: радиус
  проговаривается в самом оффере, diff показывается до записи, бэкап
  `~/.claude/CLAUDE.md.bak-<дата>` пишется первым (файл вне git — бэкап и есть откат),
  бюджет — та же ≤200-строчная дисциплина. Детект — по всем слоям (managed policy →
  user → project → auto-memory), четвёртый исход «конфликт» — назвать оператору и
  остановиться, не мержить молча.
- **Content-version стамп** в каноническом блоке (HTML-комментарий — вырезается до
  инъекции, в рантайме бесплатен): re-sync эмбеда — через Audit §4 (зеркально
  shipped-by), глобальной копии — только по запросу через тот же guarded merge.
  Playbook получил §5 «Keeping the kit and the baseline current» (§§5–7 → 6–8).
- **devlog-плагин поставляет SessionStart-дайджест** (`hooks/hooks.json` +
  `hooks/session-start-digest.sh`): последние 3 devlog-записи + до 3 активных
  progress-файлов (CLOSED отфильтрован), молчит в проектах без обоих, read-only,
  bash-3.2-портабельно. Закрывает находку (1): машинная половина дисциплины теперь
  устанавливаема, provenance говорит об этом прямо (delivery step 4 + Provenance).
- **Baseline §7 называет нативный пол** (destructive-command block + permission flow)
  вместо молчаливой опоры на личный system-guard.
- **README «First session (start here)»**: таблица trigger-фраз, контракт
  «что бутстрап трогает / не трогает», прямая ссылка на operator-playbook.md.

## Затронутые файлы
- `plugins/harness/references/practice-baseline.md` — процедура доставки (4 исхода,
  embed-дефолт, guarded merge), стамп, §7, «Keeping installed copies current», Provenance
- `plugins/harness/references/bootstrap-checklist.md` — Phase 1/2b/4, Phase 5 items 3–4
- `plugins/harness/references/audit-checklist.md` — §4 practice-baseline re-sync
- `plugins/harness/references/operator-playbook.md` — layer map (+continuity-companion),
  delivery-буллеты, §1, новая §5, перенумерация 6–8
- `plugins/harness/SKILL.md` — Mode 1, bootstrap-plan template
- `plugins/devlog/hooks/{hooks.json,session-start-digest.sh}` — новый хук
- `plugins/devlog/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`,
  `plugins/devlog/skills/devlog/SKILL.md` — описания дайджеста
- `README.md` — First session, devlog-блёрб, What ships
- `CHANGELOG.md` — [1.16.0]
- `.claude/skills/release/SKILL.md` — gotcha про baseline-стамп (dev-harness)
- `.claude/CLAUDE.md` — исправлена устаревшая строка «devlog версионируется независимо»
  (release.sh с 1.14.1 бампит оба plugin.json в локстепе; нашёл внешний рефутер)

## Проверка
- Скрипт-фикстуры: devlog+progress (CLOSED отфильтрован, fallback-и работают), пустой
  проект, только devlog, несуществующий каталог — все rc=0, вывод ожидаемый.
- Live e2e: `claude --print --plugin-dir plugins/devlog` в фикстуре — модель дословно
  процитировала дайджест из контекста; в пустой фикстуре — «NONE» (хук молчит).
- `claude plugin validate` — marketplace + оба плагина зелёные.
- Grep-sweep: «preferred»/«~60 lines»/«does not ship» — устаревших вхождений нет;
  нумерация playbook 1–8 согласована, внутренняя ссылка «(step 7)» поправлена.
- Внешний fresh-context code-refuter по всему диффу (20+ живых фикстур, dash/bash --posix,
  canary-проба стрипания HTML-комментариев в CLAUDE.md И rules-файлах, свой e2e через
  --plugin-dir): вердикт **stands**, 0 CRITICAL/HIGH, 2 MED + 9 LOW →
  `.claude/audits/consumer-journey-v1-16-0/AUDIT-REFUTER.json`. Устранено: кап id/title
  (2 МБ title → 195 байт дайджеста), якорь quick-state-грепа (прозаическое упоминание
  больше не тенит CLOSED-маркер), числовая сортировка id, trigger-фразы «Phase 5» и
  «refresh my practice baseline» в описании скилла, недокументированный ключ
  `description` снят из hooks.json, уточнены CHANGELOG-интро / README-контракт /
  devlog-SKILL (кап ≤3). Принято осознанно: байтовый кап может порвать хвостовой
  multibyte-символ (косметика, портабельность дороже); CLOSED — верхнерегистровая
  конвенция (workflow.md), кейс «Closed» вне конвенции.

## Related
- #8 — тот же класс фолда (drift-remediation), этот закрывает консюмерский слой доставки.
