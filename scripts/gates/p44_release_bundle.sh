#!/bin/bash
# P44: Release Evidence Bundle Gate
set -euo pipefail

# shellcheck source=scripts/gates/common.sh
GATE_ID="p44_release_bundle"
source "$(dirname "$0")/common.sh" "$GATE_ID" "$@"

P44_OUTDIR="${ARTIFACT_DIR}"
mkdir -p "$P44_OUTDIR"

function run_pos() {
    echo ">>> Gate P44: Positive (Bundle Generation)..."
    
    # 1. Ensure an acceptance run exists (even if empty)
    mkdir -p "generated/accept_runs/temp_p44"
    touch "generated/accept_runs/temp_p44/dummy.log"
    
    # 2. Run collection script
    if bash scripts/collect/p44_release_bundle.sh; then
        echo "P44_COLLECT_SCRIPT_PASS"
    else
        echo "[FAIL] P44 Collection script failed."
        return 1
    fi

    # 3. Verify bundle exists
    BUNDLE_FILE=$(ls -t generated/release_bundles/bundle_*.tar.gz | head -n 1)
    if [ -f "$BUNDLE_FILE" ]; then
        echo "P44_BUNDLE_EXISTS_OK"
    else
        echo "[FAIL] Bundle file not found."
        return 1
    fi
    
    echo "P44_POS_PASS"
    return 0
}

function run_neg() {
    echo ">>> Gate P44: Negative (Secret Detection)..."
    
    # 1. Create a dummy file with a secret pattern in a place that will be collected
    # We use a unique name to ensure it's picked up
    DUMMY_DIR="generated/accept_runs/leak_test"
    mkdir -p "$DUMMY_DIR"
    echo "BREEZE_API_SECRET=\"real_secret_leak\"" > "$DUMMY_DIR/leaky.log"
    
    # 2. Run collection script - it should exit 1
    if bash scripts/collect/p44_release_bundle.sh; then
        echo "[FAIL] Collection script should have detected the secret leak!"
        rm -rf "$DUMMY_DIR"
        return 1
    else
        echo "P44_NEG_SECRET_DETECTED_OK"
        rm -rf "$DUMMY_DIR"
        return 0
    fi
}

# Parse mode
GATE_MODE="pos"
for i in "$@"; do
    case $i in
        --mode=*)
            GATE_MODE="${i#*=}"
            shift
            ;;
    esac
done

if [ "$GATE_MODE" == "pos" ]; then
    run_pos
elif [ "$GATE_MODE" == "neg" ]; then
    run_neg
else
    echo "Unknown mode: $GATE_MODE"
    exit 1
fi
