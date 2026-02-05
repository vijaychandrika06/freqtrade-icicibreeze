#!/bin/bash
# P53 Telemetry Smoke Gate
# Verifies layers L0 (silence) and L1 (emission) using UDP listeners.

GATE_ID="p53"
source scripts/gates/common.sh "$GATE_ID" "$@"

# Ports
PORT_BREEZE=17100
PORT_ENGINE=17101
PORT_ORDERS=17102
PORT_UI=17103

TELE_LOG_DIR="user_data/generated/telemetry_logs"
mkdir -p "$TELE_LOG_DIR"

SERVER_PIDS=()

LISTENER_PY="user_data/generated/p53_listener.py"
cat <<EOF > "$LISTENER_PY"
import socket
import sys
import os

port = int(sys.argv[1])
outfile = sys.argv[2]
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("127.0.0.1", port))
print(f"Listening on {port} -> {outfile}")
sys.stdout.flush()

with open(outfile, "a") as f:
    while True:
        data, addr = sock.recvfrom(65535)
        f.write(data.decode("utf-8") + "\\n")
        f.flush()
EOF

cleanup_ports() {
    pkill -f "p53_listener.py" || true
    pkill -f "nc -ukl" || true
    # Force kill if stuck
    lsof -ti :17100 | xargs -r kill -9 || true
    lsof -ti :17102 | xargs -r kill -9 || true
    sleep 2
}

start_listeners() {
    cleanup_ports
    echo "Starting UDP listeners (Python)..."
    python3 "$LISTENER_PY" $PORT_BREEZE "$TELE_LOG_DIR/breeze.jsonl" &
    SERVER_PIDS+=($!)
    python3 "$LISTENER_PY" $PORT_ORDERS "$TELE_LOG_DIR/orders.jsonl" &
    SERVER_PIDS+=($!)
}

stop_listeners() {
    echo "Stopping UDP listeners..."
    for pid in "${SERVER_PIDS[@]}"; do
        kill $pid 2>/dev/null
    done
}

run_test_cmd() {
    # Run a small python snippet to trigger CCXT init and telemetry
    # We use a temp script:
    TEST_PY="user_data/generated/p53_telemetry_trigger.py"
    cat <<EOF > "$TEST_PY"
import sys
import asyncio
from adapters.ccxt_shim.breeze_ccxt import BreezeCCXT
from freqtrade.exceptions import OperationalException

async def main():
    print("Initializing BreezeCCXT...")
    config = {
        "breeze_mock": True,
        "run_id": "p53_smoke_test"
    }
    try:
        ex = BreezeCCXT(config)
        await ex.create_order("RELIANCE/INR", "limit", "buy", 100, 2000.0)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
EOF

    python3 "$TEST_PY"
}

# Mode: pos or neg
# pos -> CHECK L1
# neg -> CHECK L0 (Silence)

echo ">>> Gate P53: Telemetry Smoke (Mode: $GATE_MODE)"

# Clean logs
rm -f "$TELE_LOG_DIR"/*.jsonl

start_listeners
sleep 1

if [ "$GATE_MODE" == "pos" ]; then
    echo "Running in Level 1..."
    export TELEMETRY_LEVEL=1
    export TELEMETRY_BIND=127.0.0.1
    export TELEMETRY_BIND=127.0.0.1
    export FT_FORCE_MARKET_OPEN=1
    export RISK_GUARD_ENABLED=false
    export FT_ENABLE_LIVE_ORDERS=1
    
    run_test_cmd
    
    sleep 2
    stop_listeners
    
    # Assertions
    echo "Checking logs..."
    cat "$TELE_LOG_DIR/breeze.jsonl" || true
    
    # Check Breeze
    if grep -q '"event": "init"' "$TELE_LOG_DIR/breeze.jsonl"; then
        echo "[OK] Breeze init received"
    else
        echo "[FAIL] Breeze init MISSING"
        cat "$TELE_LOG_DIR/breeze.jsonl"
        finish_gate 1
    fi
    
    # Check Orders
    if grep -q '"event": "order_attempt"' "$TELE_LOG_DIR/breeze.jsonl"; then
         # Wait, create_order emits via Breeze telemetry (self._telemetry) so it goes to PORT_BREEZE?
         # NO, create_order uses self._telemetry which is initialized as Breeze Bus.
         # Ah, in breeze_ccxt.py: self._telemetry = UdpTelemetryBus(PORT_BREEZE, ...)
         # So order_attempt goes to BREEZE port.
         # OrderRouter emits order_blocked to ORDERS port.
         echo "[OK] Order attempt received on Breeze Port"
    else
         echo "[FAIL] Order attempt MISSING"
         finish_gate 1
    fi

elif [ "$GATE_MODE" == "neg" ]; then
    echo "Running in Level 0 (Silence)..."
    export TELEMETRY_LEVEL=0
    
    run_test_cmd
    
    sleep 2
    stop_listeners
    
    # Assertions: Should be empty
    if [ -s "$TELE_LOG_DIR/breeze.jsonl" ]; then
        echo "[FAIL] Breeze log should be empty in L0"
        cat "$TELE_LOG_DIR/breeze.jsonl"
        finish_gate 1
    else
        echo "[OK] Breeze log empty (Silence verified)"
    fi

fi

echo ">>> Gate P53: SUCCESS"
finish_gate 0
