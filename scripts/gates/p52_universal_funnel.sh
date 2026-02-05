#!/bin/bash
# P52 Universal Funnel Gate
# Verifies:
# 1. Scanner runs with Universal Funnel logic.
# 2. Stage counters are produced in logs.
# 3. Artifact contains P52 metrics.

set -euo pipefail

GATE_ID="p52"
source scripts/gates/common.sh "$GATE_ID" "$@"

export PYTHONPATH="$PWD${PYTHONPATH:+:$PYTHONPATH}"
export BREEZE_MOCK=1

echo ">>> Gate P52: Universal Funnel... ($GATE_MODE)"

if [ "$GATE_MODE" == "pos" ]; then
    # Positive Case: Run scanner
    echo "1. Running Universal Scanner (Mock)..."
    LOG_FILE="$ARTIFACT_DIR/scanner.log"
    
    # Run scanner (should succeed in mock mode)
    $PYTHON scripts/universal_scanner.py --config user_data/config_icicibreeze.json > "$LOG_FILE" 2>&1 || finish_gate $?
    
    echo "2. Validating Logs for Stage Counters..."
    if grep -q "P52_STAGE_COUNTS" "$LOG_FILE"; then
         echo "[OK] Found Stage Counters"
    else
         echo "[FAIL] Stage Counters Missing"
         tail -n 20 "$LOG_FILE"
         finish_gate 1
    fi
    
    echo "3. Validating Artifact Output..."
    REPORT_FILE="user_data/generated/p51/shortlist_report.json"
    if [ -f "$REPORT_FILE" ]; then
         echo "[OK] Report file exists"
         # specific check for config_used
         if grep -q "config_used" "$REPORT_FILE"; then
              echo "[OK] Config Used logged in report"
         else
              echo "[FAIL] Config Used missing in report"
              finish_gate 1
         fi
    else
         echo "[FAIL] Report file missing"
         finish_gate 1
    fi
    
    echo "4. Verifying Pair Config Generation & Hygiene..."
    PAIRS_FILE="user_data/generated/p51/pairs.json"
    if [ ! -f "$PAIRS_FILE" ]; then
         echo "[FAIL] pairs.json missing"
         finish_gate 1
    fi
    
    # Run make_config
    GEN_CONFIG="user_data/generated/p52_temp_config.json"
    $PYTHON scripts/make_config_with_pairs.py --base user_data/config_icicibreeze.json --pairs "$PAIRS_FILE" --out "$GEN_CONFIG" || finish_gate 1
    
    # Check Hygiene
    if grep -q "NIFTY/INR" "$GEN_CONFIG"; then
         echo "[FAIL] Found NIFTY/INR in generated config (Index Hygiene Fail)"
         finish_gate 1
    fi
    if grep -q "BTC/USDT" "$GEN_CONFIG"; then
         echo "[FAIL] Found BTC/USDT in generated config (Hygiene Fail)"
         finish_gate 1
    fi
    
    echo "[OK] Config generated without invalid pairs"
    
    echo ">>> Gate P52: SUCCESS"
    finish_gate 0

elif [ "$GATE_MODE" == "neg" ]; then
    # Negative Case: Hygiene Rejection
    echo "1. Testing Hygiene Rejection in MakeConfig..."
    DIRTY_PAIRS="user_data/generated/p52_dirty.json"
    echo '["BTC/USDT", "ETH/USD", "RELIANCE/INR", "NIFTY/INR"]' > "$DIRTY_PAIRS"
    DIRTY_OUT="user_data/generated/p52_dirty_config.json"
    
    $PYTHON scripts/make_config_with_pairs.py --base user_data/config_icicibreeze.json --pairs "$DIRTY_PAIRS" --out "$DIRTY_OUT" || finish_gate 1
    
    # Verification
    if grep -q "BTC/USDT" "$DIRTY_OUT"; then
         echo "[FAIL] BTC/USDT was NOT dropped"
         finish_gate 1
    fi
    if grep -q "NIFTY/INR" "$DIRTY_OUT"; then
         echo "[FAIL] NIFTY/INR was NOT dropped"
         finish_gate 1
    fi
    if grep -q "RELIANCE/INR" "$DIRTY_OUT"; then
         echo "[OK] RELIANCE/INR preserved"
    else
         echo "[FAIL] RELIANCE/INR lost"
         finish_gate 1
    fi

    echo ">>> Gate P52: SUCCESS (Neg)"
    finish_gate 0

else
    echo "ERROR: Invalid mode $GATE_MODE"
    finish_gate 1
fi
