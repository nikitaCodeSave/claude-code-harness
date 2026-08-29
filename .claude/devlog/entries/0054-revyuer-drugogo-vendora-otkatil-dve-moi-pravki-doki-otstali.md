---
id: 54
date: 2026-08-29
title: "Ревьюер другого вендора откатил две мои правки: доки отстали от changelog"
tags: [harness, cross-vendor, regression, evidence]
status: complete
---

# Ревьюер другого вендора откатил две мои правки: доки отстали от changelog

## Контекст

Весь дневной аудит (#50–#53, релизы v1.23.1–1.23.4) провели пять свежих контекстов **того же
вендора**, что и автор. По выбору оператора дифф `v1.23.0..v1.23.4` отдали Codex через MCP —
ревьюеру другого вендора, у которого другие слепые пятна.

Он вернул пять находок. Три HIGH оказались верными, и две из них — **регрессы, которые я внёс
сам**, а пять моих аудиторов дружно подтвердили.

## Что было сломано

**`CLAUDE_CODE_SUBAGENT_MODEL`.** Кит v1.23.0 писал: «с 2.1.251 задаёт дефолт, а не override».
Аудитор нашёл на странице `code.claude.com/docs/en/model-config` дословное «overrides the
per-invocation `model` parameter and the subagent definition's `model` frontmatter», я перепроверил
там же — и переписал четыре места «под первоисточник».

Codex открыл локальный кэш changelog. Под заголовком `## 2.1.251`:

> Changed `CLAUDE_CODE_SUBAGENT_MODEL` to set the default subagent model rather than override
> everything: an agent definition's `model:` and an explicit per-spawn model now take precedence

**Страница отстала от релиз-ноты запущенной версии.** Кит был прав до моей правки.

**Background `&`.** Тот же класс. Аудитор глобального слоя нашёл в бинаре
`classifierApprovable: false` рядом с `circuitBreaker: "backgroundOperator"` и заключил, что
классификатор одобрить его не может. Я проверил `claude auto-mode defaults` — правил про `&` нет —
и счёл подтверждённым.

Codex показал таблицу из того же бинаря:

```js
dangerousRemoval:   {bypassImmune:true,  classifierRouted:true},
backgroundOperator: {bypassImmune:false, classifierRouted:true},
suspiciousWindowsPath:{bypassImmune:false, classifierRouted:true},
```

`classifierRouted: true`. Плюс changelog 2.1.218: «the dangerous-rm, background-`&`, and
suspicious-Windows-path checks no longer open permission dialogs; the auto-mode classifier
adjudicates them instead» — и ни одной отмены позже.

Проба, на которой я стоял, показывала только, что в **конфигурируемом** policy-листе нет правила
про `&`. Это другой вопрос. То есть я нарушил ровно то правило про охват оракула, которое
релизом раньше сам же и вписал в процедуру.

## Третья находка — механика worktree

`/fork` не «создаёт worktree лениво при первой записи». Фоновая копия **стартует в исходном
чекауте с заблокированной записью** и получает инструкцию вызвать `EnterWorktree`; изоляция
возникает только после успешного вызова. Плюс пропущенный путь `worktree.bgIsolation: "none"`.

Четвёртый за день случай, когда верное знание уже лежало в репозитории: `workflow-orchestration.md`
лаборатории прямо пишет про блокировку записи до `EnterWorktree`.

## Что изменено

Откачены обе регрессии (шесть мест в ките, глобальный baseline §7, `principles.md` лаборатории),
переписана механика worktree, разделены гарантии ledger и verification-команды, возвращён алиас
`/review` в отгружаемый `project-docs/workflow.md`.

**Новое правило в процедуру интейка:** при расхождении docs-страницы и changelog запущенной
версии — **побеждает changelog**. Страница описывает установившееся состояние и правится вручную;
релиз-нота пишется в момент изменения поведения. Кэш changelog локальный, проверка стоит грепа.
Основание — два случая, не один.

## Вывод, ради которого стоило звать другого вендора

Пять свежих контекстов одного вендора **согласованно ошиблись дважды**, потому что все пятеро
предпочли одну и ту же поверхность (docs-страницу) другой (changelog). Свежесть контекста не
лечит общий приор; §8 baseline про judge≠author получает уточнение — для фактов о рантайме
судья другого вендора ловит то, чего не ловит свой, каким бы свежим он ни был.
