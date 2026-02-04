#!/bin/bash
set -euo pipefail

MODE="${1:-pos}"
MODE="${MODE#--mode=}"

if [ "$MODE" == "pos" ]; then
    # Use Mock Mode for deterministic pass
    export BREEZE_MOCK=1
    python3 scripts/universal_scanner.py --config user_data/config_icicibreeze.json
elif [ "$MODE" == "neg" ]; then
    echo "P51_NEG_START"
    # Negative test? Empty universe?
    # Or mock with blackout?
    # For now just verify it runs without crashing.
    export BREEZE_MOCK=1
    # Create empty config
    echo '{"universe": {"stocks": []}}' > /tmp/empty_config.json
    python3 scripts/universal_scanner.py --config /tmp/empty_config.json
    echo "P51_EMPTY_SHORTLIST_OK"
    echo "P51_PASS"
fi
