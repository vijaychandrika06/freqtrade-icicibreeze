#!/usr/bin/env bash
# scripts/ui_start.sh
# Comprehensive UI startup wrapper for Phase P46

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUTDIR="user_data/generated/ui_universe"
mkdir -p "$OUTDIR"

# Ensure UI assets (idempotent)
freqtrade install-ui >/dev/null 2>&1 || true

# 1. Generate Actionable Universe
echo "Searching for actionable pairs..."
python3 scripts/gen_actionable_universe_pairs.py --out "$OUTDIR/pairs.json"

# 2. Build configuration with pairs
echo "Applying pair whitelist to configuration..."
WHITELIST_FILE="$OUTDIR/whitelist.json"
jq '.pair_whitelist' "$OUTDIR/pairs.json" > "$WHITELIST_FILE"

python3 scripts/make_config_with_pairs.py \
    --base user_data/generated/manual_select/config.json \
    --pairs "$WHITELIST_FILE" \
    --out "$OUTDIR/config_base.json"

# 3. Inject API Auth
echo "Securing API server..."

# Fail-fast if FT_UI_PASS is missing
if [ -z "${FT_UI_PASS:-}" ]; then
    echo "ERROR: FT_UI_PASS environment variable must be set."
    exit 1
fi

# Determine username
UI_USER="${FT_UI_USER:-}"
if [ -z "$UI_USER" ]; then
    if [ "${BREEZE_MOCK:-0}" == "1" ]; then
        UI_USER="admin"
    else
        echo "ERROR: FT_UI_USER must be set in real mode."
        exit 1
    fi
fi

python3 scripts/make_config_ui.py \
    --in "$OUTDIR/config_base.json" \
    --out "$OUTDIR/config_ui.json" \
    --username "$UI_USER" \
    --password "$FT_UI_PASS" \
    --verbosity error

# 4. Start Webserver
echo "Launching Freqtrade UI on http://127.0.0.1:8080"
exec .venv/bin/freqtrade webserver \
    -c "$OUTDIR/config_ui.json" \
    --userdir user_data \
    -v
