# Phase P53: Telemetry & 3P Review Fixes

## Overview

This phase introduces a robust, layered telemetry system over UDP and addresses critical third-party review findings related to shadowing, fail-fast defaults, and guard enforcement.

## Telemetry System

Telemetry is emitted via UDP JSONL packets to localhost ports.

### Ports

- `17100`: Breeze (Connection, OHLCV)
- `17101`: Engine (Scanner, Scheduler)
- `17102`: Orders (Router, Risk)
- `17103`: UI (Heartbeat)

### Levels

- **0 (IDLE)**: No emission (Default).
- **1 (L1)**: System Keypoints (Init, Order Lifecycle, Errors).
  - Anti-spam: Aggregated summaries.
- **2 (L2)**: Debug Tracing.
  - Granular events (Router paths, Guard decisions).
  - Throttled (Max 5 ev/sec).

### Configuration

Set env vars:

- `TELEMETRY_LEVEL`: "0", "1", or "2".
- `TELEMETRY_BIND`: "127.0.0.1" (default).

## 3P Fixes

1. **Fail-Fast Credentials**:
    - In `real` mode, if API Key/Secret are missing, the bot raises `OperationalException` immediately on init.
    - In `mock` mode, session init is skipped.
2. **Edit Order Shadowing**:
    - Fixed `edit_order` signature to safely alias `type` -> `order_type`.
3. **Guard Enforcement**:
    - `edit_order` and `cancel_order` now explicitly check `MarketHoursGuard`.
    - `OrderRouter` emits `order_blocked` telemetry when rejecting orders.

## Deterministic Time

Introduced `adapters/time/clock.py`:

- `FT_IST_NOW`: Overrides system time for deterministic testing of Market Hours.
- `MarketHoursGuard` and `DegradedModeGuard` verify logic against this clock.
