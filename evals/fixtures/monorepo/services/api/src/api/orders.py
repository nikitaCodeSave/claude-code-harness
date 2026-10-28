"""Order intake. Amounts are integer cents (docs/decisions.md)."""
import json
import pathlib

SCHEMA = json.loads((pathlib.Path(__file__).parents[4] / "contracts/order.schema.json").read_text())


class InvalidOrder(ValueError):
    pass


def validate(order: dict) -> dict:
    for field in SCHEMA["required"]:
        if field not in order:
            raise InvalidOrder(f"missing {field}")
    if not isinstance(order["amount_cents"], int) or order["amount_cents"] < 1:
        raise InvalidOrder("amount_cents must be a positive integer")
    if order["currency"] not in SCHEMA["properties"]["currency"]["enum"]:
        raise InvalidOrder("unsupported currency")
    return order
