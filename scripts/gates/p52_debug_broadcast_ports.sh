#!/bin/bash
# P52: Debug Broadcast Ports
# Verifies UDP telemetry emission from key layers.

set -euo pipefail

GATE_ID="p52_debug_broadcast_ports"
source "$(dirname "$0")/common.sh" "$GATE_ID" "$@"

# Cleanup
rm -rf user_data/generated/p52
mkdir -p user_data/generated/p52

CAPTURE_FILE="user_data/generated/p52/telemetry_sample.jsonl"

# --- POSITIVE CASE ---
if [ "$GATE_MODE" == "pos" ]; then
    echo ">>> Gate P52: Positive (Telemetry Emission)..."

    # Start UDP Listener (Python for JSON capture)
    python3 -c "
import socket
import json
import sys
import time

# Listen on all ports
ports = [17100, 17101, 17102]
socks = []
for p in ports:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(('127.0.0.1', p))
        s.settimeout(0.1)
        socks.append(s)
    except Exception as e:
        print(f'Failed to bind {p}: {e}')

with open('$CAPTURE_FILE', 'w') as f:
    print('Listener started...')
    sys.stdout.flush()
    
    start = time.time()
    while time.time() - start < 30: # Run for 30s max
        for s in socks:
            try:
                data, addr = s.recvfrom(4096)
                line = data.decode('utf-8')
                f.write(line + '\n')
                f.flush()
            except socket.timeout:
                pass
            except Exception as e:
                pass
" &
    LISTENER_PID=$!
    
    # Wait for listener startup
    sleep 2

    # Run Scanner (Triggers Breeze Init + Engine Scan)
    echo "Running Universal Scanner (Mock)..."
    export BREEZE_MOCK=1
    export FT_TELEMETRY=1
    export TELEMETRY_LEVEL=1
    # Create dummy config if needed
    if [ ! -f config_p52.json ]; then
        if [ -f config.json.example ]; then
             cp config.json.example config_p52.json
        else
             echo "{}" > config_p52.json
        fi
    fi
    
    # We ignore exit code of scanner as we just want telemetry side effects
    python3 scripts/universal_scanner.py --config config_p52.json > user_data/generated/p52/scanner.log 2>&1 || true

    # Run Breeze Trigger (Scanner might not init CCXT)
    echo "Triggering Breeze/Risk Telemetry..."
    python3 -c "import sys; sys.path.append('.'); from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT; print('Initing Breeze...'); BreezeCCXT({'breeze_mock': True, 'risk_guard': {'enabled': True}})" > user_data/generated/p52/trigger.log 2>&1 || true

    # Wait for Capture
    sleep 2
    kill $LISTENER_PID || true
    
    # Analyze Capture
    echo "Analyzing Telemetry Capture..."
    
    if grep -q "breeze" "$CAPTURE_FILE"; then
        echo "[OK] Found Breeze Telemetry"
    else
        echo "[FAIL] Missing Breeze Telemetry"
        # Cat capture file for debug
        cat "$CAPTURE_FILE"
        finish_gate 1
    fi

    if grep -q "engine" "$CAPTURE_FILE"; then
        echo "[OK] Found Engine Telemetry"
    else
        echo "[FAIL] Missing Engine Telemetry"
        cat "$CAPTURE_FILE"
        finish_gate 1
    fi
    
    # Scan Start check
    if grep -q "scan_start" "$CAPTURE_FILE"; then
        echo "[OK] Found Scan Start Event"
    else
        echo "[FAIL] Missing Scan Start Event"
        cat "$CAPTURE_FILE"
        finish_gate 1
    fi

    echo "P52_PASS"
fi

# --- NEGATIVE CASE ---
if [ "$GATE_MODE" == "neg" ]; then
    echo ">>> Gate P52: Negative (No Listener / Crash Prevention)..."
    
    # Run with Telemetry ON but NO LISTENER
    export BREEZE_MOCK=1
    export FT_TELEMETRY=1
    if [ ! -f config_p52.json ]; then
         echo "{}" > config_p52.json
    fi
    
    echo "Running Stress Test without Listener..."
    if python3 scripts/universal_scanner.py --config config_p52.json > /dev/null 2>&1; then
         echo "[OK] Bot did not crash without listener."
    else
         echo "[FAIL] Bot crashed!"
         finish_gate 1
    fi
    
    echo "P52_NEG_NO_LISTENER_OK"
    echo "P52_PASS"
fi

finish_gate 0
