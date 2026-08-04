# httpping — instructions for Claude Code

## Project context

A tiny CLI that pings HTTP endpoints and reports latency. One binary, no server,
no database. Used ad hoc from a laptop; not a long-running product build.

## Stack

- Go 1.23 · standard library only · `go test ./...` · `go vet ./...`

## Conventions

- Errors are wrapped with `fmt.Errorf("...: %w", err)`; no third-party error packages.
- Table-driven tests only.

## Working style

- Think first: state assumptions; if multiple readings exist, ask; if unclear, stop and name it.
- Simplicity first: minimum code that solves it; no speculative abstraction.
- Verify: turn "fix the bug" into "write a failing test, then make it pass".
- This project is tuned for Claude 3.5 Sonnet — keep prompts short and avoid multi-step plans,
  the model loses track of them.

## Critical commands

```bash
go build ./... && go test ./... && go vet ./...
```

## What NOT to do

- Don't add dependencies. Standard library only.
