#!/bin/bash
# p20_ui_webserver_smoke.sh
# Verification gate for Freqtrade webserver authentication

set -euo pipefail

GATE_ID="p20_ui_webserver_smoke"
source scripts/gates/common.sh "$GATE_ID" "$@"

require_timeout

export BREEZE_MOCK=1
export FT_RATE_LIMIT_DISABLE=1

IN_CONFIG="user_data/generated/config_p09x_v1.json"
# Fallback if p09x config missing (e.g. running p20 in isolation)
if [ ! -f "$IN_CONFIG" ]; then
    IN_CONFIG="user_data/config_icicibreeze.json"
fi
OUT_CONFIG="$ARTIFACT_DIR/config_ui.json"

if [ "$GATE_MODE" == "pos" ]; then
    echo ">>> Positive Case: Verifying webserver starts with valid auth"
    
    # 1. Generate UI Config
    $PYTHON scripts/make_config_ui.py \
        --in "$IN_CONFIG" \
        --out "$OUT_CONFIG" \
        --ip 127.0.0.1 --port 8081 --verbosity info
    
    # 2. Start Webserver in background
    echo "Starting webserver (5s smoke test)..."
    # Note: We use a different port (8081) to avoid conflicts if 8080 is used
    timeout 10s $FREQTRADE webserver -c "$OUT_CONFIG" --userdir user_data -v > "$ARTIFACT_DIR/webserver_pos.log" 2>&1 || true
    
    # 3. Assert success marker or bind line in logs
    if grep -q "Starting HTTP Server at" "$ARTIFACT_DIR/webserver_pos.log" || grep -q "Uvicorn running on" "$ARTIFACT_DIR/webserver_pos.log"; then
        echo "[OK] Webserver started successfully"
    else
        echo "[FAIL] Webserver failed to start"
        cat "$ARTIFACT_DIR/webserver_pos.log"
        finish_gate 1
    fi

elif [ "$GATE_MODE" == "neg" ]; then
    echo ">>> Negative Case: Verifying failure when auth is missing"
    
    # 1. Generate Bad Config (missing auth)
    $PYTHON -c "import json; c=json.load(open('$IN_CONFIG')); c['api_server']={'enabled':True, 'listen_ip_address':'127.0.0.1', 'listen_port':8082}; json.dump(c, open('$OUT_CONFIG', 'w'))"
    
    # 2. Start Webserver expecting failure
    echo "Starting webserver (expecting failure)..."
    if $FREQTRADE webserver -c "$OUT_CONFIG" --userdir user_data -v > "$ARTIFACT_DIR/webserver_neg.log" 2>&1; then
        echo "[FAIL] Webserver started unexpectedly without credentials"
        finish_gate 1
    else
        # 3. Assert schema validation error
        if grep -q "'username' is a required property" "$ARTIFACT_DIR/webserver_neg.log" || grep -q "'password' is a required property" "$ARTIFACT_DIR/webserver_neg.log"; then
            echo "[OK] Observed expected schema validation failure"
        else
            echo "[FAIL] Unexpected error message"
            cat "$ARTIFACT_DIR/webserver_neg.log"
            finish_gate 1
        fi
    fi
fi

finish_gate 0
