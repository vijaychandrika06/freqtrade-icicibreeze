#!/bin/bash
# P41: Deadman Auto-Renew Gate
set -euo pipefail

# shellcheck source=scripts/gates/common.sh
GATE_ID="p41_deadman_auto_renew"
source "$(dirname "$0")/common.sh" "$GATE_ID" "$@"

P41_OUTDIR="${ARTIFACT_DIR}"
mkdir -p "$P41_OUTDIR"

TEST_LEASE_FILE="${P41_OUTDIR}/deadman_lease.ok"

function run_pos() {
    echo ">>> Gate P41: Positive (Renew lease)..."
    
    # Run renewal script with custom outfile
    if python3 scripts/ops/p41_deadman_renew.py --outfile "$TEST_LEASE_FILE"; then
        echo "P41_RENEW_SCRIPT_PASS"
    else
        echo "[FAIL] P41 Renewal script failed."
        return 1
    fi

    # Verify lease file exists
    if [ ! -f "$TEST_LEASE_FILE" ]; then
        echo "[FAIL] Lease file not created."
        return 1
    fi

    # Verify freshness via LiveReadiness
    if python3 -c "
import sys
import os
from pathlib import Path
sys.path.append(os.getcwd())
from adapters.ccxt_shim.live_readiness import LiveReadiness
import adapters.ccxt_shim.live_readiness
adapters.ccxt_shim.live_readiness.DEADMAN_FILE = Path('$TEST_LEASE_FILE')
res = LiveReadiness.check_deadman()
print(res)
if res['ok']:
    sys.exit(0)
else:
    sys.exit(1)
"; then
        echo "P41_POS_PASS"
        return 0
    else
        echo "[FAIL] LiveReadiness check failed after renewal."
        return 1
    fi
}

function run_neg() {
    echo ">>> Gate P41: Negative (Expired/Missing lease)..."
    
    # 1. Missing file
    rm -f "$TEST_LEASE_FILE"
    
    if python3 -c "
import sys
import os
from pathlib import Path
sys.path.append(os.getcwd())
from adapters.ccxt_shim.live_readiness import LiveReadiness
import adapters.ccxt_shim.live_readiness
adapters.ccxt_shim.live_readiness.DEADMAN_FILE = Path('$TEST_LEASE_FILE')
res = LiveReadiness.check_deadman()
print(res)
if not res['ok'] and res['code'] == 'DEADMAN_MISSING':
    sys.exit(0)
else:
    sys.exit(1)
"; then
        echo "P41_NEG_MISSING_OK"
    else
        echo "[FAIL] Negative test for missing deadman failed."
        return 1
    fi

    # 2. Stale file (manually touch to back in time)
    touch -t 200001010000 "$TEST_LEASE_FILE"
    
    if python3 -c "
import sys
import os
from pathlib import Path
sys.path.append(os.getcwd())
from adapters.ccxt_shim.live_readiness import LiveReadiness
import adapters.ccxt_shim.live_readiness
adapters.ccxt_shim.live_readiness.DEADMAN_FILE = Path('$TEST_LEASE_FILE')
res = LiveReadiness.check_deadman()
print(res)
if not res['ok'] and res['code'] == 'DEADMAN_STALE':
    sys.exit(0)
else:
    sys.exit(1)
"; then
        echo "P41_NEG_STALE_OK"
    else
        echo "[FAIL] Negative test for stale deadman failed."
        return 1
    fi

    echo "P41_NEG_PASS"
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
