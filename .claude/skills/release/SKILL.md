---
name: release
description: "Провести изменение репозитория claude-code-harness от правки до origin/main — надёжно, одним ритуалом. Сначала решает развилку: правка задевает shipped-поверхность (plugins/**, README, CHANGELOG, marketplace.json) → нужен version bump + тег; или это dev-harness-фикс (.claude/**, .gitignore) → обычный commit+push без тега. Затем выполняет выбранный путь целиком: bump обоих plugin.json в локстепе, CHANGELOG-запись, devlog+reindex, staging через release.sh, commit/tag/push, верификация синка с origin. Используй ВСЕГДА, когда просят зарелизить/выкатить/обновить плагин, поднять/сменить версию, поставить тег, закоммитить и запушить изменение в этом репо, или спрашивают «нужен ли тег для этой правки». Триггеры: «зарелизь», «выкати обновление», «подними версию до X», «закоммить и запушь», «обнови плагин», «release», «ship it», «bump version». Скипай только для правок, которые заведомо не идут в git (черновики в scratchpad, чисто аналитические ответы)."
argument-hint: "[patch|minor|major | или коротко: что за изменение]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git status:*), Bash(git add:*), Bash(git commit:*), Bash(git tag:*), Bash(git push:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git rev-parse:*), Bash(git ls-remote:*), Bash(git branch:*), Bash(plugins/harness/scripts/release.sh:*), Bash(python3:*), Bash(jq:*), Bash(claude --version), Bash(tail:*), Bash(ls:*)
---

# Релиз / обновление репозитория claude-code-harness

Этот репозиторий — **source of truth публичного плагина**. Консюмеры устанавливают из
`origin/main` через `/plugin update`. Отсюда два жёстких факта, которые формируют весь ритуал:

1. **Версия в `plugin.json` — это update cache key.** Правка shipped-поверхности БЕЗ бампа
   версии доставляет подписчикам **ничего** (см. `native-capabilities.md` §Plugins). Значит любое
   изменение под `plugins/**` обязано пройти через релиз с бампом.
2. **Релиз существует только когда запушен** (коммит + тег + push в origin). Незапушенный
   релиз — это анонс в devlog без поставки. Три прошлых релиза сломались именно тут
   (desync версий, стампы на несуществующих версиях, «зарелизил в devlog, но не запушил») —
   ради этого и написан `scripts/release.sh`.

Не переизобретай механику: `plugins/harness/scripts/release.sh` уже бампит обе версии,
стережёт drift и стейджит поверхность. Этот скилл — рунбук поверх него: **решение + пред-шаги +
финиш + верификация**, то, что скрипт намеренно не делает.

---

## Шаг 0. Развилка — нужен ли тег?

Посмотри `git status` / `git diff --stat`. **Задевает ли изменение shipped-поверхность?**

- **Shipped-поверхность** = `plugins/**` · `README.md` · `CHANGELOG.md` · `.claude-plugin/marketplace.json`.
  → **Путь B (Релиз):** version bump + тег.
- **Только dev-harness** = `.claude/**` (CLAUDE.md, этот скилл, devlog-правка) · `.gitignore` ·
  `.gitattributes` · `LICENSE`.
  → **Путь A (Dev-harness commit):** обычный commit + push, **без бампа, без тега**.

Пограничный случай: изменение задевает и то, и другое (например, правка reference + правка
CLAUDE.md). Тогда это **Путь B** — раз shipped-поверхность затронута, нужен релиз; dev-harness-файлы
просто едут в том же коммите.

Ты работаешь в `main` (консюмеры ставят из `origin/main`) — релизы идут прямо в main, это
установившийся поток. Убедись, что ты на `main` и что пользователь действительно просил
опубликовать, прежде чем пушить.

---

## Путь A — dev-harness фикс (без тега)

Для изменений, которые не видны консюмеру (правки под `.claude/`, `.gitignore` и т.п.):

1. Внеси правку.
2. Если изменение значимое (не опечатка) → **devlog-запись + reindex** (см. Путь B, шаг B3 —
   процедура та же; devlog ведётся для любого значимого изменения репо, не только релизов).
3. `git add <файлы>` (+ `git add .claude/devlog/`, если была запись) → `git status` для контроля.
4. Коммит с футером `Co-Authored-By` (см. ниже) → `git push origin main`.
5. **Без** `plugin.json`-бампа и **без** тега.

---

## Путь B — релиз (shipped-поверхность изменена)

### B0. Выбери версию (semver)

Обе версии (`harness` + `devlog`) двигаются **в локстепе** одним числом — `release.sh` делает это сам.

- **patch (`x.y.Z`)** — прозаические фиксы, docs-гигиена, один D-cycle-фолд, micro external-intake,
  багфикс в скрипте. Дефолт для большинства правок кита.
- **minor (`x.Y.0`)** — новый компонент (reference/agent/command), новая способность, аддитивное
  изменение состава кита.
- **major (`X.0.0`)** — ломающее для консюмера (смена install-команды, удаление shipped-поверхности,
  на которую опираются). Редко.

Текущую версию смотри: `jq -r .version plugins/harness/.claude-plugin/plugin.json`.

