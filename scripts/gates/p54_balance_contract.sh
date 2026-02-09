#!/bin/bash
# P54 Balance Contract Gate
# Verifies fetch_balance does not raise in Real Mode.

GATE_ID="p54_balance_contract"
source scripts/gates/common.sh "$GATE_ID" "$@"

# Test Script
CHECK_PY="user_data/generated/check_balance_p54.py"
cat <<EOF > "$CHECK_PY"
import sys
import os
from unittest import mock
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT

mode = os.environ.get("MODE", "mock")

config = {
    "dry_run": (mode == "mock"),
    "breeze_mock": (mode == "mock"),
    "exchange": {"key": "k", "secret": "s"},
    "icicibreeze": {"session_token": "dummy"},
    "risk_guard": {"enabled": False}
}

print(f"Testing fetch_balance in {mode} mode...")

try:
    if mode == "real":
        # Mock SDK to avoid real network
        with mock.patch("adapters.ccxt_shim.breeze_ccxt.BreezeConnect"):
            ex = BreezeCCXT(config)
            bal = ex.fetch_balance()
            import json
            print(f"DEBUG: Type of bal: {type(bal)}")
            print(f"DEBUG: Bal content: {bal}")
            print(f"Balance Info: {bal.get('info')}")
            if bal['info'].get('status') == 'unavailable':
                print("[OK] Fallback returned")
            else:
                print(f"[WARN] Unexpected balance: {bal}")
    else:
        ex = BreezeCCXT(config)
        bal = ex.fetch_balance()
        if bal['free']['INR'] > 0:
            print("[OK] Mock balance returned")
        else:
             print("[FAIL] Mock balance invalid")
             sys.exit(1)

except Exception as e:
    print(f"[FAIL] fetch_balance raised exception: {e}")
    sys.exit(1)

EOF

echo ">>> [POS] Mock Mode Check"
export MODE="mock"
python3 "$CHECK_PY" || finish_gate 1

echo ">>> [POS] Real Mode Safety Check"
export MODE="real"
# Unset BREEZE_MOCK to ensure strict real mode logic is tested
unset BREEZE_MOCK
python3 "$CHECK_PY" || finish_gate 1

echo ">>> Gate P54: SUCCESS"
finish_gate 0
