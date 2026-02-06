# Phase P55: Review Hardening

## Overview

This phase addresses specific code review points related to import side-effects, time determinism, and test gaps.

## Key Changes

### P55.1: Import Side Effects

- **`freqtrade/exchange/icicibreeze.py`**:
  - Moved `patch_ccxt()` call from module level to `_init_ccxt()` method.
  - Ensures `ccxt` mutation only happens when the exchange is initialized, not when the module is imported.
- **`freqtrade/exchange/common.py`**:
  - Added logging to the `try/except` block to ensure failures in shim registration are visible (previously silent `pass`).

### P55.2: Time Determinism

- **`adapters/ccxt_shim/live_readiness.py`**:
  - Refactored `LiveReadiness` static check methods (`check_deadman`, `check_readiness`) to accept an optional `clock: Clock` argument.
  - Replaced `time.time()` with `clock.now_utc().timestamp()`.
  - Imported `Clock` lazily to avoid circular imports.
- **`adapters/ccxt_shim/breeze_ccxt.py`**:
  - Updated `mock_get_quotes` and `mock_get_historical_v2` to use `get_clock().now_ist()` instead of `datetime.now()`.
  - ensures mock timestamps are controlled by `FT_IST_NOW` in env.

### P55.3: Test Gaps

- **`scripts/universal_scanner.py`**:
  - Switched to using `BreezeCCXT` instance instead of mock fallback for real mode OHLCV fetch.
  - Now attempts to fetch real data via `fetch_ohlcv` given valid credentials.
- **`scripts/p46_check_provider.py`**:
  - Implemented a true negative test path.
  - Updated `BreezeOptionChainProvider` mock to return empty chain for `underlying="FAIL"`.
  - Script now explicitly verifies that "FAIL" underlying results in an empty chain, confirming error handling logic.

## Verification

- **Gates**:
  - `p40_live_readiness_path_consistency.sh`: Verified no regression in readiness checks.
- **Scripts**:
  - `python3 scripts/p46_check_provider.py neg`: Verified new negative test path passes.
