# Devlog TL;DR

Derived view — генерируется `rebuild-index.py` из `entries/*.md`.
Источник правды — `entries/`. **Этот файл не редактируется вручную.**

Назначение: холодный вход агента / читателя в проектную хронологию
без открытия всех entry-файлов целиком. Записи отсортированы по id desc.

---

## #32 · 2026-07-26 · Совет живёт там, где его прочтут

**Tags:** harness, evidence, bugfix, docs

Verify-after-fix по v1.19.8 — правки, снятые с трёх major-находок свежего рефутера, отданы ему же на перепроверку. Вердикт stands: все три держатся, регрессии того класса, ради которого дифф существовал, нет. Но с диффом пришли три minor, и одна из них — не про формулировку, а…

[→ entries/0032-sovet-zhivet-tam-gde-ego-prochtut.md](entries/0032-sovet-zhivet-tam-gde-ego-prochtut.md)

---

## #31 · 2026-07-26 · Свежий рефутер нашёл то, что пережило три прохода

**Tags:** harness, evidence, bugfix, docs, adr

Финальный полный аудит перед закрытием сессии — впервые все три роли, включая process-auditor, который за день ни разу не запускался, и нового рефутера без контекста предыдущих проходов. Прежний рефутер к этому моменту трижды проходил по тому же материалу и завершил петлю…

[→ entries/0031-svezhiy-refuter-nashel-to-chto-perezhilo-tri-prokhoda.md](entries/0031-svezhiy-refuter-nashel-to-chto-perezhilo-tri-prokhoda.md)

---

## #30 · 2026-07-26 · Петля верификации сошлась вхолостую

**Tags:** harness, evidence, docs, adr

Третий проход рефутера — узкий, только по диффу v1.19.6, с явным запретом переоткрывать 13 уже закрытых находок. Вопросов было два: закрыты ли три регрессии из прошлого раунда и внёс ли этот дифф что-то новое. Ответ: clean — loop can terminate. Все три закрыты, новых…

[→ entries/0030-petlya-verifikatsii-soshlas-vkholostuyu.md](entries/0030-petlya-verifikatsii-soshlas-vkholostuyu.md)

---

## #29 · 2026-07-26 · Регрессия внутри правки: строка мерилась не на том уровне

**Tags:** harness, bugfix, evidence, config

Рефутеру, закрывшему аудит v1.19.5, был отправлен второй запрос: проверить, что правки действительно закрывают его же находки, а не переформулируют их. Результат — 13 closed, 1 partially closed, 0 still open, и 3 проблемы, внесённых самой правкой. Ровно тот сценарий, ради…

[→ entries/0029-regressiya-vnutri-pravki-stroka-merilas-ne-na-tom-urovne.md](entries/0029-regressiya-vnutri-pravki-stroka-merilas-ne-na-tom-urovne.md)

---

## #28 · 2026-07-26 · Рефутер поймал верные выводы на недостаточных уликах

**Tags:** harness, evidence, bugfix, docs, adr

Первое применение шага B3.5, добавленного в release-ритуал часом раньше: две роли внешнего аудита свежим контекстом по релизам v1.19.2–v1.19.4. evidence-executor независимо переснял стек на собственном стенде (14 прогонов, ноль переиспользования артефактов автора) — все четыре…

[→ entries/0028-refuter-poymal-vernye-vyvody-na-nedostatochnykh-ulikakh.md](entries/0028-refuter-poymal-vernye-vyvody-na-nedostatochnykh-ulikakh.md)

---

## #27 · 2026-07-26 · Глубина аудита — свойство аудита, а не вызывающего

**Tags:** harness, bugfix, evidence, config

v1.19.3 установила: делегат, не объявивший effort:, наследует уровень сессии. Три роли внешнего аудита — evidence-executor, process-auditor, code-refuter — ничего не объявляли. Значит /external-audit, запущенный из неглубокой сессии, давал неглубокий аудит, молча и с тем же…

[→ entries/0027-glubina-audita-svoystvo-audita-a-ne-vyzyvayushchego.md](entries/0027-glubina-audita-svoystvo-audita-a-ne-vyzyvayushchego.md)

---

