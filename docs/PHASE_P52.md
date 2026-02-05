# Phase P52: Universal Funnel & Hygiene

## Overview

The Phase P52 update introduces a high-performance filtering funnel to the Universal Scanner, ensuring only quality candidates are successfully shortlisted. It also enforces strict pairlist hygiene to prevent non-tradable instruments (like Index Spot) or invalid pairs (like BTC/USDT) from entering the trading configuration.

## Key Features

### 1. Calibrated Funnel Logic

Candidates pass through a 5-stage funnel in `modules/universal_funnel`:

1. **Static Eligibility**: Basic checks.
2. **Underlying Fast Kill**:
    - **Stock**: Min ATR% 0.65, Min Liquidity 2M.
    - **Index**: Min ATR% 0.77, Min Liquidity 50k.
3. **Chain Fast Kill**: Min ATM Volume checks (Stock 75k, Index 150k).
4. **Direction & Universe**: Trend direction and candidate selection.
5. **Scoring**: Final ranking.

### 2. Hygiene & Normalization

- **Expiry Normalization**: All option expiries are normalized to `YYYYMMDD` format via `adapters/ccxt_shim/security_master_normalize.py`.
- **Index Guard**: NIFTY/INR and BANKNIFTY/INR are explicitly blocked from the whitelist. Only Option/Future derivatives are allowed.
- **INR Enforcement**: Any pair not ending in `/INR` is automatically dropped by `scripts/make_config_with_pairs.py`.

### 3. Reporting

Detailed reports are generated at `user_data/generated/p51/shortlist_report.json`, including:

- Per-candidate rejection stage decision.
- Key metrics snapshot.
- Global stage counters.

## Configuration

Defaults are defined in `modules/universal_funnel/config.py` and can be overridden if exposed in strategy config in future updates.

## Validation

Verification is handled by `scripts/gates/p52_universal_funnel.sh`, which:

- Runs the scanner in mock mode.
- Validates reporting artifacts.
- Ensures generated config adheres to hygiene rules.
