---
id: 21
date: 2026-07-20
title: "Заострение testing #2: красный по правильной причине"
tags: [docs, harness]
status: complete
---

# Заострение testing #2: красный по правильной причине

## Контекст
Правило #2 shipped-инвариантов testing говорило «увидь красный, прежде чем доверять тесту» — но
не называло, что делает красный доверенным. Красный от случайного `ImportError`, опечатки в тесте
или сломанного fixture — красный по неправильной причине: он доказывает, что сломан харнесс, а не
что тест ловит целевое поведение. Сессия, принимающая любой красный за зелёный свет, отгружает
тест, который никогда не сторожил то, что назван сторожить.

Заострение пришло из лаборатории (`~/PROJECTS/Harnesses-Claude`): 2026-07-20 там прогнали
multi-agent harvest-workflow по внешнему agent-harness проекту (Cursor/Codex/Claude). Из 39
дедуп-приёмов строгий adopt-on-proof-фильтр пропустил ровно **один** как немедленное
заострение — уточнение testing #2. Остальные 38 — либо уже есть у нас (HAVE), либо решают чужие
проблемы (multi-IDE rule-drift, weak-model step-skipping, marketplace-дистрибуция) и отклонены как
out-of-scope. Лабораторный operational-rule уже несёт ту же фразу; эта запись — доведение до
**отгружаемой** выжимки, чтобы заострение попадало в target-проекты, а не осталось в лаборатории.

## Изменения
- **testing rule #2 теперь называет, что делает красный доверенным**
  (`plugins/harness/references/project-docs/testing.md`): после «…before trusting it.» и перед
  «Red→green ordering…» вставлено одно предложение — *«The red must come from the assertion you
  targeted — not an incidental ImportError, typo, or broken fixture; otherwise the red proves
  nothing.»* Больше в файле ничего не переписано.
- **shipped-by stamp поднят `v1.9.2 → v1.17.4`** — правка содержательная (текст блока изменился),
  поэтому per-file provenance двигается вместе с ним; installed-копии получат re-sync offer на
  следующем аудите.
- **Version bump `1.17.3 → 1.17.4`** (patch — уточнение invariant-текста) только в
  `plugins/harness/.claude-plugin/plugin.json`. `marketplace.json` — path-source, версию не несёт,
  не тронут. Плагин `devlog` не затронут — его версия не бампалась.
- **CHANGELOG `[1.17.4]`** — что изменено + провенанс (harvest внешнего agent-harness проекта,
  дистилляция из лаборатории).
- **Back-pocket**: второй по рангу кандидат harvest'а — «skill бандлит stdlib-оракул» — оставлен под
  наблюдением (adopt-on-proof), в этом релизе не принят.

## Затронутые файлы
- `plugins/harness/references/project-docs/testing.md` — rule #2 +1 предложение; stamp `v1.9.2 → v1.17.4`
- `plugins/harness/.claude-plugin/plugin.json` — `version` `1.17.3 → 1.17.4`
- `CHANGELOG.md` — запись `[1.17.4]`

`marketplace.json` и `plugins/devlog/**` не тронуты намеренно.

## Проверка
- **Single-source**: `grep` по репо — текст rule #2 живёт только в `testing.md:11`; `workflow.md`
  step 3 ссылается на «`testing.md` rule 2» (ссылка, не копия); `ImportError` / `broken fixture` /
  `proves nothing` нигде дословно не продублированы.
- **Заострение не было в shipped-файле** до правки (проверено grep'ом до вставки) — не дубль.
- **devlog-reindex не сломан**: `plugins/devlog/skills/devlog/test_rebuild_index.py` зелёный;
  `index.json` + `tldr.md` перегенерены.

## Related
- Провенанс из лаборатории `Harnesses-Claude` (testing rule #2) — та же формулировка одним слоем выше.
- #16 — тот же класс «строка читается как способность»: там оракул инвентаря = прямой вызов тула;
  здесь оракул поведения = целевой assert, а не любой красный.
