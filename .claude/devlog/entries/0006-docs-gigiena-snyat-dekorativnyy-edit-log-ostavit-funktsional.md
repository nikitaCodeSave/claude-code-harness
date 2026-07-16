---
id: 6
date: 2026-07-16
title: "Docs-гигиена: снять декоративный edit-log, оставить функциональные staleness-стампы"
tags: [docs, refactor, canon]
status: complete
---

# Docs-гигиена: снять декоративный edit-log, оставить функциональные staleness-стампы

## Контекст
Оператор указал на `## Provenance` в `practice-baseline.md` и на класс «архаизмов» в
справочной документации — прозу, описывающую правки самого документа: это читается как логи /
AI-slop, а не польза для плагина. Инстинкт верный и совпадает с собственным правилом кита
(`docs-discipline` rule 7 «current-state, not changelog»; practice-baseline §6 «atemporal facts,
not history»). Но «удалить все» — слишком крупно: часть дат-стампов в ките **функциональна по
дизайну** (staleness-машинерия), а не лог. Разделяющий тест: **дата двигает будущее действие
(re-verify / re-sync / delta-compare) → load-bearing; дата лишь фиксирует «файл редактировали»
→ декоративно.** По этому тесту функциональное (refresh-ledger, native-capabilities version-line
+ `verified DATE`/`re-ground on bump`, `shipped-by:` заголовки re-sync) оставлено нетронутым;
вырезан только декоративный слой. Выбран scope «surgical trim» (решение оператора из 4 вариантов).

## Изменения
- **`practice-baseline.md` §Provenance** переписана в current-state: снят датированный edit-log
  «re-distilled 2026-07-15 (added §1/§2/§6/§8 … lab devlog #115)»; сохранён load-bearing
  эмпирический якорь (§5/§6 zero-prompt red→green; §8 fresh-context-critic нашёл реальный баг) +
  добавлен кросс-реф на `evidence-base.md` вместо дублирования. «were deliberately removed» →
  «are deliberately omitted» (настоящее время = состояние, не история правок).
- **Сняты 2 `<!-- last-updated -->` HTML-комментария** — `harness-evolution.md` (дублировал дату
  refresh-ledger строкой выше) и `operator-playbook.md` (edit-дата + указатели на непоставляемые
  лаб-артефакты WORKFLOW.md / devlog #78–#82).
- **`evidence-base.md` grounding-стамп** синхронизирован CC v2.1.210 → v2.1.211 (протух после
  вчерашнего бампа #5; это функциональный «verified against docs on X» стамп, поэтому tracks live).

Нетронуто (функциональная провенанс, сознательно оставлено): refresh-ledger в `harness-evolution.md`;
version-line + `verified DATE`/`re-ground on bump` в `native-capabilities.md`; `shipped-by:` заголовки
project-docs (update cache key / re-sync).

## Затронутые файлы
- `plugins/harness/references/practice-baseline.md` — §Provenance current-state rewrite
- `plugins/harness/references/harness-evolution.md` — снят bottom `<!-- last-updated -->`
- `plugins/harness/references/operator-playbook.md` — снят bottom `<!-- last-updated -->`
- `plugins/harness/references/evidence-base.md` — стамп → v2.1.211
- `CHANGELOG.md`, обе `plugin.json` — bump 1.14.4 (lockstep)

## Проверка
- Разделяющий тест применён пофайлово: каждый оставленный дат-стамп двигает будущее действие
  (delta-compare / re-verify / re-sync), каждый снятый — лишь фиксировал факт правки.
- Хвосты `operator-playbook.md` / `harness-evolution.md` завершаются чисто (один trailing newline,
  без залётных двойных пустых строк) — проверено `tail -c … | cat -A`.
- Эмпирический якорь §5/§6/§8 не потерян — сохранён в Provenance + кросс-реф на `evidence-base.md`.
- Reindex (`rebuild-index.py .claude/devlog`) регенерирует index/tldr; slug файла = slugify(title).

## Related
- #5 — micro external-intake 2.1.211 (источник дрейфа стампа evidence-base, поправлен здесь)
