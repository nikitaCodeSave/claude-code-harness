"""Тесты rebuild-index.py. Запуск: pytest test_rebuild_index.py

Регрессия 2026-06-11: чисто кириллический title давал пустой slug
(slugify выбрасывал всё кроме [a-z0-9]) — файл не проходил валидацию,
включая собственный пример из SKILL.md.

Регрессия 2026-08-03: preview тащил inline-ссылки как есть. Href, корректный
внутри entries/, в поднятом на уровень выше tldr.md не резолвится — и съедает
бюджет PREVIEW_MAX_LEN, который должен доставаться смыслу.
"""
import importlib.util
import os
import re
from pathlib import Path

_SCRIPT = Path(__file__).parent / "rebuild-index.py"
_spec = importlib.util.spec_from_file_location("rebuild_index", _SCRIPT)
ri = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(ri)


def _write_entry(devlog_root: Path, filename: str, entry_id: int, title: str) -> None:
    entries = devlog_root / "entries"
    entries.mkdir(parents=True, exist_ok=True)
    (entries / filename).write_text(
        f"---\nid: {entry_id}\ndate: 2026-06-11\ntitle: {title}\n---\n\n"
        "## Контекст\n\nТестовая запись.\n",
        encoding="utf-8",
    )


def test_slugify_pure_cyrillic_title_transliterated():
    # Пример из SKILL.md — до фикса давал пустой slug
    assert ri.slugify("Добавлена фильтрация по ключевым словам") == \
        "dobavlena-filtratsiya-po-klyuchevym-slovam"


def test_slugify_mixed_title_keeps_latin_tokens():
    assert ri.slugify("Регламент v1 released") == "reglament-v1-released"


def test_collect_accepts_pure_cyrillic_entry(tmp_path):
    _write_entry(tmp_path, "0001-dobavlena-filtratsiya-po-klyuchevym-slovam.md",
                 1, "Добавлена фильтрация по ключевым словам")
    entries, errors = ri.collect_entries(tmp_path)
    assert errors == [] and len(entries) == 1


def test_collect_accepts_legacy_slug_filename(tmp_path):
    # Файлы, созданные до транслитерации (кириллица выброшена из slug),
    # обязаны проходить валидацию без переименования
    _write_entry(tmp_path, "0002-plugin-v1-3-0.md", 2, "Релиз plugin v1.3.0")
    entries, errors = ri.collect_entries(tmp_path)
    assert errors == [] and len(entries) == 1


def test_collect_rejects_wrong_slug(tmp_path):
    _write_entry(tmp_path, "0003-sovsem-drugoy-slug.md", 3, "Релиз plugin v1.3.0")
    entries, errors = ri.collect_entries(tmp_path)
    assert len(errors) == 1 and "slug" in errors[0]


def _entry_with_heading(heading: str) -> str:
    return (f"---\nid: 1\ndate: 2026-06-11\ntitle: T\n---\n\n"
            f"# T\n\n## {heading}\n\nSummary paragraph.\n\n## Next\n\nX\n")


def test_extract_preview_language_agnostic():
    # preview берётся из первой '## '-секции независимо от языка заголовка (RU/EN/…)
    assert ri.extract_preview(_entry_with_heading("Контекст")) == "Summary paragraph."
    assert ri.extract_preview(_entry_with_heading("Context")) == "Summary paragraph."
    assert ri.extract_preview(_entry_with_heading("Kontext")) == "Summary paragraph."


def test_extract_preview_anchors_on_first_section_not_preamble():
    # Якорь — первая '## '-секция, а не преамбула между H1 и секцией.
    # Падает при захардкоженном '## Контекст' (fallback вернул бы преамбулу).
    text = ("---\nid: 1\ndate: 2026-06-11\ntitle: T\n---\n\n"
            "# T\n\nPreamble noise.\n\n## Context\n\nThe real summary.\n")
    assert ri.extract_preview(text) == "The real summary."


def _entry_with_body(body: str) -> str:
    return f"---\nid: 1\ndate: 2026-06-11\ntitle: T\n---\n\n# T\n\n## Context\n\n{body}\n"


def test_extract_preview_flattens_links_to_their_label():
    # preview — plain-текст резюме, а не markdown-фрагмент: href уходит, label остаётся.
    # Sibling-путь корректен внутри entries/, но preview живёт уровнем выше (tldr.md).
    text = _entry_with_body("Записи [#24](0024-a.md) и [#25](0025-b.md) оставляли позицию.")
    assert ri.extract_preview(text) == "Записи #24 и #25 оставляли позицию."


def test_extract_preview_flattens_external_links_and_images():
    text = _entry_with_body("См. [тред](https://example.com/x?a=1) и ![схема](img/x.png).")
    assert ri.extract_preview(text) == "См. тред и схема."


def test_extract_preview_keeps_code_spans_verbatim():
    # Содержимое code span — не markdown. Bold-regex склеивал '**' из ДВУХ разных
    # спанов в пару и съедал текст между ними: живая запись #12 показывала
    # `Glob(./**)` как Glob(./) — ровно те паттерны, о которых она написана.
    text = _entry_with_body("Команды `Glob(./**)` и `Grep(./**)` не матчат.")
    assert ri.extract_preview(text) == "Команды Glob(./**) и Grep(./**) не матчат."


def test_extract_preview_does_not_flatten_links_inside_code_spans():
    text = _entry_with_body("Команда `[x](docs/x.md)` остаётся литералом.")
    assert ri.extract_preview(text) == "Команда [x](docs/x.md) остаётся литералом."


