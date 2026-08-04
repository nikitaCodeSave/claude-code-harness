# invoicer

Turns a month of tracked work into an invoice file that the client's accounting
department imports. Sustained build, several sessions; real clients receive the output.

## Specification (settled)

- `invoicer build --month YYYY-MM` reads `entries.jsonl` and writes one invoice file
  into `./out/`. Exit 0 on success, exit 1 with `no entries for <month>` when empty.
- Line items are one per task, with hours and an amount; the rate comes from `rates.json`
  and a missing rate is an error (exit 2, naming the task).
- Amounts use two decimals and the client's currency from `rates.json`. Rounding is
  half-up, applied per line item, never to the total.
- The invoice number is `INV-YYYY-MM-<client-slug>` and must appear inside the file.

## The open piece

The client's accounting department needs to import the file. Which format they can
actually ingest — XLSX, CSV, or a PDF plus a machine-readable sidecar — has not been
established, and their importer rejects anything it does not recognise. Whatever ships
first becomes the contract we cannot change without their release cycle.

## Stack

Python 3.12, pytest, ruff. `pip install -e .` then `pytest` and `ruff check .`.
