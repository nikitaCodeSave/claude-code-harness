---
id: 17
date: 2026-07-17
title: "Continuity доезжает в проект, а гейт ловит свой же класс"
tags: [harness, adr, config]
status: complete
---

# Continuity доезжает в проект, а гейт ловит свой же класс

## Контекст

Тест кита в чистом окружении (`claude-fresh` config + пустой demo-project, v1.16.3) вскрыл два
разрыва. Оператор поймал руками то, что должен был поймать механический гейт.

**Разрыв 1 — continuity не write-through.** Шаблон CLAUDE.md в Phase 2 не имел ни секции, ни
duty-строки про continuity. Phase 5 item 3 двадцатью строками описывал эпизодический слой, но
нигде не говорил «назови карьер в CLAUDE.md». Итог жёсткий: **сессия, буквально следующая
чеклисту, обязана произвести CLAUDE.md с нулём упоминаний devlog.** Phase 7 грепала ровно три
токена (`plan mode` / `fresh-context` / `size the change`) — continuity среди них не было, гейт
зелёный. При этом комментарий над грепом заявляет, что это и есть write-through-проверка,
ловящая «инструкции, оставшиеся в references вместо проекта». Она пропустила свой класс.

Нюанс, задавший форму фикса: **глубина доезжает дважды** — `practice-baseline.md` §6 и
`project-docs/workflow.md` §Continuity, обе лежали в demo-project. Не доехали только per-turn duty
и имя карьера. Значит фикс — не 14-строчная секция (как импровизировала сессия, дублируя оба
шипнутых файла), а 2–3 строки по образцу существующей `Doc-with-code`, ровно как предписывает
собственное разделение труда кита из Phase 2c: *«CLAUDE.md carries the ~per-turn duty lines;
`.claude/docs/` carries the on-demand depth»*.

**Разрыв 2 — нет политики для greenfield.** Phase 0 детектит стек из манифестов, Phase 1 требует
ARCHITECTURE/CODE-MAP «из реально прочитанного кода», Phase 7 пробит `what is the project's
stack?`. При нуле файлов не применимо ничего — сессия импровизирует политику на месте.

## Изменения

- **Phase 2, шаблон Working style** — duty-строка continuity: триггер, карьер, progress-файл,
  указатель на `.claude/docs/workflow.md`. Не пересказ baseline §6 / workflow.md §Continuity.
- **Phase 2, Reference materials** — строка `.claude/devlog/entries/` (index.json / tldr.md
  генерируемые, руками не трогать).
- **Phase 2, docs-параграф** — разведены **placeholder vs boilerplate**: запрещено выдумывать
  правдоподобный факт; честно помеченная пустая ячейка с триггером заполнения — не выдумка.
  На greenfield ARCHITECTURE/CODE-MAP пишутся помеченными стабами. Та же правка в Phase 1 table.
- **Phase 0** — «0 файлов / 0 коммитов» = валидное detected-состояние. Явный запрос полного
  набора = информированное согласие: разворачивать, не спорить. Intent неопределим → спросить
  один раз, дефолт — полный набор.
- **Phase 5 item 2** — на greenfield ledger сеется фичей `F0`, `passes: false`; session-ritual
  подхватывает её сам — добивка TBD в петле, а не в человеческой памяти.
- **Phase 5 item 3** — ссылается на duty из Phase 2 вместо описания слоя «в воздухе».
  Detect-гейт карьера как был.
- **Phase 8 (новая)** — бутстрап пишет о себе devlog-запись #1. Phase 6 «Stop» не переименована:
  она про «не добавлять машинерию», не про конец.
- **Phase 7** — четвёртый греп-токен `continuity` (carrier-agnostic). На greenfield stack-пробит
  и прогон оракула помечаются N/A-by-construction, а не «пропущены».
- **audit-checklist §4** — гэп-чек «CLAUDE.md не называет continuity-duty»: все проекты на
  ≤1.16.3 получат находку (adopt-on-proof — proof это данный прогон).
- **SKILL.md** — greenfield-строка + Phase 8 в bootstrap-абзаце и output-template.

**Пойманное рефутацией (до релиза).** Первый черновик утверждал безусловно: «The stub's fill
trigger … is the `F0` ledger feature (Phase 5, item 2)». Но Phase 5 явно скипается для
libraries / scripts / one-offs → на **несustained** greenfield нет features.json → нет F0, а стаб
уже ссылается на него. Дангл-указатель — ровно тот шум, что запрещает собственная MVH-нота
чеклиста, только в костюме подотчётности. Утверждение сделано branch-aware; та же
Phase-5-презумпция убрана из фоллбэка карьера в Phase 8 и из плейсхолдера карьера в шаблоне duty.