## #26 · 2026-07-26 · Потолок принадлежит Opus 5: делегат выходит из него сам

**Tags:** harness, evidence, feature, docs

v1.19.2 установила, что WebSearch ломает сам уровень, а не способ его задать. Оставался вопрос оператора: каких агентов создавать, чтобы у них поиск был? Ответить на него из v1.19.2 нельзя — она говорит «выше high поиска нет» и предлагает делегата на другой модели, не объясняя…

[→ entries/0026-potolok-prinadlezhit-opus-5-delegat-vykhodit-iz-nego-sam.md](entries/0026-potolok-prinadlezhit-opus-5-delegat-vykhodit-iz-nego-sam.md)

---

## #25 · 2026-07-26 · Триггер — уровень, а не env-слой: матрица не воспроизвелась

**Tags:** harness, evidence, bugfix, docs

Запись #24 отменила вывод #23 и объявила: WebSearch ломает env-слой (CLAUDE_CODE_EFFORT_LEVEL), а effortLevel в settings, флаг --effort и ultracode работают — 0/12 отказов. Вывод отгружен в v1.19.1. Живая проверка из главного треда в тот же день его опровергла: сессия при…

[→ entries/0025-trigger-uroven-a-ne-env-sloy-matritsa-ne-vosproizvelas.md](entries/0025-trigger-uroven-a-ne-env-sloy-matritsa-ne-vosproizvelas.md)

---

## #24 · 2026-07-26 · Ломает env, а не уровень: матрица без контроля

**Tags:** harness, evidence, bugfix, docs

В #23 зафиксирован вывод: на Opus 5 сессия выше high теряет WebSearch — server-tool sub-request несёт effort сессии без thinking-конфига, API отвечает 400 output_config.effort 'xhigh' is not supported when thinking is disabled. Матрица была снята добросовестно: пять точек…

[→ entries/0024-lomaet-env-a-ne-uroven-matritsa-bez-kontrolya.md](entries/0024-lomaet-env-a-ne-uroven-matritsa-bez-kontrolya.md)

---

## #23 · 2026-07-26 · Один файл несёт версию: детектор вместо вычитки

**Tags:** docs, harness, audit

Версионный пин, продублированный в двух живых доках, протухает в одном из них молча: ничего не падает, два файла просто расходятся, и читатель верит тому, который открыл. Кит проезжал по этому классу три апгрейда модели подряд (4.7 → 4.8 → 5), каждый раз пин ловился вручную и…

[→ entries/0023-odin-fayl-neset-versiyu-detektor-vmesto-vychitki.md](entries/0023-odin-fayl-neset-versiyu-detektor-vmesto-vychitki.md)

---

## #22 · 2026-07-22 · Спека фиксирует что и зачем; соседка по брифу не прошла

**Tags:** docs, harness

