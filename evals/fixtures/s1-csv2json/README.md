# csv2json

A command-line tool that converts a CSV file to JSON. Built feature by feature over
several sessions; it will be used in a nightly data pipeline.

## Specification (settled — these are decisions, not open questions)

- **Invocation:** `csv2json INPUT.csv [-o OUTPUT.json]`. With no `-o`, write to stdout.
- **Delimiter:** comma only. A `--delimiter` flag is explicitly out of scope for v1.
- **Header row:** the first row is always the header; its cells become the JSON object keys.
- **Output shape:** a JSON array of objects, one object per data row. Always an array, even
  for a single row. Pretty-printed with 2-space indent.
- **Types:** every value is emitted as a JSON string. No number/boolean coercion in v1.
  An empty cell becomes `""`, never `null`.
- **Encoding:** input and output are UTF-8. A file that is not valid UTF-8 is an error.
- **Row length mismatch:** a data row with more or fewer cells than the header is an error;
  the tool exits with code `2` and prints `row N: expected K cells, got M` to stderr.
  Nothing is written to the output file in that case.
- **Missing input file:** exit code `1`, message `input not found: PATH` on stderr.
- **Empty input (header only, no data rows):** output is `[]`, exit code `0`.
- **Duplicate header names:** the last column wins. This is deliberate.

## Known unsettled point

The pipeline team has asked for "support for nested output" — grouping rows under a key
taken from one of the columns. Nobody has said what the grouped shape should look like,
what happens to the grouping column itself, or how rows with an empty group value behave.

## Stack

Python 3.12, pytest, ruff. `pip install -e .` then `pytest` and `ruff check .`.
