#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

test -f .env
test -f .venv/bin/activate
source .venv/bin/activate
export PYTHONPATH="$PWD${PYTHONPATH:+:$PYTHONPATH}"

RUN_ID="ft_debug_bundle_$(date -u +%Y%m%d_%H%M%SZ)"
OUT="user_data/generated/${RUN_ID}"
mkdir -p "${OUT}"/{meta,terminal,telemetry,logs,artifacts}

echo "${RUN_ID}" > "${OUT}/meta/run_id.txt"
date -u > "${OUT}/meta/start_utc.txt"
uname -a > "${OUT}/meta/uname.txt" || true
python --version > "${OUT}/meta/python_version.txt" 2>&1 || true
freqtrade --version > "${OUT}/meta/freqtrade_version.txt" 2>&1 || true

# Load credentials without echoing them
set +x
set -a; . ./.env; set +a
set -x

# Enforce live data path + fake money
export BREEZE_MOCK=0

RUN_MINS="${RUN_MINS:-10}"
DEBUG_LEVELS="${DEBUG_LEVELS:-1,2}"
CONFIG="${CONFIG:-user_data/config_icicibreeze.json}"
USERDIR="${USERDIR:-user_data}"
STRATEGY="${STRATEGY:-IndiaOptionsAutoStrategy}"
TELEMETRY_BIND="${TELEMETRY_BIND:-127.0.0.1}"
TELEMETRY_PORTS="${TELEMETRY_PORTS:-17100,17101,17102,17103}"

# Start UDP listeners for all ports (one file per port)
IFS=',' read -r -a PORTS <<< "${TELEMETRY_PORTS}"
for P in "${PORTS[@]}"; do
  ( nc -klu "${TELEMETRY_BIND}" "${P}" >> "${OUT}/telemetry/udp_${P}.log" ) & echo $! > "${OUT}/telemetry/udp_${P}.pid"
done
echo "UDP_LISTENERS_STARTED ${TELEMETRY_BIND} ${TELEMETRY_PORTS}" > "${OUT}/telemetry/_status.txt"

# Run debug levels sequentially
IFS=',' read -r -a LEVELS <<< "${DEBUG_LEVELS}"
for L in "${LEVELS[@]}"; do
  LTRIM="$(echo "${L}" | tr -d '[:space:]')"
  echo "RUN_DEBUG_LEVEL=${LTRIM}" | tee "${OUT}/meta/debug_${LTRIM}.txt"

  # Export FT_DEBUG for telemetry activation
  export FT_DEBUG="${LTRIM}"

  # Capture list-markets + download-data minimal (optional, helps diagnose)
  freqtrade list-markets -c "${CONFIG}" --userdir "${USERDIR}" \
    |& tee "${OUT}/terminal/list_markets_debug${LTRIM}.log" || true

  # Main dry-run trade loop (timeboxed)
  # Use -vv for more verbosity; Freqtrade does not reliably accept --debug=2 everywhere, so map:
  # debug=1 -> -v, debug=2 -> -vv (deterministic)
  if [ "${LTRIM}" = "1" ]; then
    VERB="-v"
  else
    VERB="-vv"
  fi

  timeout "${RUN_MINS}m" \
    freqtrade trade --dry-run -c "${CONFIG}" --userdir "${USERDIR}" -s "${STRATEGY}" ${VERB} \
    |& tee "${OUT}/terminal/freqtrade_trade_debug${LTRIM}.log" || true

  # Snapshot key artifacts after each run (best-effort)
  if [ -d user_data/generated/p51 ]; then
    mkdir -p "${OUT}/artifacts/p51_after_debug${LTRIM}"
    cp -a user_data/generated/p51/* "${OUT}/artifacts/p51_after_debug${LTRIM}/" || true
  fi
  if [ -f user_data/cache/security_master/latest.json ]; then
    cp -a user_data/cache/security_master/latest.json "${OUT}/artifacts/security_master_latest.json" || true
  fi
done

# Stop UDP listeners
for P in "${PORTS[@]}"; do
  if [ -f "${OUT}/telemetry/udp_${P}.pid" ]; then
    kill "$(cat "${OUT}/telemetry/udp_${P}.pid")" 2>/dev/null || true
  fi
done
date -u > "${OUT}/meta/end_utc.txt"

# Bundle
tar -czf "${OUT}.tar.gz" "${OUT}"
echo "BUNDLE=${OUT}.tar.gz"
