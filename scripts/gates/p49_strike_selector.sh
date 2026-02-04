#!/bin/bash
set -euo pipefail

MODE="${1:-pos}"
MODE="${MODE#--mode=}"

if [ "$MODE" == "pos" ]; then
    python3 scripts/p49_check_selector.py pos
elif [ "$MODE" == "neg" ]; then
    python3 scripts/p49_check_selector.py neg
fi
