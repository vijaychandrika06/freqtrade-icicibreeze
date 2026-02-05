#!/bin/bash
# P40 Readiness Path Consistency Gate
# Verifies Readiness Logic respects file location and state.

GATE_ID="p40_live_readiness_path_consistency"
source scripts/gates/common.sh "$GATE_ID" "$@"

# Setup
TEST_DIR="user_data/data/icicibreeze"
mkdir -p "$TEST_DIR"
MASTER_FILE="$TEST_DIR/FONSEScripMaster.txt"

cleanup() {
    rm -f "$MASTER_FILE"
}
trap cleanup EXIT

# 1. POSITIVE: File exists, Fresh
echo ">>> [POS] Creating fresh Master File..."
touch "$MASTER_FILE"

# Run readiness check (using a snippet)
# We need to simulate readiness call.
# Simplest way is a small python script importing LiveReadiness
CHECK_SCRIPT="user_data/generated/check_readiness_p40.py"
cat <<EOF > "$CHECK_SCRIPT"
import sys
import os
from adapters.ccxt_shim.live_readiness import LiveReadiness

# Mock config
config = {
    "icicibreeze": {"session_token": "dummy"},
    "exchange": {"pair_whitelist": ["RELIANCE/INR"]}
}

# Ensure BREEZE_MOCK is set so Token check passes if we want (or we provide token)
os.environ["BREEZE_MOCK"] = "1"

res = LiveReadiness.check_readiness(config)
print(f"Result: {res['ok']} Code: {res.get('code')}")
if not res['ok']:
    sys.exit(1)
EOF

if python3 "$CHECK_SCRIPT"; then
    echo "[OK] Readiness passed with file present."
else
    echo "[FAIL] Readiness failed despite file present."
    finish_gate 1
fi

# 2. NEGATIVE: File missing
echo ">>> [NEG] Removing Master File..."
rm -f "$MASTER_FILE"

if python3 "$CHECK_SCRIPT"; then
    echo "[FAIL] Readiness passed with file MISSING!"
    finish_gate 1
else
    echo "[OK] Readiness correctly failed with file missing."
fi

echo ">>> Gate P40: SUCCESS"
finish_gate 0
