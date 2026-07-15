"""Тесты rebuild-index.py. Запуск: pytest test_rebuild_index.py

Регрессия 2026-06-11: чисто кириллический title давал пустой slug
(slugify выбрасывал всё кроме [a-z0-9]) — файл не проходил валидацию,
включая собственный пример из SKILL.md.
"""
import importlib.util
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
