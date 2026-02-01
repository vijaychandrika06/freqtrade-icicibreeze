import logging
import json
import sys
from pathlib import Path
import argparse
from collections import Counter

# Observability Compliance: Use logger
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("p43_reconcile")

DEFAULT_CACHE = Path("user_data/generated/runtime/order_id_cache.json")


def main():
    parser = argparse.ArgumentParser(description="Reconcile bot state with exchange")
    parser.add_argument("--cache", type=Path, default=DEFAULT_CACHE, help="Idempotency cache path")
    parser.add_argument("--mock-exchange", type=Path, help="JSON file with mock exchange orders")
    args = parser.parse_args()

    results = {"status": "OK", "untracked_orders": [], "duplicates_found": 0, "summary": ""}

    try:
        if not args.cache.exists():
            cache = {}
        else:
            with args.cache.open("r") as f:
                cache = json.load(f)

        if args.mock_exchange and args.mock_exchange.exists():
            with args.mock_exchange.open("r") as f:
                exchange_orders = json.load(f)
        else:
            exchange_orders = []

        cache_ids = set(cache.keys())
        # Filter out empty IDs
        exchange_client_ids = [
            o.get("clientOrderId") for o in exchange_orders if o.get("clientOrderId")
        ]
        exchange_client_id_set = set(exchange_client_ids)

        # Untracked: on exchange but not in local cache
        untracked = sorted(list(exchange_client_id_set - cache_ids))
        results["untracked_orders"] = untracked

        # Duplicates: multiple orders with same clientOrderId on exchange
        counts = Counter(exchange_client_ids)
        dups = sorted([cid for cid, count in counts.items() if count > 1])
        results["duplicates_found"] = len(dups)

        if dups:
            results["status"] = "ERROR"
            results["summary"] = (
                f"CRITICAL: Found {len(dups)} duplicate clientOrderIDs on exchange!"
            )
        elif untracked:
            results["status"] = "RECONCILE_REQUIRED"
            results["summary"] = f"WARNING: Found {len(untracked)} untracked orders on exchange!"
        else:
            results["status"] = "OK"
            results["summary"] = "State is consistent."

        # Output JSON for machine parsing - still stdout for the gate script
        print(json.dumps(results, indent=2, sort_keys=True))

        return 0 if results["status"] != "ERROR" else 1

    except Exception:
        logger.exception("Exception during reconciliation")
        # Ensure minimum JSON output even on failure
        print(json.dumps({"status": "EXCEPTION", "summary": "See logs for details"}, indent=2))
        return 1


if __name__ == "__main__":
    sys.exit(main())
