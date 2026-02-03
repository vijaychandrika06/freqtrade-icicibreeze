#!/usr/bin/env bash
# scripts/ops/soak_monitor_10min.sh

ROOT="/home/trader/work/freqtrade-icicibreeze"
cd "$ROOT" || exit 1

SESSION_TS="$(date -u +%Y%m%d_%H%M%S)"
SESSION_DIR="generated/soak_checks/session_${SESSION_TS}"
mkdir -p "$SESSION_DIR"

echo "Starting 10-minute monitoring session: $SESSION_TS"

for i in {1..10}; do
    TS="$(date -u +%Y%m%d_%H%M%S)"
    OUT="$SESSION_DIR/$TS"
    mkdir -p "$OUT"
    
    echo "Iteration $i/10 at $TS"
    
    SOAK_DIR="$(ls -1dt generated/soak/* 2>/dev/null | head -n 1)"
    if [ -z "$SOAK_DIR" ]; then
        echo "No soak directory found" > "$OUT/error.txt"
    else
        LOG="$SOAK_DIR/soak.log"
        echo "ist=$(TZ=Asia/Kolkata date '+%F %T %Z')" > "$OUT/status.txt"
        tmux ls >> "$OUT/status.txt" 2>/dev/null || true
        tail -n 500 "$LOG" > "$OUT/log_tail.txt" 2>/dev/null || true
        
        {
          echo "tracebacks=$(grep -Eci 'Traceback' "$LOG" 2>/dev/null || echo 0)"
          echo "operational_exception=$(grep -Eci 'OperationalException' "$LOG" 2>/dev/null || echo 0)"
          echo "disconnect_reconnect=$(grep -Eci 'disconnect|reconnect' "$LOG" 2>/dev/null || echo 0)"
          echo "websocket_mentions=$(grep -Eci 'websocket|wss|subscribe|on_tick|ticks' "$LOG" 2>/dev/null || echo 0)"
        } > "$OUT/counters.txt"
        
        ss -tpn > "$OUT/ss_tpn.txt" 2>/dev/null || true
    fi
    
    if [ $i -lt 10 ]; then
        sleep 60
    fi
done

TAR_FILE="generated/soak_bundle_${SESSION_TS}.tar.gz"
tar -czf "$TAR_FILE" -C "generated/soak_checks" "session_${SESSION_TS}"
echo "BUNDLED_FILE=$TAR_FILE"
