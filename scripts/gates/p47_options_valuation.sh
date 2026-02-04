#!/bin/bash
set -euo pipefail

MODE="${1:-pos}"
MODE="${MODE#--mode=}"

if [ "$MODE" == "pos" ]; then
    python3 scripts/p47_check_valuation.py pos
elif [ "$MODE" == "neg" ]; then
    python3 scripts/p47_check_valuation.py neg
fi
