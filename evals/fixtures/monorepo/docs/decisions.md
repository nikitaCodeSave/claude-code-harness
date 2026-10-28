# Decisions

- 2026-03-02 — Money is integer cents everywhere, never floats. In v0.3 float rounding
  double-charged 41 customers; switching to cents removed the whole class.
- 2026-05-19 — The worker retries a settlement at most 3 times, then parks it for a human.
  Unlimited retries once settled the same order twice during a ledger outage.
