from worker import ledger


def test_post_is_idempotent():
    ledger._LOG.clear()
    ledger.post("o1", 100); ledger.post("o1", 100)
    assert ledger._LOG == [("o1", 100)]


def test_parks_after_three_attempts():
    assert ledger.settle({"order_id": "o2", "amount_cents": 5}, attempt=4) == "parked"
