#!/bin/bash
# P42: Incident Response Gate
set -euo pipefail

# shellcheck source=scripts/gates/common.sh
GATE_ID="p42_incident_response"
source "$(dirname "$0")/common.sh" "$GATE_ID" "$@"

P42_OUTDIR="${ARTIFACT_DIR}"
mkdir -p "$P42_OUTDIR"

function run_pos() {
    echo ">>> Gate P42: Positive (Normal operation)..."
    
    if env BREEZE_MOCK=1 python3 -c "
import sys
import os
from pathlib import Path
sys.path.append(os.getcwd())
try:
    from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
    # Pass minimal config, BREEZE_MOCK=1 will handle the rest
    exchange = BreezeCCXT({'dry_run': True})
    ohlcv = exchange.fetch_ohlcv('RELIANCE/INR', '5m', limit=5)
    if len(ohlcv) == 5:
        sys.exit(0)
    else:
        print(f'Expected 5 bars, got {len(ohlcv)}')
        sys.exit(1)
except Exception as e:
    print(f'Error: {e}')
    sys.exit(1)
"; then
        echo "P42_POS_OK"
        return 0
    else
        echo "[FAIL] P42 Positive test failed."
        return 1
    fi
}

function run_neg() {
    echo ">>> Gate P42: Negative (Incident Responses)..."
    
    # 1. Data Fetch Failure
    echo "Testing Incident: data_fetch_fail"
    if env BREEZE_MOCK=1 FT_FAULT_INJECT=data_fetch_fail python3 -c "
import sys
import os
sys.path.append(os.getcwd())
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
from freqtrade.exceptions import OperationalException
exchange = BreezeCCXT({'dry_run': True})
try:
    exchange.fetch_ohlcv('RELIANCE/INR', '5m')
    sys.exit(1)
except OperationalException as e:
    if 'FT_FAULT_INJECT: data_fetch_fail' in str(e):
        sys.exit(0)
    sys.exit(1)
"; then
        echo "P42_NEG_DATA_FETCH_OBSERVED"
    else
        echo "[FAIL] Negative test for data_fetch_fail failed."
        return 1
    fi

    # 2. Rate Limit Trip
    echo "Testing Incident: rate_limit"
    if env BREEZE_MOCK=1 FT_FAULT_INJECT=rate_limit python3 -c "
import sys
import os
sys.path.append(os.getcwd())
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
from freqtrade.exceptions import OperationalException
exchange = BreezeCCXT({'dry_run': True})
try:
    exchange.fetch_ticker('RELIANCE/INR')
    sys.exit(1)
except OperationalException as e:
    if 'rate_limit_block' in str(e):
        sys.exit(0)
    sys.exit(1)
"; then
        echo "P42_NEG_RATE_LIMIT_OBSERVED"
    else
        echo "[FAIL] Negative test for rate_limit failed."
        return 1
    fi

    # 3. Degraded Mode Active
    echo "Testing Incident: degraded_mode"
    if env BREEZE_MOCK=1 FT_DEGRADED_MODE=1 FT_FORCE_MARKET_OPEN=1 python3 -c "
import sys
import os
sys.path.append(os.getcwd())
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
from freqtrade.exceptions import OperationalException
exchange = BreezeCCXT({'dry_run': True})
try:
    exchange.create_order('RELIANCE/INR', 'market', 'buy', 1)
    sys.exit(1)
except OperationalException as e:
    if 'degraded_block' in str(e):
        sys.exit(0)
    sys.exit(1)
"; then
        echo "P42_NEG_DEGRADED_OBSERVED"
    else
        echo "[FAIL] Negative test for degraded_mode failed."
        return 1
    fi

    echo "P42_NEG_PASS"
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
