# Phase P42: Incident Response Gates

## Goal

Prove fail-closed behavior under simulated infrastructure and API incidents.

## Implementation

- Added `FT_FAULT_INJECT` environment variable support to `BreezeCCXT` and `RateLimiter`.
- Implemented fault simulation hooks for:
  - `data_fetch_fail`: Mock OHLCV fetch failure.
  - `rate_limit`: Force rate limit trip.
  - `create_order_fail`: Mock order placement failure.

## Verification

The gate `scripts/gates/p42_incident_response.sh` verifies:

- **Positive**: System works normally when no faults are injected.
- **Negative**: Checks three specific failure scenarios:
  1. **Data Fetch Failure**: System detects and reports OHLCV fetch error.
  2. **Rate Limit Trip**: System correctly identifies and blocks requests when rate limited.
  3. **Degraded Mode**: System blocks entry orders when the circuit breaker is tripped or forced via `FT_DEGRADED_MODE`.

These tests ensure that the system enters a safe, predictable state during common trading failures.
