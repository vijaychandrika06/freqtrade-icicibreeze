#!/bin/bash
# P45 Universe Rotation Verification Gate
# Objective: Prove that universe scanning can be batched to fit within the 120s budget.

set -euo pipefail

GATE_ID="p45"
source scripts/gates/common.sh "$GATE_ID" "$@"

STRATEGY_YAML="user_data/p45_strategy.yaml"
SECURITY_MASTER_TXT="user_data/cache/security_master/FONSEScripMaster.txt"
STATE_FILE="$ARTIFACT_DIR/scan_state.json"
CACHE_FILE="$ARTIFACT_DIR/universe_screening.json"

# Helper to ensure we have a full universe config
if [ ! -f "$STRATEGY_YAML" ]; then
    echo "Creating full universe strategy config..."
    jq -r '.options | map(.underlying) | unique | .[]' user_data/cache/security_master/latest.json > "$ARTIFACT_DIR/all_underlyings.txt"
    echo "universe:" > "$STRATEGY_YAML"
    echo "  indices: []" >> "$STRATEGY_YAML"
    echo "  stocks:" >> "$STRATEGY_YAML"
    sed 's/^/    - /' "$ARTIFACT_DIR/all_underlyings.txt" >> "$STRATEGY_YAML"
    cat <<EOF >> "$STRATEGY_YAML"
option_policy:
  expiry_policy: nearest
  atm_breadth: 2
  total_pairs_cap: 80
  require_two_sided: true
  include_cash_pair: true
EOF
fi

if [ "$GATE_MODE" == "pos" ]; then
    echo "=== POSITIVE CASE: Batch Rotation ==="
    rm -f "$STATE_FILE" "$CACHE_FILE"

    # 1. First Run: Cursor 0 -> 70
    echo ">>> Pass 1: Scan first batch (70)"
    $PYTHON scripts/universe_scan_and_generate_pairs.py \
        --config "$STRATEGY_YAML" \
        --security-master "$SECURITY_MASTER_TXT" \
        --out-pairs "$ARTIFACT_DIR/pairs_v1.json" \
        --state "$STATE_FILE" \
        --screening-cache "$CACHE_FILE" \
        --batch-size 70

    CURSOR=$(jq '.cursor' "$STATE_FILE")
    if [ "$CURSOR" -ne 70 ]; then
        echo "[FAIL] Expected cursor 70, got $CURSOR"
        finish_gate 1
    fi
    echo "[OK] Cursor advanced to 70"

    # 2. Second Run: Cursor 70 -> 140
    echo ">>> Pass 2: Scan second batch (70)"
    $PYTHON scripts/universe_scan_and_generate_pairs.py \
        --config "$STRATEGY_YAML" \
        --security-master "$SECURITY_MASTER_TXT" \
        --out-pairs "$ARTIFACT_DIR/pairs_v2.json" \
        --state "$STATE_FILE" \
        --screening-cache "$CACHE_FILE" \
        --batch-size 70

    CURSOR=$(jq '.cursor' "$STATE_FILE")
    if [ "$CURSOR" -ne 140 ]; then
        echo "[FAIL] Expected cursor 140, got $CURSOR"
        finish_gate 1
    fi
    echo "[OK] Cursor advanced to 140"

    # 3. Verify Markers
    grep -q "P45_BATCH_ROTATION_START" "$GATE_LOG" || { echo "P45 marker missing"; finish_gate 1; }
    grep -q "P45_STATE_PERSISTED" "$GATE_LOG" || { echo "P45 marker missing"; finish_gate 1; }
    grep -q "P45_BATCH_COMPLETE_SUCCESS" "$GATE_LOG" || { echo "P45 marker missing"; finish_gate 1; }
    echo "P45_POS_PASS"

elif [ "$GATE_MODE" == "neg" ]; then
    echo "=== NEGATIVE CASE: Time Budget Pre-check ==="
    # High batch-size to trigger failure (150 * 2 = 300 calls = 180s)
    echo ">>> Testing Oversized Batch (150)"
    $PYTHON scripts/universe_scan_and_generate_pairs.py \
        --config "$STRATEGY_YAML" \
        --security-master "$SECURITY_MASTER_TXT" \
        --out-pairs "$ARTIFACT_DIR/pairs_neg.json" \
        --state "$STATE_FILE" \
        --batch-size 150

    if grep -q "P45_NEG_TIME_BUDGET_PRECHECK" "$GATE_LOG"; then
        echo "[OK] Observed expected pre-check failure"
        echo "P45_NEG_PASS"
    else
        echo "[FAIL] P45_NEG_TIME_BUDGET_PRECHECK marker missing"
        finish_gate 1
    fi
fi

finish_gate 0