Разговор, из которого растёт спека, всегда содержит реализационные реплики — имя таблицы, путь к файлу, библиотека, которую кто-то вскользь назвал. Без правила они не остаются репликами: в лабораторном A/B (~/PROJECTS/Harnesses-Claude, прогон 2026-07-22 — CC 2.1.217, Opus 4.8…

[→ entries/0022-speka-fiksiruet-chto-i-zachem-sosedka-po-brifu-ne-proshla.md](entries/0022-speka-fiksiruet-chto-i-zachem-sosedka-po-brifu-ne-proshla.md)

---

## #21 · 2026-07-20 · Заострение testing #2: красный по правильной причине

**Tags:** docs, harness

Правило #2 shipped-инвариантов testing говорило «увидь красный, прежде чем доверять тесту» — но не называло, что делает красный доверенным. Красный от случайного ImportError, опечатки в тесте или сломанного fixture — красный по неправильной причине: он доказывает, что сломан…

[→ entries/0021-zaostrenie-testing-2-krasnyy-po-pravilnoy-prichine.md](entries/0021-zaostrenie-testing-2-krasnyy-po-pravilnoy-prichine.md)

---

## #20 · 2026-07-17 · README как онбординг: счастливый путь вперёд, devlog из сноски в продукт

**Tags:** docs, onboarding

README был написан для читателя, который уже знает, что такое кит. Два дефекта — оба про онбординг, не про прозу:

[→ entries/0020-readme-kak-onbording-schastlivyy-put-vpered-devlog-iz-snoski.md](entries/0020-readme-kak-onbording-schastlivyy-put-vpered-devlog-iz-snoski.md)

---

## #19 · 2026-07-17 · Указатель пережил ноту, которая его запрещает

**Tags:** harness, docs

Оператор назвал остаток, который сам же не тронул в v1.17.1, чтобы не расширять скоуп: строка change-sizing в шаблоне ## Working style заканчивается указателем — .claude/docs/workflow.md, а MVH-нота её не дропает. В MVH-проекте (CLAUDE.md + settings.json, больше ничего)…

[→ entries/0019-ukazatel-perezhil-notu-kotoraya-ego-zapreshchaet.md](entries/0019-ukazatel-perezhil-notu-kotoraya-ego-zapreshchaet.md)

---

## #18 · 2026-07-17 · Гейт, который проходил на собственном баге

**Tags:** harness, adr, testing

v1.17.0 отгружен полчаса назад. Внешняя рефутация диффа пришла после пуша (агент молчал, пока я релизил) и принесла CRITICAL: греп grep -ci continuity CLAUDE.md, написанный ровно ради ловли CLAUDE.md без continuity-duty, проходит на этом самом файле.

[→ entries/0018-geyt-kotoryy-prokhodil-na-sobstvennom-bage.md](entries/0018-geyt-kotoryy-prokhodil-na-sobstvennom-bage.md)

---

## #17 · 2026-07-17 · Continuity доезжает в проект, а гейт ловит свой же класс

**Tags:** harness, adr, config

Тест кита в чистом окружении (claude-fresh config + пустой demo-project, v1.16.3) вскрыл два разрыва. Оператор поймал руками то, что должен был поймать механический гейт.

[→ entries/0017-continuity-doezzhaet-v-proekt-a-geyt-lovit-svoy-zhe-klass.md](entries/0017-continuity-doezzhaet-v-proekt-a-geyt-lovit-svoy-zhe-klass.md)

---

## #16 · 2026-07-17 · tools: — это allowlist, и цена ошибки асимметрична

**Tags:** adr, harness

Открытый хвост #12 — аудиторские роли объявляют Grep/Glob, которых в окружении нет — закрыт замером, и вывод противоположен ожидаемому: чинить нечего, а «замер на нескольких окружениях» вообще не тот рычаг. Правку блокирует асимметрия allowlist'а, а не количество обследованных…

[→ entries/0016-tools-eto-allowlist-i-tsena-oshibki-asimmetrichna.md](entries/0016-tools-eto-allowlist-i-tsena-oshibki-asimmetrichna.md)

---

## #15 · 2026-07-16 · Детект-гейты читают активный config dir, не хардкод ~/.claude

**Tags:** harness, portability, silent-wrong

Kit хардкодил ~/.claude/ в исполняемых проверках. Claude Code переносит весь конфиг через CLAUDE_CONFIG_DIR (демо-стенды, контейнеры, CI) — и под переопределением гейты читали операторский профиль вместо активного, делая вывод о чужом окружении. Класс silent-wrong: ошибки нет…

[→ entries/0015-detekt-geyty-chitayut-aktivnyy-config-dir-ne-khardkod-claude.md](entries/0015-detekt-geyty-chitayut-aktivnyy-config-dir-ne-khardkod-claude.md)

---

## #14 · 2026-07-16 · Безопасная проба кита: два адресата, два текста

**Tags:** docs, harness

Установка кита ничего не пишет в ~/.claude — но это утверждение, и у потенциального пользователя нет причин принимать его на веру. Способа попробовать кит, ничего не трогая, в README не было. Заявка была сформулирована как «добавить DEMO.md, чтоб пользователи могли безопасно…

[→ entries/0014-bezopasnaya-proba-kita-dva-adresata-dva-teksta.md](entries/0014-bezopasnaya-proba-kita-dva-adresata-dva-teksta.md)

---

## #13 · 2026-07-16 · Оракул — это команда, а не файл

**Tags:** docs, harness

Phase 5 item 1 предписывал авторить init.sh каждому долгоживущему проекту: альтернатива — «or documented one-liner» — пряталась в скобках посреди абзаца, под жирным «Runnable oracle + env init», и де-факто дефолт читался как «сочини файл». Второй энтрипойнт, гоняющий те же…

[→ entries/0013-orakul-eto-komanda-a-ne-fayl.md](entries/0013-orakul-eto-komanda-a-ne-fayl.md)

---

## #12 · 2026-07-16 · Правила-пустышки в шаблоне settings.json

**Tags:** bugfix, harness

Шаблон settings.json из Phase 3 отдавал правила, которые движок парсит и никогда не матчит: Glob(./) и Grep(./) в allow. Нашлось живым прогоном, не ревью — в конфиге оператора, куда попало прямо из чеклиста. Шаблон — ровно то место, где no-op размножается в каждый проект…

[→ entries/0012-pravila-pustyshki-v-shablone-settings-json.md](entries/0012-pravila-pustyshki-v-shablone-settings-json.md)

---

## #11 · 2026-07-16 · Один источник истины: плагины догфудятся симлинком

**Tags:** refactor, harness

Проверка операторского окружения показала, что источником для devlog был не плагин, а личные копии: скилл-форк от 11 июня и SessionStart-хук, дублирующий поставляемый. Сегодняшний фикс хука пришлось применять дважды вручную — в личную копию и в shipped. Это признак, по которому…

[→ entries/0011-odin-istochnik-istiny-plaginy-dogfudyatsya-simlinkom.md](entries/0011-odin-istochnik-istiny-plaginy-dogfudyatsya-simlinkom.md)

---

## #10 · 2026-07-16 · SessionStart-дайджест: ограниченность как инвариант

**Tags:** bugfix, harness

Дайджест из #9 при проверке оказался способен затопить контекст: 10-мегабайтный tldr.md давал 10 МБ stdout (~2.5M токенов) за 0.6 с — инжектированных дословно до первой реплики оператора, в любом каталоге, включая свежеклонированный чужой репо. Downstream-обрезки нет…

[→ entries/0010-sessionstart-daydzhest-ogranichennost-kak-invariant.md](entries/0010-sessionstart-daydzhest-ogranichennost-kak-invariant.md)

---

## #9 · 2026-07-16 · Consumer-journey fold v1.16.0: baseline-гарды, SessionStart-дайджест, README first-session

**Tags:** feature, harness

Fresh-context аудит того, как кит приземляется на чужую машину (без личных хуков и lab-правил), показал: слой доставки настолько несогласован, что внедрение читается хуже «чистого» Claude Code. Шесть находок: (1) догфуд-асимметрия — provenance baseline'а ссылается на дисциплину…

[→ entries/0009-consumer-journey-fold-v1-16-0-baseline-gardy-sessionstart-da.md](entries/0009-consumer-journey-fold-v1-16-0-baseline-gardy-sessionstart-da.md)

---

## #8 · 2026-07-16 · Drift-remediation fold v1.15.0: continuity-профили, внешний refuter, blocked-схема

**Tags:** canon, d-cycle, continuity, verification, backlog, audit

Kickoff-артефакт лаборатории harness-drift-remediation.md (кросс-проектный fresh-context аудит: 4 адверсариальных harvest-агента над 37 .claude/-проектами, продолжение lab-devlog

[→ entries/0008-drift-remediation-fold-v1-15-0-continuity-profili-vneshniy-r.md](entries/0008-drift-remediation-fold-v1-15-0-continuity-profili-vneshniy-r.md)

---

## #7 · 2026-07-16 · Skill release: ритуал обновления репо — dev-harness commit vs shipped-release

**Tags:** feature, skill, dev-harness, release

За сессию release-ритуал выполнялся вручную дважды (v1.14.3, v1.14.4) одной и той же последовательностью, с повторяющимися gotcha-граблями (release.sh не стейджит .claude/devlog/; slug только через настоящий slugify; shipped-правка без бампа доставляет консюмерам ничего…

[→ entries/0007-skill-release-ritual-obnovleniya-repo-dev-harness-commit-vs.md](entries/0007-skill-release-ritual-obnovleniya-repo-dev-harness-commit-vs.md)

---

## #6 · 2026-07-16 · Docs-гигиена: снять декоративный edit-log, оставить функциональные staleness-стампы

**Tags:** docs, refactor, canon

Оператор указал на ## Provenance в practice-baseline.md и на класс «архаизмов» в справочной документации — прозу, описывающую правки самого документа: это читается как логи / AI-slop, а не польза для плагина. Инстинкт верный и совпадает с собственным правилом кита…

[→ entries/0006-docs-gigiena-snyat-dekorativnyy-edit-log-ostavit-funktsional.md](entries/0006-docs-gigiena-snyat-dekorativnyy-edit-log-ostavit-funktsional.md)

---

## #5 · 2026-07-16 · Micro external-intake 2.1.211: рефреш леджера + фолд hook-ask-floors

**Tags:** canon, refresh-ledger, native-capabilities

Refresh-ledger (harness-evolution.md) числился last-grounded на CC v2.1.210, а живой claude --version = 2.1.211. По harness-evolution.md дельта claude --version против леджера — самостоятельный триггер strip-revision (external-intake pass). Дельта минимальная (один patch), но…

[→ entries/0005-micro-external-intake-2-1-211-refresh-ledzhera-fold-hook-ask.md](entries/0005-micro-external-intake-2-1-211-refresh-ledzhera-fold-hook-ask.md)

---

## #4 · 2026-07-16 · Фолд «эмпирика > спека»: посылка ТЗ — тоже claim, измерь её до постройки

**Tags:** canon, d-cycle, verification

Watch-item из того же анализа Greenplun, что и reposition (#3). Повторяющийся паттерн: измерение опровергает не только переданный факт, но и саму посылку ТЗ. Две инстанции: (1) ложный «потолок модели» — Q4/Q23 числились ceiling'ом Qwen3, детерминированный intent-guard…

[→ entries/0004-fold-empirika-speka-posylka-tz-tozhe-claim-izmer-ee-do-postr.md](entries/0004-fold-empirika-speka-posylka-tz-tozhe-claim-izmer-ee-do-postr.md)

---

## #3 · 2026-07-16 · Reposition независимой верификации: лёгкий refute = воркхорс, 3-ролевой аудит = редкая эскалация

**Tags:** canon, d-cycle, verification

D-cycle-фолд из доказанной находки. Дисциплинарный текст (harness-discipline.md, лестница верификации) уже ставил лёгкий fresh-context вариант первым, но операторские поверхности переусиливали тяжёлый инструмент: operator-playbook.md §5 был целиком про 3-ролевой /external-audit…

[→ entries/0003-reposition-nezavisimoy-verifikatsii-legkiy-refute-vorkkhors.md](entries/0003-reposition-nezavisimoy-verifikatsii-legkiy-refute-vorkkhors.md)

---

## #2 · 2026-07-15 · Локали кита: harness на английский, devlog языко-независим

**Tags:** refactor, i18n

Кит был локале-сплит: harness-промпты частично по-русски (/external-audit, operator-playbook, harness-evolution, footer SKILL.md), а devlog-машинерия хардкодила ## Контекст в извлечении preview — плюс path-рассинхрон audits/ (мн.ч. в команде) vs audit/ (ед.ч. в playbook). Для…

[→ entries/0002-lokali-kita-harness-na-angliyskiy-devlog-yazyko-nezavisim.md](entries/0002-lokali-kita-harness-na-angliyskiy-devlog-yazyko-nezavisim.md)

---

## #1 · 2026-07-15 · Devlog companion plugin + multi-plugin marketplace layout

**Tags:** feature, plugin

Kit ссылался на devlog как на рекомендованный continuity-компонент (10 упоминаний в references/README), но сама runnable-машинерия (/devlog skill + rebuild-index.py) жила только в операторском глобальном ~/.claude/skills/devlog/. Для публичного установщика плагина это dangling…

[→ entries/0001-devlog-companion-plugin-multi-plugin-marketplace-layout.md](entries/0001-devlog-companion-plugin-multi-plugin-marketplace-layout.md)
