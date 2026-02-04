#!/bin/bash
set -euo pipefail

MODE="${1:-pos}"
MODE="${MODE#--mode=}"

if [ "$MODE" == "pos" ]; then
    python3 scripts/p48_check_regime.py pos
elif [ "$MODE" == "neg" ]; then
    python3 scripts/p48_check_regime.py neg
fi
