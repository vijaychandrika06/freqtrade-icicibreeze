#!/usr/bin/env python3
import argparse
import logging
import os
import shutil
import zipfile
from datetime import datetime, time, timedelta
from pathlib import Path

import requests

# Setup logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("P25Fetch")

URL_ZIP = "https://directlink.icicidirect.com/NewSecurityMaster/SecurityMaster.zip"
DEFAULT_CACHE_DIR = Path("user_data/cache/security_master")
FIXTURE_DIR = Path("user_data/data/icicibreeze")
FON_FILE = "FONSEScripMaster.txt"


def needs_sync(output_dir: Path, force: bool = False) -> bool:
    if force:
        return True

    target_file = output_dir / FON_FILE
    if not target_file.exists():
        logger.info(f"File {FON_FILE} missing, triggering sync.")
        return True

    mtime = datetime.fromtimestamp(target_file.stat().st_mtime)
    now = datetime.now()
    cutoff_time = time(8, 15)
    today_cutoff = datetime.combine(now.date(), cutoff_time)

    if now.time() >= cutoff_time:
        if mtime < today_cutoff:
            logger.info(f"File {FON_FILE} is stale (last update: {mtime}), triggering sync.")
            return True
    else:
        yesterday_cutoff = today_cutoff - timedelta(days=1)
        if mtime < yesterday_cutoff:
            logger.info(f"File {FON_FILE} is too old (pre-yesterday), triggering sync.")
            return True

    return False


def fetch_mock(output_dir: Path):
    logger.info(f"Fetching in MOCK mode (copying fixtures) to {output_dir}...")
    if not output_dir.exists():
        output_dir.mkdir(parents=True, exist_ok=True)

    # R2: Extraction filters to only FONSEScripMaster.txt
    # In mock mode, we only copy the forced FON file to be R2 compliant
    src = FIXTURE_DIR / FON_FILE
    dst = output_dir / FON_FILE
    if src.exists():
        shutil.copy2(src, dst)
        logger.info(f"Copied {src} -> {dst}")
    else:
        logger.warning(f"Fixture {src} not found!")


def fetch_real(output_dir: Path):
    if not output_dir.exists():
        output_dir.mkdir(parents=True, exist_ok=True)

    zip_path = output_dir / "SecurityMaster.zip"
    logger.info(f"Downloading Security Master from {URL_ZIP}...")
    try:
        resp = requests.get(URL_ZIP, timeout=60)
        resp.raise_for_status()
        with zip_path.open("wb") as f:
            f.write(resp.content)
    except Exception as e:
        logger.exception(f"Failed to download Security Master: {e}")
        return False

    logger.info(f"Extracting {FON_FILE} only...")
    try:
        with zipfile.ZipFile(zip_path, "r") as z:
            # R2: Extraction filters to only FONSEScripMaster.txt
            if FON_FILE in z.namelist():
                z.extract(FON_FILE, output_dir)
                logger.info(f"Extracted {FON_FILE}")
            else:
                logger.error(f"{FON_FILE} not found in ZIP")
                return False

        # Cleanup zip
        zip_path.unlink()
        return True
    except Exception as e:
        logger.exception(f"Extraction failed: {e}")
        return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mock", action="store_true", help="Use mock fixtures instead of download")
    parser.add_argument("--force", action="store_true", help="Force refresh regardless of age")
    parser.add_argument("--output", help="Output directory", default=str(DEFAULT_CACHE_DIR))
    args = parser.parse_args()

    output_dir = Path(args.output)
    is_mock = args.mock or os.environ.get("BREEZE_MOCK", "0") == "1"

    if is_mock:
        fetch_mock(output_dir)
        logger.info("P25_MOCK_SUCCESS")
        return

    if needs_sync(output_dir, args.force):
        if fetch_real(output_dir):
            logger.info("Security Master refresh successful.")
            logger.info("P25_REAL_SUCCESS")
        else:
            logger.error("Security Master refresh failed.")
            exit(1)
    else:
        logger.info("Security Master is fresh (P25_SKIP_FRESH).")


if __name__ == "__main__":
    main()
