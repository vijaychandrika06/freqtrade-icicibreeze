#!/bin/bash
# scripts/gates/p46_universe_actionable_pairs.sh
# Verification gate for Phase P46

set -euo pipefail

GATE_ID="p46"
source scripts/gates/common.sh "$GATE_ID" "$@"

PAIRS_JSON="$ARTIFACT_DIR/pairs.json"
export BREEZE_MOCK=1

# Locate SecurityMaster (Must be FO Master, used in both POS and NEG)
MASTER_FILE=$(find user_data/data/icicibreeze user_data/cache/security_master -name "FONSEScripMaster.txt" 2>/dev/null | head -n 1)
if [ -z "$MASTER_FILE" ]; then
    echo "[ERROR] SecurityMaster file not found!"
    finish_gate 1
fi
echo "Using SecurityMaster: $MASTER_FILE"

if [ "$GATE_MODE" == "pos" ]; then
    echo ">>> Positive Case: Verifying actionable universe generation"
    
    $PYTHON scripts/gen_actionable_universe_pairs.py --security-master "$MASTER_FILE" --out "$PAIRS_JSON"
    
    # 1. Assert markers
    grep -q "P46_POS_PASS" "$GATE_LOG" || { echo "Marker P46_POS_PASS missing"; finish_gate 1; }
    grep -q "P46_COUNTS_OK" "$GATE_LOG" || { echo "Marker P46_COUNTS_OK missing"; finish_gate 1; }
    
    # 2. Assert constraints in JSON
    # Check that each candidate has matches the strikes_per_underlying limit (exactly 2)
    INVALID_COUNTS=$(jq -r '.candidates[].pairs | length | select(. > 2)' "$PAIRS_JSON")
    if [ -n "$INVALID_COUNTS" ]; then
        echo "[FAIL] Found candidates with more than 2 strikes: $INVALID_COUNTS"
        finish_gate 1
    fi
    
    # Check direction consistency - only one direction per underlying
    # (By design of the script, but we verify here)
    # candidates list is unique by underlying
    DUP_UNDERLYINGS=$(jq -r '.candidates[].underlying' "$PAIRS_JSON" | sort | uniq -d)
    if [ -n "$DUP_UNDERLYINGS" ]; then
        echo "[FAIL] Duplicate underlyings found: $DUP_UNDERLYINGS"
        finish_gate 1
    fi
    
    echo "P46_POS_PASS"

elif [ "$GATE_MODE" == "neg" ]; then
    echo ">>> Negative Case: Verifying clamping logic"
    
    # Request 10 strikes, expect clamp to 2
    $PYTHON scripts/gen_actionable_universe_pairs.py \
        --security-master "$MASTER_FILE" \
        --out "$PAIRS_JSON" \
        --strikes-per-underlying 10
        
    grep -q "P46_CLAMPED" "$GATE_LOG" || { echo "Marker P46_CLAMPED missing"; finish_gate 1; }
    
    MAX_COUNT=$(jq '.candidates[].pairs | length' "$PAIRS_JSON" | sort -nr | head -n 1)
    if [ "$MAX_COUNT" -gt 2 ]; then
        echo "[FAIL] Clamping failed, found $MAX_COUNT strikes"
        finish_gate 1
    fi
    
    echo "P46_NEG_PASS"
fi

finish_gate 0
