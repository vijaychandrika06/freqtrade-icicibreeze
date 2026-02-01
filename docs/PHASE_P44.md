# Phase P44: Release Evidence Bundle Automation

## Goal

Automate the production of complete, redacted, and audit-ready release bundles containing all necessary evidence for production deployment.

## Implementation

- `scripts/collect/p44_release_bundle.sh`: Master collection script that:
  - Gathers git metadata (branch, commit).
  - Collects the latest `accept_all` execution logs and artifacts.
  - Collects Phase documentation and the Operations Runbook.
  - Generates sanitized configuration templates (redacting sensitive keys).
  - Performs a final secrets hygiene scan on the collected material.
  - Produces a timestamped, checksummed tarball in `generated/release_bundles/`.

## Security & Privacy

The collection script includes a mandatory secrets scanning step. If any patterns matching known secret keys (e.g., `BREEZE_API_SECRET`) are found in the collected evidence, the bundle generation fails immediately, preventing accidental leaks to auditors or production environments.

## Verification

The gate `scripts/gates/p44_release_bundle.sh` verifies:

- **Positive**: A valid bundle is generated, containing manifest, documentation, and checksums.
- **Negative**: The bundle generation process correctly identifies and refuses to package materials containing unredacted secrets.

This phase ensures that the transition from development to live trading is accompanied by a robust, verifiable audit trail.
