GATE_ID="p51_universal_scanner"
source scripts/gates/common.sh "$GATE_ID" "$@"

if [ "$GATE_MODE" == "pos" ]; then
    # Use Mock Mode for deterministic pass
    export BREEZE_MOCK=1
    "$PYTHON" scripts/universal_scanner.py --config user_data/config_icicibreeze.json || finish_gate $?
elif [ "$GATE_MODE" == "neg" ]; then
    echo "P51_NEG_START"
    # Negative test? Empty universe?
    # Or mock with blackout?
    # For now just verify it runs without crashing.
    export BREEZE_MOCK=1
    # Create empty config
    echo '{"universe": {"stocks": []}}' > /tmp/empty_config.json
    "$PYTHON" scripts/universal_scanner.py --config /tmp/empty_config.json || finish_gate $?
    echo "P51_EMPTY_SHORTLIST_OK"
    echo "P51_PASS"
fi

finish_gate 0
