#!/bin/bash
# P55: Debug and Telemetry Smoke Test
# Verifies UDP telemetry emission from telemetry bus.

set -euo pipefail

GATE_ID="p55_debug_and_telemetry_smoke"
source "$(dirname "$0")/common.sh" "$GATE_ID" "$@"

# Cleanup
rm -rf user_data/generated/p55
mkdir -p user_data/generated/p55

# --- POSITIVE CASE ---
if [ "$GATE_MODE" == "pos" ]; then
    echo ">>> Gate P55: Positive (Telemetry Emission)..."

    export BREEZE_MOCK=1
    export FT_DEBUG=1
    export FT_TELEMETRY_BIND=127.0.0.1
    # Ports are hardcoded in code (17100-17103)

    # Start UDP Listeners for all 4 ports
    nc -klu 127.0.0.1 17100 > user_data/generated/p55/telemetry_breeze.log &
    PID_BREEZE=$!
    nc -klu 127.0.0.1 17101 > user_data/generated/p55/telemetry_engine.log &
    PID_ENGINE=$!
    nc -klu 127.0.0.1 17102 > user_data/generated/p55/telemetry_orders.log &
    PID_ORDERS=$!
    nc -klu 127.0.0.1 17103 > user_data/generated/p55/telemetry_ui.log &
    PID_UI=$!

    # Wait for listeners to start
    sleep 1

    # Run list-markets (instantiates BreezeCCXT and triggers telemetry)
    echo "Running list-markets to trigger telemetry..."
    freqtrade list-markets \
        -c user_data/config_icicibreeze.json \
        --userdir user_data \
        > user_data/generated/p55/list_markets.log 2>&1 || true

    # Wait for telemetry to be emitted
    sleep 2

    # Stop listeners
    kill $PID_BREEZE $PID_ENGINE $PID_ORDERS $PID_UI || true
    wait $PID_BREEZE $PID_ENGINE $PID_ORDERS $PID_UI 2>/dev/null || true

    # Analyze Captures
    echo "Analyzing telemetry captures..."

    # Check Breeze layer (port 17100)
    if [ -s user_data/generated/p55/telemetry_breeze.log ]; then
        if grep -q "telemetry_ping" user_data/generated/p55/telemetry_breeze.log; then
            echo "[OK] Breeze telemetry_ping found"
        else
            echo "[FAIL] Breeze log non-empty but no telemetry_ping found"
            cat user_data/generated/p55/telemetry_breeze.log
            finish_gate 1
        fi

        if grep -q '"event":"init"' user_data/generated/p55/telemetry_breeze.log; then
            echo "[OK] Breeze init event found"
        else
            echo "[WARN] Breeze init event not found (non-critical if ping present)"
        fi
    else
        echo "[FAIL] Breeze telemetry log is empty"
        finish_gate 1
    fi

    # Check other layers (at least ping should be present)
    for layer in engine orders ui; do
        logfile="user_data/generated/p55/telemetry_${layer}.log"
        if [ -s "$logfile" ]; then
            if grep -q "telemetry_ping" "$logfile"; then
                echo "[OK] ${layer} telemetry_ping found"
            else
                echo "[WARN] ${layer} log non-empty but no telemetry_ping (non-critical)"
            fi
        else
            echo "[INFO] ${layer} telemetry log empty (expected if layer not instantiated)"
        fi
    done

    echo "P55_POS_PASS"
fi

# --- NEGATIVE CASE ---
if [ "$GATE_MODE" == "neg" ]; then
    echo ">>> Gate P55: Negative (Telemetry Disabled)..."

    export BREEZE_MOCK=1
    export FT_DEBUG=0  # Disabled

    # Start UDP Listeners
    nc -klu 127.0.0.1 17100 > user_data/generated/p55/telemetry_neg_breeze.log &
    PID_BREEZE=$!

    sleep 1

    # Run list-markets
    echo "Running list-markets with telemetry disabled..."
    freqtrade list-markets \
        -c user_data/config_icicibreeze.json \
        --userdir user_data \
        > user_data/generated/p55/list_markets_neg.log 2>&1 || true

    sleep 2

    # Stop listener
    kill $PID_BREEZE || true
    wait $PID_BREEZE 2>/dev/null || true

    # Assert: Log should be empty (telemetry disabled)
    if [ -s user_data/generated/p55/telemetry_neg_breeze.log ]; then
        echo "[FAIL] Telemetry log should be empty when TELEMETRY_LEVEL=0"
        cat user_data/generated/p55/telemetry_neg_breeze.log
        finish_gate 1
    else
        echo "[OK] Telemetry silent when disabled"
    fi

    echo "P55_NEG_PASS"
fi

finish_gate 0
