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
    
    echo ">>> Gate P52: SUCCESS"
    finish_gate 0

elif [ "$GATE_MODE" == "neg" ]; then
    # Negative Case: Check behavior with empty universe/bad data?
    # For now, just a placeholder or ensure it doesn't crash on bad config (handled by scanner defaults).
    # Step 1: Run with invalid config path (should fail gracefully or exit 1)
    echo "1. Testing Invalid Config..."
    if $PYTHON scripts/universal_scanner.py --config invalid.json > /dev/null 2>&1; then
        echo "[FAIL] Should have failed with invalid config"
        finish_gate 1
    else
        echo "[OK] Failed expectedly"
    fi
    
    echo ">>> Gate P52: SUCCESS (Neg)"
    finish_gate 0

else
    echo "ERROR: Invalid mode $GATE_MODE"
    finish_gate 1
fi
