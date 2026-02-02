#!/usr/bin/env python3
import os
import zipfile
import requests
import logging
from pathlib import Path
from datetime import datetime, time

# Setup logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("SecurityMasterSync")

URL = "https://directlink.icicidirect.com/NewSecurityMaster/SecurityMaster.zip"
TARGET_DIR = Path("user_data/data/icicibreeze")
ZIP_PATH = TARGET_DIR / "SecurityMaster.zip"
TEMP_DIR = TARGET_DIR / "temp_extract"


def needs_sync(force=False):
    if force:
        return True

    # Check if files exist and are fresh (updated today after 08:15)
    files = ["NSEScripMaster.txt", "FONSEScripMaster.txt"]
    now = datetime.now()
    cutoff_time = time(8, 15)

    for f in files:
        full_path = TARGET_DIR / f
        if not full_path.exists():
            logger.info(f"File {f} missing, triggering sync.")
            return True

        mtime = datetime.fromtimestamp(full_path.stat().st_mtime)
        # If last modified is before today's 8:15 AM, and we ARE currently after 8:15 AM
        if now.time() >= cutoff_time:
            today_cutoff = datetime.combine(now.date(), cutoff_time)
            if mtime < today_cutoff:
                logger.info(f"File {f} is stale (last update: {mtime}), triggering sync.")
                return True
        else:
            # If we are before 8:15 AM today, we expect file from yesterday 8:15 AM
            from datetime import timedelta

            yesterday_cutoff = datetime.combine(now.date() - timedelta(days=1), cutoff_time)
            if mtime < yesterday_cutoff:
                logger.info(f"File {f} is too old (pre-yesterday), triggering sync.")
                return True

    return False


def sync():
    if not TARGET_DIR.exists():
        TARGET_DIR.mkdir(parents=True, exist_ok=True)

    logger.info(f"Downloading Security Master from {URL}...")
    try:
        resp = requests.get(URL, timeout=60)
        resp.raise_for_status()
        with open(ZIP_PATH, "wb") as f:
            f.write(resp.content)
        logger.info("Download complete.")
    except Exception as e:
        logger.error(f"Failed to download Security Master: {e}")
        return False

    logger.info("Extracting scrip masters...")
    try:
        with zipfile.ZipFile(ZIP_PATH, "r") as z:
            # We only extract the NSE ones
            members = [
                m for m in z.namelist() if m in ["NSEScripMaster.txt", "FONSEScripMaster.txt"]
            ]
            for member in members:
                z.extract(member, TARGET_DIR)
                logger.info(f"Extracted {member}")

        # Cleanup zip
        os.remove(ZIP_PATH)
        return True
    except Exception as e:
        logger.error(f"Extraction failed: {e}")
        return False


if __name__ == "__main__":
    import sys

    force = "--force" in sys.argv
    if needs_sync(force):
        if sync():
            logger.info("Security Master sync successful.")
            sys.exit(0)
        else:
            logger.error("Security Master sync failed.")
            sys.exit(1)
    else:
        logger.info("Security Master is already up-to-date.")
        sys.exit(0)
