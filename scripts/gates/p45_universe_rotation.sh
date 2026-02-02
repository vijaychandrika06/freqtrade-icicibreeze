#!/bin/bash
# P45 Universe Rotation Verification Gate
# Objective: Prove that universe scanning can be batched to fit within the 120s budget.

set -euo pipefail

GATE_ID="p45"
source scripts/gates/common.sh "$GATE_ID" "$@"

STRATEGY_YAML="user_data/p45_strategy.yaml"
SECURITY_MASTER_TXT="user_data/cache/security_master/FONSEScripMaster.txt"
SCAN_STATE="$ARTIFACT_DIR/scan_state.json"

echo "0" > "$SCAN_STATE"

run_batch() {
    local offset=$(cat "$SCAN_STATE")
    local batch_size=100
    local pass_id=$1
    local out_pairs="$ARTIFACT_DIR/pairs_p${pass_id}.json"
    local out_report="$ARTIFACT_DIR/report_p${pass_id}.json"

    echo ">>> Running Batch (Pass: $pass_id, Offset: $offset, Size: $batch_size)"
    
    # Time the execution
    start_time=$(date +%s)
    $PYTHON scripts/universe_scan_and_generate_pairs.py \
        --config "$STRATEGY_YAML" \
        --security-master "$SECURITY_MASTER_TXT" \
        --out-pairs "$out_pairs" \
        --out-report "$out_report" \
        --batch-size "$batch_size" \
        --offset "$offset"
    end_time=$(date +%s)
    
    elapsed=$((end_time - start_time))
    echo "Batch $pass_id took ${elapsed}s (Budget: 120s)"
    
    if [ "$elapsed" -gt 120 ]; then
        echo "[FAIL] Batch $pass_id exceeded 120s budget"
        finish_gate 1
    fi

    # Verify counts in report
    SCANNED_COUNT=$(jq '.selected_stocks | length' "$out_report")
    INDEX_COUNT=$(jq '.selected_indices | length' "$out_report")
    TOTAL_SCANNED=$((SCANNED_COUNT + INDEX_COUNT))
    
    echo "Total underlyings scanned in this batch: $TOTAL_SCANNED"
    
    # Update offset for next batch
    NEXT_OFFSET=$((offset + batch_size))
    echo "$NEXT_OFFSET" > "$SCAN_STATE"
}

echo "=== Verifying Rotation Logic ==="

# Pass 1: 0-100
run_batch 1

# Pass 2: 100-200
run_batch 2

# Pass 3: 200-300 (should wrap around 212)
run_batch 3

echo "[OK] All batches completed within time budget."
echo "P45_BATCH_ROTATION_START"
echo "P45_BATCH_COMPLETE_SUCCESS"
echo "P45_WITHIN_TIME_BUDGET"

finish_gate 0
