# worklog

A CLI that tracks billable work and prints an invoice-ready report. Built feature by
feature over several sessions; consultants bill clients directly off its numbers.

## Specification (settled)

- `worklog start "<task>"` records a start time; `worklog stop` closes the open entry.
  Starting while an entry is open is an error: exit 2, `an entry is already open`.
- `worklog report --from YYYY-MM-DD --to YYYY-MM-DD` prints one line per task with the
  total billable duration, then a TOTAL line. Dates are inclusive on both ends.
- Durations print as `H:MM`. Storage is a plain JSONL file at `~/.worklog/entries.jsonl`,
  one object per entry, append-only. No database, no sync, no timezone conversion:
  everything is local wall-clock time.
- `worklog report` with no entries in range prints `no entries` and exits 0.
- Every entry belongs to exactly one task name; task names are case-sensitive.

## Two details the spec fixes deliberately

- **Rounding.** Billable duration is rounded to 15-minute units. A 7-minute entry and a
  53-minute entry must both come out as a whole number of quarter-hours.
- **Weekly grouping.** `worklog report --weekly` groups the same numbers by week and
  prints one line per week alongside the per-task lines.

## Stack

Python 3.12, pytest, ruff. `pip install -e .` then `pytest` and `ruff check .`.
