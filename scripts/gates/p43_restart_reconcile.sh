#!/bin/bash
# P43: Restart Reconciliation Gate
set -euo pipefail

# shellcheck source=scripts/gates/common.sh
GATE_ID="p43_restart_reconcile"
source "$(dirname "$0")/common.sh" "$GATE_ID" "$@"

P43_OUTDIR="${ARTIFACT_DIR}"
mkdir -p "$P43_OUTDIR"

MOCK_CACHE="${P43_OUTDIR}/mock_cache.json"
MOCK_EXCHANGE="${P43_OUTDIR}/mock_exchange.json"

function run_pos() {
    echo ">>> Gate P43: Positive (Consistent State)..."
    
    # 1. Setup consistent state
    echo '{"ft_123456789012": 1700000000}' > "$MOCK_CACHE"
    echo '[{"clientOrderId": "ft_123456789012", "id": "1", "symbol": "RELIANCE/INR", "side": "buy", "status": "open"}]' > "$MOCK_EXCHANGE"
    
    # 2. Run reconcile first time
    POS1="${P43_OUTDIR}/pos1.json"
    python3 scripts/ops/p43_reconcile.py --cache "$MOCK_CACHE" --mock-exchange "$MOCK_EXCHANGE" > "$POS1"
    
    # 3. Verify OK status
    if grep -q '"status": "OK"' "$POS1"; then
        echo "P43_RECONCILE_OK"
    else
        echo "[FAIL] Reconciliation failed for consistent state."
        cat "$POS1"
        return 1
    fi

    # 4. Idempotency Check: Run second time, verify identical output
    POS2="${P43_OUTDIR}/pos2.json"
    python3 scripts/ops/p43_reconcile.py --cache "$MOCK_CACHE" --mock-exchange "$MOCK_EXCHANGE" > "$POS2"
    
    if diff "$POS1" "$POS2"; then
        echo "P43_IDEMPOTENCY_OK"
    else
        echo "[FAIL] Reconciliation is NOT idempotent!"
        return 1
    fi
    
    echo "P43_POS_PASS"
    return 0
}

function run_neg() {
    echo ">>> Gate P43: Negative (Inconsistent States)..."
    
    # 1. Untracked Order (in exchange but NOT in cache)
    echo 'Testing scenario: Untracked Order'
    echo '{}' > "$MOCK_CACHE"
    echo '[{"clientOrderId": "ft_untracked1", "id": "1", "symbol": "RELIANCE/INR", "side": "buy"}]' > "$MOCK_EXCHANGE"
    
    OUT_NEG1="${P43_OUTDIR}/neg1.json"
    python3 scripts/ops/p43_reconcile.py --cache "$MOCK_CACHE" --mock-exchange "$MOCK_EXCHANGE" > "$OUT_NEG1"
    
    if grep -q '"status": "RECONCILE_REQUIRED"' "$OUT_NEG1" && grep -q '"ft_untracked1"' "$OUT_NEG1"; then
        echo "P43_NEG_UNTRACKED_OK"
    else
        echo "[FAIL] Failed to detect untracked order."
        cat "$OUT_NEG1"
        return 1
    fi

    # 2. Duplicate OrderIDs (multiple orders with same clientOrderId)
    echo 'Testing scenario: Duplicate OrderIDs'
    echo '{"ft_dup": 1700000000}' > "$MOCK_CACHE"
    echo '[{"clientOrderId": "ft_dup", "id": "1"}, {"clientOrderId": "ft_dup", "id": "2"}]' > "$MOCK_EXCHANGE"
    
    OUT_NEG2="${P43_OUTDIR}/neg2.json"
    # Reconcile script exits 1 on ERROR (duplicates)
    if python3 scripts/ops/p43_reconcile.py --cache "$MOCK_CACHE" --mock-exchange "$MOCK_EXCHANGE" > "$OUT_NEG2"; then
        echo "[FAIL] Reconcile script should have exited with error for duplicates."
        return 1
    fi
    
    if grep -q '"status": "ERROR"' "$OUT_NEG2" && grep -q '"duplicates_found": 1' "$OUT_NEG2"; then
        echo "P43_NEG_DUPLICATE_OK"
    else
        echo "[FAIL] Failed to detect duplicate orders."
        cat "$OUT_NEG2"
        return 1
    fi

    echo "P43_NEG_PASS"
    return 0
}

# Parse mode
GATE_MODE="pos"
for i in "$@"; do
    case $i in
        --mode=*)
            GATE_MODE="${i#*=}"
            shift
            ;;
    esac
done

if [ "$GATE_MODE" == "pos" ]; then
    run_pos
elif [ "$GATE_MODE" == "neg" ]; then
    run_neg
else
    echo "Unknown mode: $GATE_MODE"
    exit 1
fi
