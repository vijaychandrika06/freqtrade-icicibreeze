GATE_ID="p47_options_valuation"
source scripts/gates/common.sh "$GATE_ID" "$@"

if [ "$GATE_MODE" == "pos" ]; then
    "$PYTHON" scripts/p47_check_valuation.py pos || finish_gate $?
elif [ "$GATE_MODE" == "neg" ]; then
    "$PYTHON" scripts/p47_check_valuation.py neg || finish_gate $?
fi

finish_gate 0
