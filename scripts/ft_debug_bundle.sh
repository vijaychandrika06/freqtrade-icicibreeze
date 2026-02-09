#!/bin/bash
# Canonical Debug Bundle Runner
# Produces deterministic bundle with debug1 + debug2 logs + UDP telemetry
set -euo pipefail
cd "$(dirname "$0")/.."

# Prerequisites
test -f .env
test -f .venv/bin/activate
source .venv/bin/activate
export PYTHONPATH="$PWD${PYTHONPATH:+:$PYTHONPATH}"

# Configuration
RUN_ID="ft_debug_bundle_$(date -u +%Y%m%d_%H%M%SZ)"
OUT="user_data/generated/${RUN_ID}"
mkdir -p "${OUT}"/{meta,terminal,telemetry,logs,artifacts}

echo "${RUN_ID}" > "${OUT}/meta/run_id.txt"
date -u > "${OUT}/meta/start_utc.txt"

# Load credentials without echoing
set +x
set -a; . ./.env; set +a
set -x

# Force live data path + fake money
export BREEZE_MOCK=0

RUN_MINS="${RUN_MINS:-10}"
CONFIG="${CONFIG:-user_data/config_icicibreeze.json}"
USERDIR="${USERDIR:-user_data}"
STRATEGY="${STRATEGY:-IndiaOptionsAutoStrategy}"

# Start UDP listeners for all 4 ports
nc -klu 127.0.0.1 17100 >> "${OUT}/telemetry/udp_17100.log" &
echo $! > "${OUT}/telemetry/udp_17100.pid"
nc -klu 127.0.0.1 17101 >> "${OUT}/telemetry/udp_17101.log" &
echo $! > "${OUT}/telemetry/udp_17101.pid"
nc -klu 127.0.0.1 17102 >> "${OUT}/telemetry/udp_17102.log" &
echo $! > "${OUT}/telemetry/udp_17102.pid"
nc -klu 127.0.0.1 17103 >> "${OUT}/telemetry/udp_17103.log" &
echo $! > "${OUT}/telemetry/udp_17103.pid"

echo "UDP_LISTENERS_STARTED 127.0.0.1 17100..17103" > "${OUT}/telemetry/_status.txt"
sleep 1

# Run debug levels sequentially: 1, then 2
for DEBUG_LEVEL in 1 2; do
    echo "=== Running FT_DEBUG=${DEBUG_LEVEL} ==="
    export FT_DEBUG="${DEBUG_LEVEL}"

    # Map debug level to verbosity
    if [ "${DEBUG_LEVEL}" = "1" ]; then
        VERB="-v"
    else
        VERB="-vv"
    fi

    # Capture list-markets (minimal)
    freqtrade list-markets \
        -c "${CONFIG}" \
        --userdir "${USERDIR}" \
        |& tee "${OUT}/terminal/list_markets_debug${DEBUG_LEVEL}.log" || true

    # Main dry-run trade loop (timeboxed)
    timeout "${RUN_MINS}m" \
        freqtrade trade --dry-run \
        -c "${CONFIG}" \
        --userdir "${USERDIR}" \
        -s "${STRATEGY}" \
        ${VERB} \
        |& tee "${OUT}/terminal/freqtrade_trade_debug${DEBUG_LEVEL}.log" || true

    # Snapshot artifacts after each run
    if [ -d user_data/generated/p51 ]; then
        mkdir -p "${OUT}/artifacts/p51_after_debug${DEBUG_LEVEL}"
        cp -a user_data/generated/p51/* "${OUT}/artifacts/p51_after_debug${DEBUG_LEVEL}/" || true
    fi
    if [ -f user_data/cache/security_master/latest.json ]; then
        cp -a user_data/cache/security_master/latest.json "${OUT}/artifacts/security_master_latest.json" || true
    fi
done

# Stop UDP listeners
for PID_FILE in "${OUT}"/telemetry/udp_*.pid; do
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null || true
    fi
done
date -u > "${OUT}/meta/end_utc.txt"

# Bundle
tar -czf "${OUT}.tar.gz" "${OUT}"
echo "BUNDLE=${OUT}.tar.gz"
