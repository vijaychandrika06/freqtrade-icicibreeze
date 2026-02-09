#!/usr/bin/env bash
# P57: CCXT Registration Sanity - Ensures icicibreeze is registered in ccxt namespace
set -euo pipefail

cd "$(dirname "$0")/../.."

# Prerequisites
test -f .env
test -f .venv/bin/activate
source .venv/bin/activate
export PYTHONPATH="$PWD${PYTHONPATH:+:$PYTHONPATH}"

# Enforce mock mode
export BREEZE_MOCK=1
unset FT_DISABLE_CCXT_BOOTSTRAP || true

# Create output directory
mkdir -p user_data/generated/p57

echo "=== Gate P57: CCXT Registration Sanity ==="
echo "Run ID: $(date -u +%Y%m%d_%H%M%SZ)"

# S1: Verify ccxt.icicibreeze exists and has timeframes
echo ">>> Verifying ccxt.icicibreeze registration..."
python - <<'PY'
import ccxt
assert hasattr(ccxt, "icicibreeze"), "ccxt.icicibreeze missing (bootstrap failed)"
ex = ccxt.icicibreeze({"enableRateLimit": False})
d = ex.describe()
tfs = d.get("timeframes") or {}
assert "1m" in tfs and "5m" in tfs and "30m" in tfs and "1d" in tfs, f"timeframes incomplete: {sorted(tfs.keys())}"
print("P57_OK_CCXT_REGISTERED", sorted(tfs.keys())[:10])
PY

echo "[OK] ccxt.icicibreeze registered with timeframes"

# S2: Verify list-markets returns INR markets (not crypto-only)
echo ">>> Running list-markets to verify INR markets..."
bash scripts/lib/ft_cmd.sh list-markets \
    -c user_data/config_icicibreeze.json \
    --userdir user_data \
    -v 2>&1 | tee user_data/generated/p57/list_markets.log

if ! grep -q "RELIANCE/INR" user_data/generated/p57/list_markets.log; then
    echo "P57_FAIL: No RELIANCE/INR market found"
    exit 1
fi

echo "[OK] INR markets present"

echo "=== Gate P57: PASS ==="
echo "Artifacts: user_data/generated/p57"
exit 0
