#!/usr/bin/env bash
# 300s smoke test runner - quick validation of core freqtrade functionality
set -euo pipefail

cd "$(dirname "$0")/.."

# Default to mock mode
export BREEZE_MOCK="${BREEZE_MOCK:-1}"

# Create output directory
mkdir -p user_data/generated

echo "=== Freqtrade 300s Smoke Test ==="
echo "BREEZE_MOCK: $BREEZE_MOCK"
echo "Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Check version
echo ">>> Checking freqtrade version..."
bash scripts/lib/ft_cmd.sh --version | tee user_data/generated/smoke_version.log

# List markets
echo ">>> Listing markets..."
bash scripts/lib/ft_cmd.sh list-markets \
    -c user_data/config_icicibreeze.json \
    --userdir user_data \
    -v | tee user_data/generated/smoke_list_markets.log

# Run trade for 5 minutes
echo ">>> Running trade (300s timeout)..."
timeout 300 bash scripts/lib/ft_cmd.sh trade --dry-run \
    -c user_data/config_icicibreeze.json \
    --userdir user_data \
    -s IndiaOptionsAutoStrategy \
    -vv | tee user_data/generated/smoke_trade_300s.log || true

echo "Ended: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Create bundle
echo ">>> Creating bundle..."
tar -czf user_data/generated/smoke_300s_bundle.tar.gz \
    user_data/generated/smoke_version.log \
    user_data/generated/smoke_list_markets.log \
    user_data/generated/smoke_trade_300s.log

echo "=== Smoke Test Complete ==="
echo "BUNDLE=user_data/generated/smoke_300s_bundle.tar.gz"
ls -lh user_data/generated/smoke_300s_bundle.tar.gz
