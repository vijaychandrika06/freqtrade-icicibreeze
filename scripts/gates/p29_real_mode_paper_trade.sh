#!/bin/bash
# P29: Real Mode Paper Trading
# Verifies interception of orders to local ledger.

set -euo pipefail

GATE_ID="p29"
source scripts/gates/common.sh "$GATE_ID" "$@"

if [ "$GATE_MODE" == "pos" ]; then
    echo ">>> Gate P29: Positive (Real Mode Paper Route)..."
    
    # Check for credentials
    if [ -z "${BREEZE_API_KEY:-}" ]; then
        echo ">>> WARNING: BREEZE_API_KEY not set."
        echo "P29_SKIP_MISSING_CREDS_POS"
        finish_gate 0
    fi
     
    # P29 Orderbook Check
    echo ">>> Verifying Synthetic Orderbook..."
    if python3 -c '
import os, sys
sys.path.append(os.getcwd())
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
ex = BreezeCCXT({})
ex.fetch_ticker = lambda s, p=None: {"symbol": s, "last": 2500.0, "bid": 2499.0, "ask": 2501.0}
ob = ex.fetch_order_book("RELIANCE/INR", 1)
print(f"OB: {ob}")
assert len(ob["bids"]) > 0 and len(ob["asks"]) > 0
assert ob["bids"][0][0] < ob["asks"][0][0]
'; then
        echo "P29_ORDERBOOK_OK"
    else
        echo "[FAIL] Synthetic Orderbook Check Failed."
        finish_gate 1
    fi

    # Original Paper Execution Check
    if python3 scripts/p29_check_paper_execution.py; then
        echo "P29_POS_PASS"
        finish_gate 0
    else
        echo "[FAIL] P29 Verification Script Failed."
        finish_gate 1
    fi

elif [ "$GATE_MODE" == "neg" ]; then
    echo ">>> Gate P29: Negative (Missing Creds / Invalid Config)..."
    
    # 1. Check Missing Creds
    cat <<EOF > "$ARTIFACT_DIR/neg_check.py"
import os
import sys
sys.path.append(os.getcwd())
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT

def check_missing_creds():
    exchange = BreezeCCXT({})
    if exchange.breeze is None:
        print("Success: Breeze session is None (Graceful degradation)")
        return True
    return False

if __name__ == "__main__":
    if check_missing_creds():
        sys.exit(0)
    sys.exit(1)
EOF

    if python3 "$ARTIFACT_DIR/neg_check.py"; then
        echo "P29_SKIP_MISSING_CREDS"
    else
        echo "[FAIL] Neg Mode did not skip as expected."
        finish_gate 1
    fi

    # 2. Check Invalid Spread Block
    echo ">>> Verifying Orderbook Block on Invalid Config..."
    if ! FT_SYNTH_OB_SPREAD_BPS="nan" python3 -c '
import os, sys
sys.path.append(os.getcwd())
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
ex = BreezeCCXT({})
ex.fetch_ticker = lambda s, p=None: {"symbol": s, "last": 2500.0}
ex.fetch_order_book("RELIANCE/INR", 1)
' 2>/dev/null; then
        echo "P29_NEG_ORDERBOOK_BLOCK"
    else
        echo "[FAIL] Orderbook did not block on invalid spread"
        finish_gate 1
    fi

    finish_gate 0

else
    echo "ERROR: Invalid mode"
    finish_gate 1
fi
