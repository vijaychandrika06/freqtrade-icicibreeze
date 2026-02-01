# Phase P43: Restart Reconciliation Idempotency

## Goal

Prevent duplicate live actions and ensure deterministic state recovery after a bot restart or crash.

## Implementation

- `scripts/ops/p43_reconcile.py`: Logic to compare the local idempotency cache with the actual order state on the exchange.
- **Idempotency**: The reconciliation process is deterministic and can be repeated without side effects.
- **Detection**: Identifies "untracked" orders (exist on exchange but missing from cache) and "duplicates" (multiple orders for the same client ID).

## Verification

The gate `scripts/gates/p43_restart_reconcile.sh` verifies:

- **Positive**: Consistent state results in an `OK` status and identical outputs across multiple runs (idempotency).
- **Negative**:
  1. **Untracked Order**: Successfully detects orders on the exchange that are not in the local cache, triggering a `RECONCILE_REQUIRED` warning.
  2. **Duplicate IDs**: Detects critical failures where multiple orders share the same client ID, triggering an `ERROR` status.

This reconciliation layer provides a critical safety check for operators when resuming trading after an incident.
