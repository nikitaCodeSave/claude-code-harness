"""The only writer of the ledger. Auditors reconcile against _LOG (README)."""
_LOG: list[tuple[str, int]] = []
MAX_ATTEMPTS = 3  # docs/decisions.md 2026-05-19


def post(order_id: str, amount_cents: int) -> None:
    if any(o == order_id for o, _ in _LOG):
        return  # settlement is idempotent
    _LOG.append((order_id, amount_cents))


def settle(order: dict, attempt: int = 1) -> str:
    if attempt > MAX_ATTEMPTS:
        return "parked"
    post(order["order_id"], order["amount_cents"])
    return "settled"
