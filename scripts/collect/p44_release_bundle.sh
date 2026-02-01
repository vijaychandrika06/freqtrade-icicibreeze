#!/bin/bash
# P44: Release Evidence Bundle Collector
set -euo pipefail

cd "$(dirname "$0")/../.."

BUNDLE_ID=$(date +%Y%m%d_%H%M%S)
OUTDIR="generated/release_bundles/${BUNDLE_ID}"
mkdir -p "$OUTDIR"

echo ">>> Starting Release Evidence Collection (ID: $BUNDLE_ID)..."

# 1. Metadata
echo "Collecting metadata..."
{
    echo "Bundle ID: $BUNDLE_ID"
    echo "Date: $(date -u)"
    echo "Branch: $(git rev-parse --abbrev-ref HEAD || echo 'not-a-git-repo')"
    echo "Commit: $(git rev-parse HEAD || echo 'none')"
} > "$OUTDIR/manifest.txt"

# 2. Acceptance Logs (Latest run)
LATEST_RUN=$(ls -dt generated/accept_runs/* | head -n 1 || true)
if [ -n "$LATEST_RUN" ] && [ -d "$LATEST_RUN" ]; then
    echo "Collecting latest acceptance logs from $LATEST_RUN..."
    # We copy the compressed tarball if it exists, or the folder
    RUN_NAME=$(basename "$LATEST_RUN")
    if [ -f "generated/accept_runs/${RUN_NAME}.tar.gz" ]; then
        cp "generated/accept_runs/${RUN_NAME}.tar.gz" "$OUTDIR/"
    else
        cp -r "$LATEST_RUN" "$OUTDIR/accept_run_evidence"
    fi
else
    echo "WARNING: No acceptance runs found."
fi

# 3. Documentation
echo "Collecting documentation..."
mkdir -p "$OUTDIR/docs"
cp docs/PHASE_P*.md "$OUTDIR/docs/" 2>/dev/null || true
cp docs/OPS_RUNBOOK.md "$OUTDIR/docs/" 2>/dev/null || true

# 4. Config Templates (Sanitized)
echo "Collecting config templates..."
mkdir -p "$OUTDIR/templates"
if [ -f "config_example.json" ]; then
    cp config_example.json "$OUTDIR/templates/"
    sed -i -E 's/"key":\s*".*"/"key": "REDACTED"/g' "$OUTDIR/templates"/*.json || true
    sed -i -E 's/"secret":\s*".*"/"secret": "REDACTED"/g' "$OUTDIR/templates"/*.json || true
    sed -i -E 's/"session_token":\s*".*"/"session_token": "REDACTED"/g' "$OUTDIR/templates"/*.json || true
fi

# 5. Secrets Hygiene Scan on the bundle itself
echo "Scanning bundle for leaks..."
LEAK_PATTERNS=(
    "BREEZE_API_SECRET"
    "session_token="
    "api_secret="
    "Authorization: Bearer"
)

LEAKS_FOUND=0
# We use grep -r but exclude things that are expected to have pattern names but not values
for pattern in "${LEAK_PATTERNS[@]}"; do
    if grep -r "$pattern" "$OUTDIR" | grep -vE "manifest.txt|gate.log|REDACTED|docs/PHASE_.*\.md|docs/OPS_RUNBOOK.md"; then
        echo "[FAIL] Found secret leak in bundle matching: $pattern"
        LEAKS_FOUND=1
    fi
done

if [ "$LEAKS_FOUND" -eq 1 ]; then
    echo "CRITICAL: Secrets detected in bundle! Aborting."
    exit 1
fi

# 6. Checksums
echo "Generating checksums..."
(cd "$OUTDIR" && find . -type f -not -name "sha256sums.txt" -print0 | xargs -0 sha256sum > sha256sums.txt)

# 7. Package
BUNDLE_FILE="generated/release_bundles/bundle_${BUNDLE_ID}.tar.gz"
mkdir -p generated/release_bundles
tar -czf "$BUNDLE_FILE" -C "generated/release_bundles" "$BUNDLE_ID"

echo ">>> Release Bundle Completed: $BUNDLE_FILE"
echo "P44_BUNDLE_PATH: $BUNDLE_FILE"
