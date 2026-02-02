# Phase P46: Universe Actionable UI Pairs

## Objective

Reduce UI clutter and trade risk by filtering the universe down to high-liquidity, actionable contracts (exactly 2 strikes per underlying).

## Design

### Institutional Sniper Selection Rules

1. **Universe Slicing**:
   - Indices: NIFTY, BANKNIFTY, FINNIFTY, MIDCPNIFTY.
   - Stocks: Top 5 most liquid from Nifty 50.

2. **One Direction per Pass**:
   - Only CE **or** PE contracts are selected for a single underlying, based on the current strategy signal.

3. **Strike Quality**:
   - Target exactly 2 contracts: **ATM** and **1-ITM**.
   - Target Delta Band: **0.55 - 0.65**.

4. **Risk Guards**:
   - **Spread Guard**: Reject if (Ask - Bid) / Mid > `max_spread_pct`.
   - **Death Zone**: No stock options within 5 days of expiry (physical settlement risk).
   - **IVR Guard**: Preference for IVR < 60 to avoid volatility crush on ITM buys.

### Output Schema (`pairs.json`)

```json
{
  "generated_at": "2026-02-03T00:00:00Z",
  "mode": "mock",
  "underlyings_selected": ["NIFTY", "BANKNIFTY", "RELIANCE"],
  "candidates": [
    {
      "underlying": "RELIANCE",
      "direction": "CALL",
      "pairs": ["RELIANCE-20260224-2500-CE/INR", "RELIANCE-20260224-2480-CE/INR"],
      "reasons": ["Delta 0.61", "Spread 0.2%"]
    }
  ],
  "pair_whitelist": ["RELIANCE-20260224-2500-CE/INR", ...]
}
```

## Markers

- `P46_POS_PASS`: Successful generation of actionable pairs.
- `P46_COUNTS_OK`: Pair counts per underlying are exactly 2.
- `P46_CLAMPED`: Clamping logic for strikes_per_underlying was triggerred.
- `P46_NEG_PASS`: Negative test case passed.
