#!/bin/bash
set -euo pipefail

# Mode: pos or neg
MODE="${1:-pos}"
# Strip --mode= prefix if present
MODE="${MODE#--mode=}"

if [ "$MODE" == "pos" ]; then
    echo "P46_POS_START"
    python3 scripts/p46_check_provider.py pos
elif [ "$MODE" == "neg" ]; then
    echo "P46_NEG_START"
    python3 scripts/p46_check_provider.py neg
fi
