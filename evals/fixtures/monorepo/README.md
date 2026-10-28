# Orders platform

Takes customer orders (api), settles them against the ledger in the background (worker) and shows
order status to customers (web).

Run everything: `make test`. Local stack: `docker compose up`.

## Rules we learned the hard way

- Never write to the ledger table directly. Every ledger change goes through
  `worker.ledger.post()` — the auditors reconcile against its log and nothing else.
- Order payloads between api and worker follow `contracts/order.schema.json`; both sides
  validate against it.
