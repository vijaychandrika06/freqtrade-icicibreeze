# Feasibility Assessment - Full Universe Scanning

## 1. Quantitative Analysis

- **Distinct Underlyings**: 212 (Calculated from `latest.json` options field)
- **API Call Rate Limit**: 100 calls/minute (1.67 calls/second)
- **Scan Cost per Underlying**: 2 calls (1x `fetch_ticker` for ATM selection + 1x `fetch_ohlcv` for indicator screening)
- **Total Required Calls**: 424 calls (212 * 2)
- **Total Estimated Runtime**: **254.4 seconds**
- **SLA Budget**: **120 seconds**

### Conclusion: **NOT FEASIBLE in a single run.**

## 2. Proposed Batching & Caching Strategy

### A. Stateful Rotation (2 Batches)

Divide the 212 underlyings into two stable batches (~106 each).

- **Batch A**: Underlyings 0-105
- **Batch B**: Underlyings 106-211
- **Rotation**: Orchestrator persists `last_scanned_index` in `user_data/cache/scan_state.json`.

### B. Daily Snapshot Cache

- **SecurityMaster**: Already refreshed daily at 08:15 IST (Gate P25).
- **Scanner Results**: Persist scan results in `user_data/cache/universe_screening.json`.
- **TTL**: Results are valid until the next SecurityMaster refresh.
- **Incremental Update**: If a scan is forced before TTL expiry, the scanner only fetches data for the current batch.

### C. Determinism

- **Sort**: All underlyings are sorted alphabetically before batching.
- **Snapshot**: Output is consistent for the same SecurityMaster + Batch Index.

## 3. New Gate ID: `p45_universe_rotation`

### Objective

Prove that the scan completes within the time budget by using batch rotation and state persistence.

### Verification Flow

1. **Setup**: Initialize `scan_state.json` with `index=0`.
2. **Run 1**: Execute scanner with `--batch-size 100`.
   - **Assertion**: Total time < 120s.
   - **Assertion**: `scan_state.json` now has `index=100`.
   - **Assertion**: `pairs.json` contains first ~100 underlyings.
3. **Run 2**: Execute scanner with `--batch-size 100`.
   - **Assertion**: Total time < 120s.
   - **Assertion**: `scan_state.json` now has `index=200`.
   - **Assertion**: `pairs.json` contains underlyings 100-200.
4. **Resets**: Verify that at index > 212, it wraps back to 0.

### Expected Markers

- `P45_BATCH_ROTATION_START`
- `P45_BATCH_COMPLETE_SUCCESS`
- `P45_STATE_PERSISTED`
- `P45_WITHIN_TIME_BUDGET`
