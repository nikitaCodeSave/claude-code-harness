import pytest
from api.orders import InvalidOrder, validate


def test_valid_order_passes():
    assert validate({"order_id": "o1", "amount_cents": 1250, "currency": "EUR"})["amount_cents"] == 1250


def test_float_amount_rejected():
    with pytest.raises(InvalidOrder):
        validate({"order_id": "o1", "amount_cents": 12.5, "currency": "EUR"})
