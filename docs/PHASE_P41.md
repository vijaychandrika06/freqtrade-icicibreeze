# Phase P41: Deadman Auto-Renew

## Goal

Enable unattended operation by automatically renewing the safety deadman switch lease.

## Implementation

- `scripts/ops/p41_deadman_renew.py`: Core logic to refresh the lease file.
- `deploy/systemd/deadman-renew.service`: Systemd service to execute the renewal.
- `deploy/systemd/deadman-renew.timer`: Systemd timer to trigger renewal every 5 minutes.

## Safety Defaults

The timer is provided as a template and is NOT enabled by default. Users must explicitly enable it to permit unattended trading.

## Verification

The gate `scripts/gates/p41_deadman_auto_renew.sh` verifies:

- **Positive**: Script successfully refreshes the lease file and `LiveReadiness` detects it as fresh.
- **Negative**: `LiveReadiness` correctly blocks if the file is missing or stale (>10 mins).
