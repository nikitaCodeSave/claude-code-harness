# Devlog TL;DR

Derived view — генерируется `rebuild-index.py` из `entries/*.md`.
Источник правды — `entries/`. **Этот файл не редактируется вручную.**

Назначение: холодный вход агента / читателя в проектную хронологию
без открытия всех entry-файлов целиком. Записи отсортированы по id desc.

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
