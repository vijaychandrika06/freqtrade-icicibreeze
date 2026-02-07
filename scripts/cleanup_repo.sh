#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[cleanup] repo: $(pwd)"
echo "[cleanup] head: $(git rev-parse --short HEAD 2>/dev/null || echo n/a)"

TS="$(date -u +%Y%m%d_%H%M%SZ)"
OUT="user_data/generated/cleanup_${TS}"
mkdir -p "$OUT"

# Safety: bundle artifacts before deletion
# We use tar to backup the known junk directories before nuke
echo "[cleanup] backing up artifacts to $OUT/pre_cleanup_artifacts.tar.gz ..."
tar -czf "$OUT/pre_cleanup_artifacts.tar.gz" \
  generated user_data/generated user_data/backups user_data/backtest_results user_data/cache user_data.old_* \
  2>/dev/null || true

# Only remove known junk roots (untracked or local artifacts)
echo "[cleanup] removing loose artifact roots..."
rm -rf generated || true
rm -rf user_data/backups || true
rm -rf user_data/backtest_results || true
rm -rf user_data/cache || true
rm -rf user_data.old_* || true

# Specific root level log/junk files identified in report
rm -f trade_loop_final.log soak_test_ob.log freqtrade_debug.log final_verification_v2.tar.gz \
      tradesv3.sqlite tradesv3.dryrun.sqlite

# Keep user_data/generated directory but clear heavy runs (retain cleanup bundle)
echo "[cleanup] cleaning user_data/generated (preserving backups)..."
mkdir -p user_data/generated
find user_data/generated -mindepth 1 -maxdepth 1 \
  ! -name "cleanup_*" \
  -exec rm -rf {} + 2>/dev/null || true

# Python caches
echo "[cleanup] sweeping python caches..."
find . -type d -name "__pycache__" -prune -exec rm -rf {} + 2>/dev/null || true
find . -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete 2>/dev/null || true

echo "[cleanup] done. backup bundle: $OUT/pre_cleanup_artifacts.tar.gz"
echo "[cleanup] git status:"
git status --porcelain=v1 || true