### B1. Внеси правки в поверхность

Сделай фактические правки под `plugins/**`.

**Gotcha — `shipped-by` стамп.** Если правка задевает `plugins/harness/references/project-docs/*.md`,
обнови его заголовок `<!-- shipped-by: claude-code-harness vX.Y.Z … -->` на **новую** версию —
иначе `release.sh` откажет (он проверяет, что каждый изменённый project-doc несёт актуальный стамп).

**Gotcha — baseline content-version стамп.** Если правка меняет текст канонического блока в
`plugins/harness/references/practice-baseline.md` (fenced `markdown`-блок §1–8), подними его
`practice-baseline content-version`-стамп на новую версию. Правки файла ВНЕ блока (delivery
procedure, Provenance) стамп не трогают — он ключует блок, не файл. `release.sh` это НЕ
проверяет (блочный дифф механически не стережётся) — ответственность ритуала.

**Не трогай функциональные staleness-стампы без причины** (refresh-ledger в `harness-evolution.md`,
version-line + `verified DATE` в `native-capabilities.md`) — но если релиз меняет CC-версию или
grounding, синхронизируй их (это часть изменения, а не отдельная правка).

### B2. Запись в CHANGELOG.md

Добавь секцию `## [X.Y.Z] — YYYY-MM-DD` **над** предыдущей (формат Keep a Changelog; дату бери из
контекста сессии — не выдумывай). Рубрики: `Added` / `Changed` / `Fixed` / `Removed`. Одна-две строки
контекста сверху — зачем релиз. Если уместно, явно отметь, что **не** трогалось (это ловит скоуп).

### B3. devlog-запись + reindex

devlog — источник правды хронологии репо; index.json/tldr.md **генерируются** из entries.

1. **Вычисли slug настоящей функцией, не руками** (валидатор требует точного совпадения
   `slug == slugify(title)`):
   ```bash
   python3 -c "import importlib.util as u; s=u.spec_from_file_location('r','plugins/devlog/skills/devlog/rebuild-index.py'); m=u.module_from_spec(s); s.loader.exec_module(m); print(m.slugify('<ТОЧНЫЙ TITLE>'))"
   ```
2. Создай `.claude/devlog/entries/NNNN-<slug>.md` (следующий `NNNN`; frontmatter
   `id / date / title / tags / status: complete`; тело — `## Контекст / ## Изменения /
   ## Затронутые файлы / ## Проверка / ## Related`). Пиши на языке оператора (RU).
3. **Reindex как оракул** (падает на плохом slug/frontmatter — зелёный прогон = запись валидна):
   ```bash
   python3 plugins/devlog/skills/devlog/rebuild-index.py .claude/devlog
   ```

### B4. Стейджинг + guard через release.sh

```bash
plugins/harness/scripts/release.sh X.Y.Z
```
Скрипт: бампит **оба** `plugin.json`, стережёт marketplace-drift, проверяет `shipped-by` стампы,
стейджит shipped-поверхность, печатает команды commit/tag/push. **Он НЕ автокоммитит** — финиш за тобой.

**Gotcha — devlog не стейджится.** `release.sh` стейджит только shippable-поверхность; `.claude/devlog/`
(dev-harness) он намеренно не трогает. Добавь сам:
```bash
git add .claude/devlog/
```
Затем `git status --short` → убедись, что застейджено ВСЁ: оба plugin.json, CHANGELOG, правки
поверхности, entry+index.json+tldr.md. Ничего не должно висеть в untracked/unstaged.

### B5. Коммит + тег + push

```bash
git commit -m "$(cat <<'EOF'
claude-code-harness vX.Y.Z: <однострочное summary>

<1–2 абзаца: что и зачем; при желании — что осталось нетронутым>

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
git tag vX.Y.Z
git push origin main --tags
```

### B6. Верификация (релиз существует только когда запушен)

```bash
git rev-parse HEAD; git rev-parse origin/main            # должны совпасть
git ls-remote --tags origin vX.Y.Z                        # тег на remote
```
`HEAD == origin/main` **и** тег виден на remote → релиз доставлен. Иначе — не доставлен, доводи push.

---

## Класс отказов, который снимает этот ритуал (почему шаги существуют)

- **Desync `plugin.json` ↔ marketplace** — стережёт `release.sh` (B4).
- **`shipped-by` стамп на несуществующей версии** — проверяет `release.sh` (B1/B4).
- **Релиз анонсирован в devlog, но не запушен** — ловит верификация (B6).
- **devlog-запись забыта из коммита** — ловит явный `git add .claude/devlog/` (B4).
- **Плохой devlog-slug → битый index** — снимает real-slugify + reindex-оракул (B3).
- **Правка shipped-поверхности без бампа → консюмеры получают ничего** — снимает развилка (Шаг 0 + B0).
- **Скоуп-крип** — CHANGELOG «что не трогалось» + devlog `## Затронутые файлы` держат правку хирургичной.

## Анти-паттерн

Не запускай `release.sh` для dev-harness-правки (Путь A): он забампит версии и попросит тег там, где
консюмеру нечего доставлять. Развилка (Шаг 0) — первый и главный шаг.