def test_extract_preview_flattens_links_with_parens_or_title_in_href():
    # URL со скобками (Wikipedia-стиль) и title после href — валидный markdown;
    # наивный [^)]* обрывал href на первой ')' и оставлял хвост в тексте.
    assert ri.extract_preview(_entry_with_body(
        "См. [Foo](https://ru.wikipedia.org/wiki/Foo_(bar)) дальше.")) == "См. Foo дальше."
    # Все три формы title, которые допускает CommonMark
    for title in ('"версия (новая)"', "'версия'", "(версия)"):
        assert ri.extract_preview(_entry_with_body(
            f"См. [API](docs/api.md {title}) дальше.")) == "См. API дальше."


def test_extract_preview_flattens_nested_label_and_image_inside_link():
    assert ri.extract_preview(_entry_with_body(
        "См. [outer [inner]](doc.md) дальше.")) == "См. outer [inner] дальше."
    # Картинка внутри ссылки: наивный проход сшивал '[' внешней ссылки с ')'
    # картинки и синтезировал ссылку, которой во входе не было.
    assert ri.extract_preview(_entry_with_body(
        "См. [![схема](img/x.png)](full.png) дальше.")) == "См. схема дальше."


def test_extract_preview_leaves_non_links_alone():
    # Границы: экранированная скобка — не ссылка; reference-style и голые скобки
    # в тексте не трогаем (в preview нет definition, а '[1][2]' — обычный текст).
    assert ri.extract_preview(_entry_with_body(
        r"Литерал \[x](docs/x.md) дальше.")) == r"Литерал \[x](docs/x.md) дальше."
    assert ri.extract_preview(_entry_with_body(
        "Массив [1][2] и просто [текст] в скобках.")) == "Массив [1][2] и просто [текст] в скобках."
    # Destination с пробелом — не ссылка по CommonMark; проза со скобкой после
    # скобки не должна молча терять слова.
    assert ri.extract_preview(_entry_with_body(
        "Массив [0](не ссылка) важен.")) == "Массив [0](не ссылка) важен."
    assert ri.extract_preview(_entry_with_body(
        'См. [x](url "title) дальше.')) == 'См. [x](url "title) дальше.'


def test_extract_preview_unwraps_markdown_spanning_a_code_span():
    # Защита содержимого code span не должна отменять разбор разметки ВОКРУГ него:
    # emphasis, охватывающий код, и code span внутри label — обычный markdown.
    assert ri.extract_preview(_entry_with_body(
        "Это **важный `код` здесь** дальше.")) == "Это важный код здесь дальше."
    assert ri.extract_preview(_entry_with_body(
        "См. [метод `foo()`](api.md) дальше.")) == "См. метод foo() дальше."


def test_extract_preview_multi_backtick_code_span():
    # Закрывающий run обязан совпадать по длине с открывающим, иначе одиночный
    # backtick внутри спана рвёт его посередине.
    assert ri.extract_preview(_entry_with_body(
        "Команда ``echo `x`` дальше.")) == "Команда echo `x дальше."


def test_extract_preview_flattens_nested_image():
    assert ri.extract_preview(_entry_with_body(
        "![![inner](a.png)](b.png)")) == "inner"


def test_extract_preview_respects_declared_max_len():
    # SCHEMA обещает ≤280; многоточие добавлялось ПОСЛЕ среза и давало 281.
    assert len(ri.extract_preview(_entry_with_body("a" * 400))) <= ri.PREVIEW_MAX_LEN


def test_extract_preview_keeps_word_that_ends_exactly_at_the_cap():
    # Срез на MAX-1 не захватывал пробел, стоящий ровно на границе, и rfind
    # уходил к предыдущему — выбрасывая целое слово. Живьём это укоротило
    # preview записей #3 и #9 против их же прежнего вида.
    body = "a" * 200 + " " + "b" * 78 + " хвост подлиннее"
    out = ri.extract_preview(_entry_with_body(body))
    assert out == "a" * 200 + " " + "b" * 78 + "…"
    assert len(out) <= ri.PREVIEW_MAX_LEN


def test_extract_preview_link_href_does_not_eat_the_budget():
    # Схлопывание обязано случиться ДО обрезки по PREVIEW_MAX_LEN, иначе длинный
    # href вытесняет смысл: бюджет уходит на путь, хвост параграфа не доезжает.
    href = "0024-" + "a" * 200 + ".md"
    text = _entry_with_body(f"Запись [#24]({href}) оставляла позицию. Хвост доезжает.")
    assert ri.extract_preview(text) == "Запись #24 оставляла позицию. Хвост доезжает."


def test_tldr_has_no_unresolvable_relative_links(tmp_path):
    # Артефактный оракул: каждая относительная ссылка в сгенерированном tldr.md
    # обязана резолвиться от devlog root. Ловит регрессию независимо от того,
    # чинится она схлопыванием href или его переписыванием.
    entries_dir = tmp_path / "entries"
    entries_dir.mkdir(parents=True)
    (entries_dir / "0001-first.md").write_text(
        "---\nid: 1\ndate: 2026-06-11\ntitle: first\n---\n\n## Context\n\nБаза.\n",
        encoding="utf-8")
    (entries_dir / "0002-second.md").write_text(
        "---\nid: 2\ndate: 2026-06-12\ntitle: second\n---\n\n"
        "## Context\n\nПродолжает [#1](0001-first.md) и правит [спеку](../specs/s.md).\n",
        encoding="utf-8")

    entries, errors = ri.collect_entries(tmp_path)
    assert errors == []
    tldr = tmp_path / "tldr.md"
    ri.write_tldr(entries, tldr)

    broken = [
        href for _, href in re.findall(r"\[([^\]]+)\]\(([^)]+)\)", tldr.read_text(encoding="utf-8"))
        if not href.startswith(("http://", "https://", "#", "mailto:"))
        and not os.path.exists(os.path.join(tmp_path, href))
    ]
    assert broken == []
