#!/usr/bin/env python3
import argparse
import datetime
import json
import logging
import os
import sys
from pathlib import Path

# Add project root to path to allow imports
sys.path.append(os.getcwd())

try:
    from adapters.ccxt_shim.instrument import parse_pair, InstrumentType
    from adapters.ccxt_shim.security_master import load_nfo_options_master, load_nse_cash_master
except ImportError as e:
    print(f"Error importing modules: {e}")
    sys.exit(1)

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("UIExporter")


def export(config_path: str, master_path: str, output_path: str):
    config_file = Path(config_path)
    master_file = Path(master_path)
    output_file = Path(output_path)

    if not config_file.exists():
        logger.error(f"Config not found: {config_file}")
        sys.exit(2)

    # Load whitelist from config
    try:
        with config_file.open("r") as f:
            config = json.load(f)
        whitelist = config.get("exchange", {}).get("pair_whitelist", [])
    except Exception as e:
        logger.exception(f"Failed to read config {config_file}: {e}")
        sys.exit(2)

    # Load Security Master (JSON if possible, or TXT)
    # The requirement says path to latest.json (default user_data/cache/security_master/latest.json)
    # But usually latest.json is built by build_security_master_json.py (P25)
    # If the user directs to a .json, we assume it's the flattened one.
    # If it's a .txt, we use the loaders.

    master_data = {"options": [], "cash": [], "futures": []}
    if master_file.suffix == ".json":
        try:
            with master_file.open("r") as f:
                master_data = json.load(f)
        except Exception as e:
            logger.exception(f"Failed to read master JSON {master_file}: {e}")
            sys.exit(2)
    else:
        # Fallback to loading TXT (assuming it's the NFO Options master for simplicity if not JSON)
        logger.info(f"Loading raw TXT master from {master_file}")
        nfo = load_nfo_options_master(str(master_file))
        master_data["options"] = list(nfo.get("by_contract", {}).values())

    # Build index for fast lookup
    # options key: (underlying, expiry, strike, right)
    options_map = {}
    for opt in master_data.get("options", []):
        key = (opt["underlying"], opt["expiry_yyyymmdd"], opt["strike"], opt["right"])
        options_map[key] = opt

    # cash key: symbol
    cash_map = {c["symbol"]: c for c in master_data.get("cash", [])}

    items = []
    meta = {
        "generated_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "config_path": str(config_file),
    }

    for pair in whitelist:
        try:
            spec = parse_pair(pair)
            row = {
                "pair": pair,
                "token": None,
                "underlying": spec.underlying,
                "type": spec.type,
                "reason": None,
            }

            if spec.type == InstrumentType.OPT:
                row.update(
                    {
                        "expiry_iso": spec.expiry_yyyymmdd,  # fallback
                        "strike": spec.strike,
                        "right": spec.right,
                    }
                )
                key = (spec.underlying, spec.expiry_yyyymmdd, spec.strike, spec.right)
                match = options_map.get(key)
                if match:
                    row["token"] = match.get("token")
                    row["lot_size"] = match.get("lot_size")
                    row["tick_size"] = match.get("tick_size")
                    row["expiry_iso"] = match.get("expiry_iso", spec.expiry_yyyymmdd)
                else:
                    row["reason"] = "not_found"

            elif spec.type == InstrumentType.CASH:
                match = cash_map.get(spec.underlying)
                if match:
                    row["token"] = match.get("token")
                    row["lot_size"] = match.get("lot_size")
                    row["tick_size"] = match.get("tick_size")
                else:
                    row["reason"] = "not_found"

            items.append(row)

        except ValueError as e:
            logger.warning(f"Parse error for pair {pair}: {e}")
            items.append({"pair": pair, "token": None, "reason": "parse_error"})

    meta["counts"] = {
        "whitelist": len(whitelist),
        "exported": len(items),
        "not_found": sum(1 for i in items if i["reason"] == "not_found"),
        "parse_error": sum(1 for i in items if i["reason"] == "parse_error"),
    }

    output_file.parent.mkdir(parents=True, exist_ok=True)
    with output_file.open("w") as f:
        json.dump({"meta": meta, "items": items}, f, indent=2)

    logger.info(f"Exported {len(items)} items to {output_file}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config_path", default="user_data/generated/manual_select/config.json")
    parser.add_argument("--security_master", default="user_data/cache/security_master/latest.json")
    parser.add_argument("--out", default="user_data/generated/ui_shortlist.json")
    args = parser.parse_args()

    export(args.config_path, args.security_master, args.out)


if __name__ == "__main__":
    main()
