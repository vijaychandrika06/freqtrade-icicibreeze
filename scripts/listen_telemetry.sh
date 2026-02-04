#!/bin/bash
# Telemetry Listener Helper
# Spawns nc listeners for all telemetry ports
# Usage: ./scripts/listen_telemetry.sh

set -e

# Kill existing listeners if any
pkill -f "nc -klu 127.0.0.1 171" || true

echo "Starting Telemetry Listeners..."
echo "Breeze (17100) | Engine (17101) | Orders (17102) | UI (17103)"
echo "Press Ctrl+C to stop."

# Breeze
nc -klu 127.0.0.1 17100 | sed 's/^/[BREEZE] /' &

# Engine
nc -klu 127.0.0.1 17101 | sed 's/^/[ENGINE] /' &

# Orders/Risk
nc -klu 127.0.0.1 17102 | sed 's/^/[ORDERS] /' &

# UI
nc -klu 127.0.0.1 17103 | sed 's/^/[UI]     /' &

wait
