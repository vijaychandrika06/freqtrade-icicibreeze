# Phase P54: 3P Review Fixes

## Goal

Addressed code review points related to environment parsing, path consistency, time determinism, and real-mode safety.

## Changes

### 1. Readiness Env Bool (P1)

- **File**: `adapters/ccxt_shim/live_readiness.py`
- **Change**: `_env_bool` strictly parses "1", "true", "yes", "on" as True.
- **Impact**: `BREEZE_MOCK` check is now robust against truthy strings.

### 2. Readiness Security Master Path (P2)

- **File**: `adapters/ccxt_shim/live_readiness.py`
- **Change**: Uses `security_master.find_latest_master_file` instead of hardcoded path.
- **Impact**: Consistent behavior between readiness checks and bot initialization.

### 3. Time Determinism (P3, P4)

- **Files**: `adapters/ccxt_shim/order_idempotency.py`, `adapters/ccxt_shim/health_snapshot.py`
- **Change**: Injectable `now_fn` in constructors.
- **Impact**: Allows deterministic time testing for caching and snapshots.

### 4. Fetch Balance Safety (P5)

- **File**: `adapters/ccxt_shim/breeze_ccxt.py`
- **Change**: `fetch_balance` contract implementation for Real Mode.
  - Tries SDK `get_funds` if available.
  - Returns safe "unavailable" dict instead of raising `OperationalException`.
  - Rate-limited warning logs.
- **Impact**: Prevents bot crash during balance fetch if SDK fails or is unconnected, aiding smoother startup/shutdown.

## Verification

### Gates

- **P40 (`p40_live_readiness_path_consistency`)**: Verifies Readiness passes/fails based on SecurityMaster file presence.
- **P54 (`p54_balance_contract`)**: Verifies `fetch_balance` returns valid structure in Real Mode without raising.

### Unit Tests

- `tests/test_live_readiness_env_bool.py`: Strict boolean parsing.
- `tests/test_live_readiness_security_master_path.py`: Dynamic path lookup.
- `tests/test_order_idempotency_time_inject.py`: Injected time usage.
- `tests/test_health_snapshot_time_inject.py`: Injected time usage.
- `tests/exchange/test_icicibreeze_balance_contract.py`: Contract shape and no-raise behavior.