## Затронутые файлы

- `plugins/harness/references/bootstrap-checklist.md` — Phase 0 / 1 / 2 / 5 / 7 + новая Phase 8
- `plugins/harness/references/audit-checklist.md` — §4 гэп-чек
- `plugins/harness/SKILL.md` — Mode 1 + output-template «Bootstrap plan»
- `CHANGELOG.md`, оба `plugin.json` (1.17.0, локстеп)

**Не тронуто намеренно:** `practice-baseline.md` (content-version stamp остаётся v1.16.0 — он
advances только когда меняется текст блока) и `references/project-docs/*` (per-file `shipped-by`
остаются v1.9.2 / v1.10.1 / v1.16.1). Глубина continuity в обоих уже была верной.

## Проверка

Оракул кита — **прогон бутстрапа в чистом проекте**, не греп собственных правок. Стенд: отдельный
`CLAUDE_CONFIG_DIR`, marketplace `directory:` на этот checkout, только v1.17.0 в кэше (залипшие
v1.16.0 scope `project` + v1.16.3 scope `local` из прошлого теста вычищены — иначе тест
нерепрезентативен).

**A/B двух живых бутстрапов на 0 файлов / 0 коммитов:**

| | sustained build | library (non-sustained) |
|---|---|---|
| `grep -ci continuity CLAUDE.md` | 3 | 3 |
| `plan mode` / `fresh-context` / `size the change` | 1 / 2 / 1 | 1 / 2 / 1 |
| devlog entry #1 + регенерённый index.json | есть | есть |
| `features.json` c `F0 passes:false` | есть | **нет — Phase 5 корректно скипнут** |
| стаб ссылается на F0 | да (F0 существует) | **нет — фикс держит** |
| ARCHITECTURE/CODE-MAP помечены стабами | да | да |
| `claude --print "ok"` permission-warnings | 0 | 0 |
| CLAUDE.md строк (≤200) | 85 | 65 |

Плечо «library» — это и есть тест на пойманный рефутацией дефект: Phase 5 скипнут, features.json
нет, и стаб на несуществующий F0 **не** ссылается. Плечо «sustained» — контроль на регресс.
Карьер в обоих резолвнут в решение (`/devlog:devlog`), а не скопирован меню; плейсхолдер
`<the project's carrier>` не протёк (0 вхождений). Обе сессии дедуплицировали Working style
против practice-baseline — гвард Phase 2b жив.

**Методологические заметки (стоят дороже отдельных цифр).**
- Три первых прогона были **ложно-красными по вине стенда, не кита**: (1) `settings.json`
  перезаписан после install → `enabledPlugins` затёрт, плагины `✘ disabled`, скилл не сработал;
  (2) память от прогона №1 осталась в config dir и контаминировала №2; (3) permission-правила
  писались как `Read(/tmp/...)` вместо `Read(//tmp/...)` — **без `//` путь трактуется как
  относительный** и правило молча не матчится. Каждый раз «кит не работает» было неверным
  ответом; работал сломанный метод. Ровно тот класс, про который §1 глобального baseline:
  негативный результат — заявление, а не факт.
- `claude --print` + `acceptEdits` **не может писать `.claude/`** (встроенный sensitive-file guard;
  `Edit(.claude/**)` его не перебивает). Headless-бутстрап требует `bypassPermissions` —
  разрешено оператором для throwaway-стенда.
- Живое подтверждение собственного канона Phase 3: `Write(path)`-правило выдало
  «is not matched by file permission checks — only Edit(path) rules are». Кит про это и пишет.

**Рефутация диффа свежим контекстом** (§8 — per-change для silent-wrong-prone; проза, шипящаяся
verbatim потребителям, которые не могут перепроверить upstream, ровно этот класс) дала находку
F0/Phase-5, которая и починена выше. Отдельный сбой процесса: первый `code-refuter` ушёл с задачи
и вместо рецензии написал в репо devlog #16 (закоммичен отдельно, до релиза).

## Related

- #14 — тот же тест-стенд в чистом окружении; там он вскрыл два адресата, здесь — два разрыва
- #15 — предыдущий фолд из того же прогона (detect-гейты и активный config dir)
- #13 — «оракул — это команда, а не файл»: F0 в Phase 5 item 2 опирается на этот вывод
