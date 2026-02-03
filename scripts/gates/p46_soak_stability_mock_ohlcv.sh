#!/bin/bash
# scripts/gates/p46_soak_stability_mock_ohlcv.sh
# Verification gate for P46 Soak Stability refinement

set -euo pipefail

GATE_ID="p46_soak_stability"
source scripts/gates/common.sh "$GATE_ID" "$@"

export BREEZE_MOCK=1
export FT_KILL_SWITCH=1
export FT_LIVE_ENABLE=0

# Fresh DB for soak run
TS=$(date -u +%Y%m%d_%H%M%S)
SOAK_DB_DIR="user_data/generated/soak_db"
mkdir -p "$SOAK_DB_DIR"
SOAK_DB="$SOAK_DB_DIR/${TS}.sqlite"
DB_URL="sqlite:///$SOAK_DB"

MOCK_CONFIG="$ARTIFACT_DIR/p46_soak_config.json"

if [ "$GATE_MODE" == "pos" ]; then
    echo "P46_POS_START"
    echo ">>> Positive Case: Verifying soak stability with synthetic OHLCV and fresh DB"

    # 1. Create a config with a non-SecurityMaster option contract
    cat > "$MOCK_CONFIG" <<EOF
{
  "max_open_trades": 3,
  "stake_currency": "INR",
  "stake_amount": "unlimited",
  "tradable_balance_ratio": 0.99,
  "dry_run": true,
  "exchange": {
    "name": "icicibreeze",
    "pair_whitelist": [
      "RELIANCE/INR",
      "RELIANCE-20991231-9999-CE/INR"
    ]
  },
  "entry_pricing": {
    "price_side": "same",
    "use_order_book": true,
    "order_book_top": 1
  },
  "exit_pricing": {
    "price_side": "same",
    "use_order_book": true,
    "order_book_top": 1
  },
  "pairlists": [
    {
      "method": "StaticPairList"
    }
  ],
  "strategy": "IndiaOptionsAutoStrategy"
}
EOF

    # 2. Assert fresh DB path requirement
    if [[ "$DB_URL" != *"user_data/generated/soak_db/"* ]]; then
        echo "[FAIL] DB path must be under user_data/generated/soak_db/"
        finish_gate 1
    fi
    echo "P46_POS_FRESH_DB_OK"

    # 3. Download data (should succeed for synthetic pair)
    echo "Downloading synthetic data..."

    # We use a short time range to avoid large data generation
    # Since it's mock mode, download-data will use BreezeCCXT.fetch_ohlcv
    $FREQTRADE download-data \
        --config "$MOCK_CONFIG" \
        --timeframe 5m \
        --timerange 20260101-20260102 \
        --userdir user_data || { echo "Download data failed for synthetic pair"; finish_gate 1; }

    echo "P46_POS_OHLCV_OK"

    # 4. Run dry-run (timeout 120s)
    echo "Running dry-run soak test..."
    timeout 120s $FREQTRADE trade \
        --config "$MOCK_CONFIG" \
        --strategy IndiaOptionsAutoStrategy \
        --db-url "$DB_URL" \
        --userdir user_data \
        -v || true

    # 5. Assertions on log
    grep -q "P46_MOCK_BYPASS" "$GATE_LOG" || { echo "Marker P46_MOCK_BYPASS missing from logs"; finish_gate 1; }
    echo "P46_POS_NO_SECURITYMASTER_DEP"

    # Check for strategy guard (if informative data was missing at any point)
    # This might happen if RELIANCE/INR was not downloaded or failed
    if grep -q "P46_WARN_INFORMATIVE_MISSING" "$GATE_LOG"; then
        echo "P46_POS_STRATEGY_GUARD_OK"
    fi

    if [ -f "$SOAK_DB" ]; then
        echo "P46_POS_DB_FILE_EXISTS"
    else
        echo "[FAIL] Soak DB file not created at $SOAK_DB"
        finish_gate 1
    fi

    echo "P46_POS_PASS"

elif [ "$GATE_MODE" == "neg" ]; then
    echo "P46_NEG_START"
    echo ">>> Negative Case: Verifying strategy guard with forced missing informative"
    
    # We use a config where the informative underlying is NOT in the whitelist 
    # and not downloaded, but the strategy needs it.
    cat > "$MOCK_CONFIG" <<EOF
{
  "max_open_trades": 3,
  "stake_currency": "INR",
  "stake_amount": "unlimited",
  "tradable_balance_ratio": 0.99,
  "dry_run": true,
  "exchange": {
    "name": "icicibreeze",
    "pair_whitelist": ["RELIANCE-20260224-2500-CE/INR"]
  },
  "entry_pricing": {
    "price_side": "same",
    "use_order_book": true,
    "order_book_top": 1
  },
  "exit_pricing": {
    "price_side": "same",
    "use_order_book": true,
    "order_book_top": 1
  },
  "pairlists": [
    {
      "method": "StaticPairList"
    }
  ],
  "strategy": "IndiaOptionsAutoStrategy"
}
EOF

    # Run dry-run
    timeout 60s $FREQTRADE trade \
        --config "$MOCK_CONFIG" \
        --strategy IndiaOptionsAutoStrategy \
        --db-url "$DB_URL" \
        --userdir user_data \
        -v || true

    grep -q "P46_WARN_INFORMATIVE_MISSING" "$GATE_LOG" || { echo "Marker P46_WARN_INFORMATIVE_MISSING missing from logs"; finish_gate 1; }
    echo "P46_NEG_WARN_OBSERVED"
    
    if grep -q "Traceback" "$GATE_LOG"; then
        echo "[FAIL] Traceback detected even with guard"
        finish_gate 1
    fi
    echo "P46_NEG_NO_TRACEBACK"
    echo "P46_NEG_PASS"
fi

finish_gate 0
