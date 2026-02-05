import logging
import os
import shutil
import time

from pathlib import Path

logger = logging.getLogger(__name__)

# Constants
DEADMAN_FILE = Path("user_data/secrets/deadman_live.ok")
DEADMAN_MAX_AGE_SEC = 600  # 10 minutes
MIN_DISK_FREE_GB = 2
SEC_MASTER_MAX_AGE_SEC = 86400  # 24 hours


def _env_bool(name: str, default: bool = False) -> bool:
    val = os.environ.get(name)
    if val is None:
        return default
    return val.strip().lower() in {"1", "true", "yes", "y", "on"}


class LiveReadiness:
    @staticmethod
    def check_deadman() -> dict:
        """
        Verifies the deadman switch file exists and is fresh.
        """
        # If in mock mode, deadman check might be relaxed by caller, but strictly speaking
        # for P40 we want fail-closed unless specifically bypassed.
        # We'll implement strict fail-closed here.

        if not DEADMAN_FILE.exists():
            return {
                "ok": False,
                "code": "DEADMAN_MISSING",
                "reason": f"Deadman file missing at {DEADMAN_FILE}",
            }

        try:
            stat = DEADMAN_FILE.stat()
            mtime = stat.st_mtime
            now = time.time()
            age = now - mtime

            if age > DEADMAN_MAX_AGE_SEC:
                return {
                    "ok": False,
                    "code": "DEADMAN_STALE",
                    "reason": f"Deadman file stale (age={age:.0f}s > {DEADMAN_MAX_AGE_SEC}s)",
                }

            return {"ok": True, "code": "DEADMAN_OK", "reason": "Deadman switch active"}

        except Exception as e:
            logger.error(f"Error checking deadman: {e}", exc_info=True)
            return {
                "ok": False,
                "code": "DEADMAN_ERROR",
                "reason": f"Error checking deadman: {e}",
            }

    @staticmethod
    def check_readiness(config: dict) -> dict:
        """
        Comprehensive readiness check for live trading.
        """
        # 1. Config Check (Session Token)
        # Note: BREEZE_MOCK env might be handled outside, but checking config consistency here.
        icici_config = config.get("icicibreeze") or config.get("exchange", {}).get(
            "icicibreeze", {}
        )
        if not icici_config.get("session_token") and not os.environ.get("BREEZE_SESSION_TOKEN"):
            # In mock mode this might be allowed, so check mock flag
            # In mock mode this might be allowed, so check mock flag
            if not _env_bool("BREEZE_MOCK"):
                return {
                    "ok": False,
                    "code": "TOKEN_MISSING",
                    "reason": "Breeze Session Token missing from config and env",
                    "details": {},
                }

        # 2. Disk Space Check
        try:
            # Check partition of user_data
            total, used, free = shutil.disk_usage("user_data")
            free_gb = free / (1024**3)
            if free_gb < MIN_DISK_FREE_GB:
                return {
                    "ok": False,
                    "code": "DISK_FULL",
                    "reason": f"Insufficient disk space ({free_gb:.2f}GB < {MIN_DISK_FREE_GB}GB)",
                    "details": {"free_gb": free_gb},
                }
        except Exception as e:
            logger.warning(f"Failed to check disk space: {e}")
            # Fail safe? Or warn?
            # Requirement says "disk_free_min_gb: 2". Let's fail safe.
            return {
                "ok": False,
                "code": "DISK_CHECK_ERROR",
                "reason": f"Failed to check disk space: {e}",
                "details": {},
            }

        # 3. Security Master Freshness
        from adapters.ccxt_shim.security_master import find_latest_master_file

        master_path_str = find_latest_master_file("FONSEScripMaster.txt")
        if not master_path_str:
            return {
                "ok": False,
                "code": "SEC_MASTER_MISSING",
                "reason": "Security Master file not found in search paths",
                "details": {},
            }

        scrip_master_path = Path(master_path_str)
        try:
            mtime = scrip_master_path.stat().st_mtime
            age = time.time() - mtime
            # P2 Determinism: env var for max age? Defaults to SEC_MASTER_MAX_AGE_SEC constant.
            # Plan requested constant or env-configured. Let's stick to constant for now as per code.
            if age > SEC_MASTER_MAX_AGE_SEC:
                return {
                    "ok": False,
                    "code": "SEC_MASTER_STALE",
                    "reason": f"Security Master stale (age={age:.0f}s > {SEC_MASTER_MAX_AGE_SEC}s)",
                    "details": {"age": age},
                }
        except Exception:
            pass

        # 4. Pair Whitelist (from config)
        whitelist = config.get("exchange", {}).get("pair_whitelist", [])
        if not whitelist:
            # Fallback to pair_whitelist in root?
            whitelist = config.get("pair_whitelist", [])

        if not whitelist:
            return {
                "ok": False,
                "code": "WHITELIST_EMPTY",
                "reason": "Pair whitelist is empty",
                "details": {},
            }

        return {"ok": True, "code": "READY", "reason": "All checks passed", "details": {}}
