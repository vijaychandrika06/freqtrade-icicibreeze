# Phase P45: Universe Scanner Batching & Rotation

## Objective

Scan all distinct option underlyings across multiple runs without exceeding the 120s per-run budget, while enforcing rate-limit safety and ensuring deterministic results.

## Design

### State Files

- **Scan State**: `user_data/cache/scan_state.json`
  Tracks the current rotation cursor and the snapshot of the Security Master it was generated from.
- **Screening Cache**: `user_data/cache/universe_screening.json`
  Accumulates scan results from multiple batches, valid until the Security Master refresh.

### State Schema

#### `scan_state.json`

```json
{
  "master_snapshot_id": "sha256_hash_of_latest_json",
  "cursor": 0,
  "batch_size": 70,
  "updated_at_utc": "2026-02-02T18:17:23Z"
}
```

#### `universe_screening.json`

```json
{
  "master_snapshot_id": "sha256_hash_of_latest_json",
  "batches": {
    "batch_0_70": { "results_summary": "..." },
    "batch_70_140": { "results_summary": "..." }
  },
  "updated_at_utc": "2026-02-02T18:17:23Z"
}
```

### Rotation & Reset Logic

1. **Snapshoting**: The scanner computes a `master_snapshot_id` by hashing `latest.json`.
2. **Reset**: If the `master_snapshot_id` in `scan_state.json` differs from the current one, the `cursor` is reset to 0 and the `screening_cache` is cleared.
3. **Batching**: The scanner selects a slice of sorted underlyings: `sorted_underlyings[cursor : cursor + batch_size]`.
4. **Wrap-around**: If `cursor >= total_underlyings`, it wraps back to 0.
5. **Pre-check**: If estimated scan time (based on 100 calls/min) > 110s, the scanner fails fast with `P45_NEG_TIME_BUDGET_PRECHECK`.

## Markers

- `P45_BATCH_ROTATION_START`: Emitted at beginning of scan.
- `P45_BATCH_COMPLETE_SUCCESS`: Emitted after successful batch scan.
- `P45_STATE_PERSISTED`: Emitted after atomic state update.
- `P45_WITHIN_TIME_BUDGET`: Emitted if runtime is within 120s.
- `P45_NEG_TIME_BUDGET_PRECHECK`: Emitted if batch size is too large.
