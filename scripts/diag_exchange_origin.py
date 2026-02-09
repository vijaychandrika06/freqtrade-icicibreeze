#!/usr/bin/env python3
"""Exchange origin diagnostic script - verifies CCXT exchange setup."""

import os
import sys
import json
from pathlib import Path

# Set up paths
sys.path.insert(0, str(Path(__file__).parent.parent))

print("=" * 60)
print("EXCHANGE ORIGIN DIAGNOSTIC")
print("=" * 60)

print(f"PYTHON: {sys.executable}")

try:
    import ccxt

    print(f"CCXT_VERSION: {ccxt.__version__}")
    print(f"CCXT_FILE: {Path(ccxt.__file__).resolve()}")
except ImportError as e:
    print(f"ERROR: Cannot import ccxt: {e}")
    sys.exit(1)

try:
    import freqtrade

    print(f"FREQTRADE_FILE: {Path(freqtrade.__file__).resolve()}")
except ImportError as e:
    print(f"ERROR: Cannot import freqtrade: {e}")
    sys.exit(1)

print("=" * 60)
print("DIAGNOSTICS")
print("=" * 60)

# Check if we can run freqtrade
print("\nTesting freqtrade command availability...")
import subprocess

try:
    result = subprocess.run(["freqtrade", "--version"], capture_output=True, text=True, timeout=5)
    print(f"FREQTRADE_VERSION: {result.stdout.strip()}")
except Exception as e:
    print(f"ERROR: Cannot run freqtrade command: {e}")
    sys.exit(1)

# List markets to check what exchange is loaded
print("\nRunning list-markets to check exchange and available pairs...")
try:
    result = subprocess.run(
        [
            "freqtrade",
            "list-markets",
            "-c",
            "user_data/config_icicibreeze.json",
            "--userdir",
            "user_data",
            "-v",
        ],
        capture_output=True,
        text=True,
        timeout=30,
        cwd=Path(__file__).parent.parent,
    )

    output = result.stdout + result.stderr

    # Extract key info
    inr_markets = [line for line in output.split("\n") if "/INR" in line]
    crypto_markets = [line for line in output.split("\n") if "/USDT" in line or "/BTC" in line]

    print(f"\nINR_MARKETS_COUNT: {len(inr_markets)}")
    if inr_markets:
        print(f"INR_MARKETS_SAMPLE: {inr_markets[:5]}")

    print(f"CRYPTO_MARKETS_COUNT: {len(crypto_markets)}")
    if crypto_markets:
        print(f"WARNING: Found crypto markets: {crypto_markets[:3]}")

    # Check if exchange loaded successfully
    if "Using Exchange" in output:
        for line in output.split("\n"):
            if "Using Exchange" in line:
                print(f"EXCHANGE_LOADED: {line.strip()}")

    # Check for timeframes warning
    if "no timeframe" in output.lower() or "timeframe" in output.lower():
        print("TIMEFRAME_INFO:")
        for line in output.split("\n"):
            if "timeframe" in line.lower():
                print(f"  {line.strip()}")

    if result.returncode != 0:
        print(f"\nWARNING: list-markets exited with code {result.returncode}")
        print("OUTPUT:")
        print(output)

except subprocess.TimeoutExpired:
    print("ERROR: list-markets command timed out")
    sys.exit(1)
except Exception as e:
    print(f"ERROR running list-markets: {e}")
    import traceback

    traceback.print_exc()
    sys.exit(1)

print("=" * 60)
print("DIAGNOSTIC COMPLETE")
print("=" * 60)
