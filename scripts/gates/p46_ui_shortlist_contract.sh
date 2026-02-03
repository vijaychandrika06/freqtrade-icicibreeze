#!/bin/bash
# scripts/gates/p46_ui_shortlist_contract.sh
# Verification gate for P46 UI Shortlist Exporter

set -euo pipefail

GATE_ID="p46_ui_shortlist_contract"
source scripts/gates/common.sh "$GATE_ID" "$@"

OUT_JSON="$ARTIFACT_DIR/ui_shortlist.json"
MOCK_CONFIG="$ARTIFACT_DIR/mock_config.json"
MOCK_MASTER="$ARTIFACT_DIR/mock_master.json"

if [ "$GATE_MODE" == "pos" ]; then
    echo ">>> Positive Case: Verifying metadata extraction"
    
    # 1. Create a mock config with whitelisted pairs
    cat > "$MOCK_CONFIG" <<EOF
{
  "exchange": {
    "pair_whitelist": [
      "RELIANCE/INR",
      "RELIANCE-20260224-1350-CE/INR"
    ]
  }
}
EOF

    # 2. Create a mock security master JSON
    cat > "$MOCK_MASTER" <<EOF
{
  "meta": {"generated_at_utc": "2026-02-03T00:00:00Z"},
  "cash": [
    {"symbol": "RELIANCE", "token": "2885", "lot_size": 1, "tick_size": 0.05}
  ],
  "options": [
    {
       "underlying": "RELIANCE",
       "expiry_yyyymmdd": "20260224",
       "strike": 1350.0,
       "right": "CE",
       "token": "12345",
       "lot_size": 250,
       "tick_size": 0.05,
       "expiry_iso": "2026-02-24"
    }
  ],
  "futures": []
}
EOF

    # 3. Run exporter
    $PYTHON scripts/ops/export_ui_shortlist.py \
        --config_path "$MOCK_CONFIG" \
        --security_master "$MOCK_MASTER" \
        --out "$OUT_JSON"

    # 4. Assertions
    [ -f "$OUT_JSON" ] || { echo "Output file not found"; finish_gate 1; }
    
    # Verify counts
    COUNT=$(jq '.items | length' "$OUT_JSON")
    if [ "$COUNT" -ne 2 ]; then
        echo "[FAIL] Expected 2 items, found $COUNT"
        finish_gate 1
    fi
    
    # Verify token lookup
    TOKEN=$(jq -r '.items[] | select(.pair == "RELIANCE-20260224-1350-CE/INR") | .token' "$OUT_JSON")
    if [ "$TOKEN" != "12345" ]; then
        echo "[FAIL] Option token lookup failed"
        finish_gate 1
    fi

    echo "P46_POS_OK"

elif [ "$GATE_MODE" == "neg" ]; then
    echo ">>> Negative Case: Verifying parse error handling"
    
    cat > "$MOCK_CONFIG" <<EOF
{
  "exchange": {
    "pair_whitelist": [
      "INVALID_PAIR_FORMAT"
    ]
  }
}
EOF

    cat > "$MOCK_MASTER" <<EOF
{"options": [], "cash": [], "futures": []}
EOF

    # Run exporter (should not crash)
    $PYTHON scripts/ops/export_ui_shortlist.py \
        --config_path "$MOCK_CONFIG" \
        --security_master "$MOCK_MASTER" \
        --out "$OUT_JSON"

    # Assert reason is parse_error
    REASON=$(jq -r '.items[0].reason' "$OUT_JSON")
    if [ "$REASON" != "parse_error" ]; then
        echo "[FAIL] Expected parse_error, found $REASON"
        finish_gate 1
    fi

    echo "P46_NEG_PARSE_ERROR_OBSERVED"
fi

finish_gate 0
