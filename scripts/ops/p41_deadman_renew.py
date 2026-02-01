#!/usr/bin/env python3
import os
import sys
import time
from pathlib import Path
import argparse

DEFAULT_DEADMAN = Path("user_data/secrets/deadman_live.ok")


def main():
    parser = argparse.ArgumentParser(description="Renew deadman lease")
    parser.add_argument("--outfile", type=Path, default=DEFAULT_DEADMAN, help="Lease file path")
    parser.add_argument("--dry-run", action="store_true", help="Don't actually write")
    args = parser.parse_args()

    # Allow env override for dry run
    dry_run = args.dry_run or os.environ.get("DRY_RUN") == "1"

    target = args.outfile

    if dry_run:
        print(f"[DRY-RUN] Would renew deadman lease at {target}")
        return 0

    try:
        # Create directory if missing
        target.parent.mkdir(parents=True, exist_ok=True)

        # Write/Update the file
        with open(target, "w") as f:
            f.write(f"renewed_at: {time.time()}\n")

        print(f"Deadman lease renewed at {target}")
        return 0
    except Exception as e:
        print(f"Error renewing deadman lease: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
